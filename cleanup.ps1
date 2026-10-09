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

    Each category prompts: [A]ll / [I]ndividual / [S]kip
      - [A]ll: Selects all discovered targets in the category at once.
      - [I]ndividual: Prompts for each target in the category one by one.
      - [S]kip: Skips the entire category.
    Targets with 0 bytes are automatically skipped.
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
$catSystem = if (-not $SkipSystem) {
    Ask-Category "System Caches" "Temp dirs, GPU shaders, Recycle Bin, thumbnails, Windows Update, Delivery Optimization" "All"
} else { "Skip" }

# 01. Temp files & Service Profiles
$tempPaths = @(
    $env:TEMP,
    "$sysRoot\Temp",
    "$sysRoot\ServiceProfiles\NetworkService\AppData\Local\Temp",
    "$sysRoot\ServiceProfiles\LocalService\AppData\Local\Temp"
)
if ($catSystem -ne "Skip" -and (-not $SkipTemp)) {
    $tempMetrics = Get-FolderMetrics $tempPaths
    if ($tempMetrics.Bytes -gt 0) {
        $doTemp = Ask-Choice 1 "User & Windows Temp Directories" "Found $($tempMetrics.Formatted) disposable temporary caches in %TEMP% and $sysRoot\Temp" $true $catSystem
    } else {
        $doTemp = $false
        Write-SkippedChoice 1 "User & Windows Temp Directories" "None found / 0 B (Clean)"
    }
} else {
    $doTemp = $false
    if ($SkipTemp) {
        Write-SkippedChoice 1 "User & Windows Temp Directories" "Skipped (-SkipTemp flag passed)"
    } else {
        Write-SkippedChoice 1 "User & Windows Temp Directories" "Skipped (System category skipped)"
    }
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
if ($catSystem -ne "Skip" -and (-not $SkipShaders)) {
    $shaderMetrics = Get-FolderMetrics $shaderPaths
    if ($shaderMetrics.Bytes -gt 0) {
        $doShaders = Ask-Choice 2 "DirectX, GPU Shaders & Error Reporting Logs" "Found $($shaderMetrics.Formatted) shaders (DirectX, NVIDIA, AMD, Intel) and WER archives" $true $catSystem
    } else {
        $doShaders = $false
        Write-SkippedChoice 2 "DirectX, GPU Shaders & Error Reporting Logs" "None found / 0 B (Clean)"
    }
} else {
    $doShaders = $false
    if ($SkipShaders) {
        Write-SkippedChoice 2 "DirectX, GPU Shaders & Error Reporting Logs" "Skipped (-SkipShaders flag passed)"
    } else {
        Write-SkippedChoice 2 "DirectX, GPU Shaders & Error Reporting Logs" "Skipped (System category skipped)"
    }
}

# 03. Windows Recycle Bin
if ($catSystem -ne "Skip" -and (-not $SkipRecycleBin)) {
    $recyclePaths = @("$sysDrive\`$Recycle.Bin")
    $recycleMetrics = Get-FolderMetrics $recyclePaths
    if ($recycleMetrics.Bytes -gt 0) {
        $doRecycleBin = Ask-Choice 3 "Windows Recycle Bin" "Found $($recycleMetrics.Formatted) discarded files across drive bins" $true $catSystem
    } else {
        $doRecycleBin = $false
        Write-SkippedChoice 3 "Windows Recycle Bin" "None found / 0 B (Clean)"
    }
} else {
    $doRecycleBin = $false
    if ($SkipRecycleBin) {
        Write-SkippedChoice 3 "Windows Recycle Bin" "Skipped (-SkipRecycleBin flag passed)"
    } else {
        Write-SkippedChoice 3 "Windows Recycle Bin" "Skipped (System category skipped)"
    }
}

# 04. Windows Explorer Thumbnail & Icon Caches
if ($catSystem -ne "Skip" -and (-not $SkipThumbnails)) {
    $thumbPaths = @(
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db",
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db",
        "$env:LOCALAPPDATA\IconCache.db"
    )
    $thumbMetrics = Get-FolderMetrics $thumbPaths
    if ($thumbMetrics.Bytes -gt 0) {
        $doThumbnails = Ask-Choice 4 "Explorer Thumbnail & Icon Caches" "Found $($thumbMetrics.Formatted) cached Explorer thumbnail databases (thumbcache_*.db)" $true $catSystem
    } else {
        $doThumbnails = $false
        Write-SkippedChoice 4 "Explorer Thumbnail & Icon Caches" "None found / 0 B (Clean)"
    }
} else {
    $doThumbnails = $false
    if ($SkipThumbnails) {
        Write-SkippedChoice 4 "Explorer Thumbnail & Icon Caches" "Skipped (-SkipThumbnails flag passed)"
    } else {
        Write-SkippedChoice 4 "Explorer Thumbnail & Icon Caches" "Skipped (System category skipped)"
    }
}

# 05. Windows Update Store
if ($catSystem -ne "Skip" -and $isAdmin -and (-not $SkipWindowsUpdate)) {
    $updateMetrics = Get-FolderMetrics @("$sysRoot\SoftwareDistribution\Download")
    if ($updateMetrics.Bytes -gt 0) {
        $doUpdates = Ask-Choice 5 "Windows Update Download Store" "Found $($updateMetrics.Formatted) staged packages in SoftwareDistribution\Download" $true $catSystem
    } else {
        $doUpdates = $false
        Write-SkippedChoice 5 "Windows Update Download Store" "None found / 0 B (Clean)"
    }
} else {
    $doUpdates = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 5 "Windows Update Download Store" "Skipped (Requires Administrator privileges)"
    } elseif ($SkipWindowsUpdate) {
        Write-SkippedChoice 5 "Windows Update Download Store" "Skipped (-SkipWindowsUpdate flag passed)"
    } else {
        Write-SkippedChoice 5 "Windows Update Download Store" "Skipped (System category skipped)"
    }
}

