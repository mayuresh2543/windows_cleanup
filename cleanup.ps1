<#
.SYNOPSIS
    Windows Storage Deep Cleanup Toolkit
.DESCRIPTION
    Terminal-based system storage cleaner for Windows 10 & 11.
    Features a structured, two-level interactive menu organized into 7 distinct categories:
      1. System Caches (Temp dirs, GPU shaders, Recycle Bin, Thumbnails, Windows Update, Delivery Optimization)
      2. Browser Caches (Google Chrome, Mozilla Firefox, Brave Browser)
      3. Game Launcher Caches (Steam, Epic Games Store)
      4. App Caches (Spotify, Discord, Slack, Microsoft Teams, Telegram, Zoom)
      5. Developer Tool Caches (Python/Pip, VS Code, NPM, Yarn, pnpm, NuGet, Gradle, Cargo, Go)
      6. Creative Suite Caches (Adobe Media Cache, DaVinci Resolve render cache)
      7. System Advanced (Shadow copies, upgrade folders, crash dumps, log archives, hibernate, OEM drivers, search index, WinSxS)

    Categories and targets with 0 bytes are automatically skipped without prompting.
    When a category contains cached data, it prompts: [A]ll / [I]ndividual / [S]kip
      - [A]ll: Selects all discovered targets in the category at once.
      - [I]ndividual: Prompts for each target in the category one by one.
      - [S]kip: Skips the entire category.
.PARAMETER All
    Cleans all eligible targets non-interactively without prompts.
.PARAMETER DryRun
    Simulates cleanup preview without deleting files.
.PARAMETER SkipSystem
    Skips the entire System Caches category.
.PARAMETER SkipTemp
    Skips User & Windows Temp Directories.
.PARAMETER SkipShaders
    Skips DirectX, GPU shader caches, and WER error reporting logs.
.PARAMETER SkipRecycleBin
    Skips emptying the Windows Recycle Bin.
.PARAMETER SkipThumbnails
    Skips purging Windows Explorer thumbnail and icon caches.
.PARAMETER SkipWindowsUpdate
    Skips Windows Update Download Store.
.PARAMETER SkipDeliveryOptimization
    Skips Windows Delivery Optimization Cache.
.PARAMETER SkipBrowsers
    Skips all supported web browser caches (Chrome, Firefox, Brave).
.PARAMETER SkipChrome
    Skips Google Chrome web and code caches.
.PARAMETER SkipFirefox
    Skips Mozilla Firefox web and startup caches.
.PARAMETER SkipBrave
    Skips Brave Browser web and code caches.
.PARAMETER SkipGames
    Skips all supported game launcher caches (Steam, Epic Games Store).
.PARAMETER SkipSteam
    Skips Steam web and HTTP caches.
.PARAMETER SkipEpic
    Skips Epic Games Store web cache.
.PARAMETER SkipMediaApps
    Skips all communication & media app caches.
.PARAMETER SkipSpotify
    Skips Spotify audio storage cache.
.PARAMETER SkipDiscord
    Skips Discord web and code cache.
.PARAMETER SkipSlack
    Skips Slack web, code, and service worker caches.
.PARAMETER SkipTeams
    Skips Microsoft Teams local cache.
.PARAMETER SkipTelegram
    Skips Telegram Desktop media cache.
.PARAMETER SkipZoom
    Skips Zoom meeting and temp cache.
.PARAMETER SkipDevCaches
    Skips all developer toolchain caches.
.PARAMETER SkipPip
    Skips Python pip wheel cache.
.PARAMETER SkipVSCode
    Skips Visual Studio Code web and code cache.
.PARAMETER SkipNpm
    Skips NPM cache.
.PARAMETER SkipYarn
    Skips Yarn cache.
.PARAMETER SkipPnpm
    Skips pnpm store cache.
.PARAMETER SkipNuget
    Skips NuGet package cache.
.PARAMETER SkipGradle
    Skips Gradle build cache.
.PARAMETER SkipCargo
    Skips Rust Cargo registry cache.
.PARAMETER SkipGo
    Skips Go build cache.
.PARAMETER SkipCreativeApps
    Skips all creative suite media and render caches.
.PARAMETER SkipAdobe
    Skips Adobe Premiere / After Effects Media Cache.
.PARAMETER SkipDaVinci
    Skips DaVinci Resolve CacheClip render cache.
.PARAMETER SkipAdvanced
    Skips the entire System Advanced category.
.PARAMETER SkipRestorePoints
    Skips purging oldest volume shadow copies.
.PARAMETER SkipUpgradeFolders
    Skips purging Windows.old, $WINDOWS.~BT, $WINDOWS.~WS, and $GetCurrent folders.
.PARAMETER SkipCrashDumps
    Skips purging MEMORY.DMP, Minidump, LiveKernelReports, and user-mode CrashDumps.
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
    
    # Category: System
    [switch]$SkipSystem,
    [switch]$SkipTemp,
    [switch]$SkipShaders,
    [switch]$SkipRecycleBin,
    [switch]$SkipThumbnails,
    [switch]$SkipWindowsUpdate,
    [switch]$SkipDeliveryOptimization,
    
    # Category: Browsers
    [switch]$SkipBrowsers,
    [switch]$SkipChrome,
    [switch]$SkipFirefox,
    [switch]$SkipBrave,
    
    # Category: Games
    [switch]$SkipGames,
    [switch]$SkipSteam,
    [switch]$SkipEpic,
    
    # Category: Apps
    [switch]$SkipMediaApps,
    [switch]$SkipSpotify,
    [switch]$SkipDiscord,
    [switch]$SkipSlack,
    [switch]$SkipTeams,
    [switch]$SkipTelegram,
    [switch]$SkipZoom,
    
    # Category: Developer Tools
    [switch]$SkipDevCaches,
    [switch]$SkipPip,
    [switch]$SkipVSCode,
    [switch]$SkipNpm,
    [switch]$SkipYarn,
    [switch]$SkipPnpm,
    [switch]$SkipNuget,
    [switch]$SkipGradle,
    [switch]$SkipCargo,
    [switch]$SkipGo,
    
    # Category: Creative Suite
    [switch]$SkipCreativeApps,
    [switch]$SkipAdobe,
    [switch]$SkipDaVinci,
    
    # Category: Advanced
    [switch]$SkipAdvanced,
    [switch]$SkipRestorePoints,
    [switch]$SkipUpgradeFolders,
    [switch]$SkipCrashDumps,
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

function Ask-Category {
    param(
        [string]$Label,
        [string]$Summary,
        [string]$Default = "All"
    )
    if ($All) { return "All" }
    
    $defaultHint = if ($Default -eq "All") { "[A]ll / [I]ndividual / [S]kip [A]" } else { "[A]ll / [I]ndividual / [S]kip [I]" }
    
    Write-Host ""
    Write-Host "  ---------------------------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host "  [ CATEGORY ] " -NoNewline -ForegroundColor Cyan
    Write-Host $Label -ForegroundColor White
    if ($Summary) {
        Write-Host "               $Summary" -ForegroundColor DarkGray
    }
    Write-Host "               Clean this category? " -NoNewline -ForegroundColor Gray
    Write-Host "$($defaultHint): " -NoNewline -ForegroundColor Yellow
    
    $reply = Read-Host
    if ([string]::IsNullOrWhiteSpace($reply)) {
        return $Default
    }
    if ($reply -match '^(a|all|y|yes)$') {
        return "All"
    } elseif ($reply -match '^(i|ind|individual|custom|each)$') {
        return "Individual"
    } elseif ($reply -match '^(s|skip|n|no|none)$') {
        return "Skip"
    }
    return $Default
}

