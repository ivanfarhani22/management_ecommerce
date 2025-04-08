import 'package:flutter/foundation.dart';

class AppConfig {
  // Singleton pattern for global access
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Environment configurations
  static const String environment = kDebugMode ? 'development' : 'production';

  // API Configuration
  static const String baseApiUrl = kDebugMode 
    ? 'http://127.0.0.1:8000/api'  // Updated to use 127.0.0.1 for Laravel
    : 'https://127.0.0.1:8000/api';

  // App Details
  static const String appName = 'Admin Dashboard';
  static const String appVersion = '1.0.0';

  // Feature Flags
  bool enableAnalytics = true;
  bool enableCrashReporting = true;

  // Pagination Defaults
  static const int defaultPageSize = 20;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 1);

  // Logging Configuration
  bool get isDebugMode => kDebugMode;

  // Environment-specific configurations
  Map<String, dynamic> getEnvironmentConfig() {
    switch (environment) {
      case 'development':
        return {
          'apiUrl': 'http://127.0.0.1:8000/api',  // Updated for Laravel
          'logLevel': 'debug',
        };
      case 'production':
        return {
          'apiUrl': 'https://127.0.0.1:8000/api',
          'logLevel': 'error',
        };
      default:
        return {};
    }
  }
}