# 06. Delivery Optimization
if ($catSystem -ne "Skip" -and (Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue) -and (-not $SkipDeliveryOptimization)) {
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
        $doDelivery = Ask-Choice 6 "Windows Delivery Optimization Cache" "Found $(Format-ByteSize $totalDoBytes) peer-to-peer Windows update distribution files" $true $catSystem
    } else {
        $doDelivery = $false
        Write-SkippedChoice 6 "Windows Delivery Optimization Cache" "None found / 0 B (Clean)"
    }
} else {
    $doDelivery = $false
    if ($SkipDeliveryOptimization) {
        Write-SkippedChoice 6 "Windows Delivery Optimization Cache" "Skipped (-SkipDeliveryOptimization flag passed)"
    } elseif ($catSystem -eq "Skip") {
        Write-SkippedChoice 6 "Windows Delivery Optimization Cache" "Skipped (System category skipped)"
    } else {
        Write-SkippedChoice 6 "Windows Delivery Optimization Cache" "Skipped (Cmdlet not available)"
    }
}

# ============================================================================
# CATEGORY 2 - BROWSER CACHES
# ============================================================================
$catBrowsers = if (-not $SkipBrowsers) {
    Ask-Category "Browser Caches" "Google Chrome, Mozilla Firefox, Brave Browser" "All"
} else { "Skip" }

# 07. Google Chrome
$chromePaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Code Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\GPUCache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Service Worker\CacheStorage"
)
if ($catBrowsers -ne "Skip" -and (-not $SkipChrome)) {
    $chromeMetrics = Get-FolderMetrics $chromePaths
    if ($chromeMetrics.Bytes -gt 0) {
        $doChrome = Ask-Choice 7 "Google Chrome Web & Code Cache" "Found $($chromeMetrics.Formatted) cached web assets and compiled code caches across profiles" $true $catBrowsers
    } else {
        $doChrome = $false
        Write-SkippedChoice 7 "Google Chrome Web & Code Cache" "None found / 0 B (Clean)"
    }
} else {
    $doChrome = $false
    if ($SkipChrome) {
        Write-SkippedChoice 7 "Google Chrome Web & Code Cache" "Skipped (-SkipChrome flag passed)"
    } else {
        Write-SkippedChoice 7 "Google Chrome Web & Code Cache" "Skipped (Browser category skipped)"
    }
}

# 08. Mozilla Firefox
$firefoxPaths = @(
    "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2",
    "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\startupCache"
)
if ($catBrowsers -ne "Skip" -and (-not $SkipFirefox)) {
    $firefoxMetrics = Get-FolderMetrics $firefoxPaths
    if ($firefoxMetrics.Bytes -gt 0) {
        $doFirefox = Ask-Choice 8 "Mozilla Firefox Web & Startup Cache" "Found $($firefoxMetrics.Formatted) offline cache2 files and startup cache across profiles" $true $catBrowsers
    } else {
        $doFirefox = $false
        Write-SkippedChoice 8 "Mozilla Firefox Web & Startup Cache" "None found / 0 B (Clean)"
    }
} else {
    $doFirefox = $false
    if ($SkipFirefox) {
        Write-SkippedChoice 8 "Mozilla Firefox Web & Startup Cache" "Skipped (-SkipFirefox flag passed)"
    } else {
        Write-SkippedChoice 8 "Mozilla Firefox Web & Startup Cache" "Skipped (Browser category skipped)"
    }
}

# 09. Brave Browser
$bravePaths = @(
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Cache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Code Cache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\GPUCache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Service Worker\CacheStorage"
)
if ($catBrowsers -ne "Skip" -and (-not $SkipBrave)) {
    $braveMetrics = Get-FolderMetrics $bravePaths
    if ($braveMetrics.Bytes -gt 0) {
        $doBrave = Ask-Choice 9 "Brave Browser Web & Code Cache" "Found $($braveMetrics.Formatted) cached web assets and compiled code caches across profiles" $true $catBrowsers
    } else {
        $doBrave = $false
        Write-SkippedChoice 9 "Brave Browser Web & Code Cache" "None found / 0 B (Clean)"
    }
} else {
    $doBrave = $false
    if ($SkipBrave) {
        Write-SkippedChoice 9 "Brave Browser Web & Code Cache" "Skipped (-SkipBrave flag passed)"
    } else {
        Write-SkippedChoice 9 "Brave Browser Web & Code Cache" "Skipped (Browser category skipped)"
    }
}

