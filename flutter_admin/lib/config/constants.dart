class AppConstants {
  // Authentication
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;

  // Validation Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$'
  );

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // Permission Levels
  static const String adminRole = 'admin';
  static const String managerRole = 'manager';
  static const String staffRole = 'staff';

  // Date Formats
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String fullDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // Currency Settings
  static const String defaultCurrency = 'USD';
  static const int currencyDecimalPlaces = 2;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Error Messages
  static const String genericErrorMessage = 'An unexpected error occurred';
  static const String networkErrorMessage = 'Please check your internet connection';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // Timeout Durations
  static const int apiRequestTimeout = 30; // seconds
  static const int cacheTimeout = 3600; // 1 hour in seconds
}