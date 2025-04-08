import '../api/transaction_api.dart';
import '../local/database_helper.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final TransactionApi transactionApi;
  final DatabaseHelper databaseHelper;

  TransactionRepository({
    required this.transactionApi,
    required this.databaseHelper,
  });

  Future<List<Transaction>> getAllTransactions() async {
    try {
      // Fetch from API
      final apiTransactions = await transactionApi.getAllTransactions();
      
      // Cache transactions in local database
      for (var transaction in apiTransactions) {
        await databaseHelper.insert('transactions', transaction.toJson());
      }
      
      return apiTransactions;
    } catch (e) {
      // Fallback to local database
      final localTransactions = await databaseHelper.query('transactions');
      return localTransactions.map((json) => Transaction.fromJson(json)).toList();
    }
  }

  Future<Transaction> getTransactionById(int transactionId) async {
    try {
      // Try to fetch from API first
      return await transactionApi.getTransactionById(transactionId);
    } catch (e) {
      // Fallback to local database
      final localTransaction = await databaseHelper.query(
        'transactions', 
        where: 'id = ?', 
        whereArgs: [transactionId]
      );
      
      if (localTransaction.isNotEmpty) {
        return Transaction.fromJson(localTransaction.first);
      }
      
      rethrow;
    }
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final createdTransaction = await transactionApi.createTransaction(transaction);
      
      // Cache in local database
      await databaseHelper.insert('transactions', createdTransaction.toJson());
      
      return createdTransaction;
    } catch (e) {
      rethrow;
    }
  }
}