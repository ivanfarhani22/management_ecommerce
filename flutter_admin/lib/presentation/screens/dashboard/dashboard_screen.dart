import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/routes.dart';
import '../../../config/app_config.dart';
import '../../../data/api/api_client.dart';
import '../../widgets/app_bar.dart';
import './widgets/sales_chart.dart';
import './widgets/stock_alert.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String _totalSales = 'Rp 0';
  String _totalOrders = '0';
  List<Map<String, dynamic>> _salesData = [];
  List<Map<String, dynamic>> _lowStockProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch payment data
      try {
        await _fetchPaymentData();
      } catch (e) {
        debugPrint('Error fetching payment data: $e');
      }
      
      // Fetch order data
      try {
        await _fetchOrderData();
      } catch (e) {
        debugPrint('Error fetching order data: $e');
      }
      
      // Fetch product data for stock alerts
      try {
        await _fetchProductData();
      } catch (e) {
        debugPrint('Error fetching product data: $e');
      }
    } catch (e) {
      // Handle errors
      debugPrint('Error fetching dashboard data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load dashboard data. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchPaymentData() async {
    final ApiClient apiClient = ApiClient();
    try {
      final data = await apiClient.get('/v1/payments');
      
      // Default values in case of null data
      double totalAmount = 0;
      Map<int, double> monthlySales = {};
      
      // Process data only if it's not null
      if (data != null && data['data'] != null) {
        // Calculate total sales from payments
        for (var payment in data['data']) {
          if (payment != null && payment['status'] == 'completed') {
            // Handle the case where amount could be a String or num
            final dynamic amountValue = payment['amount'];
            double amount;
            
            if (amountValue is String) {
              // Parse string to double if it's a string
              amount = double.tryParse(amountValue) ?? 0.0;
            } else if (amountValue is num) {
              // Direct cast if it's already a number
              amount = amountValue.toDouble();
            } else {
              // Default to 0 for null or other types
              amount = 0.0;
            }
            
            totalAmount += amount;
          }
        }
        
        // Extract monthly sales data for the chart
        for (var payment in data['data']) {
          if (payment != null && payment['status'] == 'completed' && payment['created_at'] != null) {
            try {
              final DateTime paymentDate = DateTime.parse(payment['created_at']);
              final int month = paymentDate.month - 1; // Adjust for 0-based index
              
              // Handle the case where amount could be a String or num
              final dynamic amountValue = payment['amount'];
              double amount;
              
              if (amountValue is String) {
                amount = double.tryParse(amountValue) ?? 0.0;
              } else if (amountValue is num) {
                amount = amountValue.toDouble();
              } else {
                amount = 0.0;
              }
              
              monthlySales[month] = (monthlySales[month] ?? 0) + amount;
            } catch (e) {
              debugPrint('Error parsing payment date: $e');
            }
          }
        }
      } else {
        debugPrint('Warning: Payment data or data["data"] is null');
      }
      
      if (mounted) {
        setState(() {
          _totalSales = 'Rp ${formatCurrency(totalAmount)}';
          
          _salesData = List.generate(6, (index) {
            return {
              'month': index,
              'sales': monthlySales[index] ?? 0,
            };
          });
        });
      }
    } catch (e) {
      throw Exception('Failed to load payment data: $e');
    }
  }

  Future<void> _fetchOrderData() async {
    final ApiClient apiClient = ApiClient();
    try {
      final data = await apiClient.get('/v1/orders');
      
      if (mounted) {
        setState(() {
          // Check if data and data['data'] are not null before accessing length
          if (data != null && data['data'] != null) {
            _totalOrders = data['data'].length.toString();
          } else {
            _totalOrders = '0';
            debugPrint('Warning: Order data or data["data"] is null');
          }
        });
      }
    } catch (e) {
      throw Exception('Failed to load order data: $e');
    }
  }

  Future<void> _fetchProductData() async {
    final ApiClient apiClient = ApiClient();
    try {
      final data = await apiClient.get('/v1/products');
      
      List<Map<String, dynamic>> lowStockItems = [];
      
      // Process data only if it's not null
      if (data != null && data['data'] != null) {
        for (var product in data['data']) {
          if (product != null) {
            // Handle possible null or string values
            final dynamic stockValue = product['stock'];
            final dynamic minStockValue = product['minimum_stock'];
            
            int currentStock = 0;
            int minimumStock = 0;
            
            // Parse current stock
            if (stockValue is int) {
              currentStock = stockValue;
            } else if (stockValue is String) {
              currentStock = int.tryParse(stockValue) ?? 0;
            }
            
            // Parse minimum stock
            if (minStockValue is int) {
              minimumStock = minStockValue;
            } else if (minStockValue is String) {
              minimumStock = int.tryParse(minStockValue) ?? 0;
            }
            
            if (currentStock < minimumStock) {
              lowStockItems.add({
                'name': product['name'] ?? 'Unknown Product',
                'currentStock': currentStock,
                'minimumStock': minimumStock,
              });
            }
          }
        }
      } else {
        debugPrint('Warning: Product data or data["data"] is null');
      }
      
      if (mounted) {
        setState(() {
          _lowStockProducts = lowStockItems;
        });
      }
    } catch (e) {
      throw Exception('Failed to load product data: $e');
    }
  }

  String formatCurrency(double amount) {
    // Format currency to include commas for thousands
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dashboard',
        showBackButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary Cards
                    _buildSummaryCard(
                      title: 'Total Sales',
                      value: _totalSales,
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSummaryCard(
                      title: 'Total Orders',
                      value: _totalOrders,
                      icon: Icons.shopping_cart,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    
                    // Sales Chart
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SalesChart(salesData: _salesData),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Stock Alerts
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: StockAlert(lowStockProducts: _lowStockProducts),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
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
            // Already on dashboard
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

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}