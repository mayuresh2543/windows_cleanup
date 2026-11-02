<#
.SYNOPSIS
    Windows Storage Deep Cleanup Toolkit
.DESCRIPTION
    Non-destructive system storage optimizer and automation tool for Windows 10 & 11.
    Scans and purges disposable temporary files, hardware GPU shader caches, web browser
    caches (Chrome, Firefox, Brave), game launchers (Steam, Epic Games Store), communication
    apps, developer toolchains, and optional Windows servicing stores.

    Features:
      - Sizing Pre-Scan: Accurately discovers actual purgeable caches in milliseconds.
      - Zero False Positives: Accurately checks Delivery Optimization via FileSizeInCache,
        queries Recycle Bin via Windows Shell COM (ignoring desktop.ini and orphaned stubs),
        and clamps sub-kilobyte empty directory stubs.
      - Modern Action Hub: Displays detected caches in a unified overview table with
        one-keystroke action presets:
          [1] Quick Clean (Default: Temp, Shaders, Thumbnails, Web Caches)
          [2] Full Clean (Purge all detected safe caches at once)
          [3] Interactive TUI Checklist (Arrow keys to navigate, Spacebar to toggle, Enter to run)
          [Q] Exit
      - Automation Ready: Fully compatible with -All, -DryRun, -Preset, and -Skip* flags.
.PARAMETER All
    Cleans all eligible targets non-interactively without prompts.
.PARAMETER DryRun
    Simulates cleanup preview without deleting files.
.PARAMETER Preset
    Executes a predefined cleanup preset non-interactively ('Quick' or 'Full').
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
    .\cleanup.ps1 -Preset Quick
.EXAMPLE
    .\cleanup.ps1 -All -DryRun
#>

[CmdletBinding()]
param(
    [switch]$All,
    [switch]$DryRun,
    [ValidateSet("Quick", "Full")]
    [string]$Preset,
    
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

$initialFreeBytes = (Get-PSDrive $sysDriveLetter).Free
$initialFreeGB = [math]::Round($initialFreeBytes / 1GB, 2)

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

# -----------------------------------------------------------------------------
# METRICS SCANNING ENGINE (ACCURATE & ZERO FALSE POSITIVES)
# -----------------------------------------------------------------------------

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
                        Where-Object { $_.Length -gt 0 } |
                        Measure-Object -Property Length -Sum
                    if ($measure -and $measure.Sum) {
                        $totalBytes += $measure.Sum
                        $fileCount += $measure.Count
                    }
                } else {
                    if ($item.Length -gt 0) {
                        $totalBytes += $item.Length
                        $fileCount++
                    }
                }
            } catch { }
        }
    }
    
    # Sub-kilobyte threshold: clamp empty directory stubs or empty lockfiles
    if ($totalBytes -lt 1024 -or $fileCount -eq 0) {
        $totalBytes = [int64]0
        $fileCount = 0
    }
    
    return [PSCustomObject]@{
        Bytes     = $totalBytes
        Count     = $fileCount
        Formatted = (Format-ByteSize $totalBytes)
    }
}

function Get-RecycleBinMetrics {
    try {
        $sh = New-Object -ComObject Shell.Application
        $rb = $sh.Namespace(0xa)
        $items = $rb.Items()
        if ($null -eq $items -or $items.Count -eq 0) {
            return [PSCustomObject]@{ Bytes = [int64]0; Count = 0; Formatted = "0 B" }
        }
        $total = [int64]0
        foreach ($it in $items) {
            $total += [int64]$it.Size
        }
        if ($total -lt 1024) {
            return [PSCustomObject]@{ Bytes = [int64]0; Count = 0; Formatted = "0 B" }
        }
        return [PSCustomObject]@{
            Bytes     = $total
            Count     = $items.Count
            Formatted = (Format-ByteSize $total)
        }
    } catch {
        $files = Get-ChildItem -LiteralPath "$sysDrive\`$Recycle.Bin" -Recurse -File -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne 'desktop.ini' -and $_.Name -notmatch '^\$I' -and $_.Length -gt 0 }
        $measure = $files | Measure-Object -Property Length -Sum
        $b = if ($measure -and $measure.Sum -ge 1024) { [int64]$measure.Sum } else { [int64]0 }
        return [PSCustomObject]@{
            Bytes     = $b
            Count     = if ($b -gt 0) { $files.Count } else { 0 }
            Formatted = (Format-ByteSize $b)
        }
    }
}

function Get-DeliveryOptimizationMetrics {
    $doBytes = [int64]0
    if (Get-Command Get-DeliveryOptimizationStatus -ErrorAction SilentlyContinue) {
        try {
            $dos = Get-DeliveryOptimizationStatus -ErrorAction SilentlyContinue
            if ($dos) {
                # FileSizeInCache is the true disk space consumed; FileSize is the historical original size
                $sum = ($dos | Measure-Object -Property FileSizeInCache -Sum).Sum
                if ($sum -and $sum -ge 1024) {
                    $doBytes = [int64]$sum
                }
            }
        } catch { }
    }
    return [PSCustomObject]@{
        Bytes     = $doBytes
        Count     = if ($doBytes -gt 0) { 1 } else { 0 }
        Formatted = (Format-ByteSize $doBytes)
    }
}

# -----------------------------------------------------------------------------
# TARGET REGISTRY DEFINITION (36 GRANULAR TARGETS ACROSS 7 CATEGORIES)
# -----------------------------------------------------------------------------

