import 'api_client.dart';

class FinanceApi {
  final ApiClient apiClient;
  FinanceApi(this.apiClient);

  // Using payments endpoints since that's what's available in the backend
  Future<List<Map<String, dynamic>>> getAllFinances() async {
    try {
      final response = await apiClient.get('/v1/payments');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map<String, dynamic>) {
        // If API returns a map with data array
        if (response.containsKey('data') && response['data'] is List) {
          return (response['data'] as List).cast<Map<String, dynamic>>();
        } else {
          // Convert single map to list
          return [response];
        }
      }
      return [];
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
      return allPayments.where((finance) => 
        finance['category']?.toString().toLowerCase() == category.toLowerCase()
      ).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFinancesByStatus(String status) async {
    try {
      final response = await apiClient.get('/v1/payments/status/$status');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          return (response['data'] as List).cast<Map<String, dynamic>>();
        } else {
          return [response];
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFinancesByOrder(int orderId) async {
    try {
      final response = await apiClient.get('/v1/payments/order/$orderId');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          return (response['data'] as List).cast<Map<String, dynamic>>();
        } else {
          return [response];
        }
      }
      return [];
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

  Future<Map<String, dynamic>> getFinanceSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // There's no direct summary endpoint, we need to aggregate the data manually
      final allPayments = await getAllFinances();
      
      // Filter by date range if provided
      List<Map<String, dynamic>> filteredPayments = allPayments;
      if (startDate != null && endDate != null) {
        filteredPayments = allPayments.where((payment) {
          try {
            final paymentDate = DateTime.parse(payment['date']?.toString() ?? 
                                               payment['created_at']?.toString() ?? 
                                               DateTime.now().toIso8601String());
            return paymentDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
                   paymentDate.isBefore(endDate.add(const Duration(days: 1)));
          } catch (e) {
            return true; // Include if date parsing fails
          }
        }).toList();
      }
      
      // Calculate total income and expenses
      double totalIncome = 0;
      double totalExpenses = 0;
      int incomeCount = 0;
      int expenseCount = 0;
      
      for (var payment in filteredPayments) {
        final amount = _parseAmount(payment['amount']);
        final isExpense = _parseBoolean(payment['isExpense']) || 
                         _parseBoolean(payment['is_expense']) ||
                         (payment['type']?.toString().toLowerCase() == 'expense');
        
        if (isExpense) {
          totalExpenses += amount;
          expenseCount++;
        } else {
          totalIncome += amount;
          incomeCount++;
        }
      }
      
      // Create summary data
      return {
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'balance': totalIncome - totalExpenses,
        'paymentCount': filteredPayments.length,
        'incomeCount': incomeCount,
        'expenseCount': expenseCount,
        'data': filteredPayments,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to safely parse amount - ENHANCED
  double _parseAmount(dynamic amount) {
    if (amount == null) return 0.0;
    if (amount is double) return amount;
    if (amount is int) return amount.toDouble();
    if (amount is String) {
      // Remove any currency symbols or whitespace
      String cleanAmount = amount.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanAmount) ?? 0.0;
    }
    if (amount is num) return amount.toDouble();
    return 0.0;
  }

  // Helper method to safely parse integer - NEW
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is num) return value.toInt();
    return 0;
  }

  // Helper method to safely parse boolean
  bool _parseBoolean(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    if (value is num) return value == 1;
    return false;
  }

  // Helper method to safely parse date - ENHANCED
  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Helper method to safely parse string
  String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  // NEW: Method to transform API payment data to FinancialReport format
  Map<String, dynamic> transformPaymentToFinancialReport(Map<String, dynamic> payment) {
    try {
      // Extract order information if available
      final order = payment['order'] as Map<String, dynamic>?;
      
      return {
        'id': _parseInt(payment['id']),
        'title': _parseString(payment['transaction_id'] ?? payment['payment_method'] ?? 'Payment'),
        'description': _parseString(payment['payment_method'] ?? ''),
        'amount': _parseAmount(payment['amount']),
        'isExpense': false, // Payments are typically income, not expenses
        'date': _parseDate(payment['created_at']) ?? DateTime.now(),
        'category': _parseString(payment['payment_method'] ?? 'Payment'),
        'status': _parseString(payment['status']),
        'order_id': _parseInt(payment['order_id']),
        'transaction_id': _parseString(payment['transaction_id']),
        'payment_method': _parseString(payment['payment_method']),
        // Add order information if available
        'order_status': order != null ? _parseString(order['status']) : null,
        'order_total': order != null ? _parseAmount(order['total_amount']) : null,
      };
    } catch (e) {
      print('Error transforming payment data: $e');
      // Return a safe default structure
      return {
        'id': _parseInt(payment['id']),
        'title': 'Payment Error',
        'description': 'Error parsing payment data',
        'amount': 0.0,
        'isExpense': false,
        'date': DateTime.now(),
        'category': 'Error',
        'status': 'error',
      };
    }
  }

  // NEW: Method to get transformed financial reports
  Future<List<Map<String, dynamic>>> getFinancialReports() async {
    try {
      final payments = await getAllFinances();
      return payments.map((payment) => transformPaymentToFinancialReport(payment)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Method to get sales data specifically - ENHANCED
  Future<Map<String, dynamic>> getSalesData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final summary = await getFinanceSummary(startDate: startDate, endDate: endDate);
      
      // Process data for sales analysis
      final payments = (summary['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      
      // Group by date for chart data
      Map<String, double> salesByDate = {};
      Map<String, int> ordersByDate = {};
      
      for (var payment in payments) {
        final parsedDate = _parseDate(payment['date']) ?? 
                          _parseDate(payment['created_at']) ?? 
                          DateTime.now();
        
        final dateKey = '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
        
        final amount = _parseAmount(payment['amount']);
        final isExpense = _parseBoolean(payment['isExpense']) || 
                         _parseBoolean(payment['is_expense']) ||
                         (payment['type']?.toString().toLowerCase() == 'expense');
        
        if (!isExpense) { // Only count income as sales
          salesByDate[dateKey] = (salesByDate[dateKey] ?? 0) + amount;
          ordersByDate[dateKey] = (ordersByDate[dateKey] ?? 0) + 1;
        }
      }
      
      // Convert to chart-friendly format
      List<Map<String, dynamic>> chartData = [];
      salesByDate.forEach((date, sales) {
        chartData.add({
          'date': date,
          'sales': sales,
          'orders': ordersByDate[date] ?? 0,
          'revenue': sales,
        });
      });
      
      // Sort by date
      chartData.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
      
      return {
        'chartData': chartData,
        'totalSales': _parseAmount(summary['totalIncome']),
        'totalOrders': summary['incomeCount'] ?? 0,
        'totalRevenue': _parseAmount(summary['totalIncome']),
        'summary': summary,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Modified method to work with existing endpoints - ENHANCED
  Future<Map<String, dynamic>> exportFinancialReport({
    required DateTime startDate,
    required DateTime endDate,
    required String format,
  }) async {
    try {
      // Get financial summary for the date range
      final summary = await getFinanceSummary(startDate: startDate, endDate: endDate);
      
      // Transform the data to be more user-friendly
      final transformedData = (summary['data'] as List?)?.cast<Map<String, dynamic>>()
          .map((payment) => transformPaymentToFinancialReport(payment))
          .toList() ?? [];
      
      // Prepare the report data with safe parsing
      final reportData = {
        'status': 'success',
        'message': 'Report generated successfully',
        'exportFormat': format,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'generatedAt': DateTime.now().toIso8601String(),
        'data': transformedData,
        'rawData': summary['data'] ?? [], // Keep original data as well
        'summary': {
          'totalIncome': _parseAmount(summary['totalIncome']),
          'totalExpenses': _parseAmount(summary['totalExpenses']),
          'balance': _parseAmount(summary['balance']),
          'count': summary['paymentCount'] ?? 0,
          'incomeCount': summary['incomeCount'] ?? 0,
          'expenseCount': summary['expenseCount'] ?? 0,
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