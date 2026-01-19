@echo off
TITLE ScriptExtender Auto-Updater
COLOR 0A

echo.
echo [ScriptExtender Auto-Updater]
echo.

set "ZIP=update.zip"
set "TMP=_update_tmp"
set "URL=https://github.com/freesegways/ScriptExtender/archive/refs/heads/main.zip"

:: Ensure we are in the correct directory
cd /d "%~dp0"

:: Clean Start
if exist "%ZIP%" del "%ZIP%"
if exist "%TMP%" rmdir /s /q "%TMP%"

:: 1. Download
echo [1/4] Downloading...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%URL%' -OutFile '%ZIP%'"
if not exist "%ZIP%" goto :Fail

:: 2. Extract
echo [2/4] Extracting...
powershell -Command "Expand-Archive -Path '%ZIP%' -DestinationPath '%TMP%' -Force"
if not exist "%TMP%" goto :Fail

:: 3. Find Source Folder
echo [3/4] Locating contents...
set "SRC="
for /d %%I in ("%TMP%\*") do set "SRC=%%~fI"

if "%SRC%"=="" (
    echo Error: No folder found inside zip.
    goto :Fail
)

:: 4. Install
echo [4/4] Installing from: "%SRC%"
xcopy /s /y /q "%SRC%\*" .

:: 5. Cleanup
echo Cleaning up...
timeout /t 2 /nobreak >nul
if exist "%TMP%" rmdir /s /q "%TMP%"
if exist "%ZIP%" del "%ZIP%"

echo.
echo Success! Update installed.
echo Please /reload in game.
echo.
pause
exit /b

:Fail
echo.
echo UPDATE FAILED.
echo.
pause
