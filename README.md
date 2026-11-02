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

- **Modern Action Hub & 1-Keystroke Presets**: Starts with an instant overview dashboard showing detected cache sizes across all categories. Press `[Enter]` to instantly run **Quick Clean** (safe temp, shaders, thumbnails, browser caches), `[2]` for **Full Clean**, `[3]` for the **Interactive TUI Checklist**, or `[4]` to launch the **Graphical UI**.
- **Interactive TUI Checklist**: Granular console selection using keyboard arrow keys (`↑`/`↓`) to navigate, `[SPACE]` to toggle targets, `[A]` for all/none, and `[ENTER]` to start cleaning. No tedious letter typing or sequential questionnaires.
- **Modern Dark-Mode Graphical UI (`-Gui`)**: Native Windows presentation window (WPF) with dark theme, category cards, toggle switches, and a live reclaimed space scoreboard. Built into Windows with zero external dependencies.
- **Zero False-Positive Sizing**: Accurately measures Delivery Optimization via `FileSizeInCache` (eliminates phantom multi-gigabyte reports after cleanup), accurately queries Recycle Bin via Windows Shell COM (eliminates phantom 3.7 KB from `desktop.ini` and orphaned index headers), and clamps sub-kilobyte empty directory stubs.
- **Automatic 0-Byte Bypass**: Categories and targets with 0 bytes, empty caches, or uninstalled applications are automatically hidden from view.
- **GPU Hardware Shader Pruning**: Purges unmanaged NVIDIA, AMD, and Intel hardware shader disks alongside DirectX `D3DSCache`.
- **System Drive Portability**: Automatically resolves system drive letters (`$env:SystemDrive`, `$env:SystemRoot`) rather than assuming static `C:\`.
- **QuickEdit Freeze Prevention**: Dynamically disables console QuickEdit mode via low-level Win32 API (`kernel32.dll` `SetConsoleMode`), preventing accidental process suspension when clicking inside the terminal.
- **Real-Time DISM Progress**: Streams live progress percentages (`Progress: [====== 20.0% ======]`) cleanly during WinSxS consolidation (`DISM /ResetBase`).
- **Zero Emojis & Pure ASCII**: Clean, modern terminal formatting using standard ASCII dividers, aligned status badges (`[ CLEANING ]`, `[ SKIPPED  ]`, `[ DRY-RUN  ]`), and free space scorecards.
- **Preserves Critical User Data**: Browser logins, cookies, session history, game installations, and save files are strictly preserved.

---

## Terminal Preview

```text
========================================================================
                WINDOWS STORAGE DEEP CLEANUP TOOLKIT                    
             Non-Destructive Storage Optimizer for Win 10/11            
========================================================================
  Target Volume       : Drive C: (26.94 GB Free)
  Purgeable Detected  : 296.50 MB across 2 active categories
========================================================================

  #   Category                Active Items                          Size
 -----------------------------------------------------------------------
 [1]  System Caches         User & Windows Temp Directories...   81.32 MB
 [2]  Browser Caches        Google Chrome Web & Code Cache,...  215.18 MB
 -----------------------------------------------------------------------
  * Empty categories with 0 B are automatically hidden

 Choose cleanup action:
   [1] Quick Clean (Recommended: Temp, Shaders, Thumbnails, Web Caches)  [DEFAULT]
   [2] Full Clean  (Purge all detected safe caches: 296.50 MB)
   [3] Interactive (TUI Checklist: Arrow keys to navigate, Space to toggle)
   [4] Graphical UI (Open Modern Dark Mode Window)
   [Q] Exit

 Select [1-4, Q] (Press Enter for Quick Clean): 

========================================================================
                       EXECUTING STORAGE CLEANUP                        
