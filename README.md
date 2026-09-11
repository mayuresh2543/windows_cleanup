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

- **Sizing Pre-Scan**: Dynamically measures directory sizes across all targets in milliseconds before prompting, showing exact detected space (e.g., `Found 623.21 MB`).
- **Automatic 0-Byte Bypass**: Targets with 0 bytes, empty caches, or uninstalled applications are automatically excluded from the selection wizard and skipped.
- **QuickEdit Freeze Prevention**: Dynamically disables console QuickEdit mode via low-level Win32 API (`kernel32.dll` `SetConsoleMode`), preventing accidental process suspension when clicking inside the terminal.
- **Real-Time DISM Progress**: Streams live progress percentages (`[====== 100.0% ======]`) during WinSxS Component Store consolidation (`DISM /ResetBase`).
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

  [02] DirectX Shader Cache & Error Reporting Logs
       Found 387.1 KB shaders and WER report archives
       Clean this target? [Y/n]: 

  [04] Windows Delivery Optimization Cache - None found / 0 B (Clean)

  [05] Web Browser Caches (Edge, Chrome, Brave)
       Found 623.21 MB cached web assets and code caches
       Clean this target? [Y/n]: 

  [06] Spotify & Discord Media Caches - None found / 0 B (Clean)

  [07] Game Launcher Caches (Steam, Epic, Ubisoft, Riot) - None found / 0 B (Clean)

========================================================================
                       EXECUTING STORAGE CLEANUP                        
========================================================================

  [ CLEANING ] User and Windows Temp Directories...
               Purged %TEMP% and C:\Windows\Temp disposable caches.

  [ CLEANING ] Web Browser Caches (Edge, Chrome, Brave)...
               Purged browser cache directories.

  [ SKIPPED  ] Spotify & Discord Media Caches

========================================================================
                        CLEANUP SUMMARY REPORT                          
========================================================================
  Target Volume         : Drive C:
  Starting Free Space   : 14.74 GB
  Ending Free Space     : 15.38 GB
  Total Space Reclaimed : +0.64 GB
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

## Cleanup Targets (16 Categories)

| # | Category | Scope / Path | Requires Admin | Default Prompt | Skip Flag |
| :---: | :--- | :--- | :---: | :---: | :--- |
| **01** | **User & Windows Temp** | `%TEMP%`, `C:\Windows\Temp` | No | `[Y/n]` | — |
| **02** | **DirectX Shaders & WER** | `D3DSCache`, `DirectX Shader Cache`, WER report archives | No | `[Y/n]` | — |
| **03** | **Windows Update Store** | `C:\Windows\SoftwareDistribution\Download` | **Yes** | `[Y/n]` | — |
| **04** | **Delivery Optimization** | Windows peer-to-peer update distribution cache | No | `[Y/n]` | — |
| **05** | **Browser Caches** | Edge, Chrome, and Brave cache & code cache directories | No | `[Y/n]` | `-SkipBrowsers` |
| **06** | **Media & Chat Caches** | Spotify streaming storage, Discord cache & code cache | No | `[Y/n]` | `-SkipMediaApps` |
| **07** | **Game Launcher Caches** | Steam httpcache, Epic webcache, Ubisoft & Riot logs | No | `[Y/n]` | `-SkipGames` |
| **08** | **Developer Caches** | Pip wheel download cache, VS Code cache & telemetry | No | `[Y/n]` | — |
| **09** | **Volume Shadow Copies** | Purges oldest shadow copy snapshots via `vssadmin` | **Yes** | `[Y/n]` | `-SkipRestorePoints` |
| **10** | **Upgrade Folders** | `C:\Windows.old`, `C:\$WINDOWS.~BT`, `C:\$WINDOWS.~WS` | **Yes** | `[Y/n]` | `-SkipUpgradeFolders` |
| **11** | **Kernel Crash Dumps** | `C:\Windows\MEMORY.DMP`, `C:\Windows\Minidump` | **Yes** | `[Y/n]` | `-SkipCrashDumps` |
| **12** | **CBS & DISM Logs** | `C:\Windows\Logs\CBS\CbsPersist_*.cab`, `dism.log` | **Yes** | `[Y/n]` | `-SkipCBSLogs` |
| **13** | **Hibernation File** | Disables hibernation via `powercfg -h off` (`C:\hiberfil.sys`) | **Yes** | `[Y/n]` | `-SkipHiberfil` |
| **14** | **Obsolete OEM Drivers** | Superseded INF packages in DriverStore via `pnputil` | **Yes** | `[Y/n]` | `-SkipDrivers` |
| **15** | **Windows Search Index** | Resets `SetupCompletedSuccessfully` and rebuilds index | **Yes** | `[Y/n]` | `-SkipSearchIndex` |
| **16** | **WinSxS Component Store** | `DISM /StartComponentCleanup /ResetBase` | **Yes** | `[y/N]` *(Opt-in)* | `-SkipDism` |

