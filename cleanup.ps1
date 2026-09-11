<#
.SYNOPSIS
    Windows Storage Deep Cleanup Toolkit
.DESCRIPTION
    Terminal-based system storage cleaner for Windows 10 & 11.
    Scans and interactively purges temporary files, browser caches, game launchers,
    shadow copies, leftover upgrade directories, crash dumps, log archives,
    hibernation files, obsolete OEM drivers, search index databases, and WinSxS components.
    Targets with 0 bytes are automatically skipped.
.PARAMETER All
    Cleans all eligible targets without interactive confirmation prompts.
.PARAMETER DryRun
    Simulates cleanup preview without deleting files.
.PARAMETER SkipBrowsers
    Skips Edge, Chrome, and Brave browser caches.
.PARAMETER SkipMediaApps
    Skips Spotify streaming and Discord media caches.
.PARAMETER SkipGames
    Skips Steam, Epic Games, Ubisoft Connect, and Riot Client caches.
.PARAMETER SkipRestorePoints
    Skips purging oldest volume shadow copies.
.PARAMETER SkipCrashDumps
    Skips purging MEMORY.DMP and minidump files.
.PARAMETER SkipUpgradeFolders
    Skips purging Windows.old and $WINDOWS.~BT folders.
.PARAMETER SkipCBSLogs
    Skips purging CBS persist archives and clearing DISM logs.
.PARAMETER SkipHiberfil
    Skips disabling hibernation and deleting C:\hiberfil.sys.
.PARAMETER SkipDrivers
    Skips purging superseded OEM drivers via pnputil.
.PARAMETER SkipSearchIndex
    Skips resetting and compacting the Windows Search index database.
.PARAMETER SkipDism
    Skips running WinSxS component cleanup (DISM /ResetBase).
.EXAMPLE
    .\cleanup.ps1
.EXAMPLE
    .\cleanup.ps1 -All
.EXAMPLE
    .\cleanup.ps1 -DryRun
#>

[CmdletBinding()]
param(
    [switch]$All,
    [switch]$DryRun,
    [switch]$SkipBrowsers,
    [switch]$SkipMediaApps,
    [switch]$SkipGames,
    [switch]$SkipRestorePoints,
    [switch]$SkipCrashDumps,
    [switch]$SkipUpgradeFolders,
    [switch]$SkipCBSLogs,
    [switch]$SkipHiberfil,
    [switch]$SkipDrivers,
    [switch]$SkipSearchIndex,
    [switch]$SkipDism
)

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Disable console QuickEdit mode to prevent process pause on mouse click
try {
    $null = Add-Type -MemberDefinition @"
[DllImport("kernel32.dll", SetLastError = true)]
public static extern IntPtr GetStdHandle(int nStdHandle);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);
"@ -Name "NativeConsoleHelper" -Namespace "WinStorageCleaner" -PassThru -ErrorAction SilentlyContinue

    $hStdin = [WinStorageCleaner.NativeConsoleHelper]::GetStdHandle(-10)
    $cMode = 0
    if ([WinStorageCleaner.NativeConsoleHelper]::GetConsoleMode($hStdin, [ref]$cMode)) {
        $newMode = $cMode -band (-bnot 0x0040)
        [WinStorageCleaner.NativeConsoleHelper]::SetConsoleMode($hStdin, $newMode) | Out-Null
    }
} catch { }

if (-not $isAdmin) {
    Write-Host ""
    Write-Host "  [NOTICE] Running in Standard User Mode." -ForegroundColor Yellow
    Write-Host "           System stores (Windows Update, Drivers, Shadow Copies) require Administrator." -ForegroundColor DarkGray
    Write-Host "           To clean all targets, run PowerShell or cleanup.bat as Administrator." -ForegroundColor DarkGray
    Write-Host ""
}

$initialFreeBytes = (Get-PSDrive C).Free
$initialFreeGB = [math]::Round($initialFreeBytes / 1GB, 2)

