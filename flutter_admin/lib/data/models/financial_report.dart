import 'package:json_annotation/json_annotation.dart';

part 'financial_report.g.dart';

@JsonSerializable()
class FinancialReport {
  final int? id;
  final double amount;
  final String title;
  final String category;
  final DateTime date;
  final String? description;
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

  /// Connect the generated [_$FinancialReportFromJson] function to the `fromJson`
  /// factory.
  factory FinancialReport.fromJson(Map<String, dynamic> json) => 
      _$FinancialReportFromJson(json);

  /// Connect the generated [_$FinancialReportToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FinancialReportToJson(this);
}