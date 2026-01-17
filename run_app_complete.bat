@echo off
setlocal EnableDelayedExpansion

echo Starting Expense Tracker App...

REM Function to get local IP address - specifically look for Wi-Fi adapter
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address" ^| findstr /v "127.0.0.1"') do (
    for /f "tokens=*" %%b in ('echo %%a ^| findstr /r "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*"') do (
        set "LOCAL_IP=%%b"
        set "LOCAL_IP=!LOCAL_IP: =!"
        goto :got_ip
    )
)

:got_ip

if "!LOCAL_IP!"=="" (
    echo WARNING: Could not detect local IP address. Using default 127.0.0.1
    set "LOCAL_IP=127.0.0.1"
) else (
    echo Detected local IP address: !LOCAL_IP!
)

set "API_BASE_URL=http://!LOCAL_IP!:8000"
echo Using API base URL: !API_BASE_URL!

REM Start the backend server in a new window
start "Backend Server" cmd /k "cd /d %~dp0backend && echo Starting PHP server on !API_BASE_URL! && echo Make sure ports 80 and 3306 are available for Apache and MySQL && php -S !LOCAL_IP!:8000 -t ."

REM Wait a moment for the server to start
timeout /t 5 /nobreak >nul

echo Backend server started in new window.
echo Now running Flutter app...

REM Run the Flutter application
flutter run --dart-define=API_BASE_URL=!API_BASE_URL!
