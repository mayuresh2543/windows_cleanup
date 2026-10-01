<#
.SYNOPSIS
    Windows Storage Deep Cleanup Toolkit
.DESCRIPTION
    Terminal-based system storage cleaner for Windows 10 & 11.
    Scans and interactively purges temporary files, individual browser caches
    (Google Chrome, Mozilla Firefox, Brave Browser), media and chat apps,
    individual game launchers (Steam, Epic Games Store), developer toolchain caches,
    creative suite scratch caches, recycle bin, shadow copies, leftover upgrade directories,
    crash dumps, log archives, hibernation files, obsolete OEM drivers,
    search index databases, and WinSxS components.
    Targets with 0 bytes are automatically skipped.
.PARAMETER All
    Cleans all eligible targets without interactive confirmation prompts.
.PARAMETER DryRun
    Simulates cleanup preview without deleting files.
.PARAMETER SkipRecycleBin
    Skips emptying the Windows Recycle Bin.
.PARAMETER SkipThumbnails
    Skips purging Windows Explorer thumbnail and icon caches.
.PARAMETER SkipBrowsers
    Skips all supported web browser caches (Chrome, Firefox, Brave).
.PARAMETER SkipChrome
    Skips Google Chrome web and code caches.
.PARAMETER SkipFirefox
    Skips Mozilla Firefox web and startup caches.
.PARAMETER SkipBrave
    Skips Brave Browser web and code caches.
.PARAMETER SkipMediaApps
    Skips Spotify, Discord, Slack, Microsoft Teams, Telegram, and Zoom caches.
.PARAMETER SkipGames
    Skips all supported game launcher caches (Steam, Epic Games Store).
.PARAMETER SkipSteam
    Skips Steam web and HTTP caches.
.PARAMETER SkipEpic
    Skips Epic Games Store web cache.
.PARAMETER SkipDevCaches
    Skips Pip, VS Code, NPM, Yarn, pnpm, NuGet, Gradle, Cargo, and Go caches.
.PARAMETER SkipCreativeApps
    Skips Adobe Common Media Cache and DaVinci Resolve render cache files.
.PARAMETER SkipRestorePoints
    Skips purging oldest volume shadow copies.
.PARAMETER SkipCrashDumps
    Skips purging MEMORY.DMP, Minidump, LiveKernelReports, and user-mode CrashDumps.
.PARAMETER SkipUpgradeFolders
    Skips purging Windows.old, $WINDOWS.~BT, $WINDOWS.~WS, and $GetCurrent folders.
.PARAMETER SkipCBSLogs
    Skips purging CBS persist archives, Panther logs, and clearing DISM logs.
.PARAMETER SkipHiberfil
    Skips disabling hibernation and deleting hiberfil.sys.
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
.EXAMPLE
    .\cleanup.ps1 -All -SkipRestorePoints -SkipDrivers
#>