# ============================================================================
# CATEGORY 3 - GAME LAUNCHER CACHES
# ============================================================================
$catGames = if (-not $SkipGames) {
    Ask-Category "Game Launcher Caches" "Steam web & HTTP cache, Epic Games Store web cache" "All"
} else { "Skip" }

# 10. Steam Web & HTTP Cache
$steamPaths = @(
    "$env:LOCALAPPDATA\Steam\htmlcache",
    "${env:ProgramFiles(x86)}\Steam\appcache\httpcache"
)
if ($catGames -ne "Skip" -and (-not $SkipSteam)) {
    $steamMetrics = Get-FolderMetrics $steamPaths
    if ($steamMetrics.Bytes -gt 0) {
        $doSteam = Ask-Choice 10 "Steam Web & HTTP Cache" "Found $($steamMetrics.Formatted) launcher browser and HTTP network cache files" $true $catGames
    } else {
        $doSteam = $false
        Write-SkippedChoice 10 "Steam Web & HTTP Cache" "None found / 0 B (Clean)"
    }
} else {
    $doSteam = $false
    if ($SkipSteam) {
        Write-SkippedChoice 10 "Steam Web & HTTP Cache" "Skipped (-SkipSteam flag passed)"
    } else {
        Write-SkippedChoice 10 "Steam Web & HTTP Cache" "Skipped (Game Launchers category skipped)"
    }
}

# 11. Epic Games Store Web Cache
$epicPaths = @(
    "$env:LOCALAPPDATA\EpicGamesLauncher\Saved\webcache*"
)
if ($catGames -ne "Skip" -and (-not $SkipEpic)) {
    $epicMetrics = Get-FolderMetrics $epicPaths
    if ($epicMetrics.Bytes -gt 0) {
        $doEpic = Ask-Choice 11 "Epic Games Store Web Cache" "Found $($epicMetrics.Formatted) store webcache assets and browser caches" $true $catGames
    } else {
        $doEpic = $false
        Write-SkippedChoice 11 "Epic Games Store Web Cache" "None found / 0 B (Clean)"
    }
} else {
    $doEpic = $false
    if ($SkipEpic) {
        Write-SkippedChoice 11 "Epic Games Store Web Cache" "Skipped (-SkipEpic flag passed)"
    } else {
        Write-SkippedChoice 11 "Epic Games Store Web Cache" "Skipped (Game Launchers category skipped)"
    }
}

# ============================================================================
# CATEGORY 4 - APP CACHES (Media & Communication)
# ============================================================================
$catApps = if (-not $SkipMediaApps) {
    Ask-Category "App Caches" "Spotify, Discord, Slack, Teams, Telegram, Zoom" "All"
} else { "Skip" }

# 12. Spotify
$spotifyPaths = @("$env:LOCALAPPDATA\Spotify\Storage")
if ($catApps -ne "Skip" -and (-not $SkipSpotify)) {
    $spotifyMetrics = Get-FolderMetrics $spotifyPaths
    if ($spotifyMetrics.Bytes -gt 0) {
        $doSpotify = Ask-Choice 12 "Spotify Audio Storage Cache" "Found $($spotifyMetrics.Formatted) downloaded audio streams and offline assets" $true $catApps
    } else {
        $doSpotify = $false
        Write-SkippedChoice 12 "Spotify Audio Storage Cache" "None found / 0 B (Clean)"
    }
} else {
    $doSpotify = $false
    if ($SkipSpotify) {
        Write-SkippedChoice 12 "Spotify Audio Storage Cache" "Skipped (-SkipSpotify flag passed)"
    } else {
        Write-SkippedChoice 12 "Spotify Audio Storage Cache" "Skipped (App Caches category skipped)"
    }
}

# 13. Discord
$discordPaths = @(
    "$env:APPDATA\discord\Cache",
    "$env:APPDATA\discord\Code Cache"
)
if ($catApps -ne "Skip" -and (-not $SkipDiscord)) {
    $discordMetrics = Get-FolderMetrics $discordPaths
    if ($discordMetrics.Bytes -gt 0) {
        $doDiscord = Ask-Choice 13 "Discord Web & Code Cache" "Found $($discordMetrics.Formatted) cached message media, avatars, and V8 code cache" $true $catApps
    } else {
        $doDiscord = $false
        Write-SkippedChoice 13 "Discord Web & Code Cache" "None found / 0 B (Clean)"
    }
} else {
    $doDiscord = $false
    if ($SkipDiscord) {
        Write-SkippedChoice 13 "Discord Web & Code Cache" "Skipped (-SkipDiscord flag passed)"
    } else {
        Write-SkippedChoice 13 "Discord Web & Code Cache" "Skipped (App Caches category skipped)"
    }
}