========================================================================

  --- SYSTEM CACHES ---

  [ CLEANING ] User & Windows Temp Directories...
               Purged %TEMP%, C:\Windows\Temp, and ServiceProfile disposable caches.

  [ CLEANING ] DirectX, GPU Shaders & WER Logs...
               Purged DirectX, NVIDIA, AMD, Intel shader caches and WER logs.

  [ CLEANING ] Explorer Thumbnail & Icon Caches...
               Purged Explorer thumbcache and iconcache databases.

  --- BROWSER CACHES ---

  [ CLEANING ] Google Chrome Web & Code Cache...
               Purged Google Chrome web cache, code cache, and GPU cache.

  [ CLEANING ] Brave Browser Web & Code Cache...
               Purged Brave Browser web cache, code cache, and GPU cache.

========================================================================
                        CLEANUP SUMMARY REPORT                          
========================================================================
  Target Volume         : Drive C:
  Starting Free Space   : 26.94 GB
  Ending Free Space     : 27.24 GB
  Total Space Reclaimed : +0.30 GB
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
# Interactive Action Hub Dashboard & 1-keystroke presets (default):
.\cleanup.ps1

# Launch modern Dark-Mode Graphical UI (WPF window):
.\cleanup.ps1 -Gui

# Fast unattended execution via presets (Quick or Full):
.\cleanup.ps1 -Preset Quick
.\cleanup.ps1 -Preset Full

# Unattended run (clean all eligible targets without prompts):
.\cleanup.ps1 -All

