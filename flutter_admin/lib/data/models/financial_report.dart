import 'package:json_annotation/json_annotation.dart';

part 'financial_report.g.dart';

// Custom converters untuk parsing yang aman
class SafeIntConverter implements JsonConverter<int?, dynamic> {
  const SafeIntConverter();

  @override
  int? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is double) return json.toInt();
    if (json is String) {
      if (json.trim().isEmpty) return null;
      String cleaned = json.replaceAll(RegExp(r'[^\d-]'), '');
      if (cleaned.isEmpty) return null;
      return int.tryParse(cleaned);
    }
    return null;
  }

  @override
  dynamic toJson(int? object) => object;
}

class SafeDoubleConverter implements JsonConverter<double, dynamic> {
  const SafeDoubleConverter();

  @override
  double fromJson(dynamic json) {
    if (json == null) return 0.0;
    if (json is double) return json;
    if (json is int) return json.toDouble();
    if (json is String) {
      String cleaned = json.trim()
          .replaceAll(RegExp(r'[^\d.-]'), '')
          .replaceAll(',', '');
      
      if (cleaned.isEmpty || cleaned == '.' || cleaned == '-') return 0.0;
      
      if (cleaned.split('.').length > 2 || cleaned.split('-').length > 2) {
        final match = RegExp(r'^-?\d*\.?\d*').firstMatch(cleaned);
        cleaned = match?.group(0) ?? '0';
      }
      
      return double.tryParse(cleaned) ?? 0.0;
    }
    if (json is num) return json.toDouble();
    return 0.0;
  }

  @override
  dynamic toJson(double object) => object;
}

class SafeDateTimeConverter implements JsonConverter<DateTime, dynamic> {
  const SafeDateTimeConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json == null) return DateTime.now();
    if (json is DateTime) return json;
    if (json is String) {
      final parsed = DateTime.tryParse(json);
      return parsed ?? DateTime.now();
    }
    return DateTime.now();
  }

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

class SafeStringConverter implements JsonConverter<String, dynamic> {
  const SafeStringConverter();

  @override
  String fromJson(dynamic json) {
    if (json == null) return '';
    if (json is String) return json;
    return json.toString();
  }

  @override
  String toJson(String object) => object;
}

class SafeBoolConverter implements JsonConverter<bool, dynamic> {
  const SafeBoolConverter();

  @override
  bool fromJson(dynamic json) {
    if (json == null) return false;
    if (json is bool) return json;
    if (json is String) {
      final lower = json.toLowerCase().trim();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    if (json is int) return json == 1;
    return false;
  }

  @override
  bool toJson(bool object) => object;
}

@JsonSerializable()
class FinancialReport {
  @SafeIntConverter()
  final int? id;
  
  @SafeDoubleConverter()
  final double amount;
  
  @SafeStringConverter()
  final String title;
  
  @SafeStringConverter()
  final String category;
  
  @SafeDateTimeConverter()
  final DateTime date;
  
  @SafeStringConverter()
  final String? description;
  
  @SafeBoolConverter()
  final bool isExpense;

  FinancialReport({
    this.id,
    required this.amount,
    required this.title,
    required this.category,
    required this.date,
    this.description,
    required this.isExpense,
  });

  // CUSTOM fromJson dengan error handling dan field mapping
  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    try {
      print('Creating FinancialReport with safe data: $json');
      
      // Buat copy dari json untuk modifikasi aman
      Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
      
      // Field mapping untuk kompatibilitas API
      // Handle missing title
      if (!safeJson.containsKey('title') || safeJson['title'] == null || safeJson['title'].toString().trim().isEmpty) {
        safeJson['title'] = safeJson['description'] ?? safeJson['payment_method'] ?? 'Transaction';
      }
      
      // Handle missing category
      if (!safeJson.containsKey('category') || safeJson['category'] == null || safeJson['category'].toString().trim().isEmpty) {
        safeJson['category'] = safeJson['payment_method'] ?? safeJson['type'] ?? 'General';
      }
      
      // Handle missing date - map dari created_at atau updated_at
      if (!safeJson.containsKey('date') || safeJson['date'] == null) {
        safeJson['date'] = safeJson['created_at'] ?? safeJson['updated_at'] ?? DateTime.now().toIso8601String();
      }
      
      // Handle missing description
      if (!safeJson.containsKey('description')) {
        safeJson['description'] = safeJson['transaction_id'] ?? '';
      }
      
      // Handle missing isExpense - default logic
      if (!safeJson.containsKey('isExpense')) {
        // Cek dari type atau payment_method
        bool isExpense = false;
        if (safeJson.containsKey('type')) {
          final type = safeJson['type'].toString().toLowerCase();
          isExpense = type.contains('expense') || type.contains('cost') || type.contains('debit');
        } else if (safeJson.containsKey('payment_method')) {
          // Untuk payment, default adalah income (pembayaran masuk)
          isExpense = false;
        }
        safeJson['isExpense'] = isExpense;
      }
      
      // Gunakan generated method dengan data yang sudah diperbaiki
      final report = _$FinancialReportFromJson(safeJson);
      print('Successfully created FinancialReport: ${report.toString()}');
      return report;
      
    } catch (e, stackTrace) {
      print('Error creating FinancialReport from data: $json, Error: $e');
      print('Stack trace: $stackTrace');
      
      // Fallback manual creation
      return FinancialReport(
        id: _parseId(json['id']),
        amount: _parseAmount(json['amount']),
        title: _parseString(json['title'] ?? json['description'] ?? 'Error'),
        category: _parseString(json['category'] ?? json['payment_method'] ?? 'Error'),
        date: _parseDate(json['date'] ?? json['created_at'] ?? json['updated_at']),
        description: _parseString(json['description']),
        isExpense: false,
      );
    }
  }

  // Helper methods untuk fallback parsing
  static int? _parseId(dynamic value) {
    const converter = SafeIntConverter();
    return converter.fromJson(value);
  }
  
  static double _parseAmount(dynamic value) {
    const converter = SafeDoubleConverter();
    return converter.fromJson(value);
  }
  
  static String _parseString(dynamic value) {
    const converter = SafeStringConverter();
    return converter.fromJson(value);
  }
  
  static DateTime _parseDate(dynamic value) {
    const converter = SafeDateTimeConverter();
    return converter.fromJson(value);
  }

  /// Connect the generated [_$FinancialReportToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FinancialReportToJson(this);

  @override
  String toString() {
    return 'FinancialReport(id: $id, title: $title, amount: $amount, isExpense: $isExpense)';
  }
}