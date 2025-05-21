import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/finance_repository.dart';
import '../../../data/models/financial_report.dart';

part 'reports_event.dart';
part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final FinanceRepository financeRepository;

  ReportsBloc({required this.financeRepository}) : super(const ReportsState()) {
    on<FetchFinancialReportsRequested>(_onFetchFinancialReportsRequested);
    on<CreateFinancialReportRequested>(_onCreateFinancialReportRequested);
    on<FilterReportsRequested>(_onFilterReportsRequested);
  }

  Future<void> _onFetchFinancialReportsRequested(
    FetchFinancialReportsRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      final reports = await financeRepository.getAllFinances();
      emit(state.copyWith(
        status: ReportsStatus.loaded,
        reports: reports,
        filteredReports: reports,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReportsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateFinancialReportRequested(
    CreateFinancialReportRequested event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      final newReport = await financeRepository.createFinance(event.report);
      final updatedReports = List<FinancialReport>.from(state.reports)..add(newReport);
      emit(state.copyWith(
        status: ReportsStatus.loaded,
        reports: updatedReports,
        filteredReports: updatedReports,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReportsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFilterReportsRequested(
    FilterReportsRequested event,
    Emitter<ReportsState> emit,
  ) async {
    List<FinancialReport> filtered = List.from(state.reports);

    // Filter by date range
    if (event.startDate != null && event.endDate != null) {
      filtered = filtered.where((report) => 
        report.date.isAfter(event.startDate!.subtract(const Duration(days: 1))) &&
        report.date.isBefore(event.endDate!.add(const Duration(days: 1)))
      ).toList();
    }

    // Filter by amount range
    if (event.minAmount != null) {
      filtered = filtered.where((report) => 
        report.amount >= event.minAmount!
      ).toList();
    }

    if (event.maxAmount != null) {
      filtered = filtered.where((report) => 
        report.amount <= event.maxAmount!
      ).toList();
    }

    // Filter by category
    if (event.category != null && event.category!.isNotEmpty) {
      filtered = filtered.where((report) => 
        report.category == event.category
      ).toList();
    }

    // Filter by transaction type (expense/income)
    if (event.isExpense != null) {
      filtered = filtered.where((report) => 
        report.isExpense == event.isExpense
      ).toList();
    }

    emit(state.copyWith(
      status: ReportsStatus.loaded,
      filteredReports: filtered,
    ));
  }
}