# Simulation mode (preview targets without deleting files):
.\cleanup.ps1 -DryRun
```

---

## Cleanup Targets (7 Categories, 36 Granular Targets)

### 1. System Caches (`-SkipSystem`)
| # | Target | Scope / Path | Requires Admin | Skip Flag |
| :---: | :--- | :--- | :---: | :--- |
| **01** | **User & Windows Temp** | `%TEMP%`, `C:\Windows\Temp`, ServiceProfile Temp | No | `-SkipTemp` |
| **02** | **DirectX & GPU Shaders** | `D3DSCache`, NVIDIA (`DXCache`/`GLCache`), AMD, Intel, WER | No | `-SkipShaders` |
| **03** | **Windows Recycle Bin** | Empty recycle bins across all drives via `Clear-RecycleBin` | No | `-SkipRecycleBin` |
| **04** | **Explorer Thumbnails & Icons** | Explorer `thumbcache_*.db`, `iconcache_*.db`, `IconCache.db` | No | `-SkipThumbnails` |
| **05** | **Windows Update Store** | `C:\Windows\SoftwareDistribution\Download` | **Yes** | `-SkipWindowsUpdate` |
| **06** | **Delivery Optimization** | Windows peer-to-peer update distribution cache | No | `-SkipDeliveryOptimization` |

### 2. Browser Caches (`-SkipBrowsers`)
| # | Target | Scope / Path | Requires Admin | Skip Flag |
| :---: | :--- | :--- | :---: | :--- |
| **07** | **Google Chrome** | Chrome web cache, code cache, GPUCache across all profiles | No | `-SkipChrome` |
| **08** | **Mozilla Firefox** | Firefox `cache2` and `startupCache` across all profiles | No | `-SkipFirefox` |
| **09** | **Brave Browser** | Brave web cache, code cache, GPUCache across all profiles | No | `-SkipBrave` |

### 3. Game Launcher Caches (`-SkipGames`)
| # | Target | Scope / Path | Requires Admin | Skip Flag |
| :---: | :--- | :--- | :---: | :--- |
| **10** | **Steam Launcher** | Steam `htmlcache` and `appcache\httpcache` | No | `-SkipSteam` |
| **11** | **Epic Games Store** | Epic Games Launcher `Saved\webcache*` | No | `-SkipEpic` |

### 4. App Caches (Media & Communication) (`-SkipMediaApps`)
| # | Target | Scope / Path | Requires Admin | Skip Flag |
| :---: | :--- | :--- | :---: | :--- |
| **12** | **Spotify** | Downloaded audio streams & offline cache (`Spotify\Storage`) | No | `-SkipSpotify` |
| **13** | **Discord** | Message media cache & compiled V8 code cache | No | `-SkipDiscord` |
| **14** | **Slack** | Workspace asset cache, code cache & service worker cache | No | `-SkipSlack` |
| **15** | **Microsoft Teams** | New & Classic Teams local cache, blob storage & temp files | No | `-SkipTeams` |
| **16** | **Telegram Desktop** | Downloaded voice notes, images & media previews | No | `-SkipTelegram` |
| **17** | **Zoom** | Temporary meeting data, telemetry logs & local cache | No | `-SkipZoom` |

### 5. Developer Tool Caches (`-SkipDevCaches`)
| # | Target | Scope / Path | Requires Admin | Skip Flag |
| :---: | :--- | :--- | :---: | :--- |
| **18** | **Python / Pip** | Wheel download archives & HTTP cache (`pip cache purge`) | No | `-SkipPip` |
| **19** | **Visual Studio Code** | Editor web cache & compiled V8 cached data (`Code\Cache`) | No | `-SkipVSCode` |
| **20** | **NPM** | Global tarball package cache (`npm cache clean --force`) | No | `-SkipNpm` |
| **21** | **Yarn** | Global package cache (`yarn cache clean`) | No | `-SkipYarn` |
| **22** | **pnpm** | Content-addressable package store (`pnpm\store`) | No | `-SkipPnpm` |
| **23** | **NuGet (.NET)** | Downloaded `nupkg` packages (`dotnet nuget locals all --clear`) | No | `-SkipNuget` |
| **24** | **Gradle** | Dependency jars & build cache (`.gradle\caches`) | No | `-SkipGradle` |
| **25** | **Cargo (Rust)** | Registry `.crate` archives (`.cargo\registry\cache`) | No | `-SkipCargo` |
| **26** | **Go** | Compiler build cache (`go clean -cache`) | No | `-SkipGo` |

### 6. Creative Suite Caches (`-SkipCreativeApps`)
| # | Target | Scope / Path | Requires Admin | Skip Flag |
| :---: | :--- | :--- | :---: | :--- |
| **27** | **Adobe Common Media Cache** | Conformed audio peaks (`.cfa`/`.pek`) & media cache | No | `-SkipAdobe` |
| **28** | **DaVinci Resolve** | `CacheClip` optimized media & timeline scratch renders | No | `-SkipDaVinci` |

### 7. System Advanced (`-SkipAdvanced`)
| # | Target | Scope / Path | Requires Admin | Skip Flag |
| :---: | :--- | :--- | :---: | :--- |
| **29** | **Volume Shadow Copies** | Purges oldest shadow copy snapshots via `vssadmin` | **Yes** | `-SkipRestorePoints` |
| **30** | **Upgrade Folders** | `C:\Windows.old`, `$WINDOWS.~BT`, `$WINDOWS.~WS`, `$GetCurrent` | **Yes** | `-SkipUpgradeFolders` |
| **31** | **Crash Dumps** | `MEMORY.DMP`, `Minidump`, `LiveKernelReports`, `CrashDumps` | **Yes** / No | `-SkipCrashDumps` |
| **32** | **CBS, DISM & Panther Logs** | `CbsPersist_*.cab`, `dism.log`, `Panther`, `ETLLogs` | **Yes** | `-SkipCBSLogs` |
| **33** | **Hibernation File** | Disables hibernation via `powercfg -h off` (`C:\hiberfil.sys`) | **Yes** | `-SkipHiberfil` |
| **34** | **Obsolete OEM Drivers** | Superseded INF packages in DriverStore via `pnputil` | **Yes** | `-SkipDrivers` |
| **35** | **Windows Search Index** | Resets `SetupCompletedSuccessfully` and rebuilds index | **Yes** | `-SkipSearchIndex` |
| **36** | **WinSxS Component Store** | `DISM /StartComponentCleanup /ResetBase` *(Opt-in, default No)* | **Yes** | `-SkipDism` |

---

## Command-Line Automation Flags

| Flag | Purpose |
| :--- | :--- |
| `-All` | Cleans all eligible targets without interactive confirmation prompts. |
| `-DryRun` | Simulates cleanup and prints targets without deleting files. |
| `-Gui` | Launches the modern dark-mode graphical user interface (WPF window). |
| `-Preset <Quick\|Full>` | Executes a predefined cleanup preset non-interactively (`Quick` for safe caches, `Full` for all). |
| `-SkipSystem` | Skips the entire System Caches category (Temp, Shaders, Recycle Bin, Thumbnails, Updates, Delivery). |
| `-SkipTemp` | Skips User & Windows Temp Directories. |
| `-SkipShaders` | Skips DirectX, GPU shader caches, and WER error reporting logs. |
| `-SkipRecycleBin` | Skips emptying the Windows Recycle Bin. |
| `-SkipThumbnails` | Skips purging Windows Explorer thumbnail and icon caches. |
| `-SkipWindowsUpdate` | Skips Windows Update Download Store. |
| `-SkipDeliveryOptimization` | Skips Windows Delivery Optimization Cache. |
| `-SkipBrowsers` | Skips all web browser caches (Chrome, Firefox, and Brave). |
| `-SkipChrome` | Skips Google Chrome web and code caches. |
| `-SkipFirefox` | Skips Mozilla Firefox web and startup caches. |
| `-SkipBrave` | Skips Brave Browser web and code caches. |
| `-SkipGames` | Skips all game launcher caches (Steam and Epic Games Store). |
| `-SkipSteam` | Skips Steam web and HTTP network caches. |
| `-SkipEpic` | Skips Epic Games Store web caches. |
| `-SkipMediaApps` | Skips all communication & media app caches (Spotify, Discord, Slack, Teams, Telegram, Zoom). |
| `-SkipSpotify` | Skips Spotify audio storage cache. |
| `-SkipDiscord` | Skips Discord web and code cache. |
| `-SkipSlack` | Skips Slack web, code, and service worker caches. |
| `-SkipTeams` | Skips Microsoft Teams local cache. |
| `-SkipTelegram` | Skips Telegram Desktop media cache. |
| `-SkipZoom` | Skips Zoom meeting and temp cache. |
| `-SkipDevCaches` | Skips all developer toolchain caches (Pip, VS Code, NPM, Yarn, pnpm, NuGet, Gradle, Cargo, Go). |
| `-SkipPip` | Skips Python pip wheel cache. |
| `-SkipVSCode` | Skips Visual Studio Code web and code cache. |
| `-SkipNpm` | Skips NPM cache. |
| `-SkipYarn` | Skips Yarn cache. |
| `-SkipPnpm` | Skips pnpm store cache. |
| `-SkipNuget` | Skips NuGet package cache. |
| `-SkipGradle` | Skips Gradle build cache. |
| `-SkipCargo` | Skips Rust Cargo registry cache. |
| `-SkipGo` | Skips Go build cache. |
| `-SkipCreativeApps` | Skips all creative suite caches (Adobe and DaVinci Resolve). |
| `-SkipAdobe` | Skips Adobe Common Media Cache. |
| `-SkipDaVinci` | Skips DaVinci Resolve render cache. |
| `-SkipAdvanced` | Skips the entire System Advanced category. |
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
# Interactive run with two-level category menus (default):
.\cleanup.ps1

# Full unattended cleanup:
.\cleanup.ps1 -All

# Dry run simulation:
.\cleanup.ps1 -DryRun

# Automated cleanup skipping system restore points, drivers, and NPM:
.\cleanup.ps1 -All -SkipRestorePoints -SkipDrivers -SkipNpm
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