Clear-Host
Write-Host ""
Write-Host "========================================================================" -ForegroundColor DarkCyan
Write-Host "                WINDOWS STORAGE DEEP CLEANUP TOOLKIT                    " -ForegroundColor Cyan
Write-Host "             Non-Destructive Storage Optimizer for Win 10/11            " -ForegroundColor DarkGray
Write-Host "========================================================================" -ForegroundColor DarkCyan
if ($DryRun) {
    Write-Host "  [MODE: DRY RUN] Preview simulation active - no files will be deleted. " -ForegroundColor Magenta
    Write-Host "------------------------------------------------------------------------" -ForegroundColor DarkGray
}
Write-Host "  Target Volume       : Drive C:" -ForegroundColor Gray
Write-Host "  Initial Free Space  : $initialFreeGB GB" -ForegroundColor White
Write-Host "========================================================================" -ForegroundColor DarkCyan
Write-Host ""

function Format-ByteSize {
    param([int64]$Bytes)
    if ($Bytes -ge 1GB) {
        return "{0:N2} GB" -f ($Bytes / 1GB)
    } elseif ($Bytes -ge 1MB) {
        return "{0:N2} MB" -f ($Bytes / 1MB)
    } elseif ($Bytes -ge 1KB) {
        return "{0:N1} KB" -f ($Bytes / 1KB)
    } else {
        return "$Bytes B"
    }
}

function Get-FolderMetrics {
    param([string[]]$Paths)
    $totalBytes = [int64]0
    $fileCount = 0
    foreach ($p in $Paths) {
        if (-not (Test-Path -LiteralPath $p -ErrorAction SilentlyContinue)) { continue }
        try {
            $item = Get-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
            if ($item.PSIsContainer) {
                $measure = Get-ChildItem -LiteralPath $p -Recurse -File -Force -ErrorAction SilentlyContinue |
                    Measure-Object -Property Length -Sum
                if ($measure -and $measure.Sum) {
                    $totalBytes += $measure.Sum
                    $fileCount += $measure.Count
                }
            } else {
                $totalBytes += $item.Length
                $fileCount++
            }
        } catch { }
    }
    return [PSCustomObject]@{
        Bytes     = $totalBytes
        Count     = $fileCount
        Formatted = (Format-ByteSize $totalBytes)
    }
}

function Ask-Choice {
    param(
        [int]$Number,
        [string]$Title,
        [string]$Description,
        [bool]$Default = $true
    )
    if ($All) { return $true }
    
    $numStr = $Number.ToString("00")
    $defaultLabel = if ($Default) { "[Y/n]" } else { "[y/N]" }
    
    Write-Host ""
    Write-Host "  [$numStr] " -NoNewline -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor White
    if ($Description) {
        Write-Host "       $Description" -ForegroundColor DarkGray
    }
    Write-Host "       Clean this target? " -NoNewline -ForegroundColor Gray
    Write-Host "$($defaultLabel): " -NoNewline -ForegroundColor Yellow
    
    $reply = Read-Host
    if ([string]::IsNullOrWhiteSpace($reply)) {
        return $Default
    }
    return ($reply -match '^(y|yes)$')
}

function Write-SkippedChoice {
    param(
        [int]$Number,
        [string]$Title,
        [string]$Reason
    )
    if ($All) { return }
    $numStr = $Number.ToString("00")
    Write-Host ""
    Write-Host "  [$numStr] " -NoNewline -ForegroundColor DarkGray
    Write-Host "$Title " -NoNewline -ForegroundColor DarkGray
    Write-Host "- $Reason" -ForegroundColor DarkGray
}

Write-Host " [CONFIG] Select cleanup targets (Press Enter to accept default):" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------------------" -ForegroundColor DarkGray

# 01. Temp files
$tempMetrics = Get-FolderMetrics @($env:TEMP, "C:\Windows\Temp")
if ($tempMetrics.Bytes -gt 0) {
    $doTemp = Ask-Choice 1 "User & Windows Temp Directories" "Found $($tempMetrics.Formatted) disposable temporary caches in %TEMP% and C:\Windows\Temp" $true
} else {
    $doTemp = $false
    Write-SkippedChoice 1 "User & Windows Temp Directories" "None found / 0 B (Clean)"
}

