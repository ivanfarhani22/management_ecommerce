// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinancialReport _$FinancialReportFromJson(Map<String, dynamic> json) =>
    FinancialReport(
      id: json['id'] as int?,
      amount: (json['amount'] as num).toDouble(),
      title: json['title'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      isExpense: json['isExpense'] as bool,
    );

Map<String, dynamic> _$FinancialReportToJson(FinancialReport instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['amount'] = instance.amount;
  val['title'] = instance.title;
  val['category'] = instance.category;
  val['date'] = instance.date.toIso8601String();
  writeNotNull('description', instance.description);
  val['isExpense'] = instance.isExpense;
  return val;
}