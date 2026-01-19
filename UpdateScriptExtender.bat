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
set EXTRACT_DIR=_update_tmp

:: 2. Download
echo [1/4] Downloading latest version...
powershell -Command "try { Invoke-WebRequest -Uri '%REPO_URL%' -OutFile '%ZIP_FILE%' -ErrorAction Stop } catch { Write-Host 'Download failed.' -ForegroundColor Red; exit 1 }"

if not exist "%ZIP_FILE%" (
    echo Error: Download failed or file not found.
    pause
    exit /b
)

:: 3. Extract
echo [2/4] Extracting...
if exist "%EXTRACT_DIR%" rd /s /q "%EXTRACT_DIR%"
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%EXTRACT_DIR%' -Force"

:: Find inner folder (e.g. ScriptExtender-main)
set "SOURCE_DIR="
for /d %%D in ("%EXTRACT_DIR%\*") do set "SOURCE_DIR=%%~fD"

if not defined SOURCE_DIR (
    echo Error: Extraction failed (folder empty).
    if exist "%EXTRACT_DIR%" rd /s /q "%EXTRACT_DIR%"
    del "%ZIP_FILE%"
    pause
    exit /b
)

:: 4. Update
echo [3/4] Updating from: "%SOURCE_DIR%"
xcopy /s /y /q "%SOURCE_DIR%\*" "."

:: 5. Cleanup
echo [4/4] Cleaning up...
if exist "%EXTRACT_DIR%" rd /s /q "%EXTRACT_DIR%"
if exist "%ZIP_FILE%" del "%ZIP_FILE%"

echo.
echo ========================================================
echo       Update Complete! Please Reload UI in-game.
echo ========================================================
echo.
pause
