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
        return 'http://192.168.9.13:8000/api';
        //return 'http://54.251.64.31/api';
      } else {
        // Windows, macOS, Linux, etc.
        return 'http://127.0.0.1:8000/api';
        //return 'http://54.251.64.31/api';
      }
    } else {
      // Production environment
      return 'http://54.251.64.31/api';  // Replace with your actual production API
    }
  }
  
  // Get the appropriate storage URL for images
  static String get storageBaseUrl {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        // Android emulator needs 10.0.2.2 to access host's localhost
        // or use your specific IP for physical devices
        return 'http://192.168.9.13:8000/storage';
        //return 'http://54.251.64.31/storage';
      } else {
        // Windows, macOS, Linux, etc.
        return 'http://127.0.0.1:8000/storage';
        //return 'http://54.251.64.31/storage';
      }
    } else {
      // Production environment
      return 'http://54.251.64.31/storage';
    }
  }
  
  // Try multiple storage URLs if the primary one fails
  static List<String> get alternativeStorageUrls {
    return [
      // 'http://127.0.0.1:8000/storage',     // localhost
      // 'http://10.0.2.2:8000/storage',      // Android emulator localhost
      'http://192.168.9.13:8000/storage', // Specific development IP
      //'http://54.251.64.31/storage',        // Production IP
    ];
  }
  
  // Helper function to get image URL with fallbacks
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Return empty string for null or empty paths
    }
    
    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    
    // Otherwise, use the storage base URL
    return '$storageBaseUrl/$imagePath';
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
    // Selalu mengembalikan konfigurasi untuk URL yang ditentukan
    return {
      'apiUrl': baseApiUrl,
      'storageUrl': storageBaseUrl,
      'logLevel': kDebugMode ? 'debug' : 'error',
    };
  }
}