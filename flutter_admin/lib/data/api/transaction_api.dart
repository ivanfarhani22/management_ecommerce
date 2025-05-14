import '../models/transaction.dart';
import 'api_client.dart';

class TransactionApi {
  final ApiClient apiClient;
  
  TransactionApi(this.apiClient);
  
  Future<List<Transaction>> getAllTransactions({
    int page = 1,
    int limit = 100,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Build the URL with query parameters
      String url = '/v1/payments?page=$page&limit=$limit';
      
      if (startDate != null) {
        url += '&start_date=${startDate.toIso8601String()}';
      }
      
      if (endDate != null) {
        url += '&end_date=${endDate.toIso8601String()}';
      }
      
      final response = await apiClient.get(url);
      // Extract data from the response structure
      final responseData = response['data'] as List;
      return responseData
        .map((transactionJson) => Transaction.fromJson(transactionJson))
        .toList();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Transaction> getTransactionById(int transactionId) async {
    try {
      final response = await apiClient.get('/v1/payments/$transactionId');
      // Extract data from the response structure
      return Transaction.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Transaction> processPayment({
    required int orderId, 
    required String paymentMethod,
    String? stripeToken
  }) async {
    try {
      final Map<String, dynamic> paymentData = {
        'order_id': orderId,
        'payment_method': paymentMethod,
      };
      
      // Add stripe token if available
      if (stripeToken != null && paymentMethod == 'stripe') {
        paymentData['stripe_token'] = stripeToken;
      }
      
      final response = await apiClient.post('/v1/payments/process', body: paymentData);
      // Extract data from the response structure
      return Transaction.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Transaction> refundPayment(int transactionId) async {
    try {
      final response = await apiClient.post('/v1/payments/$transactionId/refund');
      // Extract data from the response structure
      return Transaction.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<Transaction>> getTransactionsByOrder(int orderId) async {
    try {
      final response = await apiClient.get('/v1/payments/order/$orderId');
      // Extract data from the response structure
      final responseData = response['data'] as List;
      return responseData
        .map((transactionJson) => Transaction.fromJson(transactionJson))
        .toList();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<Transaction>> getTransactionsByStatus(String status) async {
    try {
      final response = await apiClient.get('/v1/payments/status/$status');
      // Extract data from the response structure
      final responseData = response['data'] as List;
      return responseData
        .map((transactionJson) => Transaction.fromJson(transactionJson))
        .toList();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await apiClient.post('/v1/payments', body: transaction.toJson());
      // Extract data from the response structure
      return Transaction.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> cancelTransaction(String transactionId) async {
    try {
      await apiClient.post('/v1/payments/$transactionId/cancel');
    } catch (e) {
      rethrow;
    }
  }
}