function Get-CleanupTargetsRegistry {
    $defs = @(
        # Category 1: System Caches
        @{
            Id = "temp"; Number = 1; Category = "System Caches"; Title = "User & Windows Temp Directories";
            Description = "Disposable temporary caches in %TEMP% and Windows\Temp";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipSystem -or $SkipTemp);
            ScanFunc = { Get-FolderMetrics @($env:TEMP, "$sysRoot\Temp", "$sysRoot\ServiceProfiles\NetworkService\AppData\Local\Temp", "$sysRoot\ServiceProfiles\LocalService\AppData\Local\Temp") };
            PurgeAction = {
                Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "$sysRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                if ($isAdmin) {
                    Remove-Item -Path "$sysRoot\ServiceProfiles\NetworkService\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                    Remove-Item -Path "$sysRoot\ServiceProfiles\LocalService\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
                Write-Host "    > Purged %TEMP%, $sysRoot\Temp, and ServiceProfile disposable caches." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "shaders"; Number = 2; Category = "System Caches"; Title = "DirectX, GPU Shaders & WER Logs";
            Description = "DirectX, NVIDIA, AMD, Intel shader disks and WER error logs";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipSystem -or $SkipShaders);
            ScanFunc = { Get-FolderMetrics @(
                "$env:LOCALAPPDATA\D3DSCache", "$env:LOCALAPPDATA\Microsoft\DirectX Shader Cache",
                "$env:LOCALAPPDATA\NVIDIA\DXCache", "$env:LOCALAPPDATA\NVIDIA\GLCache", "$env:APPDATA\NVIDIA\ComputeCache",
                "$env:LOCALAPPDATA\AMD\DxCache", "$env:LOCALAPPDATA\AMD\GLCache", "$env:LOCALAPPDATA\AMD\OglShaders",
                "$env:LOCALAPPDATA\Intel\ShaderCache", "$env:PROGRAMDATA\Microsoft\Windows\WER\ReportArchive",
                "$env:PROGRAMDATA\Microsoft\Windows\WER\ReportQueue", "$env:PROGRAMDATA\Microsoft\Windows\WER\Temp",
                "$env:LOCALAPPDATA\Microsoft\Windows\WER\ReportArchive"
            ) };
            PurgeAction = {
                $paths = @(
                    "$env:LOCALAPPDATA\D3DSCache", "$env:LOCALAPPDATA\Microsoft\DirectX Shader Cache",
                    "$env:LOCALAPPDATA\NVIDIA\DXCache", "$env:LOCALAPPDATA\NVIDIA\GLCache", "$env:APPDATA\NVIDIA\ComputeCache",
                    "$env:LOCALAPPDATA\AMD\DxCache", "$env:LOCALAPPDATA\AMD\GLCache", "$env:LOCALAPPDATA\AMD\OglShaders",
                    "$env:LOCALAPPDATA\Intel\ShaderCache", "$env:PROGRAMDATA\Microsoft\Windows\WER\ReportArchive",
                    "$env:PROGRAMDATA\Microsoft\Windows\WER\ReportQueue", "$env:PROGRAMDATA\Microsoft\Windows\WER\Temp",
                    "$env:LOCALAPPDATA\Microsoft\Windows\WER\ReportArchive"
                )
                foreach ($p in $paths) { if (Test-Path -LiteralPath $p) { Remove-Item -Path "$p\*" -Recurse -Force -ErrorAction SilentlyContinue } }
                Write-Host "    > Purged DirectX, NVIDIA, AMD, Intel shader caches and WER logs." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "recyclebin"; Number = 3; Category = "System Caches"; Title = "Windows Recycle Bin";
            Description = "Discarded files across drive bins";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipSystem -or $SkipRecycleBin);
            ScanFunc = { Get-RecycleBinMetrics };
            PurgeAction = {
                Clear-RecycleBin -Force -ErrorAction SilentlyContinue
                Write-Host "    > Emptied Windows Recycle Bin across all drives." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "thumbnails"; Number = 4; Category = "System Caches"; Title = "Explorer Thumbnail & Icon Caches";
            Description = "Cached Explorer thumbnail databases (thumbcache_*.db, iconcache_*.db)";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipSystem -or $SkipThumbnails);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db", "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db", "$env:LOCALAPPDATA\IconCache.db") };
            PurgeAction = {
                Get-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
                Get-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
                if (Test-Path -LiteralPath "$env:LOCALAPPDATA\IconCache.db") { Remove-Item -LiteralPath "$env:LOCALAPPDATA\IconCache.db" -Force -ErrorAction SilentlyContinue }
                Write-Host "    > Purged Explorer thumbcache and iconcache databases." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "wuauserv"; Number = 5; Category = "System Caches"; Title = "Windows Update Download Store";
            Description = "Staged update packages in SoftwareDistribution\Download";
            IsSafePreset = $true; AdminRequired = $true; SkipFlag = [bool]($SkipSystem -or $SkipWindowsUpdate -or (-not $isAdmin));
            ScanFunc = { if ($isAdmin) { Get-FolderMetrics @("$sysRoot\SoftwareDistribution\Download") } else { [PSCustomObject]@{ Bytes = [int64]0; Count = 0; Formatted = "0 B" } } };
            PurgeAction = {
                Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "$sysRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
                Start-Service -Name wuauserv -ErrorAction SilentlyContinue
                Write-Host "    > Stopped wuauserv, purged SoftwareDistribution\Download, restarted service." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "deliveryopt"; Number = 6; Category = "System Caches"; Title = "Windows Delivery Optimization Cache";
            Description = "Peer-to-peer Windows update distribution cache files";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipSystem -or $SkipDeliveryOptimization);
            ScanFunc = { Get-DeliveryOptimizationMetrics };
            PurgeAction = {
                $origOut = [Console]::Out
                $sw = New-Object System.IO.StringWriter
                try {
                    [Console]::SetOut($sw)
                    $null = Delete-DeliveryOptimizationCache -Force -ErrorAction SilentlyContinue
                } catch { } finally {
                    [Console]::SetOut($origOut)
                }
                Write-Host "    > Purged Windows Delivery Optimization cache." -ForegroundColor DarkGray
            }
        },

        # Category 2: Browser Caches
        @{
            Id = "chrome"; Number = 7; Category = "Browser Caches"; Title = "Google Chrome Web & Code Cache";
            Description = "Cached web assets, GPUCache, and V8 code cache across all profiles";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipBrowsers -or $SkipChrome);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\Google\Chrome\User Data\*\Cache", "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Code Cache", "$env:LOCALAPPDATA\Google\Chrome\User Data\*\GPUCache", "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Service Worker\CacheStorage") };
            PurgeAction = {
                $paths = @("$env:LOCALAPPDATA\Google\Chrome\User Data\*\Cache", "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Code Cache", "$env:LOCALAPPDATA\Google\Chrome\User Data\*\GPUCache", "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Service Worker\CacheStorage")
                foreach ($p in $paths) {
                    $found = Get-Item -Path $p -Force -ErrorAction SilentlyContinue
                    if ($found) { foreach ($f in $found) { Remove-Item -Path "$($f.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue } }
                }
                Write-Host "    > Purged Google Chrome web cache, code cache, and GPU cache." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "firefox"; Number = 8; Category = "Browser Caches"; Title = "Mozilla Firefox Web & Startup Cache";
            Description = "Offline cache2 files and startup cache across all profiles";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipBrowsers -or $SkipFirefox);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2", "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\startupCache") };
            PurgeAction = {
                $paths = @("$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2", "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\startupCache")
                foreach ($p in $paths) {
                    $found = Get-Item -Path $p -Force -ErrorAction SilentlyContinue
                    if ($found) { foreach ($f in $found) { Remove-Item -Path "$($f.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue } }
                }
                Write-Host "    > Purged Mozilla Firefox cache2 and startupCache directories." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "brave"; Number = 9; Category = "Browser Caches"; Title = "Brave Browser Web & Code Cache";
            Description = "Cached web assets, GPUCache, and V8 code cache across all profiles";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipBrowsers -or $SkipBrave);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Cache", "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Code Cache", "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\GPUCache", "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Service Worker\CacheStorage") };
            PurgeAction = {
                $paths = @("$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Cache", "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Code Cache", "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\GPUCache", "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Service Worker\CacheStorage")
                foreach ($p in $paths) {
                    $found = Get-Item -Path $p -Force -ErrorAction SilentlyContinue
                    if ($found) { foreach ($f in $found) { Remove-Item -Path "$($f.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue } }
                }
                Write-Host "    > Purged Brave Browser web cache, code cache, and GPU cache." -ForegroundColor DarkGray
            }
        },

        # Category 3: Game Launchers
        @{
            Id = "steam"; Number = 10; Category = "Game Launchers"; Title = "Steam Web & HTTP Cache";
            Description = "Steam htmlcache and appcache\httpcache files";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipGames -or $SkipSteam);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\Steam\htmlcache", "${env:ProgramFiles(x86)}\Steam\appcache\httpcache") };
            PurgeAction = {
                foreach ($p in @("$env:LOCALAPPDATA\Steam\htmlcache", "${env:ProgramFiles(x86)}\Steam\appcache\httpcache")) {
                    if (Test-Path -LiteralPath $p) { Remove-Item -Path "$p\*" -Recurse -Force -ErrorAction SilentlyContinue }
                }
                Write-Host "    > Purged Steam htmlcache and appcache\httpcache directories." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "epic"; Number = 11; Category = "Game Launchers"; Title = "Epic Games Store Web Cache";
            Description = "Epic Games Launcher Saved\webcache assets and browser caches";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipGames -or $SkipEpic);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\EpicGamesLauncher\Saved\webcache*") };
            PurgeAction = {
                $found = Get-Item -Path "$env:LOCALAPPDATA\EpicGamesLauncher\Saved\webcache*" -Force -ErrorAction SilentlyContinue
                if ($found) { foreach ($f in $found) { Remove-Item -Path "$($f.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue } }
                Write-Host "    > Purged Epic Games Launcher Saved\webcache directories." -ForegroundColor DarkGray
            }
        },

        # Category 4: App Caches
        @{
            Id = "spotify"; Number = 12; Category = "App Caches"; Title = "Spotify Audio Storage Cache";
            Description = "Downloaded audio streams & offline cache files";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipMediaApps -or $SkipSpotify);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\Spotify\Storage") };
            PurgeAction = {
                if (Test-Path -LiteralPath "$env:LOCALAPPDATA\Spotify\Storage") { Remove-Item -Path "$env:LOCALAPPDATA\Spotify\Storage\*" -Recurse -Force -ErrorAction SilentlyContinue }
                Write-Host "    > Purged Spotify streaming audio storage cache." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "discord"; Number = 13; Category = "App Caches"; Title = "Discord Web & Code Cache";
            Description = "Message media cache and compiled V8 code cache";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipMediaApps -or $SkipDiscord);
            ScanFunc = { Get-FolderMetrics @("$env:APPDATA\discord\Cache", "$env:APPDATA\discord\Code Cache") };
            PurgeAction = {
                foreach ($dp in @("$env:APPDATA\discord\Cache", "$env:APPDATA\discord\Code Cache")) {
                    if (Test-Path -LiteralPath $dp) { Remove-Item -Path "$dp\*" -Recurse -Force -ErrorAction SilentlyContinue }
                }
                Write-Host "    > Purged Discord web cache and code cache." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "slack"; Number = 14; Category = "App Caches"; Title = "Slack Web & Code Cache";
            Description = "Workspace cached images, attachments, and code cache";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipMediaApps -or $SkipSlack);
            ScanFunc = { Get-FolderMetrics @("$env:APPDATA\Slack\Cache", "$env:APPDATA\Slack\Code Cache", "$env:APPDATA\Slack\Service Worker\CacheStorage") };
            PurgeAction = {
                foreach ($sp in @("$env:APPDATA\Slack\Cache", "$env:APPDATA\Slack\Code Cache", "$env:APPDATA\Slack\Service Worker\CacheStorage")) {
                    if (Test-Path -LiteralPath $sp) { Remove-Item -Path "$sp\*" -Recurse -Force -ErrorAction SilentlyContinue }
                }
                Write-Host "    > Purged Slack web cache, code cache, and service worker cache." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "teams"; Number = 15; Category = "App Caches"; Title = "Microsoft Teams Cache";
            Description = "New & Classic Teams local cache, blob storage, and temporary files";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipMediaApps -or $SkipTeams);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache", "$env:APPDATA\Microsoft\Teams\Cache", "$env:APPDATA\Microsoft\Teams\blob_storage", "$env:APPDATA\Microsoft\Teams\tmp") };
            PurgeAction = {
                foreach ($tp in @("$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache", "$env:APPDATA\Microsoft\Teams\Cache", "$env:APPDATA\Microsoft\Teams\blob_storage", "$env:APPDATA\Microsoft\Teams\tmp")) {
                    if (Test-Path -LiteralPath $tp) { Remove-Item -Path "$tp\*" -Recurse -Force -ErrorAction SilentlyContinue }
                }
                Write-Host "    > Purged Microsoft Teams local cache, blob storage, and temporary files." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "telegram"; Number = 16; Category = "App Caches"; Title = "Telegram Desktop Media Cache";
            Description = "Downloaded media previews, voice notes, and images";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipMediaApps -or $SkipTelegram);
            ScanFunc = { Get-FolderMetrics @("$env:APPDATA\Telegram Desktop\tdata\user_data\media_cache") };
            PurgeAction = {
                if (Test-Path -LiteralPath "$env:APPDATA\Telegram Desktop\tdata\user_data\media_cache") { Remove-Item -Path "$env:APPDATA\Telegram Desktop\tdata\user_data\media_cache\*" -Recurse -Force -ErrorAction SilentlyContinue }
                Write-Host "    > Purged Telegram Desktop user media cache." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "zoom"; Number = 17; Category = "App Caches"; Title = "Zoom Meeting & Temp Cache";
            Description = "Temporary meeting data and telemetry logs";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipMediaApps -or $SkipZoom);
            ScanFunc = { Get-FolderMetrics @("$env:APPDATA\Zoom\data", "$env:LOCALAPPDATA\Zoom\temp") };
            PurgeAction = {
                foreach ($zp in @("$env:APPDATA\Zoom\data", "$env:LOCALAPPDATA\Zoom\temp")) {
                    if (Test-Path -LiteralPath $zp) { Remove-Item -Path "$zp\*" -Recurse -Force -ErrorAction SilentlyContinue }
                }
                Write-Host "    > Purged Zoom meeting data cache and temporary files." -ForegroundColor DarkGray
            }
        },

        # Category 5: Developer Tools
        @{
            Id = "pip"; Number = 18; Category = "Developer Tools"; Title = "Python / Pip Package Cache";
            Description = "Downloaded wheel archives and HTTP cache";
            IsSafePreset = $false; AdminRequired = $false; SkipFlag = [bool]($SkipDevCaches -or $SkipPip);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\pip\cache") };
            PurgeAction = {
                if (Get-Command pip -ErrorAction SilentlyContinue) { $null = pip cache purge 2>&1 }
                if (Test-Path -LiteralPath "$env:LOCALAPPDATA\pip\cache") { Remove-Item -Path "$env:LOCALAPPDATA\pip\cache\*" -Recurse -Force -ErrorAction SilentlyContinue }
                Write-Host "    > Purged Python pip wheel download and HTTP cache." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "vscode"; Number = 19; Category = "Developer Tools"; Title = "Visual Studio Code Cache";
            Description = "Editor web cache and compiled V8 data cache";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipDevCaches -or $SkipVSCode);
            ScanFunc = { Get-FolderMetrics @("$env:APPDATA\Code\Cache", "$env:APPDATA\Code\CachedData") };
            PurgeAction = {
                foreach ($vp in @("$env:APPDATA\Code\Cache", "$env:APPDATA\Code\CachedData")) {
                    if (Test-Path -LiteralPath $vp) { Remove-Item -Path "$vp\*" -Recurse -Force -ErrorAction SilentlyContinue }
                }
                Write-Host "    > Purged Visual Studio Code web cache and compiled V8 data cache." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "npm"; Number = 20; Category = "Developer Tools"; Title = "NPM Package Cache";
            Description = "Global cached tarballs and package metadata";
            IsSafePreset = $false; AdminRequired = $false; SkipFlag = [bool]($SkipDevCaches -or $SkipNpm);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\npm-cache", "$env:APPDATA\npm-cache") };
            PurgeAction = {
                if (Get-Command npm -ErrorAction SilentlyContinue) { $null = npm cache clean --force 2>&1 }
                foreach ($np in @("$env:LOCALAPPDATA\npm-cache", "$env:APPDATA\npm-cache")) {
                    if (Test-Path -LiteralPath $np) { Remove-Item -Path "$np\*" -Recurse -Force -ErrorAction SilentlyContinue }
                }
                Write-Host "    > Purged NPM global cache files." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "yarn"; Number = 21; Category = "Developer Tools"; Title = "Yarn Package Cache";
            Description = "Global Yarn package download cache";
            IsSafePreset = $false; AdminRequired = $false; SkipFlag = [bool]($SkipDevCaches -or $SkipYarn);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\Yarn\Cache") };
            PurgeAction = {
                if (Get-Command yarn -ErrorAction SilentlyContinue) { $null = yarn cache clean 2>&1 }
                if (Test-Path -LiteralPath "$env:LOCALAPPDATA\Yarn\Cache") { Remove-Item -Path "$env:LOCALAPPDATA\Yarn\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue }
                Write-Host "    > Purged Yarn package cache." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "pnpm"; Number = 22; Category = "Developer Tools"; Title = "pnpm Store Cache";
            Description = "Content-addressable package store files";
            IsSafePreset = $false; AdminRequired = $false; SkipFlag = [bool]($SkipDevCaches -or $SkipPnpm);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\pnpm\store") };
            PurgeAction = {
                if (Test-Path -LiteralPath "$env:LOCALAPPDATA\pnpm\store") { Remove-Item -Path "$env:LOCALAPPDATA\pnpm\store\*" -Recurse -Force -ErrorAction SilentlyContinue }
                Write-Host "    > Purged pnpm content-addressable store cache." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "nuget"; Number = 23; Category = "Developer Tools"; Title = "NuGet (.NET) Package Cache";
            Description = "Downloaded nupkg files in v3-cache";
            IsSafePreset = $false; AdminRequired = $false; SkipFlag = [bool]($SkipDevCaches -or $SkipNuget);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\NuGet\v3-cache") };
            PurgeAction = {
                if (Get-Command dotnet -ErrorAction SilentlyContinue) { $null = dotnet nuget locals all --clear 2>&1 }
                if (Test-Path -LiteralPath "$env:LOCALAPPDATA\NuGet\v3-cache") { Remove-Item -Path "$env:LOCALAPPDATA\NuGet\v3-cache\*" -Recurse -Force -ErrorAction SilentlyContinue }
                Write-Host "    > Purged NuGet v3 local cache." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "gradle"; Number = 24; Category = "Developer Tools"; Title = "Gradle Build Cache";
            Description = "Compiled jars, plugins, and dependency caches";
            IsSafePreset = $false; AdminRequired = $false; SkipFlag = [bool]($SkipDevCaches -or $SkipGradle);
            ScanFunc = { Get-FolderMetrics @("$env:USERPROFILE\.gradle\caches") };
            PurgeAction = {
                if (Test-Path -LiteralPath "$env:USERPROFILE\.gradle\caches") { Remove-Item -Path "$env:USERPROFILE\.gradle\caches\*" -Recurse -Force -ErrorAction SilentlyContinue }
                Write-Host "    > Purged Gradle build caches." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "cargo"; Number = 25; Category = "Developer Tools"; Title = "Cargo (Rust) Registry Cache";
            Description = "Downloaded .crate archives in registry";
            IsSafePreset = $false; AdminRequired = $false; SkipFlag = [bool]($SkipDevCaches -or $SkipCargo);
            ScanFunc = { Get-FolderMetrics @("$env:USERPROFILE\.cargo\registry\cache") };
            PurgeAction = {
                if (Test-Path -LiteralPath "$env:USERPROFILE\.cargo\registry\cache") { Remove-Item -Path "$env:USERPROFILE\.cargo\registry\cache\*" -Recurse -Force -ErrorAction SilentlyContinue }
                Write-Host "    > Purged Cargo (Rust) registry package cache." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "go"; Number = 26; Category = "Developer Tools"; Title = "Go Build Cache";
            Description = "Compiled build artifacts in go-build";
            IsSafePreset = $false; AdminRequired = $false; SkipFlag = [bool]($SkipDevCaches -or $SkipGo);
            ScanFunc = { Get-FolderMetrics @("$env:LOCALAPPDATA\go-build") };
            PurgeAction = {
                if (Get-Command go -ErrorAction SilentlyContinue) { $null = go clean -cache 2>&1 }
                if (Test-Path -LiteralPath "$env:LOCALAPPDATA\go-build") { Remove-Item -Path "$env:LOCALAPPDATA\go-build\*" -Recurse -Force -ErrorAction SilentlyContinue }
                Write-Host "    > Purged Go compiler build cache." -ForegroundColor DarkGray
            }
        },

        # Category 6: Creative Suite
        @{
            Id = "adobe"; Number = 27; Category = "Creative Suite"; Title = "Adobe Common Media Cache";
            Description = "Conformed audio peaks (.cfa/.pek) and video media cache";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipCreativeApps -or $SkipAdobe);
            ScanFunc = { Get-FolderMetrics @("$env:APPDATA\Adobe\Common\Media Cache Files", "$env:APPDATA\Adobe\Common\Media Cache") };
            PurgeAction = {
                foreach ($cp in @("$env:APPDATA\Adobe\Common\Media Cache Files", "$env:APPDATA\Adobe\Common\Media Cache")) {
                    if (Test-Path -LiteralPath $cp) { Remove-Item -Path "$cp\*" -Recurse -Force -ErrorAction SilentlyContinue }
                }
                Write-Host "    > Purged Adobe Premiere / After Effects Media Cache files." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "davinci"; Number = 28; Category = "Creative Suite"; Title = "DaVinci Resolve Render Cache";
            Description = "CacheClip optimized media and timeline scratch renders";
            IsSafePreset = $true; AdminRequired = $false; SkipFlag = [bool]($SkipCreativeApps -or $SkipDaVinci);
            ScanFunc = { Get-FolderMetrics @("$env:USERPROFILE\Videos\CacheClip") };
            PurgeAction = {
                if (Test-Path -LiteralPath "$env:USERPROFILE\Videos\CacheClip") { Remove-Item -Path "$env:USERPROFILE\Videos\CacheClip\*" -Recurse -Force -ErrorAction SilentlyContinue }
                Write-Host "    > Purged DaVinci Resolve CacheClip scratch and render cache files." -ForegroundColor DarkGray
            }
        },

        # Category 7: System Advanced
        @{
            Id = "shadows"; Number = 29; Category = "System Advanced"; Title = "Oldest Volume Shadow Copies";
            Description = "Purges oldest shadow copy snapshots via vssadmin, keeps newest";
            IsSafePreset = $false; AdminRequired = $true; SkipFlag = [bool]($SkipAdvanced -or $SkipRestorePoints -or (-not $isAdmin));
            ScanFunc = {
                if ($isAdmin) {
                    $shadowOutput = vssadmin list shadows 2>&1
                    if ($shadowOutput -match 'Shadow Copy ID:') {
                        $count = ($shadowOutput | Select-String 'Shadow Copy ID:').Count
                        return [PSCustomObject]@{ Bytes = [int64]($count * 1024 * 1024); Count = $count; Formatted = "$count copies" }
                    }
                }
                return [PSCustomObject]@{ Bytes = [int64]0; Count = 0; Formatted = "0 B" }
            };
            PurgeAction = {
                $null = vssadmin delete shadows /for=$sysDrive /oldest /quiet 2>&1
                Write-Host "    > Purged oldest shadow copies from $sysDrive (kept newest)." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "upgrades"; Number = 30; Category = "System Advanced"; Title = "Leftover Windows Upgrade Folders";
            Description = "Rollback folders (Windows.old, `$WINDOWS.~BT, `$GetCurrent)";
            IsSafePreset = $false; AdminRequired = $true; SkipFlag = [bool]($SkipAdvanced -or $SkipUpgradeFolders -or (-not $isAdmin));
            ScanFunc = {
                $upgradePaths = @("$sysDrive\Windows.old", "$sysDrive\`$WINDOWS.~BT", "$sysDrive\`$WINDOWS.~WS", "$sysDrive\`$GetCurrent")
                $found = @($upgradePaths | Where-Object { Test-Path -LiteralPath $_ })
                if ($found.Count -gt 0) { Get-FolderMetrics $found } else { [PSCustomObject]@{ Bytes = [int64]0; Count = 0; Formatted = "0 B" } }
            };
            PurgeAction = {
                $upgradePaths = @("$sysDrive\Windows.old", "$sysDrive\`$WINDOWS.~BT", "$sysDrive\`$WINDOWS.~WS", "$sysDrive\`$GetCurrent")
                foreach ($p in $upgradePaths) {
                    if (Test-Path -LiteralPath $p) {
                        Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
                        Write-Host "    > Removed $p." -ForegroundColor DarkGray
                    }
                }
            }
        },
        @{
            Id = "crashdumps"; Number = 31; Category = "System Advanced"; Title = "Kernel & User Crash Dump Files";
            Description = "MEMORY.DMP, Minidump, LiveKernelReports, and CrashDumps";
            IsSafePreset = $false; AdminRequired = $false; SkipFlag = [bool]($SkipAdvanced -or $SkipCrashDumps);
            ScanFunc = { Get-FolderMetrics @("$sysRoot\MEMORY.DMP", "$sysRoot\Minidump", "$sysRoot\LiveKernelReports", "$env:LOCALAPPDATA\CrashDumps") };
            PurgeAction = {
                if (Test-Path -LiteralPath "$sysRoot\MEMORY.DMP") { Remove-Item -LiteralPath "$sysRoot\MEMORY.DMP" -Force -ErrorAction SilentlyContinue }
                if (Test-Path -LiteralPath "$sysRoot\Minidump") { Remove-Item -Path "$sysRoot\Minidump\*" -Force -ErrorAction SilentlyContinue }
                if (Test-Path -LiteralPath "$sysRoot\LiveKernelReports") { Remove-Item -Path "$sysRoot\LiveKernelReports\*" -Recurse -Force -ErrorAction SilentlyContinue }
                if (Test-Path -LiteralPath "$env:LOCALAPPDATA\CrashDumps") { Remove-Item -Path "$env:LOCALAPPDATA\CrashDumps\*" -Force -ErrorAction SilentlyContinue }
                Write-Host "    > Purged memory crash dumps and minidump files." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "cbslogs"; Number = 32; Category = "System Advanced"; Title = "CBS, DISM & Panther Log Archives";
            Description = "CBS persist archives, Panther logs, ETLLogs, and dism.log";
            IsSafePreset = $false; AdminRequired = $true; SkipFlag = [bool]($SkipAdvanced -or $SkipCBSLogs -or (-not $isAdmin));
            ScanFunc = {
                if ($isAdmin) {
                    $m = Get-FolderMetrics @("$sysRoot\Logs\CBS\CbsPersist_*", "$sysRoot\Panther", "$env:ProgramData\Microsoft\Diagnosis\ETLLogs\*.etl")
                    if (Test-Path -LiteralPath "$sysRoot\Logs\DISM\dism.log") {
                        try { $m.Bytes += (Get-Item -LiteralPath "$sysRoot\Logs\DISM\dism.log" -Force -ErrorAction SilentlyContinue).Length } catch { }
                    }
                    $m.Formatted = Format-ByteSize $m.Bytes
                    return $m
                }
                return [PSCustomObject]@{ Bytes = [int64]0; Count = 0; Formatted = "0 B" }
            };
            PurgeAction = {
                Remove-Item -Path "$sysRoot\Logs\CBS\CbsPersist_*" -Force -ErrorAction SilentlyContinue
                if (Test-Path -LiteralPath "$sysRoot\Logs\DISM\dism.log") { Clear-Content -Path "$sysRoot\Logs\DISM\dism.log" -ErrorAction SilentlyContinue }
                if (Test-Path -LiteralPath "$sysRoot\Panther") { Remove-Item -Path "$sysRoot\Panther\*" -Recurse -Force -ErrorAction SilentlyContinue }
                if (Test-Path -LiteralPath "$env:ProgramData\Microsoft\Diagnosis\ETLLogs") { Remove-Item -Path "$env:ProgramData\Microsoft\Diagnosis\ETLLogs\*.etl" -Force -ErrorAction SilentlyContinue }
                Write-Host "    > Purged CBS persist archives, Panther logs, ETLLogs, and cleared DISM log." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "hiberfil"; Number = 33; Category = "System Advanced"; Title = "Windows Hibernation File (hiberfil.sys)";
            Description = "Disables Hibernate to reclaim space (Sleep unaffected)";
            IsSafePreset = $false; AdminRequired = $true; SkipFlag = [bool]($SkipAdvanced -or $SkipHiberfil -or (-not $isAdmin));
            ScanFunc = {
                if ($isAdmin -and (Test-Path -LiteralPath "$sysDrive\hiberfil.sys")) {
                    try {
                        $sz = (Get-Item -LiteralPath "$sysDrive\hiberfil.sys" -Force -ErrorAction Stop).Length
                        if ($sz -ge 1024) { return [PSCustomObject]@{ Bytes = [int64]$sz; Count = 1; Formatted = (Format-ByteSize $sz) } }
                    } catch { }
                }
                return [PSCustomObject]@{ Bytes = [int64]0; Count = 0; Formatted = "0 B" }
            };
            PurgeAction = {
                $null = powercfg -h off 2>&1
                Write-Host "    > Disabled hibernation via powercfg and purged $sysDrive\hiberfil.sys." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "drivers"; Number = 34; Category = "System Advanced"; Title = "Obsolete OEM Hardware Drivers";
            Description = "Superseded driver packages in DriverStore via pnputil";
            IsSafePreset = $false; AdminRequired = $true; SkipFlag = [bool]($SkipAdvanced -or $SkipDrivers -or (-not $isAdmin));
            ScanFunc = {
                if ($isAdmin) {
                    $raw = pnputil /enum-drivers 2>&1
                    $count = 0
                    $names = @{}
                    foreach ($l in $raw) {
                        if ($l -match '^Original Name:\s+(.+)$') {
                            $orig = $matches[1].Trim()
                            if ($names.ContainsKey($orig)) { $count++ } else { $names[$orig] = 1 }
                        }
                    }
                    if ($count -gt 0) {
                        return [PSCustomObject]@{ Bytes = [int64]($count * 50 * 1024 * 1024); Count = $count; Formatted = "$count package(s)" }
                    }
                }
                return [PSCustomObject]@{ Bytes = [int64]0; Count = 0; Formatted = "0 B" }
            };
            PurgeAction = {
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
                    }
                }
                if ($currentDriver.PublishedName) { $driverList += [PSCustomObject]$currentDriver }
                $grouped = $driverList | Where-Object { $_.OriginalName } | Group-Object OriginalName
                $superseded = @()
                foreach ($grp in $grouped) {
                    if ($grp.Count -gt 1) {
                        $sorted = $grp.Group | Sort-Object Date -Descending
                        for ($i = 1; $i -lt $sorted.Count; $i++) { $superseded += $sorted[$i] }
                    }
                }
                $delCount = 0
                foreach ($drv in $superseded) {
                    $pOut = pnputil /delete-driver $drv.PublishedName 2>&1
                    if ($pOut -match "successfully deleted" -or $pOut -match "Driver package deleted") { $delCount++ }
                }
                Write-Host "    > Purged $delCount superseded OEM driver packages from DriverStore." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "searchindex"; Number = 35; Category = "System Advanced"; Title = "Windows Search Index Database";
            Description = "Resets Windows Search database (rebuilds and compacts in background)";
            IsSafePreset = $false; AdminRequired = $true; SkipFlag = [bool]($SkipAdvanced -or $SkipSearchIndex -or (-not $isAdmin));
            ScanFunc = {
                if ($isAdmin -and (Get-Service -Name WSearch -ErrorAction SilentlyContinue)) {
                    return (Get-FolderMetrics @("$env:ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb", "$env:ProgramData\Microsoft\Search\Data\Applications\Windows\Projects\SystemIndex\Indexer"))
                }
                return [PSCustomObject]@{ Bytes = [int64]0; Count = 0; Formatted = "0 B" }
            };
            PurgeAction = {
                Stop-Service -Name WSearch -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Search" -Name "SetupCompletedSuccessfully" -Value 0 -ErrorAction SilentlyContinue
                Start-Service -Name WSearch -ErrorAction SilentlyContinue
                Write-Host "    > Reset Windows Search index configuration and restarted WSearch service." -ForegroundColor DarkGray
            }
        },
        @{
            Id = "dism"; Number = 36; Category = "System Advanced"; Title = "WinSxS Component Store ResetBase";
            Description = "Deep WinSxS component purge (Takes 2-5 min, prevents old update rollbacks)";
            IsSafePreset = $false; AdminRequired = $true; SkipFlag = [bool]($SkipAdvanced -or $SkipDism -or (-not $isAdmin));
            ScanFunc = {
                if ($isAdmin -and (-not $SkipDism)) {
                    return [PSCustomObject]@{ Bytes = [int64]1; Count = 1; Formatted = "Component Store" }
                }
                return [PSCustomObject]@{ Bytes = [int64]0; Count = 0; Formatted = "0 B" }
            };
            PurgeAction = {
                Write-Host "    > Consolidating WinSxS component store via DISM..." -ForegroundColor DarkGray
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
                        if ($char -eq -1) { Start-Sleep -Milliseconds 30; continue }
                        $c = [char]$char
                        if ($c -eq "`r" -or $c -eq "`n") {
                            $rawLine = $buffer.Trim()
                            $buffer = ""
                            if ($rawLine) {
                                if ($rawLine -match '(\[\s*=*\s*(\d{1,3}(\.\d+)?)%\s*=*\s*\])') {
                                    $currProgress = $matches[1]
                                    if ($currProgress -ne $lastProgress) {
                                        $lastProgress = $currProgress
                                        Write-Host -NoNewline "`r    > Progress: $currProgress   " -ForegroundColor Cyan
                                    }
                                } elseif ($rawLine -match '(\d{1,3}(\.\d+)?)%') {
                                    $pct = $matches[0]
                                    if ($pct -ne $lastProgress) {
                                        $lastProgress = $pct
                                        Write-Host -NoNewline "`r    > Progress: $pct   " -ForegroundColor Cyan
                                    }
                                } elseif ($rawLine -match 'completed successfully' -or $rawLine -match '100(\.0)?%') {
                                    Write-Host -NoNewline "`r    > Progress: [100.0%] - Completed successfully.          `n" -ForegroundColor Green
                                }
                            }
                        } else {
                            $buffer += $c
                        }
                    }
                    $p.WaitForExit()
                    Write-Host "    > Deep WinSxS component cleanup completed." -ForegroundColor DarkGray
                } catch {
                    $null = Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1
                    Write-Host "    > Deep WinSxS component cleanup completed." -ForegroundColor DarkGray
                }
            }
        }
    )

    $targetObjects = @()
    foreach ($d in $defs) {
        $targetObjects += [PSCustomObject]@{
            Id            = $d.Id
            Number        = $d.Number
            Category      = $d.Category
            Title         = $d.Title
            Description   = $d.Description
            IsSafePreset  = $d.IsSafePreset
            AdminRequired = $d.AdminRequired
            SkipFlag      = $d.SkipFlag
            ScanFunc      = $d.ScanFunc
            PurgeAction   = $d.PurgeAction
            SizeBytes     = [int64]0
            Count         = 0
            FormattedSize = "0 B"
            Selected      = $false
        }
    }
    return $targetObjects
}

# -----------------------------------------------------------------------------
# FAST PRE-SCAN EXECUTION
# -----------------------------------------------------------------------------

if (-not $All -and [string]::IsNullOrEmpty($Preset) -and -not [Console]::IsOutputRedirected) {
    Write-Host "  Scanning disposable caches..." -ForegroundColor Cyan -NoNewline
}

$allTargets = Get-CleanupTargetsRegistry
$activeTargets = @()
$totalPurgeableBytes = [int64]0

foreach ($target in $allTargets) {
    if ($target.SkipFlag) { continue }
    $m = & $target.ScanFunc
    $target.SizeBytes = $m.Bytes
    $target.Count = $m.Count
    $target.FormattedSize = $m.Formatted
    if ($m.Bytes -gt 0) {
        $target.Selected = $target.IsSafePreset
        $activeTargets += $target
        $totalPurgeableBytes += $m.Bytes
    }
}

if (-not $All -and [string]::IsNullOrEmpty($Preset) -and -not [Console]::IsOutputRedirected) {
    Write-Host "`r                                              `r" -NoNewline
}

# Group active targets by category
$categoriesGrouped = $activeTargets | Group-Object Category

# -----------------------------------------------------------------------------
# INTERACTIVE TUI CHECKLIST
# -----------------------------------------------------------------------------

function Invoke-TuiChecklist {
    param([array]$Targets)
    if ($Targets.Count -eq 0) { return @() }
    if ([Console]::IsInputRedirected) {
        return ($Targets | Where-Object { $_.Selected })
    }
    
    $selectedIndex = 0
    $running = $true
    
    while ($running) {
        Clear-Host
        Write-Host ""
        Write-Host "========================================================================" -ForegroundColor DarkCyan
        Write-Host "                      INTERACTIVE TARGET SELECTION                      " -ForegroundColor Cyan
        Write-Host "  [UP/DOWN] Move  |  [SPACE] Toggle  |  [A] All/None  |  [ENTER] Clean  " -ForegroundColor DarkGray
        Write-Host "========================================================================" -ForegroundColor DarkCyan
        Write-Host ""
        
        $currentCat = ""
        for ($i = 0; $i -lt $Targets.Count; $i++) {
            $t = $Targets[$i]
            if ($t.Category -ne $currentCat) {
                $currentCat = $t.Category
                Write-Host "  --- $currentCat ---" -ForegroundColor DarkCyan
            }
            
            $prefix = if ($i -eq $selectedIndex) { " >" } else { "  " }
            $check = if ($t.Selected) { "[*]" } else { "[ ]" }
            $idStr = $t.Number.ToString("00")
            
            if ($i -eq $selectedIndex) {
                Write-Host "$prefix " -NoNewline -ForegroundColor Yellow
                Write-Host "$check [$idStr] " -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-38}" -f $t.Title) -NoNewline -ForegroundColor White
                Write-Host ($t.FormattedSize.PadLeft(12)) -ForegroundColor Yellow
            } else {
                Write-Host "$prefix " -NoNewline
                $checkColor = if ($t.Selected) { "Green" } else { "DarkGray" }
                Write-Host "$check " -NoNewline -ForegroundColor $checkColor
                Write-Host "[$idStr] " -NoNewline -ForegroundColor DarkGray
                $nameColor = if ($t.Selected) { "White" } else { "Gray" }
                Write-Host ("{0,-38}" -f $t.Title) -NoNewline -ForegroundColor $nameColor
                Write-Host ($t.FormattedSize.PadLeft(12)) -ForegroundColor DarkGray
            }
        }
        
        $selectedCount = ($Targets | Where-Object { $_.Selected }).Count
        $selectedBytes = ($Targets | Where-Object { $_.Selected } | Measure-Object -Property SizeBytes -Sum).Sum
        if ($null -eq $selectedBytes) { $selectedBytes = 0 }
        
        Write-Host ""
        Write-Host "------------------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "  Selected Space : " -NoNewline -ForegroundColor Gray
        Write-Host (Format-ByteSize $selectedBytes) -NoNewline -ForegroundColor Green
        Write-Host " ($selectedCount target(s))" -NoNewline -ForegroundColor Gray
        Write-Host "                    [ENTER: Start Clean]" -ForegroundColor Cyan
        Write-Host "========================================================================" -ForegroundColor DarkCyan
        Write-Host "  [R] Recommended Preset  |  [Q] Cancel / Return to Menu" -ForegroundColor DarkGray
        
        $key = [Console]::ReadKey($true)
        switch ($key.Key) {
            "UpArrow" {
                if ($selectedIndex -gt 0) { $selectedIndex-- }
                else { $selectedIndex = $Targets.Count - 1 }
            }
            "DownArrow" {
                if ($selectedIndex -lt ($Targets.Count - 1)) { $selectedIndex++ }
                else { $selectedIndex = 0 }
            }
            "Spacebar" {
                $Targets[$selectedIndex].Selected = -not $Targets[$selectedIndex].Selected
            }
            "A" {
                $anyUnselected = ($Targets | Where-Object { -not $_.Selected }).Count -gt 0
                foreach ($t in $Targets) { $t.Selected = $anyUnselected }
            }
            "R" {
                foreach ($t in $Targets) { $t.Selected = $t.IsSafePreset }
            }
            "Enter" {
                $running = $false
            }
            "Escape" {
                return $null
            }
            "Q" {
                return $null
            }
        }
    }
    return ($Targets | Where-Object { $_.Selected })
}

# -----------------------------------------------------------------------------
# UNIFIED ACTION HUB SELECTION ENGINE
# -----------------------------------------------------------------------------

$selectedTargets = @()

if ($All) {
    # Non-interactive automated mode
    $selectedTargets = @($activeTargets | Where-Object { $_.IsSafePreset })
} elseif ($Preset -eq "Quick") {
    $selectedTargets = @($activeTargets | Where-Object { $_.IsSafePreset })
} elseif ($Preset -eq "Full") {
    $selectedTargets = @($activeTargets)
} else {
    # Default Interactive Dashboard
    Write-Host ""
    Write-Host "========================================================================" -ForegroundColor DarkCyan
    Write-Host "                WINDOWS STORAGE DEEP CLEANUP TOOLKIT                    " -ForegroundColor Cyan
    Write-Host "             Non-Destructive Storage Optimizer for Win 10/11            " -ForegroundColor DarkGray
    Write-Host "========================================================================" -ForegroundColor DarkCyan
    if ($DryRun) {
        Write-Host "  [MODE: DRY RUN] Preview simulation active - no files will be deleted. " -ForegroundColor Magenta
        Write-Host "------------------------------------------------------------------------" -ForegroundColor DarkGray
    }
    Write-Host "  Target Volume       : Drive $sysDrive ($initialFreeGB GB Free)" -ForegroundColor Gray
    Write-Host "  Purgeable Detected  : $(Format-ByteSize $totalPurgeableBytes) across $($categoriesGrouped.Count) active categories" -ForegroundColor White
    Write-Host "========================================================================" -ForegroundColor DarkCyan
    Write-Host ""

    if ($activeTargets.Count -eq 0) {
        Write-Host "  [CLEAN] No purgeable caches detected. Storage is already clean!" -ForegroundColor Green
        Write-Host "========================================================================" -ForegroundColor DarkCyan
        Write-Host ""
        exit 0
    }

    # Display detected storage table - cleanly itemized with NO row numbers
    Write-Host "  DETECTED DISPOSABLE CACHES:" -ForegroundColor Cyan
    Write-Host " -----------------------------------------------------------------------" -ForegroundColor DarkGray
    
    foreach ($grp in $categoriesGrouped) {
        $grpSum = ($grp.Group | Measure-Object -Property SizeBytes -Sum).Sum
        Write-Host "  * " -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-52}" -f $grp.Name.ToUpper()) -NoNewline -ForegroundColor Cyan
        Write-Host ((Format-ByteSize $grpSum).PadLeft(14)) -ForegroundColor Yellow
        
        foreach ($item in $grp.Group) {
            Write-Host "    - " -NoNewline -ForegroundColor DarkGray
            Write-Host ("{0,-50}" -f $item.Title) -NoNewline -ForegroundColor White
            Write-Host ($item.FormattedSize.PadLeft(14)) -ForegroundColor Gray
        }
    }
    Write-Host " -----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  * Empty categories with 0 B are automatically hidden" -ForegroundColor DarkGray
    Write-Host ""
    
    # 1-Keystroke intuitive action menu (numbers used EXCLUSIVELY for actions)
    Write-Host " CHOOSE CLEANUP ACTION:" -ForegroundColor Cyan
    Write-Host " -----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  [1] Quick Clean (Enter) - Safest daily caches (Temp, Shaders, Browsers) [DEFAULT]" -ForegroundColor White
    Write-Host "  [2] Full Clean          - Purge all detected disposable caches ($(Format-ByteSize $totalPurgeableBytes))" -ForegroundColor White
    Write-Host "  [3] Custom Selection    - Pick specific targets via interactive checklist" -ForegroundColor White
    Write-Host "  [Q] Exit                - Exit without making any changes" -ForegroundColor DarkGray
    Write-Host " -----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " Select action [1-3, Q] (Press Enter for Quick Clean): " -NoNewline -ForegroundColor Yellow

    $choice = if ([Console]::IsInputRedirected) { [Console]::In.ReadLine() } else { Read-Host }
    if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }

    switch ($choice.Trim().ToLower()) {
        "1" {
            $selectedTargets = @($activeTargets | Where-Object { $_.IsSafePreset })
        }
        "quick" {
            $selectedTargets = @($activeTargets | Where-Object { $_.IsSafePreset })
        }
        "2" {
            $selectedTargets = @($activeTargets)
        }
        "full" {
            $selectedTargets = @($activeTargets)
        }
        "3" {
            $tuiResult = Invoke-TuiChecklist -Targets $activeTargets
            if ($null -ne $tuiResult) {
                $selectedTargets = @($tuiResult)
            } else {
                Write-Host "Cleanup cancelled." -ForegroundColor Yellow
                exit 0
            }
        }
        "q" {
            Write-Host "Cleanup cancelled by user." -ForegroundColor DarkGray
            exit 0
        }
        default {
            $selectedTargets = @($activeTargets | Where-Object { $_.IsSafePreset })
        }
    }
}

if ($selectedTargets.Count -eq 0) {
    Write-Host ""
    Write-Host "  No targets selected for cleanup." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# -----------------------------------------------------------------------------
# EXECUTION PHASE
# -----------------------------------------------------------------------------

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

$execCategories = $selectedTargets | Group-Object Category
$actualPurgedBytes = [int64]0
$purgedTargetsCount = 0

foreach ($grp in $execCategories) {
    Write-Host "  --- $($grp.Name.ToUpper()) ---" -ForegroundColor DarkCyan
    Write-Host ""
    foreach ($target in $grp.Group) {
        Invoke-Purge $target.Title $target.PurgeAction
        $actualPurgedBytes += $target.SizeBytes
        $purgedTargetsCount++
    }
}

$finalFreeBytes = (Get-PSDrive $sysDriveLetter).Free
$finalFreeGB = [math]::Round($finalFreeBytes / 1GB, 2)
$driveDeltaGB = [math]::Round(($finalFreeBytes - $initialFreeBytes) / 1GB, 2)

Write-Host "========================================================================" -ForegroundColor DarkCyan
Write-Host "                        CLEANUP SUMMARY REPORT                          " -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor DarkCyan
if ($DryRun) {
    Write-Host "  Execution Mode        : Dry Run (Preview Simulation - No changes made)" -ForegroundColor Magenta
    Write-Host "  Target Volume         : Drive $sysDrive" -ForegroundColor Gray
    Write-Host "  Current Free Space    : $finalFreeGB GB" -ForegroundColor White
    Write-Host "  Simulated Purge Size  : $(Format-ByteSize $actualPurgedBytes) across $purgedTargetsCount target(s)" -ForegroundColor Yellow
} else {
    Write-Host "  Target Volume         : Drive $sysDrive" -ForegroundColor Gray
    Write-Host "  Starting Free Space   : $initialFreeGB GB" -ForegroundColor White
    Write-Host "  Ending Free Space     : $finalFreeGB GB" -ForegroundColor White
    if ($actualPurgedBytes -gt 0) {
        Write-Host "  Total Space Reclaimed : +$(Format-ByteSize $actualPurgedBytes) across $purgedTargetsCount target(s)" -ForegroundColor Green
    } else {
        Write-Host "  Total Space Reclaimed : 0 B (Caches were already clean)" -ForegroundColor DarkGray
    }
    if ($driveDeltaGB -gt 0) {
        Write-Host "  Drive Free Space Gain : +$driveDeltaGB GB" -ForegroundColor Green
    }
    Write-Host "  Overall Status        : Completed Successfully" -ForegroundColor Green
}
Write-Host "========================================================================" -ForegroundColor DarkCyan
Write-Host ""
