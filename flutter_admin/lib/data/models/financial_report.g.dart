// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinancialReport _$FinancialReportFromJson(Map<String, dynamic> json) =>
    FinancialReport(
      id: (json['id'] as num?)?.toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      netProfit: (json['netProfit'] as num).toDouble(),
      revenueBreakdown:
          (json['revenueBreakdown'] as List<dynamic>?)
              ?.map((e) => RevenueBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      expenseBreakdown:
          (json['expenseBreakdown'] as List<dynamic>?)
              ?.map((e) => ExpenseBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FinancialReportToJson(FinancialReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalRevenue': instance.totalRevenue,
      'totalExpenses': instance.totalExpenses,
      'netProfit': instance.netProfit,
      'revenueBreakdown': instance.revenueBreakdown,
      'expenseBreakdown': instance.expenseBreakdown,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

RevenueBreakdown _$RevenueBreakdownFromJson(Map<String, dynamic> json) =>
    RevenueBreakdown(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$RevenueBreakdownToJson(RevenueBreakdown instance) =>
    <String, dynamic>{
      'category': instance.category,
      'amount': instance.amount,
      'percentage': instance.percentage,
    };

ExpenseBreakdown _$ExpenseBreakdownFromJson(Map<String, dynamic> json) =>
    ExpenseBreakdown(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$ExpenseBreakdownToJson(ExpenseBreakdown instance) =>
    <String, dynamic>{
      'category': instance.category,
      'amount': instance.amount,
      'percentage': instance.percentage,
    };