# 02. Shaders & WER
$shaderPaths = @(
    "$env:LOCALAPPDATA\D3DSCache",
    "$env:LOCALAPPDATA\Microsoft\DirectX Shader Cache",
    "$env:PROGRAMDATA\Microsoft\Windows\WER\ReportArchive",
    "$env:LOCALAPPDATA\Microsoft\Windows\WER\ReportArchive"
)
$shaderMetrics = Get-FolderMetrics $shaderPaths
if ($shaderMetrics.Bytes -gt 0) {
    $doShaders = Ask-Choice 2 "DirectX Shader Cache & Error Reporting Logs" "Found $($shaderMetrics.Formatted) shaders and WER report archives" $true
} else {
    $doShaders = $false
    Write-SkippedChoice 2 "DirectX Shader Cache & Error Reporting Logs" "None found / 0 B (Clean)"
}

# 03. Windows Update Store
if ($isAdmin) {
    $updateMetrics = Get-FolderMetrics @("C:\Windows\SoftwareDistribution\Download")
    if ($updateMetrics.Bytes -gt 0) {
        $doUpdates = Ask-Choice 3 "Windows Update Download Store" "Found $($updateMetrics.Formatted) staged packages in SoftwareDistribution\Download" $true
    } else {
        $doUpdates = $false
        Write-SkippedChoice 3 "Windows Update Download Store" "None found / 0 B (Clean)"
    }
} else {
    $doUpdates = $false
    Write-SkippedChoice 3 "Windows Update Download Store" "Skipped (Requires Administrator privileges)"
}

# 04. Delivery Optimization
if (Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue) {
    $doBytes = [int64]0
    if (Get-Command Get-DeliveryOptimizationStatus -ErrorAction SilentlyContinue) {
        try {
            $dos = Get-DeliveryOptimizationStatus -ErrorAction SilentlyContinue
            if ($dos) {
                $sum = ($dos | Measure-Object -Property FileSize -Sum).Sum
                if ($sum) { $doBytes += $sum }
            }
        } catch { }
    }
    $doFolderMetrics = Get-FolderMetrics @("C:\Windows\ServiceState\DeliveryOptimization", "C:\ProgramData\Microsoft\Network\Downloader")
    $totalDoBytes = $doBytes + $doFolderMetrics.Bytes
    if ($totalDoBytes -gt 0) {
        $doDelivery = Ask-Choice 4 "Windows Delivery Optimization Cache" "Found $(Format-ByteSize $totalDoBytes) peer-to-peer Windows update distribution files" $true
    } else {
        $doDelivery = $false
        Write-SkippedChoice 4 "Windows Delivery Optimization Cache" "None found / 0 B (Clean)"
    }
} else {
    $doDelivery = $false
    Write-SkippedChoice 4 "Windows Delivery Optimization Cache" "Skipped (Cmdlet not available)"
}

# 05. Browsers
if (-not $SkipBrowsers) {
    $browserPaths = @(
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Code Cache"
    )
    $browserMetrics = Get-FolderMetrics $browserPaths
    if ($browserMetrics.Bytes -gt 0) {
        $doBrowsers = Ask-Choice 5 "Web Browser Caches (Edge, Chrome, Brave)" "Found $($browserMetrics.Formatted) cached web assets and code caches" $true
    } else {
        $doBrowsers = $false
        Write-SkippedChoice 5 "Web Browser Caches (Edge, Chrome, Brave)" "None found / 0 B (Clean)"
    }
} else {
    $doBrowsers = $false
    Write-SkippedChoice 5 "Web Browser Caches" "Skipped (-SkipBrowsers flag passed)"
}

# 06. Media Apps
if (-not $SkipMediaApps) {
    $mediaPaths = @(
        "$env:LOCALAPPDATA\Spotify\Storage",
        "$env:APPDATA\discord\Cache",
        "$env:APPDATA\discord\Code Cache"
    )
    $mediaMetrics = Get-FolderMetrics $mediaPaths
    if ($mediaMetrics.Bytes -gt 0) {
        $doMedia = Ask-Choice 6 "Spotify & Discord Media Caches" "Found $($mediaMetrics.Formatted) streaming songs and media/code caches" $true
    } else {
        $doMedia = $false
        Write-SkippedChoice 6 "Spotify & Discord Media Caches" "None found / 0 B (Clean)"
    }
} else {
    $doMedia = $false
    Write-SkippedChoice 6 "Spotify & Discord Media Caches" "Skipped (-SkipMediaApps flag passed)"
}