# 14. Slack
$slackPaths = @(
    "$env:APPDATA\Slack\Cache",
    "$env:APPDATA\Slack\Code Cache",
    "$env:APPDATA\Slack\Service Worker\CacheStorage"
)
if ($catApps -ne "Skip" -and (-not $SkipSlack)) {
    $slackMetrics = Get-FolderMetrics $slackPaths
    if ($slackMetrics.Bytes -gt 0) {
        $doSlack = Ask-Choice 14 "Slack Web & Code Cache" "Found $($slackMetrics.Formatted) workspace cached images, attachments, and code cache" $true $catApps
    } else {
        $doSlack = $false
        Write-SkippedChoice 14 "Slack Web & Code Cache" "None found / 0 B (Clean)"
    }
} else {
    $doSlack = $false
    if ($SkipSlack) {
        Write-SkippedChoice 14 "Slack Web & Code Cache" "Skipped (-SkipSlack flag passed)"
    } else {
        Write-SkippedChoice 14 "Slack Web & Code Cache" "Skipped (App Caches category skipped)"
    }
}

# 15. Microsoft Teams
$teamsPaths = @(
    "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache",
    "$env:APPDATA\Microsoft\Teams\Cache",
    "$env:APPDATA\Microsoft\Teams\blob_storage",
    "$env:APPDATA\Microsoft\Teams\tmp"
)
if ($catApps -ne "Skip" -and (-not $SkipTeams)) {
    $teamsMetrics = Get-FolderMetrics $teamsPaths
    if ($teamsMetrics.Bytes -gt 0) {
        $doTeams = Ask-Choice 15 "Microsoft Teams (New & Classic) Cache" "Found $($teamsMetrics.Formatted) local cache, blob storage, and temporary files" $true $catApps
    } else {
        $doTeams = $false
        Write-SkippedChoice 15 "Microsoft Teams (New & Classic) Cache" "None found / 0 B (Clean)"
    }
} else {
    $doTeams = $false
    if ($SkipTeams) {
        Write-SkippedChoice 15 "Microsoft Teams (New & Classic) Cache" "Skipped (-SkipTeams flag passed)"
    } else {
        Write-SkippedChoice 15 "Microsoft Teams (New & Classic) Cache" "Skipped (App Caches category skipped)"
    }
}

# 16. Telegram
$telegramPaths = @("$env:APPDATA\Telegram Desktop\tdata\user_data\media_cache")
if ($catApps -ne "Skip" -and (-not $SkipTelegram)) {
    $telegramMetrics = Get-FolderMetrics $telegramPaths
    if ($telegramMetrics.Bytes -gt 0) {
        $doTelegram = Ask-Choice 16 "Telegram Desktop Media Cache" "Found $($telegramMetrics.Formatted) downloaded images, voice notes, and media previews" $true $catApps
    } else {
        $doTelegram = $false
        Write-SkippedChoice 16 "Telegram Desktop Media Cache" "None found / 0 B (Clean)"
    }
} else {
    $doTelegram = $false
    if ($SkipTelegram) {
        Write-SkippedChoice 16 "Telegram Desktop Media Cache" "Skipped (-SkipTelegram flag passed)"
    } else {
        Write-SkippedChoice 16 "Telegram Desktop Media Cache" "Skipped (App Caches category skipped)"
    }
}

# 17. Zoom
$zoomPaths = @(
    "$env:APPDATA\Zoom\data",
    "$env:LOCALAPPDATA\Zoom\temp"
)
if ($catApps -ne "Skip" -and (-not $SkipZoom)) {
    $zoomMetrics = Get-FolderMetrics $zoomPaths
    if ($zoomMetrics.Bytes -gt 0) {
        $doZoom = Ask-Choice 17 "Zoom Meeting & Temp Cache" "Found $($zoomMetrics.Formatted) temporary meeting data and logs" $true $catApps
    } else {
        $doZoom = $false
        Write-SkippedChoice 17 "Zoom Meeting & Temp Cache" "None found / 0 B (Clean)"
    }
} else {
    $doZoom = $false
    if ($SkipZoom) {
        Write-SkippedChoice 17 "Zoom Meeting & Temp Cache" "Skipped (-SkipZoom flag passed)"
    } else {
        Write-SkippedChoice 17 "Zoom Meeting & Temp Cache" "Skipped (App Caches category skipped)"
    }
}

# ============================================================================
# CATEGORY 5 - DEVELOPER TOOL CACHES
# ============================================================================
$catDev = if (-not $SkipDevCaches) {
    Ask-Category "Developer Tool Caches" "Pip, VS Code, NPM, Yarn, pnpm, NuGet, Gradle, Cargo, Go" "All"
} else { "Skip" }

# 18. Python / Pip
$pipPaths = @("$env:LOCALAPPDATA\pip\cache")
if ($catDev -ne "Skip" -and (-not $SkipPip)) {
    $pipMetrics = Get-FolderMetrics $pipPaths
    if ($pipMetrics.Bytes -gt 0) {
        $doPip = Ask-Choice 18 "Python / Pip Package Cache" "Found $($pipMetrics.Formatted) downloaded wheel archives and HTTP caches" $true $catDev
    } else {
        $doPip = $false
        Write-SkippedChoice 18 "Python / Pip Package Cache" "None found / 0 B (Clean)"
    }
} else {
    $doPip = $false
    if ($SkipPip) {
        Write-SkippedChoice 18 "Python / Pip Package Cache" "Skipped (-SkipPip flag passed)"
    } else {
        Write-SkippedChoice 18 "Python / Pip Package Cache" "Skipped (Developer category skipped)"
    }
}

