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
        // Cek apakah report overlap dengan range tanggal yang dipilih
        (report.startDate.isAtSameMomentAs(event.startDate!) || 
         report.startDate.isAfter(event.startDate!)) &&
        (report.endDate.isAtSameMomentAs(event.endDate!) || 
         report.endDate.isBefore(event.endDate!))
      ).toList();
    }

    // Filter by revenue range
    if (event.minRevenue != null) {
      filtered = filtered.where((report) => 
        report.totalRevenue >= event.minRevenue!
      ).toList();
    }

    if (event.maxRevenue != null) {
      filtered = filtered.where((report) => 
        report.totalRevenue <= event.maxRevenue!
      ).toList();
    }

    // Filter by expense range
    if (event.minExpenses != null) {
      filtered = filtered.where((report) => 
        report.totalExpenses >= event.minExpenses!
      ).toList();
    }

    if (event.maxExpenses != null) {
      filtered = filtered.where((report) => 
        report.totalExpenses <= event.maxExpenses!
      ).toList();
    }

    emit(state.copyWith(
      status: ReportsStatus.loaded,
      filteredReports: filtered,
    ));
  }
}