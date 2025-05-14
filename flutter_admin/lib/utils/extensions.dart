extension StringExtensions on String {
  /// Capitalizes the first letter of a string
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Checks if the string is a valid email
  bool isValidEmail() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  /// Truncates string to specified length with optional ellipsis
  String truncate(int length, {String ellipsis = '...'}) {
    return length < this.length 
      ? '${substring(0, length)}$ellipsis' 
      : this;
  }
}

extension DateExtensions on DateTime {
  /// Formats date to a readable string
  String toFormattedString() {
    return '${day.toString().padLeft(2, '0')}/'
           '${month.toString().padLeft(2, '0')}/'
           '$year';
  }

  /// Checks if the date is today
  bool get isToday {
    final now = DateTime.now();
    return now.year == year && 
           now.month == month && 
           now.day == day;
  }
}

extension NumExtensions on num {
  /// Rounds number to specified decimal places
  String toRoundedString(int decimalPlaces) {
    return toStringAsFixed(decimalPlaces);
  }
}