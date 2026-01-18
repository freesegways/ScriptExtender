@echo off
setlocal

:: Check if Lua is installed
where lua >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Lua is not installed or not in your PATH.
    echo To run tests locally, please install Lua 5.1 or newer.
    echo Website: https://luabinaries.sourceforge.net/
    echo.
    echo You can still run tests IN-GAME by typing /se RunTests
    exit /b 1
)

echo Running ScriptExtender Tests...
lua Tests/StandaloneRunner.lua

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] All tests passed. You are ready to commit.
) else (
    echo.
    echo [FAILURE] Tests failed. Please fix errors before committing.
    exit /b 1
)