---

## Command-Line Automation Flags

| Flag | Purpose |
| :--- | :--- |
| `-All` | Cleans all eligible targets without interactive Yes/No confirmation prompts. |
| `-DryRun` | Simulates cleanup and prints targets without deleting files. |
| `-SkipBrowsers` | Skips Edge, Chrome, and Brave browser caches. |
| `-SkipMediaApps` | Skips Spotify and Discord media caches. |
| `-SkipGames` | Skips Steam, Epic Games, Ubisoft Connect, and Riot Client caches. |
| `-SkipRestorePoints` | Skips purging oldest volume shadow copies. |
| `-SkipUpgradeFolders` | Skips deleting `Windows.old` and `$WINDOWS.~BT` rollback folders. |
| `-SkipCrashDumps` | Skips deleting kernel memory crash dumps and minidumps. |
| `-SkipCBSLogs` | Skips purging CBS persist archives and truncating DISM logs. |
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

# Automated cleanup skipping system restore points and drivers:
.\cleanup.ps1 -All -SkipRestorePoints -SkipDrivers
```

---

## Manual Reference (Individual Commands)

For users who prefer running specific commands individually:

### Navigation

- [1. System & OS-Level Storage](#system-storage)
  - [Disable or Shrink Hibernation](#disable-hibernation)
  - [Deep Component Store Cleanup (ResetBase)](#resetbase-cleanup)
  - [Clear Windows Update Download Cache](#update-cache)
  - [Purge Delivery Optimization Cache](#delivery-optimization)
  - [Rebuild Windows Explorer Thumbnail Cache](#thumbnail-cache)
  - [Purge Oldest Volume Shadow Copies](#shadow-copies)
  - [Delete Leftover Windows Upgrade Folders](#upgrade-folders)
  - [Delete Kernel Crash Dump Files](#crash-dumps)
  - [Purge CBS & DISM Log Archives](#cbs-logs)
  - [Purge Obsolete OEM Drivers](#driverstore-cleanup)
  - [Reset & Compact Windows Search Database](#search-index)
- [2. Browser, Media & Game Caches](#app-caches)
  - [Web Browsers (Chrome, Edge, Brave)](#browser-caches)
  - [Media & Chat Apps (Spotify, Discord)](#media-caches)
  - [Game Launchers (Steam, Epic, Ubisoft, Riot)](#game-caches)
- [3. Developer Caches & Package Managers](#developer-caches)
  - [Python & Pip](#python-pip)
  - [Node.js (NPM & Yarn)](#nodejs)
  - [.NET / NuGet](#dotnet-nuget)
  - [Java & Gradle](#java-gradle)
  - [VS Code Caches & Workspaces](#vscode-cache)
  - [Docker Prune](#docker-prune)
- [4. WSL2 Virtual Disk Compaction](#wsl-compaction)
- [5. Storage Diagnostics](#diagnostic-tools)
- [6. Scheduled Automation](#task-scheduler)

---

<a id="system-storage"></a>
### 1. System & OS-Level Storage

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
Stop-Process -Name explorer -Force
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue
Start-Process explorer
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
```

