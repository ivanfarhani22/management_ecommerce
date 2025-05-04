import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../../config/app_config.dart';
import '../api/transaction_api.dart';

class TransactionRepository extends ChangeNotifier {
  final AppConfig _appConfig = AppConfig();
  final TransactionApi _transactionApi;
  
  // Constructor to accept TransactionApi
  TransactionRepository(this._transactionApi);
  
  // Create transaction via API
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      print('Creating transaction with amount: ${transaction.amount}');
      
      // Determine if this is a payment processing operation or just a transaction creation
      if (['stripe', 'bank_transfer', 'cash', 'credit_card'].contains(transaction.paymentMethod)) {
        // This is a payment process operation
        return await processPayment(
          orderId: transaction.orderId,
          paymentMethod: transaction.paymentMethod,
          amount: transaction.amount,
          stripeToken: transaction.stripeToken,
          reference: transaction.reference,
          transactionDate: transaction.transactionDate,
          transactionId: transaction.transactionId,
        );
      } else {
        // Regular transaction creation
        final createdTransaction = await _transactionApi.createTransaction(transaction);
        notifyListeners();
        return createdTransaction;
      }
    } catch (e) {
      print('Transaction creation failed: $e');
      throw Exception('Failed to post data: $e');
    }
  }
  
  // Get all transactions
  Future<List<Transaction>> getAllTransactions({
    int page = 1,
    int limit = 100,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Use the API to get all transactions with optional filtering
      return await _transactionApi.getAllTransactions(
        page: page,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }
  
  // Get transaction by ID
  Future<Transaction> getTransactionById(String id) async {
    try {
      // Convert string id to int if possible
      int? numericId;
      try {
        numericId = int.parse(id);
      } catch (e) {
        // If id can't be parsed as int, proceed with original string
        print('ID could not be parsed as int: $id');
        throw Exception('Invalid transaction ID format');
      }
      
      // Use the API to get transaction by ID
      return await _transactionApi.getTransactionById(numericId);
    } catch (e) {
      throw Exception('Failed to load transaction: $e');
    }
  }
  
  // Get transactions by order ID
  Future<List<Transaction>> getTransactionsByOrderId(int orderId) async {
    try {
      // Use the API to get transactions by order ID
      return await _transactionApi.getTransactionsByOrder(orderId);
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }
  
  // Get transactions by status
  Future<List<Transaction>> getTransactionsByStatus(String status) async {
    try {
      // Use the API to get transactions by status
      return await _transactionApi.getTransactionsByStatus(status);
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }
  
  // Process payment
  Future<Transaction> processPayment({
    required int orderId,
    required String paymentMethod,
    required double amount,
    String? stripeToken,
    String? reference,
    DateTime? transactionDate,
    String? transactionId,
  }) async {
    try {
      // Determine API endpoint based on payment method
      if (paymentMethod == 'stripe' && (stripeToken == null || stripeToken.isEmpty)) {
        throw Exception('Validation error: The stripe token field is required when payment method is stripe.');
      }
      
      // Use the appropriate method based on payment method
      if (['bank_transfer', 'cash', 'credit_card'].contains(paymentMethod)) {
        // For offline payment methods
        final Map<String, dynamic> paymentData = {
          'order_id': orderId,
          'payment_method': paymentMethod,
          'amount': amount,
          'reference': reference,
          'transaction_id': transactionId,
          'transaction_date': transactionDate?.toIso8601String(),
        };
        
        // Create a transaction using the data
        final transaction = Transaction(
          id: 0, // This will be assigned by the API
          orderId: orderId,
          paymentMethod: paymentMethod,
          amount: amount,
          status: 'pending',
          reference: reference,
          transactionId: transactionId,
          transactionDate: transactionDate,
        );
        
        // Process offline payment
        final result = await _transactionApi.createTransaction(transaction);
        notifyListeners();
        return result;
      } else {
        // For online payment methods like stripe
        final result = await _transactionApi.processPayment(
          orderId: orderId,
          paymentMethod: paymentMethod,
          stripeToken: stripeToken,
        );
        notifyListeners();
        return result;
      }
    } catch (e) {
      print('Payment processing failed: $e');
      throw Exception('Failed to process payment: $e');
    }
  }
  
  // Cancel transaction
  Future<void> cancelTransaction(String transactionId) async {
    try {
      // Use the API to cancel transaction
      await _transactionApi.cancelTransaction(transactionId);
      notifyListeners(); // Notify listeners of the change
    } catch (e) {
      throw Exception('Failed to cancel transaction: $e');
    }
  }
}