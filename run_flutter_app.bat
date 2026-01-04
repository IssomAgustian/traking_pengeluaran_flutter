@echo off
title Expense Tracker Flutter App

echo ================================================
echo    Expense Tracker Flutter App
echo ================================================
echo.

REM Get the current directory to make the script portable
set "PROJECT_DIR=%~dp0"

echo Project directory: %PROJECT_DIR%
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

echo Updating API service with detected IP address...
powershell -Command "(Get-Content '%PROJECT_DIR%lib\services\api_service.dart') -replace 'http://[0-9.]*:8000', 'http://%LOCAL_IP%:8000' | Set-Content -Encoding UTF8 '%PROJECT_DIR%lib\services\api_service.dart'"

echo Updating Budget API service with detected IP address...
powershell -Command "(Get-Content '%PROJECT_DIR%lib\services\budget_api_service.dart') -replace 'http://[0-9.]*:8000', 'http://%LOCAL_IP%:8000' | Set-Content -Encoding UTF8 '%PROJECT_DIR%lib\services\budget_api_service.dart'"

echo.
echo Cleaning Flutter project...
cd /d "%PROJECT_DIR%"
flutter clean
if errorlevel 1 (
    echo ERROR: Flutter clean failed. Please check if Flutter is installed and in PATH.
    pause
    exit /b 1
)
echo.

echo Getting dependencies...
flutter pub get
if errorlevel 1 (
    echo ERROR: Flutter pub get failed. Please check your internet connection and Flutter installation.
    pause
    exit /b 1
)
echo.

echo Building and running Flutter app...
echo Make sure you have an emulator running or a physical device connected.
echo Backend server should be running on http://%LOCAL_IP%:8000
echo.

flutter run
if errorlevel 1 (
    echo ERROR: Flutter run failed. Make sure you have an emulator/device connected.
    pause
    exit /b 1
)

echo.
echo ================================================
echo    Application execution completed
echo ================================================
pause