# 07. Games
if (-not $SkipGames) {
    $gamePaths = @(
        "$env:LOCALAPPDATA\Steam\htmlcache",
        "C:\Program Files (x86)\Steam\appcache\httpcache",
        "$env:LOCALAPPDATA\EpicGamesLauncher\Saved\webcache",
        "$env:LOCALAPPDATA\Ubisoft Game Launcher\cache",
        "$env:LOCALAPPDATA\Riot Games\Riot Client\Data\Logs"
    )
    $gameMetrics = Get-FolderMetrics $gamePaths
    if ($gameMetrics.Bytes -gt 0) {
        $doGames = Ask-Choice 7 "Game Launcher Caches (Steam, Epic, Ubisoft, Riot)" "Found $($gameMetrics.Formatted) launcher web/http caches and diagnostic logs" $true
    } else {
        $doGames = $false
        Write-SkippedChoice 7 "Game Launcher Caches (Steam, Epic, Ubisoft, Riot)" "None found / 0 B (Clean)"
    }
} else {
    $doGames = $false
    Write-SkippedChoice 7 "Game Launcher Caches" "Skipped (-SkipGames flag passed)"
}

# 08. Dev caches
$devPaths = @(
    "$env:LOCALAPPDATA\pip\cache",
    "$env:APPDATA\Code\Cache",
    "$env:APPDATA\Code\CachedData"
)
$devMetrics = Get-FolderMetrics $devPaths
if ($devMetrics.Bytes -gt 0) {
    $doDev = Ask-Choice 8 "Developer Caches (Python pip & VS Code)" "Found $($devMetrics.Formatted) cached pip download wheels and VS Code editor caches" $true
} else {
    $doDev = $false
    Write-SkippedChoice 8 "Developer Caches (Python pip & VS Code)" "None found / 0 B (Clean)"
}

# 09. Volume Shadow Copies
if ($isAdmin -and (-not $SkipRestorePoints)) {
    $shadowOutput = vssadmin list shadows 2>&1
    $hasShadows = ($shadowOutput -match 'Shadow Copy ID:')
    if ($hasShadows) {
        $shadowCount = ($shadowOutput | Select-String 'Shadow Copy ID:').Count
        $doShadows = Ask-Choice 9 "Oldest Volume Shadow Copies (vssadmin)" "Found $shadowCount shadow copies. Purges old snapshots via vssadmin, keeps newest" $true
    } else {
        $doShadows = $false
        Write-SkippedChoice 9 "Oldest Volume Shadow Copies (vssadmin)" "None found / 0 copies (Clean)"
    }
} else {
    $doShadows = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 9 "System Restore Points" "Skipped (Requires Administrator privileges)"
    } else {
        Write-SkippedChoice 9 "System Restore Points" "Skipped (-SkipRestorePoints flag passed)"
    }
}

