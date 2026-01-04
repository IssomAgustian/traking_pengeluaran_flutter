@echo off
title Expense Tracker Backend Server

echo ================================================
echo    Expense Tracker Backend Server
echo ================================================
echo.

REM Get the current directory to make the script portable
set "PROJECT_DIR=%~dp0"
set "BACKEND_DIR=%PROJECT_DIR%backend"

echo Starting Backend Server...
echo Backend directory: %BACKEND_DIR%
echo.

REM Function to get local IP address
for /f "tokens=2-3 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    set "LOCAL_IP=%%a"
    set "LOCAL_IP=!LOCAL_IP: =!"
    goto :got_ip
)
:got_ip

if "%LOCAL_IP%"=="" (
    echo WARNING: Could not detect local IP address. Using default 127.0.0.1
    set "LOCAL_IP=127.0.0.1"
) else (
    echo Detected local IP address: %LOCAL_IP%
)

echo Starting PHP development server on http://%LOCAL_IP%:8000
echo Make sure you have PHP installed and in your system PATH.
echo.

REM Start the PHP server
cd /d "%BACKEND_DIR%"
php -S %LOCAL_IP%:8000 -t .
if errorlevel 1 (
    echo ERROR: PHP server failed to start. Please check if PHP is installed and in PATH.
    echo Make sure you're running this on Windows Command Prompt with administrator privileges if needed.
    pause
    exit /b 1
)

echo.
echo Backend server stopped.
pause