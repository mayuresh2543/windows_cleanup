# Windows Storage Deep Cleanup

> A non-destructive system storage optimizer for Windows 10 & 11 designed to reclaim gigabytes of disk space.

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207%2B-blue?logo=powershell)](https://microsoft.com/PowerShell)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%2F%2011-0078D6?logo=windows)](https://microsoft.com/windows)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/mayuresh2543/windows_cleanup?style=social)](https://github.com/mayuresh2543/windows_cleanup)

---

> [!NOTE]
> Run PowerShell or the batch launcher as Administrator for full access to system stores (Windows Update, drivers, shadow copies, and WinSxS).

---

## Features

- **Sizing Pre-Scan**: Dynamically measures directory sizes across all 22 targets in milliseconds before prompting, showing exact detected space (e.g., `Found 8.57 GB`).
- **Automatic 0-Byte Bypass**: Targets with 0 bytes, empty caches, or uninstalled applications are automatically excluded from the selection wizard and skipped.
- **Individual Browser Granularity**: Dedicated prompts and controls for **Google Chrome**, **Mozilla Firefox**, and **Brave Browser** (scans all user profiles).
- **Individual Game Launcher Granularity**: Dedicated prompts and controls for **Steam** and **Epic Games Store**.
- **GPU Hardware Shader Pruning**: Purges unmanaged NVIDIA, AMD, and Intel hardware shader disks alongside DirectX `D3DSCache`.
- **System Drive Portability**: Automatically resolves system drive letters (`$env:SystemDrive`, `$env:SystemRoot`) rather than assuming static `C:\`.
- **QuickEdit Freeze Prevention**: Dynamically disables console QuickEdit mode via low-level Win32 API (`kernel32.dll` `SetConsoleMode`), preventing accidental process suspension when clicking inside the terminal.
- **Real-Time DISM Progress**: Streams live progress percentages (`Progress: [====== 20.0% ======]`) indented cleanly during WinSxS consolidation (`DISM /ResetBase`).
- **Zero Emojis**: Clean, modern terminal formatting using standard ASCII dividers, aligned status badges (`[ CLEANING ]`, `[ SKIPPED  ]`, `[ DRY-RUN  ]`), and free space scorecards.
- **Preserves Critical User Data**: Browser logins, cookies, session history, game installations, and save files are strictly preserved.

---

## Terminal Preview

```text
========================================================================
                WINDOWS STORAGE DEEP CLEANUP TOOLKIT                    
             Non-Destructive Storage Optimizer for Win 10/11            
========================================================================
  Target Volume       : Drive C:
  Initial Free Space  : 14.74 GB
========================================================================

 [CONFIG] Select cleanup targets (Press Enter to accept default):
------------------------------------------------------------------------

  [01] User & Windows Temp Directories
       Found 5.81 MB disposable temporary caches in %TEMP% and C:\Windows\Temp
       Clean this target? [Y/n]: 

  [02] DirectX, GPU Shaders & Error Reporting Logs
       Found 1.91 GB shaders (DirectX, NVIDIA, AMD, Intel) and WER archives
       Clean this target? [Y/n]: 

  [03] Windows Recycle Bin
       Found 3.52 GB discarded files across drive bins
       Clean this target? [Y/n]: 

  [04] Explorer Thumbnail & Icon Caches
       Found 47.3 MB cached Explorer thumbnail databases (thumbcache_*.db)
       Clean this target? [Y/n]: 

  [06] Windows Delivery Optimization Cache - None found / 0 B (Clean)

  [07] Google Chrome Web & Code Cache
       Found 8.57 GB cached web assets and compiled code caches across profiles
       Clean this target? [Y/n]: 

  [08] Mozilla Firefox Web & Startup Cache
       Found 717.05 MB offline cache2 files and startup cache across profiles
       Clean this target? [Y/n]: 

  [09] Brave Browser Web & Code Cache
       Found 512.78 MB cached web assets and compiled code caches across profiles
       Clean this target? [Y/n]: 

  [10] Media & Chat Caches (Spotify, Discord, Slack, Teams, Telegram, Zoom)
       Found 340.50 MB streaming audio, chat media, and code caches
       Clean this target? [Y/n]: 

  [11] Steam Web & HTTP Cache - None found / 0 B (Clean)

  [12] Epic Games Store Web Cache - None found / 0 B (Clean)

========================================================================
                       EXECUTING STORAGE CLEANUP                        
========================================================================

  [ CLEANING ] User and Windows Temp Directories...
               Purged %TEMP%, C:\Windows\Temp, and ServiceProfile disposable caches.

  [ CLEANING ] DirectX, GPU Shaders & Windows Error Reporting Logs...
               Purged DirectX, NVIDIA, AMD, Intel shader caches and WER logs.

  [ CLEANING ] Windows Recycle Bin...
               Emptied Windows Recycle Bin across all drives.

  [ CLEANING ] Google Chrome Web & Code Cache...
               Purged Google Chrome web cache, code cache, and GPU cache.

  [ CLEANING ] Mozilla Firefox Web & Startup Cache...
               Purged Mozilla Firefox cache2 and startupCache directories.

  [ CLEANING ] Brave Browser Web & Code Cache...
               Purged Brave Browser web cache, code cache, and GPU cache.

========================================================================
                        CLEANUP SUMMARY REPORT                          
========================================================================
  Target Volume         : Drive C:
  Starting Free Space   : 14.74 GB
  Ending Free Space     : 29.53 GB
  Total Space Reclaimed : +14.79 GB
  Overall Status        : Completed Successfully
========================================================================
```

---

## Quick Start

### 1. Remote One-Liner (No Git Clone Required)
Open **PowerShell as Administrator** and run:

```powershell
irm https://raw.githubusercontent.com/mayuresh2543/windows_cleanup/main/cleanup.ps1 | iex
```

### 2. Desktop Launcher
Double-click [`cleanup.bat`](cleanup.bat). The launcher checks for Administrator privileges, requests UAC elevation if needed, sets console QuickEdit safety flags, and starts the cleanup.

### 3. Local PowerShell Run
Clone the repository and run directly from an elevated terminal:

```powershell
# Interactive run (default):
.\cleanup.ps1

# Unattended run (clean all eligible targets without prompts):
.\cleanup.ps1 -All

# Simulation mode (preview targets without deleting files):
.\cleanup.ps1 -DryRun
```

---

## Cleanup Targets (22 Categories)

| # | Category | Scope / Path | Requires Admin | Default Prompt | Skip Flag |
| :---: | :--- | :--- | :---: | :---: | :--- |
| **01** | **User & Windows Temp** | `%TEMP%`, `C:\Windows\Temp`, ServiceProfile Temp | No | `[Y/n]` | — |
| **02** | **DirectX & GPU Shaders** | `D3DSCache`, NVIDIA (`DXCache`/`GLCache`), AMD, Intel, WER | No | `[Y/n]` | — |
| **03** | **Windows Recycle Bin** | Empty recycle bins across all drives via `Clear-RecycleBin` | No | `[Y/n]` | `-SkipRecycleBin` |
| **04** | **Explorer Thumbnails & Icons** | Explorer `thumbcache_*.db`, `iconcache_*.db`, `IconCache.db` | No | `[Y/n]` | `-SkipThumbnails` |
| **05** | **Windows Update Store** | `C:\Windows\SoftwareDistribution\Download` | **Yes** | `[Y/n]` | — |
| **06** | **Delivery Optimization** | Windows peer-to-peer update distribution cache | No | `[Y/n]` | — |
| **07** | **Google Chrome Cache** | Chrome web cache, code cache, GPUCache across all profiles | No | `[Y/n]` | `-SkipChrome` *(or `-SkipBrowsers`)* |
| **08** | **Mozilla Firefox Cache** | Firefox `cache2` and `startupCache` across all profiles | No | `[Y/n]` | `-SkipFirefox` *(or `-SkipBrowsers`)* |
| **09** | **Brave Browser Cache** | Brave web cache, code cache, GPUCache across all profiles | No | `[Y/n]` | `-SkipBrave` *(or `-SkipBrowsers`)* |
| **10** | **Media & Chat Caches** | Spotify, Discord, Slack, Microsoft Teams, Telegram, Zoom | No | `[Y/n]` | `-SkipMediaApps` |
| **11** | **Steam Launcher Cache** | Steam `htmlcache` and `appcache\httpcache` | No | `[Y/n]` | `-SkipSteam` *(or `-SkipGames`)* |
| **12** | **Epic Games Store Cache** | Epic Games Launcher `Saved\webcache*` | No | `[Y/n]` | `-SkipEpic` *(or `-SkipGames`)* |
| **13** | **Developer Toolchains** | Pip, VS Code, NPM, Yarn, pnpm, NuGet, Gradle, Cargo, Go | No | `[Y/n]` | `-SkipDevCaches` |
| **14** | **Creative Media Caches** | Adobe Common Media Cache, DaVinci Resolve `CacheClip` | No | `[Y/n]` | `-SkipCreativeApps` |
| **15** | **Volume Shadow Copies** | Purges oldest shadow copy snapshots via `vssadmin` | **Yes** | `[Y/n]` | `-SkipRestorePoints` |
| **16** | **Upgrade Folders** | `C:\Windows.old`, `$WINDOWS.~BT`, `$WINDOWS.~WS`, `$GetCurrent` | **Yes** | `[Y/n]` | `-SkipUpgradeFolders` |
| **17** | **Crash Dumps** | `MEMORY.DMP`, `Minidump`, `LiveKernelReports`, `CrashDumps` | **Yes** / No | `[Y/n]` | `-SkipCrashDumps` |
| **18** | **CBS, DISM & Panther Logs** | `CbsPersist_*.cab`, `dism.log`, `Panther`, `ETLLogs` | **Yes** | `[Y/n]` | `-SkipCBSLogs` |
| **19** | **Hibernation File** | Disables hibernation via `powercfg -h off` (`C:\hiberfil.sys`) | **Yes** | `[Y/n]` | `-SkipHiberfil` |
| **20** | **Obsolete OEM Drivers** | Superseded INF packages in DriverStore via `pnputil` | **Yes** | `[Y/n]` | `-SkipDrivers` |
| **21** | **Windows Search Index** | Resets `SetupCompletedSuccessfully` and rebuilds index | **Yes** | `[Y/n]` | `-SkipSearchIndex` |
| **22** | **WinSxS Component Store** | `DISM /StartComponentCleanup /ResetBase` | **Yes** | `[y/N]` *(Opt-in)* | `-SkipDism` |

---

## Command-Line Automation Flags

| Flag | Purpose |
| :--- | :--- |
| `-All` | Cleans all eligible targets without interactive Yes/No confirmation prompts. |
| `-DryRun` | Simulates cleanup and prints targets without deleting files. |
| `-SkipRecycleBin` | Skips emptying the Windows Recycle Bin. |
| `-SkipThumbnails` | Skips purging Windows Explorer thumbnail and icon caches. |
| `-SkipBrowsers` | Skips all web browser caches (Chrome, Firefox, and Brave). |
| `-SkipChrome` | Skips Google Chrome web and code caches. |
| `-SkipFirefox` | Skips Mozilla Firefox web and startup caches. |
| `-SkipBrave` | Skips Brave Browser web and code caches. |
| `-SkipMediaApps` | Skips Spotify, Discord, Slack, Microsoft Teams, Telegram, and Zoom caches. |
| `-SkipGames` | Skips all game launcher caches (Steam and Epic Games Store). |
| `-SkipSteam` | Skips Steam web and HTTP network caches. |
| `-SkipEpic` | Skips Epic Games Store web caches. |
| `-SkipDevCaches` | Skips Pip, VS Code, NPM, Yarn, pnpm, NuGet, Gradle, Cargo, and Go caches. |
| `-SkipCreativeApps` | Skips Adobe Common Media Cache and DaVinci Resolve render cache files. |
| `-SkipRestorePoints` | Skips purging oldest volume shadow copies. |
| `-SkipUpgradeFolders` | Skips deleting `Windows.old`, `$WINDOWS.~BT`, and `$GetCurrent` rollback folders. |
| `-SkipCrashDumps` | Skips deleting kernel and user-mode memory crash dumps (`CrashDumps`). |
| `-SkipCBSLogs` | Skips purging CBS persist archives, Panther logs, and truncating DISM logs. |
| `-SkipHiberfil` | Skips disabling hibernation and deleting `C:\hiberfil.sys`. |
| `-SkipDrivers` | Skips scanning and purging superseded OEM drivers via `pnputil`. |
| `-SkipSearchIndex` | Skips resetting and rebuilding the Windows Search index database. |
| `-SkipDism` | Skips deep WinSxS component store cleanup (`DISM /ResetBase`). |

### Command Examples

```powershell
# Interactive run (default):
.\cleanup.ps1

# Full unattended cleanup:
.\cleanup.ps1 -All

# Dry run simulation:
.\cleanup.ps1 -DryRun

# Automated cleanup skipping system restore points, drivers, and Chrome:
.\cleanup.ps1 -All -SkipRestorePoints -SkipDrivers -SkipChrome
```

---

## Manual Reference (Individual Commands)

For users who prefer running specific commands individually:

### Navigation

- [1. System & OS-Level Storage](#system-storage)
  - [Empty Windows Recycle Bin](#recycle-bin)
  - [Disable or Shrink Hibernation](#disable-hibernation)
  - [Deep Component Store Cleanup (ResetBase)](#resetbase-cleanup)
  - [Clear Windows Update Download Cache](#update-cache)
  - [Purge Delivery Optimization Cache](#delivery-optimization)
  - [Rebuild Windows Explorer Thumbnail Cache](#thumbnail-cache)
  - [Purge Oldest Volume Shadow Copies](#shadow-copies)
  - [Delete Leftover Windows Upgrade Folders](#upgrade-folders)
  - [Delete Crash Dump Files](#crash-dumps)
  - [Purge CBS, DISM & Panther Log Archives](#cbs-logs)
  - [Purge Obsolete OEM Drivers](#driverstore-cleanup)
  - [Reset & Compact Windows Search Database](#search-index)
- [2. Browser, Media & Game Caches](#app-caches)
  - [Hardware GPU Shader Caches (NVIDIA & AMD)](#gpu-shader-caches)
  - [Web Browsers (Chrome, Firefox, Brave)](#browser-caches)
  - [Media & Communication Apps (Spotify, Discord, Slack, Teams, Telegram)](#media-caches)
  - [Game Launchers (Steam, Epic Games Store)](#game-caches)
  - [Creative Suite Caches (Adobe, DaVinci Resolve)](#creative-caches)
- [3. Developer Caches & Package Managers](#developer-caches)
  - [Python & Pip](#python-pip)
  - [Node.js (NPM, Yarn, pnpm)](#nodejs)
  - [.NET / NuGet](#dotnet-nuget)
  - [Java & Gradle](#java-gradle)
  - [Rust & Go](#rust-go)
  - [VS Code Caches & Workspaces](#vscode-cache)
  - [Docker Prune](#docker-prune)
- [4. WSL2 Virtual Disk Compaction](#wsl-compaction)
- [5. Storage Diagnostics](#diagnostic-tools)
- [6. Scheduled Automation](#task-scheduler)

---

<a id="system-storage"></a>
### 1. System & OS-Level Storage

<a id="recycle-bin"></a>
#### Empty Windows Recycle Bin
```powershell
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
```

<a id="disable-hibernation"></a>
#### Disable or Shrink Hibernation (6–16+ GB)
Windows reserves `C:\hiberfil.sys` matching 40%–100% of total RAM. If Hibernate mode is not used, disabling it deletes the file immediately:

```powershell
# Turn off hibernation (instantly deletes C:\hiberfil.sys):
powercfg -h off

# Turn on hibernation:
powercfg -h on

# Alternative: Reduce file size by 50% while keeping Fast Startup:
powercfg /h /type reduced
```

<a id="resetbase-cleanup"></a>
#### Deep Component Store Cleanup / ResetBase (2–8 GB)
Permanently purges all superseded Windows update components from `WinSxS`:

```powershell
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
```

<a id="update-cache"></a>
#### Clear Windows Update Download Cache (2–5 GB)
Removes downloaded update packages left behind after installation:

```powershell
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service -Name wuauserv -ErrorAction SilentlyContinue
```

<a id="delivery-optimization"></a>
#### Purge Delivery Optimization Cache (1–5 GB)
Cleans the Windows peer-to-peer update distribution cache:

```powershell
Delete-DeliveryOptimizationCache -Force
```

<a id="thumbnail-cache"></a>
#### Rebuild Windows Explorer Thumbnail Cache
Clears Explorer preview databases that can become bloated or corrupted:

```powershell
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db" -Force -ErrorAction SilentlyContinue
```

<a id="shadow-copies"></a>
#### Purge Oldest Volume Shadow Copies (1–10+ GB)
Purges older Volume Shadow Copy snapshots while preserving the latest restore point:

```powershell
# Delete the oldest shadow copy snapshot on Drive C:
vssadmin delete shadows /for=C: /oldest /quiet

# Inspect currently allocated shadow copy storage:
vssadmin list shadowstorage
```

<a id="upgrade-folders"></a>
#### Delete Leftover Windows Upgrade Folders (10–30+ GB)
After feature updates, previous OS rollback archives remain in `Windows.old` and `$WINDOWS.~BT`:

```powershell
Remove-Item -Path "C:\Windows.old" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\$WINDOWS.~BT" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\$WINDOWS.~WS" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\$GetCurrent" -Recurse -Force -ErrorAction SilentlyContinue
```

<a id="crash-dumps"></a>
#### Delete Crash Dump Files (1–16+ GB)
Purges kernel memory crash dumps and user-mode application crash dumps:

```powershell
Remove-Item -Path "C:\Windows\MEMORY.DMP" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Minidump\*" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\LiveKernelReports\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\CrashDumps\*" -Force -ErrorAction SilentlyContinue
```

<a id="cbs-logs"></a>
#### Purge CBS, DISM & Panther Log Archives (1–8+ GB)
Windows servicing creates archived cabinet files and upgrade logs that accumulate indefinitely:

```powershell
Remove-Item -Path "C:\Windows\Logs\CBS\CbsPersist_*" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Panther\*" -Recurse -Force -ErrorAction SilentlyContinue
if (Test-Path "C:\Windows\Logs\DISM\dism.log") { Clear-Content -Path "C:\Windows\Logs\DISM\dism.log" -ErrorAction SilentlyContinue }
```

<a id="driverstore-cleanup"></a>
#### Purge Obsolete OEM Drivers via pnputil (2–10+ GB)
When device drivers update, older superseded versions remain stored in DriverStore:

```powershell
# Delete an obsolete driver package (without /force to prevent removing active drivers):
pnputil /delete-driver oem#.inf
```

<a id="search-index"></a>
#### Reset & Compact Windows Search Database (2–10+ GB)
Resetting the Windows Search index configuration triggers an automatic database rebuild and compacts storage:

```powershell
Stop-Service -Name WSearch -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Search" -Name "SetupCompletedSuccessfully" -Value 0 -ErrorAction SilentlyContinue
Start-Service -Name WSearch -ErrorAction SilentlyContinue
```

---

<a id="app-caches"></a>
### 2. Browser, Media & Game Caches

<a id="gpu-shader-caches"></a>
#### Hardware GPU Shader Caches (NVIDIA, AMD, Intel)
```powershell
# NVIDIA:
Remove-Item -Path "$env:LOCALAPPDATA\NVIDIA\DXCache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\NVIDIA\GLCache\*" -Recurse -Force -ErrorAction SilentlyContinue

# AMD:
Remove-Item -Path "$env:LOCALAPPDATA\AMD\DxCache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\AMD\GLCache\*" -Recurse -Force -ErrorAction SilentlyContinue
```

<a id="browser-caches"></a>
#### Web Browsers (Chrome, Firefox, Brave)
Clears cached streaming assets, images, and code caches across all user profiles without logging you out of accounts:

```powershell
# Google Chrome (all profiles):
Get-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Cache\*" -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Code Cache\*" -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# Mozilla Firefox (all profiles):
Get-Item -Path "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2\*" -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# Brave Browser (all profiles):
Get-Item -Path "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Cache\*" -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-Item -Path "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Code Cache\*" -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
```

<a id="media-caches"></a>
#### Media & Communication Apps (Spotify, Discord, Slack, Teams, Telegram, Zoom)

```powershell
# Spotify:
Remove-Item -Path "$env:LOCALAPPDATA\Spotify\Storage\*" -Recurse -Force -ErrorAction SilentlyContinue

# Discord:
Remove-Item -Path "$env:APPDATA\discord\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:APPDATA\discord\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

# Slack:
Remove-Item -Path "$env:APPDATA\Slack\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

# Telegram Desktop:
Remove-Item -Path "$env:APPDATA\Telegram Desktop\tdata\user_data\media_cache\*" -Recurse -Force -ErrorAction SilentlyContinue
```

<a id="game-caches"></a>
#### Game Launchers (Steam, Epic Games Store)
Clears cached web views, banners, and network caches without touching game installations or save files:

```powershell
# Steam HTTP & web cache:
Remove-Item -Path "C:\Program Files (x86)\Steam\appcache\httpcache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\Steam\htmlcache\*" -Recurse -Force -ErrorAction SilentlyContinue

# Epic Games Store web cache:
Remove-Item -Path "$env:LOCALAPPDATA\EpicGamesLauncher\Saved\webcache*\*" -Recurse -Force -ErrorAction SilentlyContinue
```

<a id="creative-caches"></a>
#### Creative Suite Caches (Adobe & DaVinci Resolve)
```powershell
# Adobe Premiere / After Effects conformed media cache:
Remove-Item -Path "$env:APPDATA\Adobe\Common\Media Cache Files\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:APPDATA\Adobe\Common\Media Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

# DaVinci Resolve render cache:
Remove-Item -Path "$env:USERPROFILE\Videos\CacheClip\*" -Recurse -Force -ErrorAction SilentlyContinue
```

---

<a id="developer-caches"></a>
### 3. Developer Caches & Package Managers

<a id="python-pip"></a>
#### Python & Pip

```powershell
pip cache purge
```

<a id="nodejs"></a>
#### Node.js (NPM, Yarn, pnpm)

```powershell
npm cache clean --force
yarn cache clean
pnpm store prune
```

<a id="dotnet-nuget"></a>
#### .NET / NuGet

```powershell
dotnet nuget locals all --clear
```

<a id="java-gradle"></a>
#### Java & Gradle

```powershell
Remove-Item -Path "$env:USERPROFILE\.gradle\caches\*" -Recurse -Force -ErrorAction SilentlyContinue
```

<a id="rust-go"></a>
#### Rust & Go

```powershell
Remove-Item -Path "$env:USERPROFILE\.cargo\registry\cache\*" -Recurse -Force -ErrorAction SilentlyContinue
go clean -cache
```

<a id="vscode-cache"></a>
#### VS Code Caches & Workspaces

```powershell
Remove-Item -Path "$env:APPDATA\Code\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:APPDATA\Code\CachedData\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:APPDATA\Code\User\workspaceStorage\*" -Recurse -Force -ErrorAction SilentlyContinue
```

<a id="docker-prune"></a>
#### Docker Prune

```powershell
docker builder prune -f
docker system prune -f
```

---

<a id="wsl-compaction"></a>
### 4. WSL2 Virtual Disk Compaction

WSL2 virtual hard disks (`ext4.vhdx`) dynamically expand as files are written inside Linux, but **never automatically shrink** when files are deleted.

To compact the virtual disk back to its actual utilized size:

1. Terminate running WSL instances in PowerShell:
   ```powershell
   wsl --shutdown
   ```
2. Launch `diskpart` in PowerShell (Admin):
   ```powershell
   diskpart
   ```
3. Inside the `DISKPART>` prompt:
   ```cmd
   select vdisk file="C:\Users\YOUR_USERNAME\AppData\Local\Packages\CanonicalGroupLimited...\LocalState\ext4.vhdx"
   attach vdisk readonly
   compact vdisk
   detach vdisk
   exit
   ```

---

<a id="diagnostic-tools"></a>
### 5. Storage Diagnostics

Quick one-liners to inspect storage distribution:

```powershell
# Check free space on system drive:
Get-PSDrive $env:SystemDrive.TrimEnd(':') | Select-Object Name, @{Name="Free(GB)";Expression={[math]::Round($_.Free / 1GB, 2)}}

# Inspect hidden root system files (pagefile.sys, hiberfil.sys, swapfile.sys):
Get-Item "$env:SystemDrive\*.sys" -Force -ErrorAction SilentlyContinue | Select-Object Name, @{Name="Size(GB)";Expression={[math]::Round($_.Length / 1GB, 2)}}

# List top 10 largest files in your user profile:
Get-ChildItem -Path $env:USERPROFILE -Recurse -File -ErrorAction SilentlyContinue |
  Sort-Object Length -Descending |
  Select-Object -First 10 @{Name="Size(GB)";Expression={[math]::Round($_.Length / 1GB, 2)}}, FullName
```

---

<a id="task-scheduler"></a>
### 6. Scheduled Automation

To schedule an unattended monthly cleanup via Windows Task Scheduler:

```powershell
# Run once from PowerShell as Administrator:
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File D:\Github\windows_cleanup\cleanup.ps1 -All"
$Trigger = New-ScheduledTaskTrigger -Monthly -DaysOfWeek Monday -At 9am
Register-ScheduledTask -TaskName "Monthly Windows Storage Cleanup" -Action $Action -Trigger $Trigger -User "SYSTEM"
```

---

## License

Released under the [MIT License](LICENSE).
