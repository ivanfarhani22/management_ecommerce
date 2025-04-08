part of 'reports_bloc.dart';

abstract class ReportsEvent {
  const ReportsEvent();
}

class FetchFinancialReportsRequested extends ReportsEvent {}

class CreateFinancialReportRequested extends ReportsEvent {
  final FinancialReport report;

  const CreateFinancialReportRequested(this.report);
}

class FilterReportsRequested extends ReportsEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minRevenue;
  final double? maxRevenue;
  final double? minExpenses;
  final double? maxExpenses;

  const FilterReportsRequested({
    this.startDate,
    this.endDate,
    this.minRevenue,
    this.maxRevenue,
    this.minExpenses,
    this.maxExpenses,
  });
}