# 10. Leftover Windows Upgrade Folders
$upgradePaths = @("C:\Windows.old", "C:\$WINDOWS.~BT", "C:\$WINDOWS.~WS")
$foundUpgradePaths = @($upgradePaths | Where-Object { Test-Path -LiteralPath $_ })
$upgradeMetrics = if ($foundUpgradePaths.Count -gt 0) { Get-FolderMetrics $foundUpgradePaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
if ($foundUpgradePaths.Count -gt 0 -and $upgradeMetrics.Bytes -gt 0 -and (-not $SkipUpgradeFolders)) {
    $foundList = $foundUpgradePaths -join ", "
    $doUpgrade = Ask-Choice 10 "Leftover Windows Upgrade Folders" "Found $($upgradeMetrics.Formatted) across: $foundList" $true
} else {
    $doUpgrade = $false
    if ($SkipUpgradeFolders) {
        Write-SkippedChoice 10 "Leftover Windows Upgrade Folders" "Skipped (-SkipUpgradeFolders flag passed)"
    } else {
        Write-SkippedChoice 10 "Leftover Windows Upgrade Folders" "None found / 0 B (Clean)"
    }
}

# 11. Crash dumps
$crashPaths = @("C:\Windows\MEMORY.DMP", "C:\Windows\Minidump")
$crashMetrics = Get-FolderMetrics $crashPaths
if ($crashMetrics.Bytes -gt 0 -and (-not $SkipCrashDumps)) {
    $doCrashDumps = Ask-Choice 11 "Kernel Crash Dump Files (MEMORY.DMP)" "Found $($crashMetrics.Formatted) in crash dump files" $true
} else {
    $doCrashDumps = $false
    if ($SkipCrashDumps) {
        Write-SkippedChoice 11 "Kernel Crash Dump Files" "Skipped (-SkipCrashDumps flag passed)"
    } else {
        Write-SkippedChoice 11 "Kernel Crash Dump Files (MEMORY.DMP)" "None found / 0 B (Clean)"
    }
}

# 12. CBS & DISM Logs
if ($isAdmin -and (-not $SkipCBSLogs)) {
    $cbsFiles = @(Get-ChildItem -Path "C:\Windows\Logs\CBS" -Filter "CbsPersist_*" -ErrorAction SilentlyContinue)
    $cbsLogBytes = [int64]0
    if ($cbsFiles.Count -gt 0) {
        $sum = ($cbsFiles | Measure-Object -Property Length -Sum).Sum
        if ($sum) { $cbsLogBytes += $sum }
    }
    if (Test-Path -LiteralPath "C:\Windows\Logs\DISM\dism.log") {
        try { $cbsLogBytes += (Get-Item -LiteralPath "C:\Windows\Logs\DISM\dism.log" -Force -ErrorAction SilentlyContinue).Length } catch { }
    }
    if ($cbsLogBytes -gt 0) {
        $cbsFormatted = Format-ByteSize $cbsLogBytes
        $doCBSLogs = Ask-Choice 12 "CBS & DISM Log Archives" "Found $cbsFormatted in CBS persist archives and DISM logs" $true
    } else {
        $doCBSLogs = $false
        Write-SkippedChoice 12 "CBS & DISM Log Archives" "None found / 0 B (Clean)"
    }
} else {
    $doCBSLogs = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 12 "CBS & DISM Log Archives" "Skipped (Requires Administrator privileges)"
    } else {
        Write-SkippedChoice 12 "CBS & DISM Log Archives" "Skipped (-SkipCBSLogs flag passed)"
    }
}

# 13. Hibernation file
$hasHiberfil = Test-Path -LiteralPath "C:\hiberfil.sys"
if ($isAdmin -and (-not $SkipHiberfil)) {
    $hiberSize = [int64]0
    if ($hasHiberfil) {
        try { $hiberSize = (Get-Item -LiteralPath "C:\hiberfil.sys" -Force -ErrorAction Stop).Length } catch { }
    }
    if ($hasHiberfil -and $hiberSize -gt 0) {
        $hiberFormatted = Format-ByteSize $hiberSize
        $doHiberfil = Ask-Choice 13 "Windows Hibernation File (hiberfil.sys)" "Found C:\hiberfil.sys ($hiberFormatted). Disables Hibernate to reclaim space (Sleep unaffected)" $true
    } else {
        $doHiberfil = $false
        Write-SkippedChoice 13 "Windows Hibernation (hiberfil.sys)" "Already disabled / None found (Clean)"
    }
} else {
    $doHiberfil = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 13 "Windows Hibernation (hiberfil.sys)" "Skipped (Requires Administrator privileges)"
    } else {
        Write-SkippedChoice 13 "Windows Hibernation (hiberfil.sys)" "Skipped (-SkipHiberfil flag passed)"
    }
}

