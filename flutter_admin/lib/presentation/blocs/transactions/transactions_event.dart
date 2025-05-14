part of 'transactions_bloc.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class FetchTransactionsRequested extends TransactionsEvent {
  const FetchTransactionsRequested();
}

class CreateTransactionRequested extends TransactionsEvent {
  final Transaction transaction;

  const CreateTransactionRequested({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class FilterTransactionsRequested extends TransactionsEvent {
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;

  const FilterTransactionsRequested({
    this.status,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
  });

  @override
  List<Object?> get props => [
    status, 
    startDate, 
    endDate, 
    minAmount, 
    maxAmount
  ];
}