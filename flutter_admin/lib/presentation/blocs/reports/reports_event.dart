part of 'reports_bloc.dart';

abstract class ReportsEvent {
  const ReportsEvent();
}

class FetchFinancialReportsRequested extends ReportsEvent {
  const FetchFinancialReportsRequested();
}

class CreateFinancialReportRequested extends ReportsEvent {
  final FinancialReport report;
  
  const CreateFinancialReportRequested(this.report);
}

class FilterReportsRequested extends ReportsEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String? category;
  final bool? isExpense;

  const FilterReportsRequested({
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.category,
    this.isExpense,
  });
}