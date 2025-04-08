part of 'transactions_bloc.dart';

enum TransactionsStatus { initial, loading, loaded, error }

class TransactionsState extends Equatable {
  final TransactionsStatus status;
  final List<Transaction> transactions;
  final List<Transaction> filteredTransactions;
  final String? errorMessage;

  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.errorMessage,
  });

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
    String? errorMessage,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    transactions, 
    filteredTransactions, 
    errorMessage
  ];
}