<a id="crash-dumps"></a>
#### Delete Kernel Crash Dump Files (1–16+ GB)
When Windows experiences a BSOD, full memory crash dumps matching physical RAM size are saved to `C:\Windows\MEMORY.DMP`:

```powershell
Remove-Item -Path "C:\Windows\MEMORY.DMP" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Minidump\*" -Force -ErrorAction SilentlyContinue
```

<a id="cbs-logs"></a>
#### Purge CBS & DISM Log Archives (1–8+ GB)
Windows servicing creates archived cabinet files that accumulate indefinitely in `C:\Windows\Logs\CBS`:

```powershell
Remove-Item -Path "C:\Windows\Logs\CBS\CbsPersist_*" -Force -ErrorAction SilentlyContinue
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

<a id="browser-caches"></a>
#### Web Browsers (Chrome, Edge, Brave)
Clears cached streaming assets, images, and offline website data without logging you out of accounts:

```powershell
# Microsoft Edge:
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

# Google Chrome:
Remove-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

# Brave Browser:
Remove-Item -Path "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
```

<a id="media-caches"></a>
#### Media & Chat Apps (Spotify, Discord)

```powershell
# Spotify media streaming storage:
Remove-Item -Path "$env:LOCALAPPDATA\Spotify\Storage\*" -Recurse -Force -ErrorAction SilentlyContinue

# Discord media and code cache:
Remove-Item -Path "$env:APPDATA\discord\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:APPDATA\discord\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
```

<a id="game-caches"></a>
#### Game Launchers (Steam, Epic Games, Ubisoft, Riot)
Clears cached web views, banners, and diagnostic logs without touching game installations or save files:

```powershell
# Steam HTTP & web cache:
Remove-Item -Path "C:\Program Files (x86)\Steam\appcache\httpcache\*" -Recurse -Force -ErrorAction SilentlyContinue

# Epic Games Launcher web cache:
Remove-Item -Path "$env:LOCALAPPDATA\EpicGamesLauncher\Saved\webcache*\*" -Recurse -Force -ErrorAction SilentlyContinue

# Ubisoft Connect cache:
Remove-Item -Path "$env:LOCALAPPDATA\Ubisoft Game Launcher\cache\*" -Recurse -Force -ErrorAction SilentlyContinue

# Riot Games / Valorant client logs:
Remove-Item -Path "$env:LOCALAPPDATA\Riot Games\Riot Client\Logs\*" -Recurse -Force -ErrorAction SilentlyContinue
```

---

<a id="developer-caches"></a>
### 3. Developer Caches & Package Managers

<a id="python-pip"></a>
#### Python & Pip

```powershell
# Purge pip wheel download cache:
pip cache purge

# Optional: clean current environment packages:
pip freeze > packages_to_remove.txt
pip uninstall -y -r packages_to_remove.txt
Remove-Item packages_to_remove.txt
```

<a id="nodejs"></a>
#### Node.js (NPM & Yarn)

```powershell
# NPM cache:
npm cache clean --force

# Yarn cache:
yarn cache clean
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
docker system prune -a --volumes
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
# Check free space on Drive C:
Get-PSDrive C | Select-Object Name, @{Name="Free(GB)";Expression={[math]::Round($_.Free / 1GB, 2)}}

# Inspect hidden root system files (pagefile.sys, hiberfil.sys, swapfile.sys):
Get-Item C:\*.sys -Force -ErrorAction SilentlyContinue | Select-Object Name, @{Name="Size(GB)";Expression={[math]::Round($_.Length / 1GB, 2)}}

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
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File D:\Windows_Cleanup\cleanup.ps1 -All"
$Trigger = New-ScheduledTaskTrigger -Monthly -DaysOfWeek Monday -At 9am
Register-ScheduledTask -TaskName "Monthly Windows Storage Cleanup" -Action $Action -Trigger $Trigger -User "SYSTEM"
```

---

## License

Released under the [MIT License](LICENSE).
