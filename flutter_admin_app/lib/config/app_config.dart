import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AppConfig {
  // Singleton pattern for global access
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Environment configurations
  static const String environment = kDebugMode ? 'development' : 'production';

  // Get the appropriate base URL depending on platform and environment
  static String get baseApiUrl {
    if (kDebugMode) {
      // For debugging: use different URL based on platform
      if (Platform.isAndroid) {
        // Your specific IP address for Android device testing
        return 'http://192.168.1.6:8000/api';
      } else {
        // Windows, macOS, Linux, etc.
        return 'http://127.0.0.1:8000/api';
      }
    } else {
      // Production environment
      return 'https://your-production-domain.com/api';  // Replace with your actual production API
    }
  }
  
  // API Token
  String apiToken = ''; 
  
  // Set API Token
  void setApiToken(String token) {
    apiToken = token;
  }
  
  // Get API Token
  String getApiToken() {
    return apiToken;
  }

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
          'apiUrl': baseApiUrl,  // Use the dynamic getter
          'logLevel': 'debug',
        };
      case 'production':
        return {
          'apiUrl': baseApiUrl,  // Use the dynamic getter
          'logLevel': 'error',
        };
      default:
        return {};
    }
  }
}