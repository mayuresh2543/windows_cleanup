@echo off
setlocal
cd /d "%~dp0"
title Windows Storage Deep Cleanup

reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 0 /f >nul 2>&1

net session >nul 2>&1
if %errorLevel% equ 0 goto :run_elevated

echo ========================================================================
echo   Windows Storage Deep Cleanup - Elevation Check
echo ========================================================================
echo   Requesting Administrator privileges...
echo   (Click 'Yes' if prompted by User Account Control)
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "try { Start-Process cmd.exe -ArgumentList '/c \"\"%~f0\" %*\"' -Verb RunAs -ErrorAction Stop; exit 0 } catch { exit 1 }" 2>nul
if %errorLevel% equ 0 exit /b 0

echo   [Notice] Administrator privileges not granted. Running in Standard User Mode...
echo.

:run_elevated
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0cleanup.ps1" %*

echo.
echo ========================================================================
echo   Press any key to exit...
echo ========================================================================
pause >nul
exit /b 0
