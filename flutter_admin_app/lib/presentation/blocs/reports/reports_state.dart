part of 'reports_bloc.dart';

enum ReportsStatus { initial, loading, loaded, error }

class ReportsState {
  final ReportsStatus status;
  final List<FinancialReport> reports;
  final List<FinancialReport> filteredReports;
  final String? errorMessage;

  const ReportsState({
    this.status = ReportsStatus.initial,
    this.reports = const [],
    this.filteredReports = const [],
    this.errorMessage,
  });

  ReportsState copyWith({
    ReportsStatus? status,
    List<FinancialReport>? reports,
    List<FinancialReport>? filteredReports,
    String? errorMessage,
  }) {
    return ReportsState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      filteredReports: filteredReports ?? this.filteredReports,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}