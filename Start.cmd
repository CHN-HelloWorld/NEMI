@echo off
setlocal

rem 3DMigoto Loader.exe requires administrator privileges.
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath \"%~f0\" -Verb RunAs"
    exit /b 0
)

cd /d "%~dp0"

set "LOADER_EXE=%~dp03DMigoto Loader.exe"

if not exist "%LOADER_EXE%" (
    echo [ERROR] File not found: "%LOADER_EXE%"
    exit /b 1
)

start "" "%LOADER_EXE%"
timeout /t 15 /nobreak >nul
taskkill /f /im "3DMigoto Loader.exe" >nul 2>&1

endlocal
exit /b 0