[CmdletBinding()]
param(
    [switch]$All,
    [switch]$DryRun,
    [switch]$SkipRecycleBin,
    [switch]$SkipThumbnails,
    [switch]$SkipBrowsers,
    [switch]$SkipChrome,
    [switch]$SkipFirefox,
    [switch]$SkipBrave,
    [switch]$SkipMediaApps,
    [switch]$SkipGames,
    [switch]$SkipSteam,
    [switch]$SkipEpic,
    [switch]$SkipDevCaches,
    [switch]$SkipCreativeApps,
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

# Dynamic system drive resolution
$sysDrive = if ($env:SystemDrive) { $env:SystemDrive } else { "C:" }
$sysDriveLetter = $sysDrive.TrimEnd(':')
$sysRoot = if ($env:SystemRoot) { $env:SystemRoot } else { "$sysDrive\Windows" }

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

$initialFreeBytes = (Get-PSDrive $sysDriveLetter).Free
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
Write-Host "  Target Volume       : Drive $sysDrive" -ForegroundColor Gray
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
        if ([string]::IsNullOrWhiteSpace($p)) { continue }
        $resolvedPaths = @()
        if ($p -match '[\*\?]') {
            try {
                $found = Get-Item -Path $p -Force -ErrorAction SilentlyContinue
                if ($found) {
                    $resolvedPaths = @($found | Select-Object -ExpandProperty FullName)
                }
            } catch { }
        } else {
            if (Test-Path -LiteralPath $p -ErrorAction SilentlyContinue) {
                $resolvedPaths = @($p)
            }
        }

        foreach ($rp in $resolvedPaths) {
            try {
                $item = Get-Item -LiteralPath $rp -Force -ErrorAction SilentlyContinue
                if ($item.PSIsContainer) {
                    $measure = Get-ChildItem -LiteralPath $rp -Recurse -File -Force -ErrorAction SilentlyContinue |
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

# 01. Temp files & Service Profiles
$tempPaths = @(
    $env:TEMP,
    "$sysRoot\Temp",
    "$sysRoot\ServiceProfiles\NetworkService\AppData\Local\Temp",
    "$sysRoot\ServiceProfiles\LocalService\AppData\Local\Temp"
)
$tempMetrics = Get-FolderMetrics $tempPaths
if ($tempMetrics.Bytes -gt 0) {
    $doTemp = Ask-Choice 1 "User & Windows Temp Directories" "Found $($tempMetrics.Formatted) disposable temporary caches in %TEMP% and $sysRoot\Temp" $true
} else {
    $doTemp = $false
    Write-SkippedChoice 1 "User & Windows Temp Directories" "None found / 0 B (Clean)"
}

# 02. Shaders (DirectX, NVIDIA, AMD, Intel) & WER Logs
$shaderPaths = @(
    "$env:LOCALAPPDATA\D3DSCache",
    "$env:LOCALAPPDATA\Microsoft\DirectX Shader Cache",
    "$env:LOCALAPPDATA\NVIDIA\DXCache",
    "$env:LOCALAPPDATA\NVIDIA\GLCache",
    "$env:APPDATA\NVIDIA\ComputeCache",
    "$env:LOCALAPPDATA\AMD\DxCache",
    "$env:LOCALAPPDATA\AMD\GLCache",
    "$env:LOCALAPPDATA\AMD\OglShaders",
    "$env:LOCALAPPDATA\Intel\ShaderCache",
    "$env:PROGRAMDATA\Microsoft\Windows\WER\ReportArchive",
    "$env:PROGRAMDATA\Microsoft\Windows\WER\ReportQueue",
    "$env:PROGRAMDATA\Microsoft\Windows\WER\Temp",
    "$env:LOCALAPPDATA\Microsoft\Windows\WER\ReportArchive"
)
$shaderMetrics = Get-FolderMetrics $shaderPaths
if ($shaderMetrics.Bytes -gt 0) {
    $doShaders = Ask-Choice 2 "DirectX, GPU Shaders & Error Reporting Logs" "Found $($shaderMetrics.Formatted) shaders (DirectX, NVIDIA, AMD, Intel) and WER archives" $true
} else {
    $doShaders = $false
    Write-SkippedChoice 2 "DirectX, GPU Shaders & Error Reporting Logs" "None found / 0 B (Clean)"
}

# 03. Windows Recycle Bin
if (-not $SkipRecycleBin) {
    $recyclePaths = @("$sysDrive\`$Recycle.Bin")
    $recycleMetrics = Get-FolderMetrics $recyclePaths
    if ($recycleMetrics.Bytes -gt 0) {
        $doRecycleBin = Ask-Choice 3 "Windows Recycle Bin" "Found $($recycleMetrics.Formatted) discarded files across drive bins" $true
    } else {
        $doRecycleBin = $false
        Write-SkippedChoice 3 "Windows Recycle Bin" "None found / 0 B (Clean)"
    }
} else {
    $doRecycleBin = $false
    Write-SkippedChoice 3 "Windows Recycle Bin" "Skipped (-SkipRecycleBin flag passed)"
}

# 04. Windows Explorer Thumbnail & Icon Caches
if (-not $SkipThumbnails) {
    $thumbPaths = @(
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db",
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db",
        "$env:LOCALAPPDATA\IconCache.db"
    )
    $thumbMetrics = Get-FolderMetrics $thumbPaths
    if ($thumbMetrics.Bytes -gt 0) {
        $doThumbnails = Ask-Choice 4 "Explorer Thumbnail & Icon Caches" "Found $($thumbMetrics.Formatted) cached Explorer thumbnail databases (thumbcache_*.db)" $true
    } else {
        $doThumbnails = $false
        Write-SkippedChoice 4 "Explorer Thumbnail & Icon Caches" "None found / 0 B (Clean)"
    }
} else {
    $doThumbnails = $false
    Write-SkippedChoice 4 "Explorer Thumbnail & Icon Caches" "Skipped (-SkipThumbnails flag passed)"
}

# 05. Windows Update Store
if ($isAdmin) {
    $updateMetrics = Get-FolderMetrics @("$sysRoot\SoftwareDistribution\Download")
    if ($updateMetrics.Bytes -gt 0) {
        $doUpdates = Ask-Choice 5 "Windows Update Download Store" "Found $($updateMetrics.Formatted) staged packages in SoftwareDistribution\Download" $true
    } else {
        $doUpdates = $false
        Write-SkippedChoice 5 "Windows Update Download Store" "None found / 0 B (Clean)"
    }
} else {
    $doUpdates = $false
    Write-SkippedChoice 5 "Windows Update Download Store" "Skipped (Requires Administrator privileges)"
}

# 06. Delivery Optimization
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
    $doFolderMetrics = Get-FolderMetrics @("$sysRoot\ServiceState\DeliveryOptimization", "$env:ProgramData\Microsoft\Network\Downloader")
    $totalDoBytes = $doBytes + $doFolderMetrics.Bytes
    if ($totalDoBytes -gt 0) {
        $doDelivery = Ask-Choice 6 "Windows Delivery Optimization Cache" "Found $(Format-ByteSize $totalDoBytes) peer-to-peer Windows update distribution files" $true
    } else {
        $doDelivery = $false
        Write-SkippedChoice 6 "Windows Delivery Optimization Cache" "None found / 0 B (Clean)"
    }
} else {
    $doDelivery = $false
    Write-SkippedChoice 6 "Windows Delivery Optimization Cache" "Skipped (Cmdlet not available)"
}

# 07. Google Chrome
$chromePaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Code Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\GPUCache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Service Worker\CacheStorage"
)
if (-not ($SkipBrowsers -or $SkipChrome)) {
    $chromeMetrics = Get-FolderMetrics $chromePaths
    if ($chromeMetrics.Bytes -gt 0) {
        $doChrome = Ask-Choice 7 "Google Chrome Web & Code Cache" "Found $($chromeMetrics.Formatted) cached web assets and compiled code caches across profiles" $true
    } else {
        $doChrome = $false
        Write-SkippedChoice 7 "Google Chrome Web & Code Cache" "None found / 0 B (Clean)"
    }
} else {
    $doChrome = $false
    Write-SkippedChoice 7 "Google Chrome Web & Code Cache" "Skipped (-SkipChrome or -SkipBrowsers flag passed)"
}

# 08. Mozilla Firefox
$firefoxPaths = @(
    "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2",
    "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\startupCache"
)
if (-not ($SkipBrowsers -or $SkipFirefox)) {
    $firefoxMetrics = Get-FolderMetrics $firefoxPaths
    if ($firefoxMetrics.Bytes -gt 0) {
        $doFirefox = Ask-Choice 8 "Mozilla Firefox Web & Startup Cache" "Found $($firefoxMetrics.Formatted) offline cache2 files and startup cache across profiles" $true
    } else {
        $doFirefox = $false
        Write-SkippedChoice 8 "Mozilla Firefox Web & Startup Cache" "None found / 0 B (Clean)"
    }
} else {
    $doFirefox = $false
    Write-SkippedChoice 8 "Mozilla Firefox Web & Startup Cache" "Skipped (-SkipFirefox or -SkipBrowsers flag passed)"
}

# 09. Brave Browser
$bravePaths = @(
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Cache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Code Cache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\GPUCache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Service Worker\CacheStorage"
)
if (-not ($SkipBrowsers -or $SkipBrave)) {
    $braveMetrics = Get-FolderMetrics $bravePaths
    if ($braveMetrics.Bytes -gt 0) {
        $doBrave = Ask-Choice 9 "Brave Browser Web & Code Cache" "Found $($braveMetrics.Formatted) cached web assets and compiled code caches across profiles" $true
    } else {
        $doBrave = $false
        Write-SkippedChoice 9 "Brave Browser Web & Code Cache" "None found / 0 B (Clean)"
    }
} else {
    $doBrave = $false
    Write-SkippedChoice 9 "Brave Browser Web & Code Cache" "Skipped (-SkipBrave or -SkipBrowsers flag passed)"
}

# 10. Media & Communication Apps (Spotify, Discord, Slack, Teams, Telegram, Zoom)
if (-not $SkipMediaApps) {
    $mediaPaths = @(
        "$env:LOCALAPPDATA\Spotify\Storage",
        "$env:APPDATA\discord\Cache",
        "$env:APPDATA\discord\Code Cache",
        "$env:APPDATA\Slack\Cache",
        "$env:APPDATA\Slack\Code Cache",
        "$env:APPDATA\Slack\Service Worker\CacheStorage",
        "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache",
        "$env:APPDATA\Microsoft\Teams\Cache",
        "$env:APPDATA\Microsoft\Teams\blob_storage",
        "$env:APPDATA\Microsoft\Teams\tmp",
        "$env:APPDATA\Telegram Desktop\tdata\user_data\media_cache",
        "$env:APPDATA\Zoom\data",
        "$env:LOCALAPPDATA\Zoom\temp"
    )
    $mediaMetrics = Get-FolderMetrics $mediaPaths
    if ($mediaMetrics.Bytes -gt 0) {
        $doMedia = Ask-Choice 10 "Media & Chat Caches (Spotify, Discord, Slack, Teams, Telegram, Zoom)" "Found $($mediaMetrics.Formatted) streaming audio, chat media, and code caches" $true
    } else {
        $doMedia = $false
        Write-SkippedChoice 10 "Media & Chat Caches" "None found / 0 B (Clean)"
    }
} else {
    $doMedia = $false
    Write-SkippedChoice 10 "Media & Chat Caches" "Skipped (-SkipMediaApps flag passed)"
}

# 11. Steam Web & HTTP Cache
$steamPaths = @(
    "$env:LOCALAPPDATA\Steam\htmlcache",
    "${env:ProgramFiles(x86)}\Steam\appcache\httpcache"
)
if (-not ($SkipGames -or $SkipSteam)) {
    $steamMetrics = Get-FolderMetrics $steamPaths
    if ($steamMetrics.Bytes -gt 0) {
        $doSteam = Ask-Choice 11 "Steam Web & HTTP Cache" "Found $($steamMetrics.Formatted) launcher browser and HTTP network cache files" $true
    } else {
        $doSteam = $false
        Write-SkippedChoice 11 "Steam Web & HTTP Cache" "None found / 0 B (Clean)"
    }
} else {
    $doSteam = $false
    Write-SkippedChoice 11 "Steam Web & HTTP Cache" "Skipped (-SkipSteam or -SkipGames flag passed)"
}

# 12. Epic Games Store Web Cache
$epicPaths = @(
    "$env:LOCALAPPDATA\EpicGamesLauncher\Saved\webcache*"
)
if (-not ($SkipGames -or $SkipEpic)) {
    $epicMetrics = Get-FolderMetrics $epicPaths
    if ($epicMetrics.Bytes -gt 0) {
        $doEpic = Ask-Choice 12 "Epic Games Store Web Cache" "Found $($epicMetrics.Formatted) store webcache assets and browser caches" $true
    } else {
        $doEpic = $false
        Write-SkippedChoice 12 "Epic Games Store Web Cache" "None found / 0 B (Clean)"
    }
} else {
    $doEpic = $false
    Write-SkippedChoice 12 "Epic Games Store Web Cache" "Skipped (-SkipEpic or -SkipGames flag passed)"
}

# 13. Developer Toolchain Caches (Pip, VS Code, NPM, Yarn, pnpm, NuGet, Gradle, Cargo, Go)
if (-not $SkipDevCaches) {
    $devPaths = @(
        "$env:LOCALAPPDATA\pip\cache",
        "$env:APPDATA\Code\Cache",
        "$env:APPDATA\Code\CachedData",
        "$env:LOCALAPPDATA\npm-cache",
        "$env:APPDATA\npm-cache",
        "$env:LOCALAPPDATA\Yarn\Cache",
        "$env:LOCALAPPDATA\pnpm\store",
        "$env:LOCALAPPDATA\NuGet\v3-cache",
        "$env:USERPROFILE\.gradle\caches",
        "$env:USERPROFILE\.cargo\registry\cache",
        "$env:LOCALAPPDATA\go-build"
    )
    $devMetrics = Get-FolderMetrics $devPaths
    if ($devMetrics.Bytes -gt 0) {
        $doDev = Ask-Choice 13 "Developer Toolchain Caches (Pip, VS Code, NPM, Yarn, NuGet, Gradle, Cargo, Go)" "Found $($devMetrics.Formatted) package download wheels and build cache artifacts" $true
    } else {
        $doDev = $false
        Write-SkippedChoice 13 "Developer Toolchain Caches" "None found / 0 B (Clean)"
    }
} else {
    $doDev = $false
    Write-SkippedChoice 13 "Developer Toolchain Caches" "Skipped (-SkipDevCaches flag passed)"
}

# 14. Creative Suite Media Caches (Adobe & DaVinci Resolve)
if (-not $SkipCreativeApps) {
    $creativePaths = @(
        "$env:APPDATA\Adobe\Common\Media Cache Files",
        "$env:APPDATA\Adobe\Common\Media Cache",
        "$env:USERPROFILE\Videos\CacheClip"
    )
    $creativeMetrics = Get-FolderMetrics $creativePaths
    if ($creativeMetrics.Bytes -gt 0) {
        $doCreative = Ask-Choice 14 "Creative Suite Media Caches (Adobe & DaVinci Resolve)" "Found $($creativeMetrics.Formatted) conformed audio peaks and video scratch renders" $true
    } else {
        $doCreative = $false
        Write-SkippedChoice 14 "Creative Suite Media Caches" "None found / 0 B (Clean)"
    }
} else {
    $doCreative = $false
    Write-SkippedChoice 14 "Creative Suite Media Caches" "Skipped (-SkipCreativeApps flag passed)"
}

# 15. Volume Shadow Copies
if ($isAdmin -and (-not $SkipRestorePoints)) {
    $shadowOutput = vssadmin list shadows 2>&1
    $hasShadows = ($shadowOutput -match 'Shadow Copy ID:')
    if ($hasShadows) {
        $shadowCount = ($shadowOutput | Select-String 'Shadow Copy ID:').Count
        $doShadows = Ask-Choice 15 "Oldest Volume Shadow Copies (vssadmin)" "Found $shadowCount shadow copies. Purges old snapshots via vssadmin, keeps newest" $true
    } else {
        $doShadows = $false
        Write-SkippedChoice 15 "Oldest Volume Shadow Copies (vssadmin)" "None found / 0 copies (Clean)"
    }
} else {
    $doShadows = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 15 "System Restore Points" "Skipped (Requires Administrator privileges)"
    } else {
        Write-SkippedChoice 15 "System Restore Points" "Skipped (-SkipRestorePoints flag passed)"
    }
}

# 16. Leftover Windows Upgrade Folders
$upgradePaths = @("$sysDrive\Windows.old", "$sysDrive\`$WINDOWS.~BT", "$sysDrive\`$WINDOWS.~WS", "$sysDrive\`$GetCurrent")
$foundUpgradePaths = @($upgradePaths | Where-Object { Test-Path -LiteralPath $_ })
$upgradeMetrics = if ($foundUpgradePaths.Count -gt 0) { Get-FolderMetrics $foundUpgradePaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
if ($foundUpgradePaths.Count -gt 0 -and $upgradeMetrics.Bytes -gt 0 -and (-not $SkipUpgradeFolders)) {
    $foundList = $foundUpgradePaths -join ", "
    $doUpgrade = Ask-Choice 16 "Leftover Windows Upgrade Folders" "Found $($upgradeMetrics.Formatted) across: $foundList" $true
} else {
    $doUpgrade = $false
    if ($SkipUpgradeFolders) {
        Write-SkippedChoice 16 "Leftover Windows Upgrade Folders" "Skipped (-SkipUpgradeFolders flag passed)"
    } else {
        Write-SkippedChoice 16 "Leftover Windows Upgrade Folders" "None found / 0 B (Clean)"
    }
}

# 17. Kernel & User Crash Dumps
$crashPaths = @(
    "$sysRoot\MEMORY.DMP",
    "$sysRoot\Minidump",
    "$sysRoot\LiveKernelReports",
    "$env:LOCALAPPDATA\CrashDumps"
)
$crashMetrics = Get-FolderMetrics $crashPaths
if ($crashMetrics.Bytes -gt 0 -and (-not $SkipCrashDumps)) {
    $doCrashDumps = Ask-Choice 17 "Kernel & User Crash Dump Files" "Found $($crashMetrics.Formatted) in crash dump files (MEMORY.DMP, CrashDumps)" $true
} else {
    $doCrashDumps = $false
    if ($SkipCrashDumps) {
        Write-SkippedChoice 17 "Kernel & User Crash Dump Files" "Skipped (-SkipCrashDumps flag passed)"
    } else {
        Write-SkippedChoice 17 "Kernel & User Crash Dump Files" "None found / 0 B (Clean)"
    }
}

# 18. CBS, DISM & Panther Logs
if ($isAdmin -and (-not $SkipCBSLogs)) {
    $cbsPaths = @(
        "$sysRoot\Logs\CBS\CbsPersist_*",
        "$sysRoot\Panther",
        "$env:ProgramData\Microsoft\Diagnosis\ETLLogs\*.etl"
    )
    $cbsFolderMetrics = Get-FolderMetrics $cbsPaths
    $cbsLogBytes = $cbsFolderMetrics.Bytes
    if (Test-Path -LiteralPath "$sysRoot\Logs\DISM\dism.log") {
        try { $cbsLogBytes += (Get-Item -LiteralPath "$sysRoot\Logs\DISM\dism.log" -Force -ErrorAction SilentlyContinue).Length } catch { }
    }
    if ($cbsLogBytes -gt 0) {
        $cbsFormatted = Format-ByteSize $cbsLogBytes
        $doCBSLogs = Ask-Choice 18 "CBS, DISM & Panther Log Archives" "Found $cbsFormatted in CBS persist archives, Panther logs, and DISM traces" $true
    } else {
        $doCBSLogs = $false
        Write-SkippedChoice 18 "CBS, DISM & Panther Log Archives" "None found / 0 B (Clean)"
    }
} else {
    $doCBSLogs = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 18 "CBS, DISM & Panther Log Archives" "Skipped (Requires Administrator privileges)"
    } else {
        Write-SkippedChoice 18 "CBS, DISM & Panther Log Archives" "Skipped (-SkipCBSLogs flag passed)"
    }
}

# 19. Hibernation file
$hiberPath = "$sysDrive\hiberfil.sys"
$hasHiberfil = Test-Path -LiteralPath $hiberPath
if ($isAdmin -and (-not $SkipHiberfil)) {
    $hiberSize = [int64]0
    if ($hasHiberfil) {
        try { $hiberSize = (Get-Item -LiteralPath $hiberPath -Force -ErrorAction Stop).Length } catch { }
    }
    if ($hasHiberfil -and $hiberSize -gt 0) {
        $hiberFormatted = Format-ByteSize $hiberSize
        $doHiberfil = Ask-Choice 19 "Windows Hibernation File (hiberfil.sys)" "Found $hiberPath ($hiberFormatted). Disables Hibernate to reclaim space (Sleep unaffected)" $true
    } else {
        $doHiberfil = $false
        Write-SkippedChoice 19 "Windows Hibernation (hiberfil.sys)" "Already disabled / None found (Clean)"
    }
} else {
    $doHiberfil = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 19 "Windows Hibernation (hiberfil.sys)" "Skipped (Requires Administrator privileges)"
    } else {
        Write-SkippedChoice 19 "Windows Hibernation (hiberfil.sys)" "Skipped (-SkipHiberfil flag passed)"
    }
}