# 19. Visual Studio Code
$vscodePaths = @(
    "$env:APPDATA\Code\Cache",
    "$env:APPDATA\Code\CachedData"
)
if ($catDev -ne "Skip" -and (-not $SkipVSCode)) {
    $vscodeMetrics = Get-FolderMetrics $vscodePaths
    if ($vscodeMetrics.Bytes -gt 0) {
        $doVSCode = Ask-Choice 19 "Visual Studio Code Cache" "Found $($vscodeMetrics.Formatted) editor web cache and compiled V8 data cache" $true $catDev
    } else {
        $doVSCode = $false
        Write-SkippedChoice 19 "Visual Studio Code Cache" "None found / 0 B (Clean)"
    }
} else {
    $doVSCode = $false
    if ($SkipVSCode) {
        Write-SkippedChoice 19 "Visual Studio Code Cache" "Skipped (-SkipVSCode flag passed)"
    } else {
        Write-SkippedChoice 19 "Visual Studio Code Cache" "Skipped (Developer category skipped)"
    }
}

# 20. NPM
$npmPaths = @(
    "$env:LOCALAPPDATA\npm-cache",
    "$env:APPDATA\npm-cache"
)
if ($catDev -ne "Skip" -and (-not $SkipNpm)) {
    $npmMetrics = Get-FolderMetrics $npmPaths
    if ($npmMetrics.Bytes -gt 0) {
        $doNpm = Ask-Choice 20 "NPM Package Cache" "Found $($npmMetrics.Formatted) cached tarballs and package metadata" $true $catDev
    } else {
        $doNpm = $false
        Write-SkippedChoice 20 "NPM Package Cache" "None found / 0 B (Clean)"
    }
} else {
    $doNpm = $false
    if ($SkipNpm) {
        Write-SkippedChoice 20 "NPM Package Cache" "Skipped (-SkipNpm flag passed)"
    } else {
        Write-SkippedChoice 20 "NPM Package Cache" "Skipped (Developer category skipped)"
    }
}

# 21. Yarn
$yarnPaths = @("$env:LOCALAPPDATA\Yarn\Cache")
if ($catDev -ne "Skip" -and (-not $SkipYarn)) {
    $yarnMetrics = Get-FolderMetrics $yarnPaths
    if ($yarnMetrics.Bytes -gt 0) {
        $doYarn = Ask-Choice 21 "Yarn Package Cache" "Found $($yarnMetrics.Formatted) global Yarn cached packages" $true $catDev
    } else {
        $doYarn = $false
        Write-SkippedChoice 21 "Yarn Package Cache" "None found / 0 B (Clean)"
    }
} else {
    $doYarn = $false
    if ($SkipYarn) {
        Write-SkippedChoice 21 "Yarn Package Cache" "Skipped (-SkipYarn flag passed)"
    } else {
        Write-SkippedChoice 21 "Yarn Package Cache" "Skipped (Developer category skipped)"
    }
}

# 22. pnpm
$pnpmPaths = @("$env:LOCALAPPDATA\pnpm\store")
if ($catDev -ne "Skip" -and (-not $SkipPnpm)) {
    $pnpmMetrics = Get-FolderMetrics $pnpmPaths
    if ($pnpmMetrics.Bytes -gt 0) {
        $doPnpm = Ask-Choice 22 "pnpm Store Cache" "Found $($pnpmMetrics.Formatted) content-addressable package files" $true $catDev
    } else {
        $doPnpm = $false
        Write-SkippedChoice 22 "pnpm Store Cache" "None found / 0 B (Clean)"
    }
} else {
    $doPnpm = $false
    if ($SkipPnpm) {
        Write-SkippedChoice 22 "pnpm Store Cache" "Skipped (-SkipPnpm flag passed)"
    } else {
        Write-SkippedChoice 22 "pnpm Store Cache" "Skipped (Developer category skipped)"
    }
}

# 23. NuGet (.NET)
$nugetPaths = @("$env:LOCALAPPDATA\NuGet\v3-cache")
if ($catDev -ne "Skip" -and (-not $SkipNuget)) {
    $nugetMetrics = Get-FolderMetrics $nugetPaths
    if ($nugetMetrics.Bytes -gt 0) {
        $doNuget = Ask-Choice 23 "NuGet (.NET) Package Cache" "Found $($nugetMetrics.Formatted) downloaded nupkg files in v3-cache" $true $catDev
    } else {
        $doNuget = $false
        Write-SkippedChoice 23 "NuGet (.NET) Package Cache" "None found / 0 B (Clean)"
    }
} else {
    $doNuget = $false
    if ($SkipNuget) {
        Write-SkippedChoice 23 "NuGet (.NET) Package Cache" "Skipped (-SkipNuget flag passed)"
    } else {
        Write-SkippedChoice 23 "NuGet (.NET) Package Cache" "Skipped (Developer category skipped)"
    }
}

