import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/repositories/transaction_repository.dart';
import '../../../data/models/transaction.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepository transactionRepository;

  TransactionsBloc({required this.transactionRepository}) 
      : super(const TransactionsState()) {
    on<FetchTransactionsRequested>(_onFetchTransactionsRequested);
    on<CreateTransactionRequested>(_onCreateTransactionRequested);
    on<FilterTransactionsRequested>(_onFilterTransactionsRequested);
  }

  Future<void> _onFetchTransactionsRequested(
    FetchTransactionsRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(state.copyWith(status: TransactionsStatus.loading));
    try {
      final transactions = await transactionRepository.getAllTransactions();
      emit(state.copyWith(
        status: TransactionsStatus.loaded,
        transactions: transactions,
        filteredTransactions: transactions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateTransactionRequested(
    CreateTransactionRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      final newTransaction = await transactionRepository.createTransaction(event.transaction);
      final updatedTransactions = List<Transaction>.from(state.transactions)..add(newTransaction);
      emit(state.copyWith(
        status: TransactionsStatus.loaded,
        transactions: updatedTransactions,
        filteredTransactions: updatedTransactions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFilterTransactionsRequested(
    FilterTransactionsRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    List<Transaction> filtered = List<Transaction>.from(state.transactions);

    if (event.status != null) {
      filtered = filtered.where((transaction) => 
        transaction.status.toLowerCase() == event.status!.toLowerCase()
      ).toList();
    }

    if (event.startDate != null) {
      filtered = filtered.where((transaction) => 
        transaction.transactionDate != null &&
        (transaction.transactionDate!.isAfter(event.startDate!) || 
        transaction.transactionDate!.isAtSameMomentAs(event.startDate!))
      ).toList();
    }

    if (event.endDate != null) {
      filtered = filtered.where((transaction) => 
        transaction.transactionDate != null &&
        (transaction.transactionDate!.isBefore(event.endDate!) || 
        transaction.transactionDate!.isAtSameMomentAs(event.endDate!))
      ).toList();
    }

    if (event.minAmount != null) {
      filtered = filtered.where((transaction) => 
        transaction.amount >= event.minAmount!
      ).toList();
    }

    if (event.maxAmount != null) {
      filtered = filtered.where((transaction) => 
        transaction.amount <= event.maxAmount!
      ).toList();
    }

    emit(state.copyWith(
      status: TransactionsStatus.loaded,
      filteredTransactions: filtered,
    ));
  }
}