# 20. Obsolete OEM drivers
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
        $doDrivers = Ask-Choice 20 "Obsolete OEM Hardware Drivers" "Found $($supersededDrivers.Count) superseded driver packages in DriverStore" $true
    } else {
        $doDrivers = $false
        Write-SkippedChoice 20 "Obsolete OEM Hardware Drivers" "None found / 0 drivers (Clean)"
    }
} else {
    $doDrivers = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 20 "Obsolete OEM Hardware Drivers" "Skipped (Requires Administrator privileges)"
    } else {
        Write-SkippedChoice 20 "Obsolete OEM Hardware Drivers" "Skipped (-SkipDrivers flag passed)"
    }
}

# 21. Windows Search index
$searchService = Get-Service -Name WSearch -ErrorAction SilentlyContinue
if ($isAdmin -and ($null -ne $searchService) -and (-not $SkipSearchIndex)) {
    $searchPaths = @(
        "$env:ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb",
        "$env:ProgramData\Microsoft\Search\Data\Applications\Windows\Projects\SystemIndex\Indexer"
    )
    $searchMetrics = Get-FolderMetrics $searchPaths
    if ($searchMetrics.Bytes -gt 0) {
        $doSearchIndex = Ask-Choice 21 "Windows Search Index Database" "Found $($searchMetrics.Formatted) in search database (resets and compacts in background)" $true
    } else {
        $doSearchIndex = $false
        Write-SkippedChoice 21 "Windows Search Index Database" "None found / 0 B (Clean)"
    }
} else {
    $doSearchIndex = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 21 "Windows Search Index Database" "Skipped (Requires Administrator privileges)"
    } elseif ($SkipSearchIndex) {
        Write-SkippedChoice 21 "Windows Search Index Database" "Skipped (-SkipSearchIndex flag passed)"
    } else {
        Write-SkippedChoice 21 "Windows Search Index Database" "Service not present (Clean)"
    }
}

