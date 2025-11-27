class AppConfig {
  // Base API URL from --dart-define (with fallback)
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8000');

  // Add more environment configs here
  static const String appName = String.fromEnvironment('APP_NAME', defaultValue: 'E-Services Mobile');

  static const bool enableLogging = bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);
}
