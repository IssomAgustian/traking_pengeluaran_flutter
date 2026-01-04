# Expense Tracker Flutter App

A comprehensive expense tracking application built with Flutter and PHP backend. This application allows users to manage their expenses, view transaction history, and generate reports.

## 📋 Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Automatic Setup (Recommended)](#automatic-setup-recommended)
- [Manual Setup](#manual-setup)
- [Running the Application](#running-the-application)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)
- [API Endpoints](#api-endpoints)

## 🌟 Features

- Add, edit, and delete expense transactions
- View transaction history with filtering options
- Budget management and tracking
- Data visualization with charts
- PDF report generation
- RESTful API backend with PHP

## 🛠️ Prerequisites

Before setting up the application, ensure you have the following installed on your system:

### Required Software
- **Flutter SDK** (latest stable version)
- **PHP** (version 7.4 or higher)
- **Git** (for version control)
- **Android Studio** or **VS Code** (with Flutter extensions)
- **Android SDK** (for Android development)

### System Requirements
- Windows 7 or higher (for batch file support)
- At least 4GB RAM (8GB recommended)
- 2GB free disk space

## 🚀 Automatic Setup (Recommended)

The easiest way to set up and run the application is using the provided batch files.

### Option 1: Complete Setup and Run
Run the complete setup that will configure the app, start the backend server, and launch the Flutter app:

1. Double-click on `run_app_complete.bat` file
2. The script will automatically:
   - Detect your local IP address
   - Update API configuration with your IP
   - Clean and get Flutter dependencies
   - Start the PHP backend server
   - Launch the Flutter application

### Option 2: Separate Components
If you prefer to run components separately:

1. **Start Backend Server Only:**
   - Double-click on `run_backend_server.bat`
   - The server will start on your local IP address at port 8000

2. **Run Flutter App Only:**
   - Make sure the backend server is running
   - Double-click on `run_flutter_app.bat`
   - The script will update API configuration and launch the app

## ⚙️ Manual Setup

If you prefer to set up the application manually, follow these steps:

### 1. Clone or Download the Repository
```bash
git clone https://github.com/IssomAgustian/traking_pengeluaran_flutter.git
cd traking_pengeluaran_flutter
```

### 2. Install Flutter Dependencies
```bash
flutter clean
flutter pub get
```

### 3. Set Up Backend Server
1. Navigate to the `backend` directory
2. Make sure PHP is installed and in your system PATH
3. Start the PHP development server:
```bash
cd backend
php -S localhost:8000 -t .
```

### 4. Configure API Endpoints
Update the API service files with your local IP address:

1. Open `lib/services/api_service.dart`
2. Update the `baseUrl` variable with your local IP address:
```dart
final String baseUrl = "http://YOUR_LOCAL_IP:8000";
```

3. Open `lib/services/budget_api_service.dart`
4. Update the base URL similarly:
```dart
final String baseUrl = "http://YOUR_LOCAL_IP:8000";
```

### 5. Run the Flutter Application
```bash
flutter run
```

## 📱 Running the Application

### Using Android Emulator
1. Start an Android emulator in Android Studio
2. Run the application:
```bash
flutter run
```

### Using Physical Device
1. Enable USB debugging on your Android device
2. Connect your device via USB
3. Run the application:
```bash
flutter run
```

### Using iOS Simulator (if applicable)
1. Start iOS simulator
2. Run the application:
```bash
flutter run
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### Issue: "Could not resolve host" or "Connection failed"
- **Solution:** Make sure the backend server is running and accessible
- Check that your IP address is correctly configured in the API service files
- Ensure firewall is not blocking the connection

#### Issue: "PHP is not recognized as an internal or external command"
- **Solution:** Add PHP to your system PATH environment variable
- Restart your command prompt after updating PATH

#### Issue: "No connected device found"
- **Solution:** Make sure an emulator is running or a physical device is connected
- Check USB debugging is enabled on Android devices

#### Issue: "Port 8000 already in use"
- **Solution:** Find and terminate the process using port 8000:
```bash
netstat -ano | findstr :8000
taskkill /PID <PID_NUMBER> /F
```

#### Issue: "Gradle build failed"
- **Solution:** Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

### Backend Server Issues
- Make sure the backend server is running before starting the Flutter app
- Check `backend/server.log` for any server errors
- Ensure PHP extensions required by your application are installed

## 📁 Project Structure

```
expense_tracker_flutter/
├── lib/                    # Flutter source code
│   ├── services/          # API services
│   │   ├── api_service.dart
│   │   └── budget_api_service.dart
│   ├── models/            # Data models
│   │   └── transaction_model.dart
│   ├── screens/           # UI screens
│   └── main.dart          # Application entry point
├── backend/               # PHP backend
│   ├── start_server.php   # Server startup script
│   ├── config.php         # Database configuration
│   ├── create.php         # Create transaction endpoint
│   ├── read.php           # Read transactions endpoint
│   ├── update.php         # Update transaction endpoint
│   ├── delete.php         # Delete transaction endpoint
│   ├── database_schema.sql # Database schema
│   └── budgets/           # Budget-related endpoints
├── assets/                # Application assets
├── test/                  # Test files
├── run_app_complete.bat   # Complete setup and run script
├── run_backend_server.bat # Backend server only script
├── run_flutter_app.bat    # Flutter app only script
└── pubspec.yaml           # Flutter dependencies
```

## 🌐 API Endpoints

The backend provides the following RESTful API endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/read.php` | Get all transactions |
| POST | `/create.php` | Create a new transaction |
| POST | `/update.php` | Update an existing transaction |
| POST | `/delete.php` | Delete a transaction |
| POST | `/budgets/create.php` | Create a budget |
| GET | `/budgets/read.php` | Get all budgets |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions, please:
1. Check the [Troubleshooting](#troubleshooting) section
2. Open an issue in the GitHub repository
3. Contact the development team

---

Made with ❤️ using Flutter and PHP