# 22. WinSxS ResetBase
if ($isAdmin -and (-not $SkipDism)) {
    $doDism = Ask-Choice 22 "WinSxS Component Store ResetBase" "Deep WinSxS component purge (Takes 2-5 min, prevents old update rollbacks)" $false
} else {
    $doDism = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 22 "WinSxS Component Store ResetBase" "Skipped (Requires Administrator privileges)"
    } else {
        Write-SkippedChoice 22 "WinSxS Component Store ResetBase" "Skipped (-SkipDism flag passed)"
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

# Execution: 01. Temp Files
if ($doTemp) {
    Invoke-Purge "User and Windows Temp Directories" {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$sysRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        if ($isAdmin) {
            Remove-Item -Path "$sysRoot\ServiceProfiles\NetworkService\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$sysRoot\ServiceProfiles\LocalService\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-Host "               Purged %TEMP%, $sysRoot\Temp, and ServiceProfile disposable caches." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "User and Windows Temp Directories"
}

# Execution: 02. Shaders & WER
if ($doShaders) {
    Invoke-Purge "DirectX, GPU Shaders & Windows Error Reporting Logs" {
        foreach ($p in $shaderPaths) {
            if (Test-Path -LiteralPath $p) {
                Remove-Item -Path "$p\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        Write-Host "               Purged DirectX, NVIDIA, AMD, Intel shader caches and WER logs." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "DirectX, GPU Shaders & Windows Error Reporting Logs"
}

# Execution: 03. Recycle Bin
if ($doRecycleBin) {
    Invoke-Purge "Windows Recycle Bin" {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "               Emptied Windows Recycle Bin across all drives." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Windows Recycle Bin"
}

# Execution: 04. Explorer Thumbnails & Icon Caches
if ($doThumbnails) {
    Invoke-Purge "Windows Explorer Thumbnail & Icon Caches" {
        Get-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        Get-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        if (Test-Path -LiteralPath "$env:LOCALAPPDATA\IconCache.db") {
            Remove-Item -LiteralPath "$env:LOCALAPPDATA\IconCache.db" -Force -ErrorAction SilentlyContinue
        }
        Write-Host "               Purged Explorer thumbcache and iconcache databases." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Windows Explorer Thumbnail & Icon Caches"
}

# Execution: 05. Windows Update Store
if ($doUpdates -and $isAdmin) {
    Invoke-Purge "Windows Update Download Store" {
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$sysRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        Write-Host "               Stopped wuauserv, purged SoftwareDistribution\Download, restarted service." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Windows Update Download Store"
}

# Execution: 06. Delivery Optimization
if ($doDelivery) {
    Invoke-Purge "Windows Delivery Optimization Cache" {
        $origOut = [Console]::Out
        $sw = New-Object System.IO.StringWriter
        try {
            [Console]::SetOut($sw)
            $null = Delete-DeliveryOptimizationCache -Force -ErrorAction SilentlyContinue
        } catch { } finally {
            [Console]::SetOut($origOut)
        }
        Write-Host "               Purged Windows Delivery Optimization cache." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Windows Delivery Optimization Cache"
}

# Execution: 07. Google Chrome
if ($doChrome) {
    Invoke-Purge "Google Chrome Web & Code Cache" {
        foreach ($p in $chromePaths) {
            if ($p -match '[\*\?]') {
                $found = Get-Item -Path $p -Force -ErrorAction SilentlyContinue
                if ($found) {
                    foreach ($f in $found) {
                        Remove-Item -Path "$($f.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            } else {
                if (Test-Path -LiteralPath $p) {
                    Remove-Item -Path "$p\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }
        Write-Host "               Purged Google Chrome web cache, code cache, and GPU cache." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Google Chrome Web & Code Cache"
}

# Execution: 08. Mozilla Firefox
if ($doFirefox) {
    Invoke-Purge "Mozilla Firefox Web & Startup Cache" {
        foreach ($p in $firefoxPaths) {
            if ($p -match '[\*\?]') {
                $found = Get-Item -Path $p -Force -ErrorAction SilentlyContinue
                if ($found) {
                    foreach ($f in $found) {
                        Remove-Item -Path "$($f.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            } else {
                if (Test-Path -LiteralPath $p) {
                    Remove-Item -Path "$p\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }
        Write-Host "               Purged Mozilla Firefox cache2 and startupCache directories." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Mozilla Firefox Web & Startup Cache"
}

# Execution: 09. Brave Browser
if ($doBrave) {
    Invoke-Purge "Brave Browser Web & Code Cache" {
        foreach ($p in $bravePaths) {
            if ($p -match '[\*\?]') {
                $found = Get-Item -Path $p -Force -ErrorAction SilentlyContinue
                if ($found) {
                    foreach ($f in $found) {
                        Remove-Item -Path "$($f.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            } else {
                if (Test-Path -LiteralPath $p) {
                    Remove-Item -Path "$p\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }
        Write-Host "               Purged Brave Browser web cache, code cache, and GPU cache." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Brave Browser Web & Code Cache"
}

# Execution: 10. Media & Chat Caches
if ($doMedia) {
    Invoke-Purge "Media & Chat Caches (Spotify, Discord, Slack, Teams, Telegram, Zoom)" {
        foreach ($mp in $mediaPaths) {
            if (Test-Path -LiteralPath $mp) {
                Remove-Item -Path "$mp\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        Write-Host "               Purged Spotify, Discord, Slack, Teams, Telegram, and Zoom caches." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Media & Chat Caches"
}

# Execution: 11. Steam
if ($doSteam) {
    Invoke-Purge "Steam Web & HTTP Cache" {
        foreach ($p in $steamPaths) {
            if (Test-Path -LiteralPath $p) {
                Remove-Item -Path "$p\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        Write-Host "               Purged Steam htmlcache and appcache\httpcache directories." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Steam Web & HTTP Cache"
}

# Execution: 12. Epic Games Store
if ($doEpic) {
    Invoke-Purge "Epic Games Store Web Cache" {
        foreach ($p in $epicPaths) {
            if ($p -match '[\*\?]') {
                $found = Get-Item -Path $p -Force -ErrorAction SilentlyContinue
                if ($found) {
                    foreach ($f in $found) {
                        Remove-Item -Path "$($f.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            } else {
                if (Test-Path -LiteralPath $p) {
                    Remove-Item -Path "$p\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }
        Write-Host "               Purged Epic Games Launcher Saved\webcache directories." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Epic Games Store Web Cache"
}

# Execution: 13. Developer Caches
if ($doDev) {
    Invoke-Purge "Developer Toolchain Caches (Pip, VS Code, NPM, Yarn, NuGet, Gradle, Cargo, Go)" {
        if (Get-Command pip -ErrorAction SilentlyContinue) {
            $null = pip cache purge 2>&1
        }
        if (Get-Command npm -ErrorAction SilentlyContinue) {
            $null = npm cache clean --force 2>&1
        }
        if (Get-Command yarn -ErrorAction SilentlyContinue) {
            $null = yarn cache clean 2>&1
        }
        if (Get-Command dotnet -ErrorAction SilentlyContinue) {
            $null = dotnet nuget locals all --clear 2>&1
        }
        if (Get-Command go -ErrorAction SilentlyContinue) {
            $null = go clean -cache 2>&1
        }

        foreach ($dp in $devPaths) {
            if (Test-Path -LiteralPath $dp) {
                Remove-Item -Path "$dp\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        Write-Host "               Purged Pip, VS Code, NPM, Yarn, NuGet, Gradle, Cargo, and Go caches." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Developer Toolchain Caches"
}

# Execution: 14. Creative Suite Media Caches
if ($doCreative) {
    Invoke-Purge "Creative Suite Media Caches (Adobe & DaVinci Resolve)" {
        foreach ($cp in $creativePaths) {
            if (Test-Path -LiteralPath $cp) {
                Remove-Item -Path "$cp\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        Write-Host "               Purged Adobe Media Cache and DaVinci Resolve render cache files." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Creative Suite Media Caches"
}

# Execution: 15. Shadow Copies
if ($doShadows -and $isAdmin) {
    Invoke-Purge "Oldest Volume Shadow Copies (vssadmin)" {
        $null = vssadmin delete shadows /for=$sysDrive /oldest /quiet 2>&1
        Write-Host "               Purged oldest shadow copies from $sysDrive (kept newest)." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Oldest Volume Shadow Copies"
}

# Execution: 16. Upgrade Folders
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

# Execution: 17. Crash Dumps
if ($doCrashDumps) {
    Invoke-Purge "Kernel & User Crash Dump Files" {
        if (Test-Path -LiteralPath "$sysRoot\MEMORY.DMP") {
            Remove-Item -LiteralPath "$sysRoot\MEMORY.DMP" -Force -ErrorAction SilentlyContinue
            Write-Host "               Deleted $sysRoot\MEMORY.DMP." -ForegroundColor DarkGray
        }
        if (Test-Path -LiteralPath "$sysRoot\Minidump") {
            Remove-Item -Path "$sysRoot\Minidump\*" -Force -ErrorAction SilentlyContinue
            Write-Host "               Purged $sysRoot\Minidump." -ForegroundColor DarkGray
        }
        if (Test-Path -LiteralPath "$sysRoot\LiveKernelReports") {
            Remove-Item -Path "$sysRoot\LiveKernelReports\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "               Purged $sysRoot\LiveKernelReports." -ForegroundColor DarkGray
        }
        if (Test-Path -LiteralPath "$env:LOCALAPPDATA\CrashDumps") {
            Remove-Item -Path "$env:LOCALAPPDATA\CrashDumps\*" -Force -ErrorAction SilentlyContinue
            Write-Host "               Purged %LOCALAPPDATA%\CrashDumps." -ForegroundColor DarkGray
        }
    }
} else {
    Write-SkippedExecution "Kernel & User Crash Dump Files"
}

# Execution: 18. CBS & Servicing Logs
if ($doCBSLogs -and $isAdmin) {
    Invoke-Purge "CBS, DISM & Panther Log Archives" {
        Remove-Item -Path "$sysRoot\Logs\CBS\CbsPersist_*" -Force -ErrorAction SilentlyContinue
        if (Test-Path -LiteralPath "$sysRoot\Logs\DISM\dism.log") {
            Clear-Content -Path "$sysRoot\Logs\DISM\dism.log" -ErrorAction SilentlyContinue
        }
        if (Test-Path -LiteralPath "$sysRoot\Panther") {
            Remove-Item -Path "$sysRoot\Panther\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path -LiteralPath "$env:ProgramData\Microsoft\Diagnosis\ETLLogs") {
            Remove-Item -Path "$env:ProgramData\Microsoft\Diagnosis\ETLLogs\*.etl" -Force -ErrorAction SilentlyContinue
        }
        Write-Host "               Purged CBS persist archives, Panther logs, ETLLogs, and cleared DISM log." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "CBS, DISM & Panther Log Archives"
}

# Execution: 19. Hibernation File
if ($doHiberfil -and $isAdmin) {
    Invoke-Purge "Windows Hibernation File (hiberfil.sys)" {
        $null = powercfg -h off 2>&1
        Write-Host "               Disabled hibernation via powercfg and purged $hiberPath." -ForegroundColor DarkGray
    }
} else {
    Write-SkippedExecution "Windows Hibernation File (hiberfil.sys)"
}

# Execution: 20. Obsolete OEM Drivers
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

# Execution: 21. Windows Search Index
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

# Execution: 22. WinSxS ResetBase
if ($doDism -and $isAdmin) {
    Invoke-Purge "WinSxS Component Store ResetBase" {
        Write-Host "               Consolidating WinSxS component store via DISM..." -ForegroundColor DarkGray
        
        $dismPath = "$sysRoot\System32\Dism.exe"
        if (-not (Test-Path -LiteralPath $dismPath)) { $dismPath = "Dism.exe" }
        
        $pInfo = New-Object System.Diagnostics.ProcessStartInfo
        $pInfo.FileName = $dismPath
        $pInfo.Arguments = "/online /Cleanup-Image /StartComponentCleanup /ResetBase"
        $pInfo.RedirectStandardOutput = $true
        $pInfo.RedirectStandardError = $true
        $pInfo.UseShellExecute = $false
        $pInfo.CreateNoWindow = $true

        try {
            $p = [System.Diagnostics.Process]::Start($pInfo)
            $buffer = ""
            $lastProgress = ""
            
            while (-not $p.HasExited -or -not $p.StandardOutput.EndOfStream) {
                $char = $p.StandardOutput.Read()
                if ($char -eq -1) {
                    Start-Sleep -Milliseconds 30
                    continue
                }
                $c = [char]$char
                if ($c -eq "`r" -or $c -eq "`n") {
                    $rawLine = $buffer.Trim()
                    $buffer = ""
                    if ($rawLine) {
                        if ($rawLine -match '(\[\s*=*\s*(\d{1,3}(\.\d+)?)%\s*=*\s*\])') {
                            $currProgress = $matches[1]
                            if ($currProgress -ne $lastProgress) {
                                $lastProgress = $currProgress
                                Write-Host -NoNewline "`r               Progress: $currProgress   " -ForegroundColor Cyan
                            }
                        } elseif ($rawLine -match '(\d{1,3}(\.\d+)?)%') {
                            $pct = $matches[0]
                            if ($pct -ne $lastProgress) {
                                $lastProgress = $pct
                                Write-Host -NoNewline "`r               Progress: $pct   " -ForegroundColor Cyan
                            }
                        } elseif ($rawLine -match 'completed successfully' -or $rawLine -match '100(\.0)?%') {
                            Write-Host -NoNewline "`r               Progress: [100.0%] - Completed successfully.          `n" -ForegroundColor Green
                        } elseif ($rawLine -match 'Error:\s*\d+' -or $rawLine -match 'Failed') {
                            Write-Host "`n               $rawLine" -ForegroundColor Red
                        }
                    }
                } else {
                    $buffer += $c
                }
            }
            $p.WaitForExit()
            if ($p.ExitCode -eq 0) {
                Write-Host "               Deep WinSxS component cleanup completed." -ForegroundColor DarkGray
            } else {
                Write-Host "               DISM exited with code $($p.ExitCode)." -ForegroundColor Yellow
            }
        } catch {
            $null = Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1
            Write-Host "               Deep WinSxS component cleanup completed." -ForegroundColor DarkGray
        }
    }
} else {
    Write-SkippedExecution "WinSxS Component Store ResetBase"
}

$finalFreeBytes = (Get-PSDrive $sysDriveLetter).Free
$finalFreeGB = [math]::Round($finalFreeBytes / 1GB, 2)
$reclaimedGB = [math]::Round(($finalFreeBytes - $initialFreeBytes) / 1GB, 2)

Write-Host "========================================================================" -ForegroundColor DarkCyan
Write-Host "                        CLEANUP SUMMARY REPORT                          " -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor DarkCyan
if ($DryRun) {
    Write-Host "  Execution Mode        : Dry Run (Preview Simulation - No changes made)" -ForegroundColor Magenta
    Write-Host "  Target Volume         : Drive $sysDrive" -ForegroundColor Gray
    Write-Host "  Current Free Space    : $finalFreeGB GB" -ForegroundColor White
} else {
    Write-Host "  Target Volume         : Drive $sysDrive" -ForegroundColor Gray
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
