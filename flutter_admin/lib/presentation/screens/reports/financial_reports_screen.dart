import 'package:flutter/material.dart';
import '../../../data/api/finance_api.dart';
import './widgets/report_chart.dart';
import './widgets/trending_products.dart';
import './widgets/date_range_picker.dart';
import '../../../data/api/service_locator.dart';
import 'export_report_screen.dart';
import '../../../config/routes.dart';
import '../../../config/app_config.dart'; // Add this import for navigation

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  _FinancialReportsScreenState createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedChartType = 'bar'; // Default chart type
  final FinanceApi _financeApi = ServiceLocator.get<FinanceApi>();
  Map<String, dynamic>? _financeSummary;
  bool _isLoading = false;
  int _currentIndex = 4; // Set to 4 since Financial Reports is under "More"

  @override
  void initState() {
    super.initState();
    _fetchFinanceSummary();
  }

  Future<void> _fetchFinanceSummary() async {
    setState(() => _isLoading = true);
    try {
      final dynamic response = await _financeApi.getFinanceSummary();
      
      // Debug: Print response type and content
      print('Response type: ${response.runtimeType}');
      print('Response content: $response');
      
      // Handle response based on actual type
      Map<String, dynamic> summary;
      
      if (response is Map<String, dynamic>) {
        // If response is already a Map, process it accordingly
        summary = _processMapResponse(response);
      } else if (response is List<dynamic>) {
        // If response is a List, convert it to Map
        summary = _convertListToMap(response);
      } else {
        // Default empty summary for unknown types
        summary = {
          'totalIncome': 0.0,
          'totalExpenses': 0.0,
          'balance': 0.0,
        };
      }
      
      setState(() {
        _financeSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching financial summary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load financial summary: $e')),
      );
      
      // Set default values on error
      setState(() {
        _financeSummary = {
          'totalIncome': 0.0,
          'totalExpenses': 0.0,
          'balance': 0.0,
        };
      });
    }
  }

  // Process Map response - handles when API returns a Map directly
  Map<String, dynamic> _processMapResponse(Map<String, dynamic> response) {
    try {
      // Check if the response already contains the expected fields
      if (response.containsKey('totalIncome') || 
          response.containsKey('total_income') ||
          response.containsKey('income')) {
        return {
          'totalIncome': _getNumericValue(
            response['totalIncome'] ?? 
            response['total_income'] ?? 
            response['income'] ?? 
            0.0
          ),
          'totalExpenses': _getNumericValue(
            response['totalExpenses'] ?? 
            response['total_expenses'] ?? 
            response['expenses'] ?? 
            response['expense'] ?? 
            0.0
          ),
          'balance': _getNumericValue(
            response['balance'] ?? 
            response['net'] ?? 
            response['netAmount'] ?? 
            0.0
          ),
        };
      }
      
      // Check if the response contains a nested list or data structure
      if (response.containsKey('data') && response['data'] is List) {
        return _convertListToMap(response['data'] as List<dynamic>);
      }
      
      if (response.containsKey('finances') && response['finances'] is List) {
        return _convertListToMap(response['finances'] as List<dynamic>);
      }
      
      if (response.containsKey('summary') && response['summary'] is Map) {
        return _processMapResponse(response['summary'] as Map<String, dynamic>);
      }
      
      // If it's a single transaction record, treat it as such
      final amount = _getNumericValue(response['amount'] ?? 0.0);
      final isExpense = response['isExpense'] == true || 
                       (response['type']?.toString().toLowerCase() == 'expense');
      
      if (isExpense) {
        return {
          'totalIncome': 0.0,
          'totalExpenses': amount,
          'balance': -amount,
        };
      } else {
        return {
          'totalIncome': amount,
          'totalExpenses': 0.0,
          'balance': amount,
        };
      }
    } catch (e) {
      print('Error processing map response: $e');
      return {
        'totalIncome': 0.0,
        'totalExpenses': 0.0,
        'balance': 0.0,
      };
    }
  }

  // Helper method to convert List to Map
  Map<String, dynamic> _convertListToMap(List<dynamic> list) {
    double totalIncome = 0.0;
    double totalExpenses = 0.0;
    
    try {
      for (var item in list) {
        if (item is Map<String, dynamic>) {
          // Check if this item has a type indicator
          final type = item['type']?.toString().toLowerCase();
          final isExpense = item['isExpense'] == true || type == 'expense' || type == 'cost';
          final amount = _getNumericValue(item['amount'] ?? 0.0);
          
          if (isExpense) {
            totalExpenses += amount;
          } else {
            totalIncome += amount;
          }
          
          // Also try to get separate income/expense fields
          final income = _getNumericValue(item['income'] ?? 
                                        item['revenue'] ?? 
                                        item['total_income'] ?? 
                                        0.0);
          
          final expense = _getNumericValue(item['expense'] ?? 
                                         item['cost'] ?? 
                                         item['expenses'] ?? 
                                         item['total_expenses'] ?? 
                                         0.0);
          
          totalIncome += income;
          totalExpenses += expense;
        } else if (item is num) {
          // If list contains raw numbers, assume they are income values
          totalIncome += item.toDouble();
        }
      }
    } catch (e) {
      print('Error converting list to map: $e');
    }
    
    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
    };
  }

  // Helper method to safely extract numeric values - COMPLETELY FIXED VERSION
  double _getNumericValue(dynamic value) {
    try {
      if (value == null) return 0.0;
      
      // Handle numeric types directly
      if (value is num) return value.toDouble();
      
      // Handle string conversion with better error handling
      if (value is String) {
        // Remove any currency symbols, commas, or whitespace
        String cleanValue = value.trim();
        
        // Handle empty strings
        if (cleanValue.isEmpty) return 0.0;
        
        // Remove currency symbols and other non-numeric characters except digits, dots, and minus
        cleanValue = cleanValue
            .replaceAll(RegExp(r'[^\d.-]'), '') // Keep only digits, dots, and minus
            .replaceAll(',', ''); // Remove commas
        
        // Handle edge cases after cleaning
        if (cleanValue.isEmpty || cleanValue == '.' || cleanValue == '-') {
          return 0.0;
        }
        
        // Handle multiple dots or minus signs
        if (cleanValue.split('.').length > 2 || cleanValue.split('-').length > 2) {
          // Try to extract just the numeric part
          final match = RegExp(r'^-?\d*\.?\d*').firstMatch(cleanValue);
          if (match != null) {
            cleanValue = match.group(0) ?? '0';
          } else {
            return 0.0;
          }
        }
        
        // Final parsing attempt
        final parsed = double.tryParse(cleanValue);
        return parsed ?? 0.0;
      }
      
      // Handle boolean (some APIs return boolean for amounts)
      if (value is bool) return value ? 1.0 : 0.0;
      
      // For any other type, try toString() then parse with safety
      final stringValue = value.toString();
      if (stringValue == 'null' || stringValue.isEmpty) return 0.0;
      
      // Try direct numeric parsing first
      final directParsed = double.tryParse(stringValue);
      if (directParsed != null) return directParsed;
      
      // If direct parsing fails, clean the string and try again
      String cleanValue = stringValue
          .replaceAll(RegExp(r'[^\d.-]'), '')
          .replaceAll(',', '');
      
      if (cleanValue.isEmpty) return 0.0;
      
      final cleanParsed = double.tryParse(cleanValue);
      return cleanParsed ?? 0.0;
      
    } catch (e) {
      print('Warning: Exception while converting value to double: $value (${value.runtimeType}) - Error: $e');
      return 0.0;
    }
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        
        // Handle navigation based on index
        switch (index) {
          case 0:
            AppRoutes.navigateTo(context, AppRoutes.dashboard);
            break;
          case 1:
            AppRoutes.navigateTo(context, AppRoutes.inventory);
            break;
          case 2:
            AppRoutes.navigateTo(context, AppRoutes.orders);
            break;
          case 3:
            AppRoutes.navigateTo(context, AppRoutes.transactions);
            break;
          case 4:
            // More options - could show a modal bottom sheet with additional options
            _showMoreOptions();
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'More',
        ),
      ],
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Financial Reports'),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.financialReports);
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Wholesale Notes'),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.wholesaleNotes);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.replaceWith(context, AppRoutes.login);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Financial Reports',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true, 
      ),
      body: Column(
        children: [
          DateRangePicker(
            onDateRangeSelected: (start, end) {
              setState(() {
                _startDate = start;
                _endDate = end;
              });
              _fetchFinanceSummary();
            },
            startDate: _startDate,
            endDate: _endDate,
          ),
          // Chart Type Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text(
                  'Chart Type:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedChartType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'bar', child: Text('Bar Chart')),
                      DropdownMenuItem(value: 'line', child: Text('Line Chart')),
                      DropdownMenuItem(value: 'pie', child: Text('Pie Chart')),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedChartType = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchFinanceSummary,
                child: ListView(
                  children: [
                    if (_financeSummary != null)
                      _buildSummaryCards(),
                    ReportChart(
                      title: 'Revenue Overview',
                      startDate: _startDate,
                      endDate: _endDate,
                      chartType: _selectedChartType,
                    ),
                    TrendingProducts(
                      startDate: _startDate,
                      endDate: _endDate,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(), // Added bottom navigation here
    );
  }

  Widget _buildSummaryCards() {
    try {
      // Safely access values with null checks and type casting - IMPROVED VERSION
      final totalIncome = _financeSummary != null ? 
          _getNumericValue(_financeSummary!['totalIncome']) : 0.0;
      final totalExpenses = _financeSummary != null ? 
          _getNumericValue(_financeSummary!['totalExpenses']) : 0.0;
      
      // Get balance from response or calculate it
      final balance = _financeSummary != null && _financeSummary!.containsKey('balance') ? 
          _getNumericValue(_financeSummary!['balance']) : 
          (totalIncome - totalExpenses);
      
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Income',
                    '\$${totalIncome.toStringAsFixed(2)}',
                    Colors.green,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Expenses',
                    '\$${totalExpenses.toStringAsFixed(2)}',
                    Colors.red,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Net Balance',
                    '\$${balance.toStringAsFixed(2)}',
                    balance >= 0 ? Colors.green : Colors.red,
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Profit Margin',
                    totalIncome > 0 
                      ? '${((balance / totalIncome) * 100).toStringAsFixed(1)}%'
                      : '0.0%',
                    balance >= 0 ? Colors.blue : Colors.orange,
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error building summary cards: $e');
      // Return empty container if there's an error
      return Container();
    }
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}