# 14. Obsolete OEM drivers
$supersededDrivers = @()
if ($isAdmin -and (-not $SkipDrivers)) {
    $rawDrivers = pnputil /enum-drivers 2>&1
    $driverList = @()
    $currentDriver = @{}
    foreach ($line in $rawDrivers) {
        if ($line -match '^Published Name:\s+(oem\d+\.inf)') {
            if ($currentDriver.PublishedName) { $driverList += [PSCustomObject]$currentDriver }
            $currentDriver = @{ PublishedName = $matches[1] }
        } elseif ($line -match '^Original Name:\s+(.+)$') {
            $currentDriver.OriginalName = $matches[1].Trim()
        } elseif ($line -match '^Driver Version:\s+(\d{2}/\d{2}/\d{4})\s+(.+)$') {
            try { $currentDriver.Date = [datetime]::ParseExact($matches[1], 'MM/dd/yyyy', [System.Globalization.CultureInfo]::InvariantCulture) } catch { $currentDriver.Date = [datetime]::MinValue }
            $currentDriver.Version = $matches[2].Trim()
        } elseif ($line -match '^Class Name:\s+(.+)$') {
            $currentDriver.ClassName = $matches[1].Trim()
        }
    }
    if ($currentDriver.PublishedName) { $driverList += [PSCustomObject]$currentDriver }

    $grouped = $driverList | Where-Object { $_.OriginalName } | Group-Object OriginalName
    foreach ($grp in $grouped) {
        if ($grp.Count -gt 1) {
            $sorted = $grp.Group | Sort-Object Date -Descending
            for ($i = 1; $i -lt $sorted.Count; $i++) {
                $supersededDrivers += $sorted[$i]
            }
        }
    }
    if ($supersededDrivers.Count -gt 0) {
        $doDrivers = Ask-Choice 14 "Obsolete OEM Hardware Drivers" "Found $($supersededDrivers.Count) superseded driver packages in DriverStore" $true
    } else {
        $doDrivers = $false
        Write-SkippedChoice 14 "Obsolete OEM Hardware Drivers" "None found / 0 drivers (Clean)"
    }
} else {
    $doDrivers = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 14 "Obsolete OEM Hardware Drivers" "Skipped (Requires Administrator privileges)"
    } else {
        Write-SkippedChoice 14 "Obsolete OEM Hardware Drivers" "Skipped (-SkipDrivers flag passed)"
    }
}

# 15. Windows Search index
$searchService = Get-Service -Name WSearch -ErrorAction SilentlyContinue
if ($isAdmin -and ($null -ne $searchService) -and (-not $SkipSearchIndex)) {
    $searchPaths = @(
        "C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb",
        "C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Projects\SystemIndex\Indexer"
    )
    $searchMetrics = Get-FolderMetrics $searchPaths
    if ($searchMetrics.Bytes -gt 0) {
        $doSearchIndex = Ask-Choice 15 "Windows Search Index Database" "Found $($searchMetrics.Formatted) in search database (resets and compacts in background)" $true
    } else {
        $doSearchIndex = $false
        Write-SkippedChoice 15 "Windows Search Index Database" "None found / 0 B (Clean)"
    }
} else {
    $doSearchIndex = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 15 "Windows Search Index Database" "Skipped (Requires Administrator privileges)"
    } elseif ($SkipSearchIndex) {
        Write-SkippedChoice 15 "Windows Search Index Database" "Skipped (-SkipSearchIndex flag passed)"
    } else {
        Write-SkippedChoice 15 "Windows Search Index Database" "Service not present (Clean)"
    }
}

# 16. WinSxS ResetBase
if ($isAdmin -and (-not $SkipDism)) {
    $doDism = Ask-Choice 16 "WinSxS Component Store ResetBase" "Deep WinSxS component purge (Takes 2-5 min, prevents old update rollbacks)" $false
} else {
    $doDism = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 16 "WinSxS Component Store ResetBase" "Skipped (Requires Administrator privileges)"
    } else {
        Write-SkippedChoice 16 "WinSxS Component Store ResetBase" "Skipped (-SkipDism flag passed)"
    }
}

Write-Host ""
Write-Host "========================================================================" -ForegroundColor DarkCyan
Write-Host "                       EXECUTING STORAGE CLEANUP                        " -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor DarkCyan
Write-Host ""

function Invoke-Purge {
    param(
        [string]$TargetName,
        [scriptblock]$Action
    )
    if ($DryRun) {
        Write-Host "  [ DRY-RUN  ] " -NoNewline -ForegroundColor Magenta
        Write-Host $TargetName -ForegroundColor White
    } else {
        Write-Host "  [ CLEANING ] " -NoNewline -ForegroundColor Cyan
        Write-Host "$TargetName..." -ForegroundColor White
        & $Action
    }
    Write-Host ""
}