function Write-SkippedCategory {
    param(
        [string]$Label,
        [string]$Reason = "None found / 0 B (Clean)"
    )
    if ($All) { return }
    Write-Host ""
    Write-Host "  ---------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  [ CATEGORY ] " -NoNewline -ForegroundColor DarkGray
    Write-Host "$Label " -NoNewline -ForegroundColor DarkGray
    Write-Host "- $Reason" -ForegroundColor DarkGray
}

function Ask-Choice {
    param(
        [int]$Number,
        [string]$Title,
        [string]$Description,
        [bool]$Default = $true,
        [string]$CategoryMode = "Individual"
    )
    $numStr = $Number.ToString("00")
    if ($All -or ($CategoryMode -eq "All" -and $Default)) {
        Write-Host ""
        Write-Host "  [$numStr] " -NoNewline -ForegroundColor Cyan
        Write-Host $Title -ForegroundColor White
        if ($Description) {
            Write-Host "       $Description" -ForegroundColor DarkGray
        }
        Write-Host "       [+] Included (Category: All)" -ForegroundColor Green
        return $true
    }
    
    $defaultLabel = "[Y/n]"
    if (-not $Default) { $defaultLabel = "[y/N]" }
    
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

# ============================================================================
# CATEGORY 1 - SYSTEM CACHES
# ============================================================================
$tempPaths = @(
    $env:TEMP,
    "$sysRoot\Temp",
    "$sysRoot\ServiceProfiles\NetworkService\AppData\Local\Temp",
    "$sysRoot\ServiceProfiles\LocalService\AppData\Local\Temp"
)
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
$recyclePaths = @("$sysDrive\`$Recycle.Bin")
$thumbPaths = @(
    "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db",
    "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db",
    "$env:LOCALAPPDATA\IconCache.db"
)
$updatePaths = @("$sysRoot\SoftwareDistribution\Download")

$tempMetrics = if (-not $SkipTemp) { Get-FolderMetrics $tempPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$shaderMetrics = if (-not $SkipShaders) { Get-FolderMetrics $shaderPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$recycleMetrics = if (-not $SkipRecycleBin) { Get-FolderMetrics $recyclePaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$thumbMetrics = if (-not $SkipThumbnails) { Get-FolderMetrics $thumbPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$updateMetrics = if ($isAdmin -and (-not $SkipWindowsUpdate)) { Get-FolderMetrics $updatePaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }

$doBytes = [int64]0
if ((Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue) -and (-not $SkipDeliveryOptimization)) {
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
} else {
    $totalDoBytes = [int64]0
}

$catSystemBytes = $tempMetrics.Bytes + $shaderMetrics.Bytes + $recycleMetrics.Bytes + $thumbMetrics.Bytes + $updateMetrics.Bytes + $totalDoBytes

if ($SkipSystem) {
    Write-SkippedCategory "System Caches" "Skipped (-SkipSystem flag passed)"
    $catSystem = "Skip"
} elseif ($catSystemBytes -eq 0) {
    Write-SkippedCategory "System Caches" "None found / 0 B (Clean)"
    $catSystem = "Skip"
} else {
    $catSystem = Ask-Category "System Caches (Found $(Format-ByteSize $catSystemBytes))" "Temp dirs, GPU shaders, Recycle Bin, thumbnails, Windows Update, Delivery Optimization" "All"
}

if ($catSystem -ne "Skip") {
    # 01. Temp files & Service Profiles
    if (-not $SkipTemp -and $tempMetrics.Bytes -gt 0) {
        $doTemp = Ask-Choice 1 "User & Windows Temp Directories" "Found $($tempMetrics.Formatted) disposable temporary caches in %TEMP% and $sysRoot\Temp" $true $catSystem
    } else {
        $doTemp = $false
        if ($SkipTemp) { Write-SkippedChoice 1 "User & Windows Temp Directories" "Skipped (-SkipTemp flag passed)" }
        else { Write-SkippedChoice 1 "User & Windows Temp Directories" "None found / 0 B (Clean)" }
    }

    # 02. Shaders & WER
    if (-not $SkipShaders -and $shaderMetrics.Bytes -gt 0) {
        $doShaders = Ask-Choice 2 "DirectX, GPU Shaders & Error Reporting Logs" "Found $($shaderMetrics.Formatted) shaders (DirectX, NVIDIA, AMD, Intel) and WER archives" $true $catSystem
    } else {
        $doShaders = $false
        if ($SkipShaders) { Write-SkippedChoice 2 "DirectX, GPU Shaders & Error Reporting Logs" "Skipped (-SkipShaders flag passed)" }
        else { Write-SkippedChoice 2 "DirectX, GPU Shaders & Error Reporting Logs" "None found / 0 B (Clean)" }
    }

    # 03. Recycle Bin
    if (-not $SkipRecycleBin -and $recycleMetrics.Bytes -gt 0) {
        $doRecycleBin = Ask-Choice 3 "Windows Recycle Bin" "Found $($recycleMetrics.Formatted) discarded files across drive bins" $true $catSystem
    } else {
        $doRecycleBin = $false
        if ($SkipRecycleBin) { Write-SkippedChoice 3 "Windows Recycle Bin" "Skipped (-SkipRecycleBin flag passed)" }
        else { Write-SkippedChoice 3 "Windows Recycle Bin" "None found / 0 B (Clean)" }
    }

    # 04. Thumbnails & Icon Caches
    if (-not $SkipThumbnails -and $thumbMetrics.Bytes -gt 0) {
        $doThumbnails = Ask-Choice 4 "Explorer Thumbnail & Icon Caches" "Found $($thumbMetrics.Formatted) cached Explorer thumbnail databases (thumbcache_*.db)" $true $catSystem
    } else {
        $doThumbnails = $false
        if ($SkipThumbnails) { Write-SkippedChoice 4 "Explorer Thumbnail & Icon Caches" "Skipped (-SkipThumbnails flag passed)" }
        else { Write-SkippedChoice 4 "Explorer Thumbnail & Icon Caches" "None found / 0 B (Clean)" }
    }

    # 05. Windows Update Store
    if ($isAdmin -and (-not $SkipWindowsUpdate) -and $updateMetrics.Bytes -gt 0) {
        $doUpdates = Ask-Choice 5 "Windows Update Download Store" "Found $($updateMetrics.Formatted) staged packages in SoftwareDistribution\Download" $true $catSystem
    } else {
        $doUpdates = $false
        if (-not $isAdmin) { Write-SkippedChoice 5 "Windows Update Download Store" "Skipped (Requires Administrator privileges)" }
        elseif ($SkipWindowsUpdate) { Write-SkippedChoice 5 "Windows Update Download Store" "Skipped (-SkipWindowsUpdate flag passed)" }
        else { Write-SkippedChoice 5 "Windows Update Download Store" "None found / 0 B (Clean)" }
    }

    # 06. Delivery Optimization
    if ((Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue) -and (-not $SkipDeliveryOptimization) -and $totalDoBytes -gt 0) {
        $doDelivery = Ask-Choice 6 "Windows Delivery Optimization Cache" "Found $(Format-ByteSize $totalDoBytes) peer-to-peer Windows update distribution files" $true $catSystem
    } else {
        $doDelivery = $false
        if ($SkipDeliveryOptimization) { Write-SkippedChoice 6 "Windows Delivery Optimization Cache" "Skipped (-SkipDeliveryOptimization flag passed)" }
        elseif (-not (Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue)) { Write-SkippedChoice 6 "Windows Delivery Optimization Cache" "Skipped (Cmdlet not available)" }
        else { Write-SkippedChoice 6 "Windows Delivery Optimization Cache" "None found / 0 B (Clean)" }
    }
} else {
    $doTemp = $false
    $doShaders = $false
    $doRecycleBin = $false
    $doThumbnails = $false
    $doUpdates = $false
    $doDelivery = $false
}

# ============================================================================
# CATEGORY 2 - BROWSER CACHES
# ============================================================================
$chromePaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Code Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\GPUCache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Service Worker\CacheStorage"
)
$firefoxPaths = @(
    "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2",
    "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\startupCache"
)
$bravePaths = @(
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Cache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Code Cache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\GPUCache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Service Worker\CacheStorage"
)

$chromeMetrics = if (-not $SkipChrome) { Get-FolderMetrics $chromePaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$firefoxMetrics = if (-not $SkipFirefox) { Get-FolderMetrics $firefoxPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$braveMetrics = if (-not $SkipBrave) { Get-FolderMetrics $bravePaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }

$catBrowsersBytes = $chromeMetrics.Bytes + $firefoxMetrics.Bytes + $braveMetrics.Bytes

if ($SkipBrowsers) {
    Write-SkippedCategory "Browser Caches" "Skipped (-SkipBrowsers flag passed)"
    $catBrowsers = "Skip"
} elseif ($catBrowsersBytes -eq 0) {
    Write-SkippedCategory "Browser Caches" "None found / 0 B (Clean)"
    $catBrowsers = "Skip"
} else {
    $catBrowsers = Ask-Category "Browser Caches (Found $(Format-ByteSize $catBrowsersBytes))" "Google Chrome, Mozilla Firefox, Brave Browser" "All"
}

if ($catBrowsers -ne "Skip") {
    # 07. Google Chrome
    if (-not $SkipChrome -and $chromeMetrics.Bytes -gt 0) {
        $doChrome = Ask-Choice 7 "Google Chrome Web & Code Cache" "Found $($chromeMetrics.Formatted) cached web assets and compiled code caches across profiles" $true $catBrowsers
    } else {
        $doChrome = $false
        if ($SkipChrome) { Write-SkippedChoice 7 "Google Chrome Web & Code Cache" "Skipped (-SkipChrome flag passed)" }
        else { Write-SkippedChoice 7 "Google Chrome Web & Code Cache" "None found / 0 B (Clean)" }
    }

    # 08. Mozilla Firefox
    if (-not $SkipFirefox -and $firefoxMetrics.Bytes -gt 0) {
        $doFirefox = Ask-Choice 8 "Mozilla Firefox Web & Startup Cache" "Found $($firefoxMetrics.Formatted) offline cache2 files and startup cache across profiles" $true $catBrowsers
    } else {
        $doFirefox = $false
        if ($SkipFirefox) { Write-SkippedChoice 8 "Mozilla Firefox Web & Startup Cache" "Skipped (-SkipFirefox flag passed)" }
        else { Write-SkippedChoice 8 "Mozilla Firefox Web & Startup Cache" "None found / 0 B (Clean)" }
    }

    # 09. Brave Browser
    if (-not $SkipBrave -and $braveMetrics.Bytes -gt 0) {
        $doBrave = Ask-Choice 9 "Brave Browser Web & Code Cache" "Found $($braveMetrics.Formatted) cached web assets and compiled code caches across profiles" $true $catBrowsers
    } else {
        $doBrave = $false
        if ($SkipBrave) { Write-SkippedChoice 9 "Brave Browser Web & Code Cache" "Skipped (-SkipBrave flag passed)" }
        else { Write-SkippedChoice 9 "Brave Browser Web & Code Cache" "None found / 0 B (Clean)" }
    }
} else {
    $doChrome = $false
    $doFirefox = $false
    $doBrave = $false
}

# ============================================================================
# CATEGORY 3 - GAME LAUNCHER CACHES
# ============================================================================
$steamPaths = @(
    "$env:LOCALAPPDATA\Steam\htmlcache",
    "${env:ProgramFiles(x86)}\Steam\appcache\httpcache"
)
$epicPaths = @(
    "$env:LOCALAPPDATA\EpicGamesLauncher\Saved\webcache*"
)

$steamMetrics = if (-not $SkipSteam) { Get-FolderMetrics $steamPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$epicMetrics = if (-not $SkipEpic) { Get-FolderMetrics $epicPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }

$catGamesBytes = $steamMetrics.Bytes + $epicMetrics.Bytes

if ($SkipGames) {
    Write-SkippedCategory "Game Launcher Caches" "Skipped (-SkipGames flag passed)"
    $catGames = "Skip"
} elseif ($catGamesBytes -eq 0) {
    Write-SkippedCategory "Game Launcher Caches" "None found / 0 B (Clean)"
    $catGames = "Skip"
} else {
    $catGames = Ask-Category "Game Launcher Caches (Found $(Format-ByteSize $catGamesBytes))" "Steam web & HTTP cache, Epic Games Store web cache" "All"
}

if ($catGames -ne "Skip") {
    # 10. Steam Web & HTTP Cache
    if (-not $SkipSteam -and $steamMetrics.Bytes -gt 0) {
        $doSteam = Ask-Choice 10 "Steam Web & HTTP Cache" "Found $($steamMetrics.Formatted) launcher browser and HTTP network cache files" $true $catGames
    } else {
        $doSteam = $false
        if ($SkipSteam) { Write-SkippedChoice 10 "Steam Web & HTTP Cache" "Skipped (-SkipSteam flag passed)" }
        else { Write-SkippedChoice 10 "Steam Web & HTTP Cache" "None found / 0 B (Clean)" }
    }

    # 11. Epic Games Store Web Cache
    if (-not $SkipEpic -and $epicMetrics.Bytes -gt 0) {
        $doEpic = Ask-Choice 11 "Epic Games Store Web Cache" "Found $($epicMetrics.Formatted) store webcache assets and browser caches" $true $catGames
    } else {
        $doEpic = $false
        if ($SkipEpic) { Write-SkippedChoice 11 "Epic Games Store Web Cache" "Skipped (-SkipEpic flag passed)" }
        else { Write-SkippedChoice 11 "Epic Games Store Web Cache" "None found / 0 B (Clean)" }
    }
} else {
    $doSteam = $false
    $doEpic = $false
}

# ============================================================================
# CATEGORY 4 - APP CACHES (Media & Communication)
# ============================================================================
$spotifyPaths = @("$env:LOCALAPPDATA\Spotify\Storage")
$discordPaths = @(
    "$env:APPDATA\discord\Cache",
    "$env:APPDATA\discord\Code Cache"
)
$slackPaths = @(
    "$env:APPDATA\Slack\Cache",
    "$env:APPDATA\Slack\Code Cache",
    "$env:APPDATA\Slack\Service Worker\CacheStorage"
)
$teamsPaths = @(
    "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache",
    "$env:APPDATA\Microsoft\Teams\Cache",
    "$env:APPDATA\Microsoft\Teams\blob_storage",
    "$env:APPDATA\Microsoft\Teams\tmp"
)
$telegramPaths = @("$env:APPDATA\Telegram Desktop\tdata\user_data\media_cache")
$zoomPaths = @(
    "$env:APPDATA\Zoom\data",
    "$env:LOCALAPPDATA\Zoom\temp"
)

$spotifyMetrics = if (-not $SkipSpotify) { Get-FolderMetrics $spotifyPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$discordMetrics = if (-not $SkipDiscord) { Get-FolderMetrics $discordPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$slackMetrics = if (-not $SkipSlack) { Get-FolderMetrics $slackPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$teamsMetrics = if (-not $SkipTeams) { Get-FolderMetrics $teamsPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$telegramMetrics = if (-not $SkipTelegram) { Get-FolderMetrics $telegramPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$zoomMetrics = if (-not $SkipZoom) { Get-FolderMetrics $zoomPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }

$catAppsBytes = $spotifyMetrics.Bytes + $discordMetrics.Bytes + $slackMetrics.Bytes + $teamsMetrics.Bytes + $telegramMetrics.Bytes + $zoomMetrics.Bytes

if ($SkipMediaApps) {
    Write-SkippedCategory "App Caches" "Skipped (-SkipMediaApps flag passed)"
    $catApps = "Skip"
} elseif ($catAppsBytes -eq 0) {
    Write-SkippedCategory "App Caches" "None found / 0 B (Clean)"
    $catApps = "Skip"
} else {
    $catApps = Ask-Category "App Caches (Found $(Format-ByteSize $catAppsBytes))" "Spotify, Discord, Slack, Teams, Telegram, Zoom" "All"
}

if ($catApps -ne "Skip") {
    # 12. Spotify
    if (-not $SkipSpotify -and $spotifyMetrics.Bytes -gt 0) {
        $doSpotify = Ask-Choice 12 "Spotify Audio Storage Cache" "Found $($spotifyMetrics.Formatted) downloaded audio streams and offline assets" $true $catApps
    } else {
        $doSpotify = $false
        if ($SkipSpotify) { Write-SkippedChoice 12 "Spotify Audio Storage Cache" "Skipped (-SkipSpotify flag passed)" }
        else { Write-SkippedChoice 12 "Spotify Audio Storage Cache" "None found / 0 B (Clean)" }
    }

    # 13. Discord
    if (-not $SkipDiscord -and $discordMetrics.Bytes -gt 0) {
        $doDiscord = Ask-Choice 13 "Discord Web & Code Cache" "Found $($discordMetrics.Formatted) cached message media, avatars, and V8 code cache" $true $catApps
    } else {
        $doDiscord = $false
        if ($SkipDiscord) { Write-SkippedChoice 13 "Discord Web & Code Cache" "Skipped (-SkipDiscord flag passed)" }
        else { Write-SkippedChoice 13 "Discord Web & Code Cache" "None found / 0 B (Clean)" }
    }

    # 14. Slack
    if (-not $SkipSlack -and $slackMetrics.Bytes -gt 0) {
        $doSlack = Ask-Choice 14 "Slack Web & Code Cache" "Found $($slackMetrics.Formatted) workspace cached images, attachments, and code cache" $true $catApps
    } else {
        $doSlack = $false
        if ($SkipSlack) { Write-SkippedChoice 14 "Slack Web & Code Cache" "Skipped (-SkipSlack flag passed)" }
        else { Write-SkippedChoice 14 "Slack Web & Code Cache" "None found / 0 B (Clean)" }
    }

    # 15. Microsoft Teams
    if (-not $SkipTeams -and $teamsMetrics.Bytes -gt 0) {
        $doTeams = Ask-Choice 15 "Microsoft Teams (New & Classic) Cache" "Found $($teamsMetrics.Formatted) local cache, blob storage, and temporary files" $true $catApps
    } else {
        $doTeams = $false
        if ($SkipTeams) { Write-SkippedChoice 15 "Microsoft Teams (New & Classic) Cache" "Skipped (-SkipTeams flag passed)" }
        else { Write-SkippedChoice 15 "Microsoft Teams (New & Classic) Cache" "None found / 0 B (Clean)" }
    }

    # 16. Telegram
    if (-not $SkipTelegram -and $telegramMetrics.Bytes -gt 0) {
        $doTelegram = Ask-Choice 16 "Telegram Desktop Media Cache" "Found $($telegramMetrics.Formatted) downloaded images, voice notes, and media previews" $true $catApps
    } else {
        $doTelegram = $false
        if ($SkipTelegram) { Write-SkippedChoice 16 "Telegram Desktop Media Cache" "Skipped (-SkipTelegram flag passed)" }
        else { Write-SkippedChoice 16 "Telegram Desktop Media Cache" "None found / 0 B (Clean)" }
    }

    # 17. Zoom
    if (-not $SkipZoom -and $zoomMetrics.Bytes -gt 0) {
        $doZoom = Ask-Choice 17 "Zoom Meeting & Temp Cache" "Found $($zoomMetrics.Formatted) temporary meeting data and logs" $true $catApps
    } else {
        $doZoom = $false
        if ($SkipZoom) { Write-SkippedChoice 17 "Zoom Meeting & Temp Cache" "Skipped (-SkipZoom flag passed)" }
        else { Write-SkippedChoice 17 "Zoom Meeting & Temp Cache" "None found / 0 B (Clean)" }
    }
} else {
    $doSpotify = $false
    $doDiscord = $false
    $doSlack = $false
    $doTeams = $false
    $doTelegram = $false
    $doZoom = $false
}

# ============================================================================
# CATEGORY 5 - DEVELOPER TOOL CACHES
# ============================================================================
$pipPaths = @("$env:LOCALAPPDATA\pip\cache")
$vscodePaths = @(
    "$env:APPDATA\Code\Cache",
    "$env:APPDATA\Code\CachedData"
)
$npmPaths = @(
    "$env:LOCALAPPDATA\npm-cache",
    "$env:APPDATA\npm-cache"
)
$yarnPaths = @("$env:LOCALAPPDATA\Yarn\Cache")
$pnpmPaths = @("$env:LOCALAPPDATA\pnpm\store")
$nugetPaths = @("$env:LOCALAPPDATA\NuGet\v3-cache")
$gradlePaths = @("$env:USERPROFILE\.gradle\caches")
$cargoPaths = @("$env:USERPROFILE\.cargo\registry\cache")
$goPaths = @("$env:LOCALAPPDATA\go-build")

$pipMetrics = if (-not $SkipPip) { Get-FolderMetrics $pipPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$vscodeMetrics = if (-not $SkipVSCode) { Get-FolderMetrics $vscodePaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$npmMetrics = if (-not $SkipNpm) { Get-FolderMetrics $npmPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$yarnMetrics = if (-not $SkipYarn) { Get-FolderMetrics $yarnPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$pnpmMetrics = if (-not $SkipPnpm) { Get-FolderMetrics $pnpmPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$nugetMetrics = if (-not $SkipNuget) { Get-FolderMetrics $nugetPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$gradleMetrics = if (-not $SkipGradle) { Get-FolderMetrics $gradlePaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$cargoMetrics = if (-not $SkipCargo) { Get-FolderMetrics $cargoPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$goMetrics = if (-not $SkipGo) { Get-FolderMetrics $goPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }

$catDevBytes = $pipMetrics.Bytes + $vscodeMetrics.Bytes + $npmMetrics.Bytes + $yarnMetrics.Bytes + $pnpmMetrics.Bytes + $nugetMetrics.Bytes + $gradleMetrics.Bytes + $cargoMetrics.Bytes + $goMetrics.Bytes

if ($SkipDevCaches) {
    Write-SkippedCategory "Developer Tool Caches" "Skipped (-SkipDevCaches flag passed)"
    $catDev = "Skip"
} elseif ($catDevBytes -eq 0) {
    Write-SkippedCategory "Developer Tool Caches" "None found / 0 B (Clean)"
    $catDev = "Skip"
} else {
    $catDev = Ask-Category "Developer Tool Caches (Found $(Format-ByteSize $catDevBytes))" "Pip, VS Code, NPM, Yarn, pnpm, NuGet, Gradle, Cargo, Go" "All"
}

if ($catDev -ne "Skip") {
    # 18. Python / Pip
    if (-not $SkipPip -and $pipMetrics.Bytes -gt 0) {
        $doPip = Ask-Choice 18 "Python / Pip Package Cache" "Found $($pipMetrics.Formatted) downloaded wheel archives and HTTP caches" $true $catDev
    } else {
        $doPip = $false
        if ($SkipPip) { Write-SkippedChoice 18 "Python / Pip Package Cache" "Skipped (-SkipPip flag passed)" }
        else { Write-SkippedChoice 18 "Python / Pip Package Cache" "None found / 0 B (Clean)" }
    }

    # 19. Visual Studio Code
    if (-not $SkipVSCode -and $vscodeMetrics.Bytes -gt 0) {
        $doVSCode = Ask-Choice 19 "Visual Studio Code Cache" "Found $($vscodeMetrics.Formatted) editor web cache and compiled V8 data cache" $true $catDev
    } else {
        $doVSCode = $false
        if ($SkipVSCode) { Write-SkippedChoice 19 "Visual Studio Code Cache" "Skipped (-SkipVSCode flag passed)" }
        else { Write-SkippedChoice 19 "Visual Studio Code Cache" "None found / 0 B (Clean)" }
    }

    # 20. NPM
    if (-not $SkipNpm -and $npmMetrics.Bytes -gt 0) {
        $doNpm = Ask-Choice 20 "NPM Package Cache" "Found $($npmMetrics.Formatted) cached tarballs and package metadata" $true $catDev
    } else {
        $doNpm = $false
        if ($SkipNpm) { Write-SkippedChoice 20 "NPM Package Cache" "Skipped (-SkipNpm flag passed)" }
        else { Write-SkippedChoice 20 "NPM Package Cache" "None found / 0 B (Clean)" }
    }

    # 21. Yarn
    if (-not $SkipYarn -and $yarnMetrics.Bytes -gt 0) {
        $doYarn = Ask-Choice 21 "Yarn Package Cache" "Found $($yarnMetrics.Formatted) global Yarn cached packages" $true $catDev
    } else {
        $doYarn = $false
        if ($SkipYarn) { Write-SkippedChoice 21 "Yarn Package Cache" "Skipped (-SkipYarn flag passed)" }
        else { Write-SkippedChoice 21 "Yarn Package Cache" "None found / 0 B (Clean)" }
    }

    # 22. pnpm
    if (-not $SkipPnpm -and $pnpmMetrics.Bytes -gt 0) {
        $doPnpm = Ask-Choice 22 "pnpm Store Cache" "Found $($pnpmMetrics.Formatted) content-addressable package files" $true $catDev
    } else {
        $doPnpm = $false
        if ($SkipPnpm) { Write-SkippedChoice 22 "pnpm Store Cache" "Skipped (-SkipPnpm flag passed)" }
        else { Write-SkippedChoice 22 "pnpm Store Cache" "None found / 0 B (Clean)" }
    }

    # 23. NuGet (.NET)
    if (-not $SkipNuget -and $nugetMetrics.Bytes -gt 0) {
        $doNuget = Ask-Choice 23 "NuGet (.NET) Package Cache" "Found $($nugetMetrics.Formatted) downloaded nupkg files in v3-cache" $true $catDev
    } else {
        $doNuget = $false
        if ($SkipNuget) { Write-SkippedChoice 23 "NuGet (.NET) Package Cache" "Skipped (-SkipNuget flag passed)" }
        else { Write-SkippedChoice 23 "NuGet (.NET) Package Cache" "None found / 0 B (Clean)" }
    }

    # 24. Gradle
    if (-not $SkipGradle -and $gradleMetrics.Bytes -gt 0) {
        $doGradle = Ask-Choice 24 "Gradle Build Cache" "Found $($gradleMetrics.Formatted) compiled jars, plugins, and dependency caches" $true $catDev
    } else {
        $doGradle = $false
        if ($SkipGradle) { Write-SkippedChoice 24 "Gradle Build Cache" "Skipped (-SkipGradle flag passed)" }
        else { Write-SkippedChoice 24 "Gradle Build Cache" "None found / 0 B (Clean)" }
    }

    # 25. Cargo (Rust)
    if (-not $SkipCargo -and $cargoMetrics.Bytes -gt 0) {
        $doCargo = Ask-Choice 25 "Cargo (Rust) Registry Cache" "Found $($cargoMetrics.Formatted) downloaded .crate archives in registry" $true $catDev
    } else {
        $doCargo = $false
        if ($SkipCargo) { Write-SkippedChoice 25 "Cargo (Rust) Registry Cache" "Skipped (-SkipCargo flag passed)" }
        else { Write-SkippedChoice 25 "Cargo (Rust) Registry Cache" "None found / 0 B (Clean)" }
    }

    # 26. Go
    if (-not $SkipGo -and $goMetrics.Bytes -gt 0) {
        $doGo = Ask-Choice 26 "Go Build Cache" "Found $($goMetrics.Formatted) compiled build artifacts in go-build" $true $catDev
    } else {
        $doGo = $false
        if ($SkipGo) { Write-SkippedChoice 26 "Go Build Cache" "Skipped (-SkipGo flag passed)" }
        else { Write-SkippedChoice 26 "Go Build Cache" "None found / 0 B (Clean)" }
    }
} else {
    $doPip = $false
    $doVSCode = $false
    $doNpm = $false
    $doYarn = $false
    $doPnpm = $false
    $doNuget = $false
    $doGradle = $false
    $doCargo = $false
    $doGo = $false
}

# ============================================================================
# CATEGORY 6 - CREATIVE SUITE CACHES
# ============================================================================
$adobePaths = @(
    "$env:APPDATA\Adobe\Common\Media Cache Files",
    "$env:APPDATA\Adobe\Common\Media Cache"
)
$davinciPaths = @("$env:USERPROFILE\Videos\CacheClip")

$adobeMetrics = if (-not $SkipAdobe) { Get-FolderMetrics $adobePaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$davinciMetrics = if (-not $SkipDaVinci) { Get-FolderMetrics $davinciPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }

$catCreativeBytes = $adobeMetrics.Bytes + $davinciMetrics.Bytes

if ($SkipCreativeApps) {
    Write-SkippedCategory "Creative Suite Caches" "Skipped (-SkipCreativeApps flag passed)"
    $catCreative = "Skip"
} elseif ($catCreativeBytes -eq 0) {
    Write-SkippedCategory "Creative Suite Caches" "None found / 0 B (Clean)"
    $catCreative = "Skip"
} else {
    $catCreative = Ask-Category "Creative Suite Caches (Found $(Format-ByteSize $catCreativeBytes))" "Adobe Common Media Cache, DaVinci Resolve render cache" "All"
}

if ($catCreative -ne "Skip") {
    # 27. Adobe Common Media Cache
    if (-not $SkipAdobe -and $adobeMetrics.Bytes -gt 0) {
        $doAdobe = Ask-Choice 27 "Adobe Common Media Cache" "Found $($adobeMetrics.Formatted) conformed audio peaks (.cfa/.pek) and video media cache" $true $catCreative
    } else {
        $doAdobe = $false
        if ($SkipAdobe) { Write-SkippedChoice 27 "Adobe Common Media Cache" "Skipped (-SkipAdobe flag passed)" }
        else { Write-SkippedChoice 27 "Adobe Common Media Cache" "None found / 0 B (Clean)" }
    }

    # 28. DaVinci Resolve
    if (-not $SkipDaVinci -and $davinciMetrics.Bytes -gt 0) {
        $doDaVinci = Ask-Choice 28 "DaVinci Resolve Render Cache" "Found $($davinciMetrics.Formatted) CacheClip optimized media and timeline scratch renders" $true $catCreative
    } else {
        $doDaVinci = $false
        if ($SkipDaVinci) { Write-SkippedChoice 28 "DaVinci Resolve Render Cache" "Skipped (-SkipDaVinci flag passed)" }
        else { Write-SkippedChoice 28 "DaVinci Resolve Render Cache" "None found / 0 B (Clean)" }
    }
} else {
    $doAdobe = $false
    $doDaVinci = $false
}

# ============================================================================
# CATEGORY 7 - SYSTEM ADVANCED
# ============================================================================
$hasShadows = $false
$shadowCount = 0
if ($isAdmin -and (-not $SkipRestorePoints)) {
    $shadowOutput = vssadmin list shadows 2>&1
    $hasShadows = ($shadowOutput -match 'Shadow Copy ID:')
    if ($hasShadows) {
        $shadowCount = ($shadowOutput | Select-String 'Shadow Copy ID:').Count
    }
}

$upgradePaths = @("$sysDrive\Windows.old", "$sysDrive\`$WINDOWS.~BT", "$sysDrive\`$WINDOWS.~WS", "$sysDrive\`$GetCurrent")
$foundUpgradePaths = @($upgradePaths | Where-Object { Test-Path -LiteralPath $_ })
$upgradeMetrics = if ($foundUpgradePaths.Count -gt 0 -and (-not $SkipUpgradeFolders)) { Get-FolderMetrics $foundUpgradePaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }

$crashPaths = @(
    "$sysRoot\MEMORY.DMP",
    "$sysRoot\Minidump",
    "$sysRoot\LiveKernelReports",
    "$env:LOCALAPPDATA\CrashDumps"
)
$crashMetrics = if (-not $SkipCrashDumps) { Get-FolderMetrics $crashPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }

$cbsPaths = @(
    "$sysRoot\Logs\CBS\CbsPersist_*",
    "$sysRoot\Panther",
    "$env:ProgramData\Microsoft\Diagnosis\ETLLogs\*.etl"
)
$cbsFolderMetrics = if (-not $SkipCBSLogs) { Get-FolderMetrics $cbsPaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
$cbsLogBytes = $cbsFolderMetrics.Bytes
if ((-not $SkipCBSLogs) -and (Test-Path -LiteralPath "$sysRoot\Logs\DISM\dism.log")) {
    try { $cbsLogBytes += (Get-Item -LiteralPath "$sysRoot\Logs\DISM\dism.log" -Force -ErrorAction SilentlyContinue).Length } catch { }
}

$hiberPath = "$sysDrive\hiberfil.sys"
$hasHiberfil = Test-Path -LiteralPath $hiberPath
$hiberSize = [int64]0
if ($isAdmin -and $hasHiberfil -and (-not $SkipHiberfil)) {
    try { $hiberSize = (Get-Item -LiteralPath $hiberPath -Force -ErrorAction Stop).Length } catch { }
}

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
}

$searchService = Get-Service -Name WSearch -ErrorAction SilentlyContinue
$searchMetrics = if ($isAdmin -and ($null -ne $searchService) -and (-not $SkipSearchIndex)) {
    Get-FolderMetrics @(
        "$env:ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb",
        "$env:ProgramData\Microsoft\Search\Data\Applications\Windows\Projects\SystemIndex\Indexer"
    )
} else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }

$hasAnyAdvanced = $hasShadows -or ($upgradeMetrics.Bytes -gt 0) -or ($crashMetrics.Bytes -gt 0) -or ($cbsLogBytes -gt 0) -or ($hiberSize -gt 0) -or ($supersededDrivers.Count -gt 0) -or ($searchMetrics.Bytes -gt 0) -or ($isAdmin -and (-not $SkipDism))

if ($SkipAdvanced) {
    Write-SkippedCategory "System Advanced" "Skipped (-SkipAdvanced flag passed)"
    $catAdvanced = "Skip"
} elseif (-not $isAdmin) {
    Write-SkippedCategory "System Advanced" "Skipped (Requires Administrator privileges)"
    $catAdvanced = "Skip"
} elseif (-not $hasAnyAdvanced) {
    Write-SkippedCategory "System Advanced" "None found / 0 B (Clean)"
    $catAdvanced = "Skip"
} else {
    $catAdvanced = Ask-Category "System Advanced" "Shadow copies, upgrade folders, crash dumps, logs, hibernate, OEM drivers, search index, WinSxS" "Individual"
}

if ($catAdvanced -ne "Skip") {
    # 29. Volume Shadow Copies
    if ($isAdmin -and (-not $SkipRestorePoints) -and $hasShadows) {
        $doShadows = Ask-Choice 29 "Oldest Volume Shadow Copies (vssadmin)" "Found $shadowCount shadow copies. Purges old snapshots via vssadmin, keeps newest" $true $catAdvanced
    } else {
        $doShadows = $false
        if (-not $isAdmin) { Write-SkippedChoice 29 "System Restore Points" "Skipped (Requires Administrator privileges)" }
        elseif ($SkipRestorePoints) { Write-SkippedChoice 29 "System Restore Points" "Skipped (-SkipRestorePoints flag passed)" }
        else { Write-SkippedChoice 29 "Oldest Volume Shadow Copies (vssadmin)" "None found / 0 copies (Clean)" }
    }

    # 30. Leftover Windows Upgrade Folders
    if ($foundUpgradePaths.Count -gt 0 -and $upgradeMetrics.Bytes -gt 0 -and (-not $SkipUpgradeFolders)) {
        $foundList = $foundUpgradePaths -join ", "
        $doUpgrade = Ask-Choice 30 "Leftover Windows Upgrade Folders" "Found $($upgradeMetrics.Formatted) across: $foundList" $true $catAdvanced
    } else {
        $doUpgrade = $false
        if ($SkipUpgradeFolders) { Write-SkippedChoice 30 "Leftover Windows Upgrade Folders" "Skipped (-SkipUpgradeFolders flag passed)" }
        else { Write-SkippedChoice 30 "Leftover Windows Upgrade Folders" "None found / 0 B (Clean)" }
    }

    # 31. Kernel & User Crash Dumps
    if ((-not $SkipCrashDumps) -and $crashMetrics.Bytes -gt 0) {
        $doCrashDumps = Ask-Choice 31 "Kernel & User Crash Dump Files" "Found $($crashMetrics.Formatted) in crash dump files (MEMORY.DMP, CrashDumps)" $true $catAdvanced
    } else {
        $doCrashDumps = $false
        if ($SkipCrashDumps) { Write-SkippedChoice 31 "Kernel & User Crash Dump Files" "Skipped (-SkipCrashDumps flag passed)" }
        else { Write-SkippedChoice 31 "Kernel & User Crash Dump Files" "None found / 0 B (Clean)" }
    }

    # 32. CBS, DISM & Panther Logs
    if ($isAdmin -and (-not $SkipCBSLogs) -and $cbsLogBytes -gt 0) {
        $cbsFormatted = Format-ByteSize $cbsLogBytes
        $doCBSLogs = Ask-Choice 32 "CBS, DISM & Panther Log Archives" "Found $cbsFormatted in CBS persist archives, Panther logs, and DISM traces" $true $catAdvanced
    } else {
        $doCBSLogs = $false
        if (-not $isAdmin) { Write-SkippedChoice 32 "CBS, DISM & Panther Log Archives" "Skipped (Requires Administrator privileges)" }
        elseif ($SkipCBSLogs) { Write-SkippedChoice 32 "CBS, DISM & Panther Log Archives" "Skipped (-SkipCBSLogs flag passed)" }
        else { Write-SkippedChoice 32 "CBS, DISM & Panther Log Archives" "None found / 0 B (Clean)" }
    }

    # 33. Hibernation file
    if ($isAdmin -and (-not $SkipHiberfil) -and $hasHiberfil -and $hiberSize -gt 0) {
        $hiberFormatted = Format-ByteSize $hiberSize
        $doHiberfil = Ask-Choice 33 "Windows Hibernation File (hiberfil.sys)" "Found $hiberPath ($hiberFormatted). Disables Hibernate to reclaim space (Sleep unaffected)" $true $catAdvanced
    } else {
        $doHiberfil = $false
        if (-not $isAdmin) { Write-SkippedChoice 33 "Windows Hibernation (hiberfil.sys)" "Skipped (Requires Administrator privileges)" }
        elseif ($SkipHiberfil) { Write-SkippedChoice 33 "Windows Hibernation (hiberfil.sys)" "Skipped (-SkipHiberfil flag passed)" }
        else { Write-SkippedChoice 33 "Windows Hibernation (hiberfil.sys)" "Already disabled / None found (Clean)" }
    }

    # 34. Obsolete OEM drivers
    if ($isAdmin -and (-not $SkipDrivers) -and $supersededDrivers.Count -gt 0) {
        $doDrivers = Ask-Choice 34 "Obsolete OEM Hardware Drivers" "Found $($supersededDrivers.Count) superseded driver packages in DriverStore" $true $catAdvanced
    } else {
        $doDrivers = $false
        if (-not $isAdmin) { Write-SkippedChoice 34 "Obsolete OEM Hardware Drivers" "Skipped (Requires Administrator privileges)" }
        elseif ($SkipDrivers) { Write-SkippedChoice 34 "Obsolete OEM Hardware Drivers" "Skipped (-SkipDrivers flag passed)" }
        else { Write-SkippedChoice 34 "Obsolete OEM Hardware Drivers" "None found / 0 drivers (Clean)" }
    }

    # 35. Windows Search index
    if ($isAdmin -and ($null -ne $searchService) -and (-not $SkipSearchIndex) -and $searchMetrics.Bytes -gt 0) {
        $doSearchIndex = Ask-Choice 35 "Windows Search Index Database" "Found $($searchMetrics.Formatted) in search database (resets and compacts in background)" $true $catAdvanced
    } else {
        $doSearchIndex = $false
        if (-not $isAdmin) { Write-SkippedChoice 35 "Windows Search Index Database" "Skipped (Requires Administrator privileges)" }
        elseif ($SkipSearchIndex) { Write-SkippedChoice 35 "Windows Search Index Database" "Skipped (-SkipSearchIndex flag passed)" }
        elseif ($null -eq $searchService) { Write-SkippedChoice 35 "Windows Search Index Database" "Service not present (Clean)" }
        else { Write-SkippedChoice 35 "Windows Search Index Database" "None found / 0 B (Clean)" }
    }

    # 36. WinSxS ResetBase
    if ($isAdmin -and (-not $SkipDism)) {
        $doDism = Ask-Choice 36 "WinSxS Component Store ResetBase" "Deep WinSxS component purge (Takes 2-5 min, prevents old update rollbacks)" $false $catAdvanced
    } else {
        $doDism = $false
        if (-not $isAdmin) { Write-SkippedChoice 36 "WinSxS Component Store ResetBase" "Skipped (Requires Administrator privileges)" }
        else { Write-SkippedChoice 36 "WinSxS Component Store ResetBase" "Skipped (-SkipDism flag passed)" }
    }
} else {
    $doShadows = $false
    $doUpgrade = $false
    $doCrashDumps = $false
    $doCBSLogs = $false
    $doHiberfil = $false
    $doDrivers = $false
    $doSearchIndex = $false
    $doDism = $false
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

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 1 - SYSTEM CACHES
# -----------------------------------------------------------------------------
if ($doTemp -or $doShaders -or $doRecycleBin -or $doThumbnails -or $doUpdates -or $doDelivery) {
    Write-Host "  --- SYSTEM CACHES ---" -ForegroundColor DarkCyan
    Write-Host ""

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
} else {
    Write-SkippedExecution "System Caches"
}

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 2 - BROWSER CACHES
# -----------------------------------------------------------------------------
if ($doChrome -or $doFirefox -or $doBrave) {
    Write-Host "  --- BROWSER CACHES ---" -ForegroundColor DarkCyan
    Write-Host ""

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
} else {
    Write-SkippedExecution "Browser Caches"
}

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 3 - GAME LAUNCHER CACHES
# -----------------------------------------------------------------------------
if ($doSteam -or $doEpic) {
    Write-Host "  --- GAME LAUNCHER CACHES ---" -ForegroundColor DarkCyan
    Write-Host ""

    # Execution: 10. Steam
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

    # Execution: 11. Epic Games Store
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
} else {
    Write-SkippedExecution "Game Launcher Caches"
}

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 4 - APP CACHES
# -----------------------------------------------------------------------------
if ($doSpotify -or $doDiscord -or $doSlack -or $doTeams -or $doTelegram -or $doZoom) {
    Write-Host "  --- APP CACHES ---" -ForegroundColor DarkCyan
    Write-Host ""

    # Execution: 12. Spotify
    if ($doSpotify) {
        Invoke-Purge "Spotify Audio Storage Cache" {
            if (Test-Path -LiteralPath "$env:LOCALAPPDATA\Spotify\Storage") {
                Remove-Item -Path "$env:LOCALAPPDATA\Spotify\Storage\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-Host "               Purged Spotify streaming audio storage cache." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Spotify Audio Storage Cache"
    }

    # Execution: 13. Discord
    if ($doDiscord) {
        Invoke-Purge "Discord Web & Code Cache" {
            foreach ($dp in @("$env:APPDATA\discord\Cache", "$env:APPDATA\discord\Code Cache")) {
                if (Test-Path -LiteralPath $dp) {
                    Remove-Item -Path "$dp\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Host "               Purged Discord web cache and code cache." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Discord Web & Code Cache"
    }

    # Execution: 14. Slack
    if ($doSlack) {
        Invoke-Purge "Slack Web & Code Cache" {
            foreach ($sp in @("$env:APPDATA\Slack\Cache", "$env:APPDATA\Slack\Code Cache", "$env:APPDATA\Slack\Service Worker\CacheStorage")) {
                if (Test-Path -LiteralPath $sp) {
                    Remove-Item -Path "$sp\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Host "               Purged Slack web cache, code cache, and service worker cache." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Slack Web & Code Cache"
    }

    # Execution: 15. Microsoft Teams
    if ($doTeams) {
        Invoke-Purge "Microsoft Teams (New & Classic) Cache" {
            foreach ($tp in $teamsPaths) {
                if (Test-Path -LiteralPath $tp) {
                    Remove-Item -Path "$tp\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Host "               Purged Microsoft Teams local cache, blob storage, and temporary files." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Microsoft Teams (New & Classic) Cache"
    }

    # Execution: 16. Telegram Desktop
    if ($doTelegram) {
        Invoke-Purge "Telegram Desktop Media Cache" {
            if (Test-Path -LiteralPath "$env:APPDATA\Telegram Desktop\tdata\user_data\media_cache") {
                Remove-Item -Path "$env:APPDATA\Telegram Desktop\tdata\user_data\media_cache\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-Host "               Purged Telegram Desktop user media cache." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Telegram Desktop Media Cache"
    }

    # Execution: 17. Zoom
    if ($doZoom) {
        Invoke-Purge "Zoom Meeting & Temp Cache" {
            foreach ($zp in $zoomPaths) {
                if (Test-Path -LiteralPath $zp) {
                    Remove-Item -Path "$zp\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Host "               Purged Zoom meeting data cache and temporary files." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Zoom Meeting & Temp Cache"
    }
} else {
    Write-SkippedExecution "App Caches"
}

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 5 - DEVELOPER TOOL CACHES
# -----------------------------------------------------------------------------
if ($doPip -or $doVSCode -or $doNpm -or $doYarn -or $doPnpm -or $doNuget -or $doGradle -or $doCargo -or $doGo) {
    Write-Host "  --- DEVELOPER TOOL CACHES ---" -ForegroundColor DarkCyan
    Write-Host ""

    # Execution: 18. Python / Pip
    if ($doPip) {
        Invoke-Purge "Python / Pip Package Cache" {
            if (Get-Command pip -ErrorAction SilentlyContinue) {
                $null = pip cache purge 2>&1
            }
            if (Test-Path -LiteralPath "$env:LOCALAPPDATA\pip\cache") {
                Remove-Item -Path "$env:LOCALAPPDATA\pip\cache\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-Host "               Purged Python pip wheel download and HTTP cache." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Python / Pip Package Cache"
    }

    # Execution: 19. Visual Studio Code
    if ($doVSCode) {
        Invoke-Purge "Visual Studio Code Cache" {
            foreach ($vp in $vscodePaths) {
                if (Test-Path -LiteralPath $vp) {
                    Remove-Item -Path "$vp\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Host "               Purged Visual Studio Code web cache and compiled V8 data cache." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Visual Studio Code Cache"
    }

    # Execution: 20. NPM
    if ($doNpm) {
        Invoke-Purge "NPM Package Cache" {
            if (Get-Command npm -ErrorAction SilentlyContinue) {
                $null = npm cache clean --force 2>&1
            }
            foreach ($np in $npmPaths) {
                if (Test-Path -LiteralPath $np) {
                    Remove-Item -Path "$np\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Host "               Purged NPM global cache files." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "NPM Package Cache"
    }

    # Execution: 21. Yarn
    if ($doYarn) {
        Invoke-Purge "Yarn Package Cache" {
            if (Get-Command yarn -ErrorAction SilentlyContinue) {
                $null = yarn cache clean 2>&1
            }
            if (Test-Path -LiteralPath "$env:LOCALAPPDATA\Yarn\Cache") {
                Remove-Item -Path "$env:LOCALAPPDATA\Yarn\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-Host "               Purged Yarn package cache." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Yarn Package Cache"
    }

    # Execution: 22. pnpm
    if ($doPnpm) {
        Invoke-Purge "pnpm Store Cache" {
            if (Test-Path -LiteralPath "$env:LOCALAPPDATA\pnpm\store") {
                Remove-Item -Path "$env:LOCALAPPDATA\pnpm\store\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-Host "               Purged pnpm content-addressable store cache." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "pnpm Store Cache"
    }

    # Execution: 23. NuGet (.NET)
    if ($doNuget) {
        Invoke-Purge "NuGet (.NET) Package Cache" {
            if (Get-Command dotnet -ErrorAction SilentlyContinue) {
                $null = dotnet nuget locals all --clear 2>&1
            }
            if (Test-Path -LiteralPath "$env:LOCALAPPDATA\NuGet\v3-cache") {
                Remove-Item -Path "$env:LOCALAPPDATA\NuGet\v3-cache\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-Host "               Purged NuGet v3 local cache." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "NuGet (.NET) Package Cache"
    }

    # Execution: 24. Gradle
    if ($doGradle) {
        Invoke-Purge "Gradle Build Cache" {
            if (Test-Path -LiteralPath "$env:USERPROFILE\.gradle\caches") {
                Remove-Item -Path "$env:USERPROFILE\.gradle\caches\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-Host "               Purged Gradle build caches." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Gradle Build Cache"
    }

    # Execution: 25. Cargo (Rust)
    if ($doCargo) {
        Invoke-Purge "Cargo (Rust) Registry Cache" {
            if (Test-Path -LiteralPath "$env:USERPROFILE\.cargo\registry\cache") {
                Remove-Item -Path "$env:USERPROFILE\.cargo\registry\cache\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-Host "               Purged Cargo (Rust) registry package cache." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Cargo (Rust) Registry Cache"
    }

    # Execution: 26. Go
    if ($doGo) {
        Invoke-Purge "Go Build Cache" {
            if (Get-Command go -ErrorAction SilentlyContinue) {
                $null = go clean -cache 2>&1
            }
            if (Test-Path -LiteralPath "$env:LOCALAPPDATA\go-build") {
                Remove-Item -Path "$env:LOCALAPPDATA\go-build\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-Host "               Purged Go compiler build cache." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Go Build Cache"
    }
} else {
    Write-SkippedExecution "Developer Tool Caches"
}

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 6 - CREATIVE SUITE CACHES
# -----------------------------------------------------------------------------
if ($doAdobe -or $doDaVinci) {
    Write-Host "  --- CREATIVE SUITE CACHES ---" -ForegroundColor DarkCyan
    Write-Host ""

    # Execution: 27. Adobe Common Media Cache
    if ($doAdobe) {
        Invoke-Purge "Adobe Common Media Cache" {
            foreach ($cp in $adobePaths) {
                if (Test-Path -LiteralPath $cp) {
                    Remove-Item -Path "$cp\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Host "               Purged Adobe Premiere / After Effects Media Cache files." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Adobe Common Media Cache"
    }

    # Execution: 28. DaVinci Resolve Render Cache
    if ($doDaVinci) {
        Invoke-Purge "DaVinci Resolve Render Cache" {
            if (Test-Path -LiteralPath "$env:USERPROFILE\Videos\CacheClip") {
                Remove-Item -Path "$env:USERPROFILE\Videos\CacheClip\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-Host "               Purged DaVinci Resolve CacheClip scratch and render cache files." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "DaVinci Resolve Render Cache"
    }
} else {
    Write-SkippedExecution "Creative Suite Caches"
}

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 7 - SYSTEM ADVANCED
# -----------------------------------------------------------------------------
if ($doShadows -or $doUpgrade -or $doCrashDumps -or $doCBSLogs -or $doHiberfil -or $doDrivers -or $doSearchIndex -or $doDism) {
    Write-Host "  --- SYSTEM ADVANCED ---" -ForegroundColor DarkCyan
    Write-Host ""

    # Execution: 29. Shadow Copies
    if ($doShadows -and $isAdmin) {
        Invoke-Purge "Oldest Volume Shadow Copies (vssadmin)" {
            $null = vssadmin delete shadows /for=$sysDrive /oldest /quiet 2>&1
            Write-Host "               Purged oldest shadow copies from $sysDrive (kept newest)." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Oldest Volume Shadow Copies (vssadmin)"
    }

    # Execution: 30. Upgrade Folders
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

    # Execution: 31. Crash Dumps
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

    # Execution: 32. CBS & Servicing Logs
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

    # Execution: 33. Hibernation File
    if ($doHiberfil -and $isAdmin) {
        Invoke-Purge "Windows Hibernation File (hiberfil.sys)" {
            $null = powercfg -h off 2>&1
            Write-Host "               Disabled hibernation via powercfg and purged $hiberPath." -ForegroundColor DarkGray
        }
    } else {
        Write-SkippedExecution "Windows Hibernation File (hiberfil.sys)"
    }

    # Execution: 34. Obsolete OEM Drivers
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

    # Execution: 35. Windows Search Index
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

    # Execution: 36. WinSxS ResetBase
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
} else {
    Write-SkippedExecution "System Advanced"
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
