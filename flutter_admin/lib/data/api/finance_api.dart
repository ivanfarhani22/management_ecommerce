import 'api_client.dart';

class FinanceApi {
  final ApiClient apiClient;
  FinanceApi(this.apiClient);

  // Using payments endpoints since that's what's available in the backend
  Future<List<Map<String, dynamic>>> getAllFinances() async {
    try {
      final response = await apiClient.get('/v1/payments');
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFinanceById(int financeId) async {
    try {
      final response = await apiClient.get('/v1/payments/$financeId');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createFinance(Map<String, dynamic> finance) async {
    try {
      final response = await apiClient.post('/v1/payments', body: finance);
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateFinance(Map<String, dynamic> finance) async {
    try {
      // There's no direct PUT endpoint for payments, so we might need to use a different approach
      // This is an assumption based on the available endpoints
      final response = await apiClient.post('/v1/payments/process', body: finance);
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFinance(int financeId) async {
    try {
      // There's no direct DELETE endpoint for payments in the provided API routes
      // We might need to use a different approach or implement a custom solution
      // For now, we'll throw an exception to indicate this operation is not supported
      throw UnimplementedError('Delete operation is not supported by the backend API');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFinancesByCategory(String category) async {
    try {
      // Since there's no category endpoint for payments, we'll get all payments and filter
      final allPayments = await getAllFinances();
      return allPayments.where((finance) => finance['category'] == category).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFinancesByStatus(String status) async {
    try {
      final response = await apiClient.get('/v1/payments/status/$status');
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFinancesByOrder(int orderId) async {
    try {
      final response = await apiClient.get('/v1/payments/order/$orderId');
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> refundPayment(int paymentId) async {
    try {
      final response = await apiClient.post('/v1/payments/$paymentId/refund');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFinanceSummary() async {
    try {
      // There's no direct summary endpoint, we need to aggregate the data manually
      final allPayments = await getAllFinances();
      
      // Calculate total income and expenses
      double totalIncome = 0;
      double totalExpenses = 0;
      
      for (var payment in allPayments) {
        if (payment['isExpense'] == true) {
          totalExpenses += (payment['amount'] as num).toDouble();
        } else {
          totalIncome += (payment['amount'] as num).toDouble();
        }
      }
      
      // Create summary data
      return {
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'balance': totalIncome - totalExpenses,
        'paymentCount': allPayments.length,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Modified method to work with existing endpoints
  Future<Map<String, dynamic>> exportFinancialReport({
    required DateTime startDate,
    required DateTime endDate,
    required String format,
  }) async {
    try {
      // Get all finances within the date range
      final allFinances = await getAllFinances();
      
      // Filter finances based on date range
      final filteredFinances = allFinances.where((finance) {
        final financeDate = DateTime.parse(finance['date'] as String);
        return financeDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
               financeDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
      
      // Prepare the report data
      final reportData = {
        'exportFormat': format,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'generatedAt': DateTime.now().toIso8601String(),
        'data': filteredFinances,
        'summary': {
          'total': filteredFinances.fold(0.0, (sum, item) => sum + (item['amount'] as num).toDouble()),
          'count': filteredFinances.length,
        }
      };
      
      // Here we would typically handle the actual file generation and download
      // Since there's no backend endpoint for this, this data could be used
      // elsewhere in the app for export functionality
      
      return reportData;
    } catch (e) {
      rethrow;
    }
  }
}