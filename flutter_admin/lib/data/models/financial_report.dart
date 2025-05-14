import 'package:json_annotation/json_annotation.dart';

part 'financial_report.g.dart';

@JsonSerializable()
class FinancialReport {
  final int? id;
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final List<RevenueBreakdown> revenueBreakdown;
  final List<ExpenseBreakdown> expenseBreakdown;
  final DateTime? createdAt;

  FinancialReport({
    this.id,
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    this.revenueBreakdown = const [],
    this.expenseBreakdown = const [],
    this.createdAt,
  });

  factory FinancialReport.fromJson(Map<String, dynamic> json) => _$FinancialReportFromJson(json);
  
  Map<String, dynamic> toJson() => _$FinancialReportToJson(this);

  double get profitMargin => (netProfit / totalRevenue) * 100;
}

@JsonSerializable()
class RevenueBreakdown {
  final String category;
  final double amount;
  final double percentage;

  RevenueBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory RevenueBreakdown.fromJson(Map<String, dynamic> json) => _$RevenueBreakdownFromJson(json);
  
  Map<String, dynamic> toJson() => _$RevenueBreakdownToJson(this);
}

@JsonSerializable()
class ExpenseBreakdown {
  final String category;
  final double amount;
  final double percentage;

  ExpenseBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory ExpenseBreakdown.fromJson(Map<String, dynamic> json) => _$ExpenseBreakdownFromJson(json);
  
  Map<String, dynamic> toJson() => _$ExpenseBreakdownToJson(this);
}