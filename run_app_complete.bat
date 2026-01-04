@echo off
title Expense Tracker App Runner

echo ================================================
echo    Expense Tracker App - Complete Setup
echo ================================================
echo.

REM Get the current directory to make the script portable
set "PROJECT_DIR=%~dp0"
set "BACKEND_DIR=%PROJECT_DIR%backend"

echo Project directory: %PROJECT_DIR%
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

echo.
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

echo Starting Backend Server on %LOCAL_IP%:8000...
start "Expense Tracker Backend Server" cmd /c "cd /d "%BACKEND_DIR%" && php -S %LOCAL_IP%:8000 -t . && pause"

echo Waiting for backend server to start...
timeout /t 5 /nobreak >nul

echo.
echo Checking if backend server is running...
ping -n 1 %LOCAL_IP% >nul
if errorlevel 1 (
    echo WARNING: Could not ping the server. Make sure PHP is installed and in PATH.
) else (
    echo Backend server should be running on http://%LOCAL_IP%:8000
)

echo.
echo Building and running Flutter app...
echo Make sure you have an emulator running or a physical device connected.
echo.

echo Press any key to continue to run the Flutter app...
pause >nul

REM Run the Flutter app
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