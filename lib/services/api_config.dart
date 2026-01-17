class ApiConfig {
  // Override with: flutter run --dart-define=API_BASE_URL=http://<ip>:8000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
