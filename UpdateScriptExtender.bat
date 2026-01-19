@echo off
TITLE ScriptExtender Auto-Updater
COLOR 0A

echo ========================================================
echo       ScriptExtender Automatic Updater
echo       Source: https://github.com/freesegways/ScriptExtender
echo ========================================================
echo.

:: 1. Define Paths
set REPO_URL=https://github.com/freesegways/ScriptExtender/archive/refs/heads/main.zip
set ZIP_FILE=update.zip
set TEMP_DIR=ScriptExtender-main

:: 2. Download the latest version
echo [1/4] Downloading latest version from GitHub...
powershell -Command "try { Invoke-WebRequest -Uri '%REPO_URL%' -OutFile '%ZIP_FILE%' -ErrorAction Stop } catch { Write-Host 'Error: Failed to download. Check your internet or if the repository uses main/master branch.' -ForegroundColor Red; exit 1 }"

if not exist %ZIP_FILE% (
    echo Error: Download failed!
    pause
    exit /b
)

:: 3. Extract Files
echo [2/4] Extracting files...
set EXTRACT_DIR=_update_tmp
if exist %EXTRACT_DIR% rmdir /s /q %EXTRACT_DIR%
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%EXTRACT_DIR%' -Force"

:: Find the subdirectory (e.g., ScriptExtender-main)
set "SOURCE_DIR="
for /d %%D in ("%EXTRACT_DIR%\*") do set "SOURCE_DIR=%%~fD"

if not defined SOURCE_DIR (
    echo Error: Extraction failed or zip was empty!
    if exist %EXTRACT_DIR% rmdir /s /q %EXTRACT_DIR%
    del %ZIP_FILE%
    pause
    exit /b
)

:: 4. Install / Overwrite
echo [3/4] Updating files from %SOURCE_DIR%...
xcopy /s /y /q "%SOURCE_DIR%\*" "."

:: 5. Cleanup
echo [4/4] Cleaning up...
rmdir /s /q %EXTRACT_DIR%
del %ZIP_FILE%

echo.
echo ========================================================
echo       Update Complete! Please Reload UI in-game.
echo ========================================================
echo.
pause
