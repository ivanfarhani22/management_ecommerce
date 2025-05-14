import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Formats number to local currency
  static String formatCurrency(
    num amount, {
    String locale = 'en_US',
    String? symbol,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale, 
      symbol: symbol ?? '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Converts currency to words
  static String currencyToWords(num amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formattedAmount = formatter.format(amount);
    
    // This is a simplified conversion and might need more robust implementation
    final parts = formattedAmount.split('.');
    final dollars = int.parse(parts[0].replaceAll(',', ''));
    final cents = int.parse(parts[1]);

    String dollarsToWords(int number) {
      final List<String> units = [
        '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine',
        'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen',
        'seventeen', 'eighteen', 'nineteen'
      ];
      final List<String> tens = [
        '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'
      ];

      if (number < 20) return units[number];
      if (number < 100) {
        return tens[number ~/ 10] + 
               (number % 10 != 0 ? ' ${units[number % 10]}' : '');
      }
      if (number < 1000) {
        return '${units[number ~/ 100]} hundred${number % 100 != 0 ? ' and ${dollarsToWords(number % 100)}' : ''}';
      }
      if (number < 1000000) {
        return '${dollarsToWords(number ~/ 1000)} thousand${number % 1000 != 0 ? ' ${dollarsToWords(number % 1000)}' : ''}';
      }
      return 'Number too large';
    }

    final dollarsWord = dollarsToWords(dollars);
    final centsWord = dollarsToWords(cents);

    return '$dollarsWord dollars and $centsWord cents';
  }
}