# 24. Gradle
$gradlePaths = @("$env:USERPROFILE\.gradle\caches")
if ($catDev -ne "Skip" -and (-not $SkipGradle)) {
    $gradleMetrics = Get-FolderMetrics $gradlePaths
    if ($gradleMetrics.Bytes -gt 0) {
        $doGradle = Ask-Choice 24 "Gradle Build Cache" "Found $($gradleMetrics.Formatted) compiled jars, plugins, and dependency caches" $true $catDev
    } else {
        $doGradle = $false
        Write-SkippedChoice 24 "Gradle Build Cache" "None found / 0 B (Clean)"
    }
} else {
    $doGradle = $false
    if ($SkipGradle) {
        Write-SkippedChoice 24 "Gradle Build Cache" "Skipped (-SkipGradle flag passed)"
    } else {
        Write-SkippedChoice 24 "Gradle Build Cache" "Skipped (Developer category skipped)"
    }
}

# 25. Cargo (Rust)
$cargoPaths = @("$env:USERPROFILE\.cargo\registry\cache")
if ($catDev -ne "Skip" -and (-not $SkipCargo)) {
    $cargoMetrics = Get-FolderMetrics $cargoPaths
    if ($cargoMetrics.Bytes -gt 0) {
        $doCargo = Ask-Choice 25 "Cargo (Rust) Registry Cache" "Found $($cargoMetrics.Formatted) downloaded .crate archives in registry" $true $catDev
    } else {
        $doCargo = $false
        Write-SkippedChoice 25 "Cargo (Rust) Registry Cache" "None found / 0 B (Clean)"
    }
} else {
    $doCargo = $false
    if ($SkipCargo) {
        Write-SkippedChoice 25 "Cargo (Rust) Registry Cache" "Skipped (-SkipCargo flag passed)"
    } else {
        Write-SkippedChoice 25 "Cargo (Rust) Registry Cache" "Skipped (Developer category skipped)"
    }
}

# 26. Go
$goPaths = @("$env:LOCALAPPDATA\go-build")
if ($catDev -ne "Skip" -and (-not $SkipGo)) {
    $goMetrics = Get-FolderMetrics $goPaths
    if ($goMetrics.Bytes -gt 0) {
        $doGo = Ask-Choice 26 "Go Build Cache" "Found $($goMetrics.Formatted) compiled build artifacts in go-build" $true $catDev
    } else {
        $doGo = $false
        Write-SkippedChoice 26 "Go Build Cache" "None found / 0 B (Clean)"
    }
} else {
    $doGo = $false
    if ($SkipGo) {
        Write-SkippedChoice 26 "Go Build Cache" "Skipped (-SkipGo flag passed)"
    } else {
        Write-SkippedChoice 26 "Go Build Cache" "Skipped (Developer category skipped)"
    }
}

# ============================================================================
# CATEGORY 6 - CREATIVE SUITE CACHES
# ============================================================================
$catCreative = if (-not $SkipCreativeApps) {
    Ask-Category "Creative Suite Caches" "Adobe Common Media Cache, DaVinci Resolve render cache" "All"
} else { "Skip" }

# 27. Adobe Common Media Cache
$adobePaths = @(
    "$env:APPDATA\Adobe\Common\Media Cache Files",
    "$env:APPDATA\Adobe\Common\Media Cache"
)
if ($catCreative -ne "Skip" -and (-not $SkipAdobe)) {
    $adobeMetrics = Get-FolderMetrics $adobePaths
    if ($adobeMetrics.Bytes -gt 0) {
        $doAdobe = Ask-Choice 27 "Adobe Common Media Cache" "Found $($adobeMetrics.Formatted) conformed audio peaks (.cfa/.pek) and video media cache" $true $catCreative
    } else {
        $doAdobe = $false
        Write-SkippedChoice 27 "Adobe Common Media Cache" "None found / 0 B (Clean)"
    }
} else {
    $doAdobe = $false
    if ($SkipAdobe) {
        Write-SkippedChoice 27 "Adobe Common Media Cache" "Skipped (-SkipAdobe flag passed)"
    } else {
        Write-SkippedChoice 27 "Adobe Common Media Cache" "Skipped (Creative category skipped)"
    }
}

# 28. DaVinci Resolve
$davinciPaths = @("$env:USERPROFILE\Videos\CacheClip")
if ($catCreative -ne "Skip" -and (-not $SkipDaVinci)) {
    $davinciMetrics = Get-FolderMetrics $davinciPaths
    if ($davinciMetrics.Bytes -gt 0) {
        $doDaVinci = Ask-Choice 28 "DaVinci Resolve Render Cache" "Found $($davinciMetrics.Formatted) CacheClip optimized media and timeline scratch renders" $true $catCreative
    } else {
        $doDaVinci = $false
        Write-SkippedChoice 28 "DaVinci Resolve Render Cache" "None found / 0 B (Clean)"
    }
} else {
    $doDaVinci = $false
    if ($SkipDaVinci) {
        Write-SkippedChoice 28 "DaVinci Resolve Render Cache" "Skipped (-SkipDaVinci flag passed)"
    } else {
        Write-SkippedChoice 28 "DaVinci Resolve Render Cache" "Skipped (Creative category skipped)"
    }
}

# ============================================================================
# CATEGORY 7 - SYSTEM ADVANCED
# ============================================================================
$catAdvanced = if (-not $SkipAdvanced) {
    Ask-Category "System Advanced" "Shadow copies, upgrade folders, crash dumps, logs, hibernate, OEM drivers, search index, WinSxS" "Individual"
} else { "Skip" }

