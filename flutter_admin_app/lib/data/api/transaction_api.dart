import '../models/transaction.dart';
import 'api_client.dart';

class TransactionApi {
  final ApiClient apiClient;

  TransactionApi(this.apiClient);

  Future<List<Transaction>> getAllTransactions() async {
    try {
      final response = await apiClient.get('/v1/transactions');
      return (response as List)
        .map((transactionJson) => Transaction.fromJson(transactionJson))
        .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Transaction> getTransactionById(int transactionId) async {
    try {
      final response = await apiClient.get('/v1/transactions/$transactionId');
      return Transaction.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await apiClient.post('/v1/transactions', body: transaction.toJson());
      return Transaction.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}