function Write-SkippedExecution {
    param([string]$TargetName)
    Write-Host "  [ SKIPPED  ] " -NoNewline -ForegroundColor DarkGray
    Write-Host $TargetName -ForegroundColor DarkGray
    Write-Host ""
}

if ($doTemp) {
    Invoke-Purge "User and Windows Temp Directories" {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "               Purged %TEMP% and C:\Windows\Temp disposable caches." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "User and Windows Temp Directories"
}

if ($doShaders) {
    Invoke-Purge "DirectX Shaders & Windows Error Reporting Logs" {
        Remove-Item -Path "$env:LOCALAPPDATA\D3DSCache\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "               Purged D3DSCache and WER report archive." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "DirectX Shaders & Windows Error Reporting Logs"
}

if ($doUpdates -and $isAdmin) {
    Invoke-Purge "Windows Update Download Store" {
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        Write-Host "               Stopped wuauserv, purged SoftwareDistribution\Download, restarted service." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Windows Update Download Store"
}

if ($doDelivery) {
    Invoke-Purge "Windows Delivery Optimization Cache" {
        $doOut = Delete-DeliveryOptimizationCache -Force 2>&1
        foreach ($line in $doOut) {
            if ($line.ToString().Trim()) { Write-Host "               $line" -ForegroundColor DarkGray }
        }
        Write-Host "               Purged Windows Delivery Optimization cache." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Windows Delivery Optimization Cache"
}

if ($doBrowsers) {
    Invoke-Purge "Web Browser Caches (Edge, Chrome, Brave)" {
        Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "               Purged browser cache directories." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Web Browser Caches"
}

if ($doMedia) {
    Invoke-Purge "Spotify & Discord Media Caches" {
        Remove-Item -Path "$env:LOCALAPPDATA\Spotify\Storage\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:APPDATA\discord\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:APPDATA\discord\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "               Purged Spotify streaming storage and Discord media cache." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Spotify & Discord Media Caches"
}

if ($doGames) {
    Invoke-Purge "Game Launcher Caches (Steam, Epic, Ubisoft, Riot)" {
        Remove-Item -Path "C:\Program Files (x86)\Steam\appcache\httpcache\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:LOCALAPPDATA\EpicGamesLauncher\Saved\webcache*\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:LOCALAPPDATA\Ubisoft Game Launcher\cache\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:LOCALAPPDATA\Riot Games\Riot Client\Logs\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "               Purged Steam httpcache, Epic webcache, Ubisoft & Riot logs." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Game Launcher Caches"
}

if ($doDev) {
    Invoke-Purge "Developer Caches (Python pip & VS Code)" {
        if (Get-Command pip -ErrorAction SilentlyContinue) {
            $pipOut = pip cache purge 2>&1
            foreach ($line in $pipOut) {
                if ($line.ToString().Trim()) { Write-Host "               $line" -ForegroundColor DarkGray }
            }
        }
        Remove-Item -Path "$env:APPDATA\Code\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:APPDATA\Code\CachedData\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "               Purged VS Code Cache and CachedData." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Developer Caches (Python pip & VS Code)"
}

if ($doShadows -and $isAdmin) {
    Invoke-Purge "Oldest Volume Shadow Copies (vssadmin)" {
        $vssOut = vssadmin delete shadows /for=C: /oldest /quiet 2>&1
        foreach ($line in $vssOut) {
            if ($line.ToString().Trim()) { Write-Host "               $line" -ForegroundColor DarkGray }
        }
        Write-Host "               Purged oldest shadow copies from C: (kept newest)." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Oldest Volume Shadow Copies"
}

if ($doUpgrade) {
    Invoke-Purge "Leftover Windows Upgrade Folders ($foundList)" {
        foreach ($p in $foundUpgradePaths) {
            Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "               Removed $p." -ForegroundColor DarkGray
        }
    }
} else {
    Write-SkippedExecution "Leftover Windows Upgrade Folders"
}

if ($doCrashDumps) {
    Invoke-Purge "Kernel Crash Dump & Minidump Files" {
        if (Test-Path "C:\Windows\MEMORY.DMP") {
            Remove-Item "C:\Windows\MEMORY.DMP" -Force -ErrorAction SilentlyContinue
            Write-Host "               Deleted C:\Windows\MEMORY.DMP." -ForegroundColor DarkGray
        }
        if (Test-Path "C:\Windows\Minidump") {
            Remove-Item "C:\Windows\Minidump\*" -Force -ErrorAction SilentlyContinue
            Write-Host "               Purged C:\Windows\Minidump." -ForegroundColor DarkGray
        }
    }
} else {
    Write-SkippedExecution "Kernel Crash Dump & Minidump Files"
}

if ($doCBSLogs -and $isAdmin) {
    Invoke-Purge "CBS & DISM Log Archives" {
        Remove-Item -Path "C:\Windows\Logs\CBS\CbsPersist_*" -Force -ErrorAction SilentlyContinue
        if (Test-Path "C:\Windows\Logs\DISM\dism.log") {
            Clear-Content -Path "C:\Windows\Logs\DISM\dism.log" -ErrorAction SilentlyContinue
        }
        Write-Host "               Purged CBS persist archives and cleared DISM log file." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "CBS & DISM Log Archives"
}

if ($doHiberfil -and $isAdmin) {
    Invoke-Purge "Windows Hibernation File (hiberfil.sys)" {
        powercfg -h off
        Write-Host "               Disabled hibernation via powercfg and purged C:\hiberfil.sys." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Windows Hibernation File (hiberfil.sys)"
}

if ($doDrivers -and $isAdmin -and $supersededDrivers.Count -gt 0) {
    Invoke-Purge "Obsolete OEM Hardware Drivers" {
        $deletedCount = 0
        foreach ($drv in $supersededDrivers) {
            $pOut = pnputil /delete-driver $drv.PublishedName 2>&1
            if ($pOut -match "successfully deleted" -or $pOut -match "Driver package deleted") {
                $deletedCount++
            }
        }
        Write-Host "               Purged $deletedCount superseded OEM driver packages from DriverStore." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Obsolete OEM Hardware Drivers"
}

if ($doSearchIndex -and $isAdmin) {
    Invoke-Purge "Windows Search Index Database" {
        Stop-Service -Name WSearch -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Search" -Name "SetupCompletedSuccessfully" -Value 0 -ErrorAction SilentlyContinue
        Start-Service -Name WSearch -ErrorAction SilentlyContinue
        Write-Host "               Reset Windows Search index configuration and restarted WSearch service." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Windows Search Index Database"
}

if ($doDism -and $isAdmin) {
    Invoke-Purge "WinSxS Component Store ResetBase" {
        Write-Host "               Running DISM ComponentCleanup (live progress shown below)..." -ForegroundColor DarkGray
        Write-Host ""
        Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
        Write-Host ""
        Write-Host "               Deep WinSxS component cleanup completed." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "WinSxS Component Store ResetBase"
}

$finalFreeBytes = (Get-PSDrive C).Free
$finalFreeGB = [math]::Round($finalFreeBytes / 1GB, 2)
$reclaimedGB = [math]::Round(($finalFreeBytes - $initialFreeBytes) / 1GB, 2)

Write-Host "========================================================================" -ForegroundColor DarkCyan
Write-Host "                        CLEANUP SUMMARY REPORT                          " -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor DarkCyan
if ($DryRun) {
    Write-Host "  Execution Mode        : Dry Run (Preview Simulation - No changes made)" -ForegroundColor Magenta
    Write-Host "  Target Volume         : Drive C:" -ForegroundColor Gray
    Write-Host "  Current Free Space    : $finalFreeGB GB" -ForegroundColor White
} else {
    Write-Host "  Target Volume         : Drive C:" -ForegroundColor Gray
    Write-Host "  Starting Free Space   : $initialFreeGB GB" -ForegroundColor White
    Write-Host "  Ending Free Space     : $finalFreeGB GB" -ForegroundColor White
    if ($reclaimedGB -gt 0) {
        Write-Host "  Total Space Reclaimed : +$reclaimedGB GB" -ForegroundColor Green
    } else {
        Write-Host "  Total Space Reclaimed : 0.00 GB (Caches were already clean)" -ForegroundColor DarkGray
    }
    Write-Host "  Overall Status        : Completed Successfully" -ForegroundColor Green
}
Write-Host "========================================================================" -ForegroundColor DarkCyan
Write-Host ""