# 29. Volume Shadow Copies
if ($catAdvanced -ne "Skip" -and $isAdmin -and (-not $SkipRestorePoints)) {
    $shadowOutput = vssadmin list shadows 2>&1
    $hasShadows = ($shadowOutput -match 'Shadow Copy ID:')
    if ($hasShadows) {
        $shadowCount = ($shadowOutput | Select-String 'Shadow Copy ID:').Count
        $doShadows = Ask-Choice 29 "Oldest Volume Shadow Copies (vssadmin)" "Found $shadowCount shadow copies. Purges old snapshots via vssadmin, keeps newest" $true $catAdvanced
    } else {
        $doShadows = $false
        Write-SkippedChoice 29 "Oldest Volume Shadow Copies (vssadmin)" "None found / 0 copies (Clean)"
    }
} else {
    $doShadows = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 29 "System Restore Points" "Skipped (Requires Administrator privileges)"
    } elseif ($SkipRestorePoints) {
        Write-SkippedChoice 29 "System Restore Points" "Skipped (-SkipRestorePoints flag passed)"
    } else {
        Write-SkippedChoice 29 "System Restore Points" "Skipped (System Advanced category skipped)"
    }
}

# 30. Leftover Windows Upgrade Folders
$upgradePaths = @("$sysDrive\Windows.old", "$sysDrive\`$WINDOWS.~BT", "$sysDrive\`$WINDOWS.~WS", "$sysDrive\`$GetCurrent")
$foundUpgradePaths = @($upgradePaths | Where-Object { Test-Path -LiteralPath $_ })
$upgradeMetrics = if ($foundUpgradePaths.Count -gt 0) { Get-FolderMetrics $foundUpgradePaths } else { [PSCustomObject]@{ Bytes = [int64]0; Formatted = "0 B" } }
if ($catAdvanced -ne "Skip" -and $foundUpgradePaths.Count -gt 0 -and $upgradeMetrics.Bytes -gt 0 -and (-not $SkipUpgradeFolders)) {
    $foundList = $foundUpgradePaths -join ", "
    $doUpgrade = Ask-Choice 30 "Leftover Windows Upgrade Folders" "Found $($upgradeMetrics.Formatted) across: $foundList" $true $catAdvanced
} else {
    $doUpgrade = $false
    if ($SkipUpgradeFolders) {
        Write-SkippedChoice 30 "Leftover Windows Upgrade Folders" "Skipped (-SkipUpgradeFolders flag passed)"
    } elseif ($catAdvanced -eq "Skip") {
        Write-SkippedChoice 30 "Leftover Windows Upgrade Folders" "Skipped (System Advanced category skipped)"
    } else {
        Write-SkippedChoice 30 "Leftover Windows Upgrade Folders" "None found / 0 B (Clean)"
    }
}

# 31. Kernel & User Crash Dumps
$crashPaths = @(
    "$sysRoot\MEMORY.DMP",
    "$sysRoot\Minidump",
    "$sysRoot\LiveKernelReports",
    "$env:LOCALAPPDATA\CrashDumps"
)
if ($catAdvanced -ne "Skip" -and (-not $SkipCrashDumps)) {
    $crashMetrics = Get-FolderMetrics $crashPaths
    if ($crashMetrics.Bytes -gt 0) {
        $doCrashDumps = Ask-Choice 31 "Kernel & User Crash Dump Files" "Found $($crashMetrics.Formatted) in crash dump files (MEMORY.DMP, CrashDumps)" $true $catAdvanced
    } else {
        $doCrashDumps = $false
        Write-SkippedChoice 31 "Kernel & User Crash Dump Files" "None found / 0 B (Clean)"
    }
} else {
    $doCrashDumps = $false
    if ($SkipCrashDumps) {
        Write-SkippedChoice 31 "Kernel & User Crash Dump Files" "Skipped (-SkipCrashDumps flag passed)"
    } else {
        Write-SkippedChoice 31 "Kernel & User Crash Dump Files" "Skipped (System Advanced category skipped)"
    }
}

# 32. CBS, DISM & Panther Logs
if ($catAdvanced -ne "Skip" -and $isAdmin -and (-not $SkipCBSLogs)) {
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
        $doCBSLogs = Ask-Choice 32 "CBS, DISM & Panther Log Archives" "Found $cbsFormatted in CBS persist archives, Panther logs, and DISM traces" $true $catAdvanced
    } else {
        $doCBSLogs = $false
        Write-SkippedChoice 32 "CBS, DISM & Panther Log Archives" "None found / 0 B (Clean)"
    }
} else {
    $doCBSLogs = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 32 "CBS, DISM & Panther Log Archives" "Skipped (Requires Administrator privileges)"
    } elseif ($SkipCBSLogs) {
        Write-SkippedChoice 32 "CBS, DISM & Panther Log Archives" "Skipped (-SkipCBSLogs flag passed)"
    } else {
        Write-SkippedChoice 32 "CBS, DISM & Panther Log Archives" "Skipped (System Advanced category skipped)"
    }
}

