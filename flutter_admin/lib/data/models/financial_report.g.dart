part of 'financial_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinancialReport _$FinancialReportFromJson(Map<String, dynamic> json) {
  try {
    return FinancialReport(
      id: const SafeIntConverter().fromJson(json['id']),
      amount: const SafeDoubleConverter().fromJson(json['amount']),
      title: const SafeStringConverter().fromJson(json['title']),
      category: const SafeStringConverter().fromJson(json['category']),
      date: const SafeDateTimeConverter().fromJson(json['date']),
      description: json['description'] == null 
          ? null 
          : const SafeStringConverter().fromJson(json['description']),
      isExpense: const SafeBoolConverter().fromJson(json['isExpense']),
    );
  } catch (e) {
    print('Error in _\$FinancialReportFromJson: $e');
    // Return safe fallback
    return FinancialReport(
      id: const SafeIntConverter().fromJson(json['id']),
      amount: const SafeDoubleConverter().fromJson(json['amount']),
      title: 'Error Loading',
      category: 'Error',
      date: DateTime.now(),
      isExpense: false,
    );
  }
}

Map<String, dynamic> _$FinancialReportToJson(FinancialReport instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', const SafeIntConverter().toJson(instance.id));
  val['amount'] = const SafeDoubleConverter().toJson(instance.amount);
  val['title'] = const SafeStringConverter().toJson(instance.title);
  val['category'] = const SafeStringConverter().toJson(instance.category);
  val['date'] = const SafeDateTimeConverter().toJson(instance.date);
  writeNotNull('description', instance.description == null 
      ? null 
      : const SafeStringConverter().toJson(instance.description!));
  val['isExpense'] = const SafeBoolConverter().toJson(instance.isExpense);
  return val;
}