# 33. Hibernation file
$hiberPath = "$sysDrive\hiberfil.sys"
$hasHiberfil = Test-Path -LiteralPath $hiberPath
if ($catAdvanced -ne "Skip" -and $isAdmin -and (-not $SkipHiberfil)) {
    $hiberSize = [int64]0
    if ($hasHiberfil) {
        try { $hiberSize = (Get-Item -LiteralPath $hiberPath -Force -ErrorAction Stop).Length } catch { }
    }
    if ($hasHiberfil -and $hiberSize -gt 0) {
        $hiberFormatted = Format-ByteSize $hiberSize
        $doHiberfil = Ask-Choice 33 "Windows Hibernation File (hiberfil.sys)" "Found $hiberPath ($hiberFormatted). Disables Hibernate to reclaim space (Sleep unaffected)" $true $catAdvanced
    } else {
        $doHiberfil = $false
        Write-SkippedChoice 33 "Windows Hibernation (hiberfil.sys)" "Already disabled / None found (Clean)"
    }
} else {
    $doHiberfil = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 33 "Windows Hibernation (hiberfil.sys)" "Skipped (Requires Administrator privileges)"
    } elseif ($SkipHiberfil) {
        Write-SkippedChoice 33 "Windows Hibernation (hiberfil.sys)" "Skipped (-SkipHiberfil flag passed)"
    } else {
        Write-SkippedChoice 33 "Windows Hibernation (hiberfil.sys)" "Skipped (System Advanced category skipped)"
    }
}

# 34. Obsolete OEM drivers
$supersededDrivers = @()
if ($catAdvanced -ne "Skip" -and $isAdmin -and (-not $SkipDrivers)) {
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
        $doDrivers = Ask-Choice 34 "Obsolete OEM Hardware Drivers" "Found $($supersededDrivers.Count) superseded driver packages in DriverStore" $true $catAdvanced
    } else {
        $doDrivers = $false
        Write-SkippedChoice 34 "Obsolete OEM Hardware Drivers" "None found / 0 drivers (Clean)"
    }
} else {
    $doDrivers = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 34 "Obsolete OEM Hardware Drivers" "Skipped (Requires Administrator privileges)"
    } elseif ($SkipDrivers) {
        Write-SkippedChoice 34 "Obsolete OEM Hardware Drivers" "Skipped (-SkipDrivers flag passed)"
    } else {
        Write-SkippedChoice 34 "Obsolete OEM Hardware Drivers" "Skipped (System Advanced category skipped)"
    }
}

# 35. Windows Search index
$searchService = Get-Service -Name WSearch -ErrorAction SilentlyContinue
if ($catAdvanced -ne "Skip" -and $isAdmin -and ($null -ne $searchService) -and (-not $SkipSearchIndex)) {
    $searchPaths = @(
        "$env:ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb",
        "$env:ProgramData\Microsoft\Search\Data\Applications\Windows\Projects\SystemIndex\Indexer"
    )
    $searchMetrics = Get-FolderMetrics $searchPaths
    if ($searchMetrics.Bytes -gt 0) {
        $doSearchIndex = Ask-Choice 35 "Windows Search Index Database" "Found $($searchMetrics.Formatted) in search database (resets and compacts in background)" $true $catAdvanced
    } else {
        $doSearchIndex = $false
        Write-SkippedChoice 35 "Windows Search Index Database" "None found / 0 B (Clean)"
    }
} else {
    $doSearchIndex = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 35 "Windows Search Index Database" "Skipped (Requires Administrator privileges)"
    } elseif ($SkipSearchIndex) {
        Write-SkippedChoice 35 "Windows Search Index Database" "Skipped (-SkipSearchIndex flag passed)"
    } elseif ($catAdvanced -eq "Skip") {
        Write-SkippedChoice 35 "Windows Search Index Database" "Skipped (System Advanced category skipped)"
    } else {
        Write-SkippedChoice 35 "Windows Search Index Database" "Service not present (Clean)"
    }
}

# 36. WinSxS ResetBase
if ($catAdvanced -ne "Skip" -and $isAdmin -and (-not $SkipDism)) {
    $doDism = Ask-Choice 36 "WinSxS Component Store ResetBase" "Deep WinSxS component purge (Takes 2-5 min, prevents old update rollbacks)" $false $catAdvanced
} else {
    $doDism = $false
    if (-not $isAdmin) {
        Write-SkippedChoice 36 "WinSxS Component Store ResetBase" "Skipped (Requires Administrator privileges)"
    } elseif ($SkipDism) {
        Write-SkippedChoice 36 "WinSxS Component Store ResetBase" "Skipped (-SkipDism flag passed)"
    } else {
        Write-SkippedChoice 36 "WinSxS Component Store ResetBase" "Skipped (System Advanced category skipped)"
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

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 1 - SYSTEM CACHES
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 2 - BROWSER CACHES
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 3 - GAME LAUNCHER CACHES
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 4 - APP CACHES
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 5 - DEVELOPER TOOL CACHES
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 6 - CREATIVE SUITE CACHES
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# EXECUTION: CATEGORY 7 - SYSTEM ADVANCED
# -----------------------------------------------------------------------------
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
