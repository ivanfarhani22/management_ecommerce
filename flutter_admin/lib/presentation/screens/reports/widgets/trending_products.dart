import 'package:flutter/material.dart';
import '../../../../data/api/finance_api.dart';
import '../../../../data/models/financial_report.dart';
import '../../../../data/api/service_locator.dart';

class TrendingProducts extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const TrendingProducts({
    Key? key,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  _TrendingProductsState createState() => _TrendingProductsState();
}

class _TrendingProductsState extends State<TrendingProducts> {
  final FinanceApi _financeApi = ServiceLocator.get<FinanceApi>();
  List<FinancialReport> _reports = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  @override
  void didUpdateWidget(TrendingProducts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate || oldWidget.endDate != widget.endDate) {
      _fetchReports();
    }
  }

  // Helper method to safely convert dynamic value to double
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove any currency symbols, commas, or whitespace
      String cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    if (value is num) return value.toDouble();
    return 0.0;
  }

  // Helper method to safely convert dynamic value to bool
  bool _safeToBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return false;
  }

  // Helper method to safely convert dynamic value to DateTime
  DateTime _safeToDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // Helper method to safely convert dynamic value to String
  String _safeToString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  // Safe method to create FinancialReport from JSON with error handling
  FinancialReport? _safeCreateFinancialReport(Map<String, dynamic> data) {
    try {
      // Create a completely safe copy of the data with proper type conversion
      final Map<String, dynamic> safeData = {
        'id': _safeToString(data['id'] ?? ''),
        'title': _safeToString(data['title'] ?? data['name'] ?? data['product_name'] ?? ''),
        'description': _safeToString(data['description'] ?? data['desc'] ?? ''),
        'amount': _safeToDouble(data['amount']),
        'isExpense': _safeToBool(data['isExpense'] ?? data['is_expense'] ?? data['type'] == 'expense'),
        'date': _safeToDateTime(data['date'] ?? data['created_at'] ?? data['timestamp']),
        'category': _safeToString(data['category'] ?? ''),
      };
      
      print('Creating FinancialReport with safe data: $safeData'); // Debug log
      
      return FinancialReport.fromJson(safeData);
    } catch (e) {
      print('Error creating FinancialReport from data: $data, Error: $e');
      return null;
    }
  }

  // Helper method to safely parse amount from different data types (kept for backward compatibility)
  double _parseAmount(dynamic amount) {
    return _safeToDouble(amount);
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the raw data from API
      final dynamic rawData = await _financeApi.getAllFinances();
      
      print('Raw API response: $rawData'); // Debug log
      
      List<FinancialReport> reports = [];
      
      if (rawData is List) {
        // If rawData is a List, process each item with safe conversion
        for (var item in rawData) {
          if (item is Map<String, dynamic>) {
            final report = _safeCreateFinancialReport(item);
            if (report != null) {
              reports.add(report);
            }
          } else {
            print('Skipping invalid item: $item (${item.runtimeType})');
          }
        }
      } else if (rawData is Map<String, dynamic>) {
        // If rawData is a Map, check if it contains a list of reports
        List<dynamic> dataList = [];
        
        if (rawData.containsKey('data') && rawData['data'] is List) {
          dataList = rawData['data'];
        } else if (rawData.containsKey('reports') && rawData['reports'] is List) {
          dataList = rawData['reports'];
        } else if (rawData.containsKey('finances') && rawData['finances'] is List) {
          dataList = rawData['finances'];
        } else if (rawData.containsKey('result') && rawData['result'] is List) {
          dataList = rawData['result'];
        } else {
          // If it's a single report object
          final report = _safeCreateFinancialReport(rawData);
          if (report != null) {
            reports = [report];
          }
        }
        
        // Process the list with safe conversion
        for (var item in dataList) {
          if (item is Map<String, dynamic>) {
            final report = _safeCreateFinancialReport(item);
            if (report != null) {
              reports.add(report);
            }
          } else {
            print('Skipping invalid item in list: $item (${item.runtimeType})');
          }
        }
      } else {
        throw Exception('Unexpected data format: ${rawData.runtimeType}');
      }

      print('Successfully loaded ${reports.length} reports'); // Debug log

      // Filter by date range if provided
      if (widget.startDate != null && widget.endDate != null) {
        final initialCount = reports.length;
        reports = reports.where((report) {
          // Use date field from FinancialReport model
          final reportDate = report.date;
          return reportDate.isAfter(widget.startDate!.subtract(const Duration(days: 1))) &&
                 reportDate.isBefore(widget.endDate!.add(const Duration(days: 1)));
        }).toList();
        print('Filtered ${initialCount} reports to ${reports.length} based on date range'); // Debug log
      }

      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      print('Error loading reports: $e'); // Debug print
      print('Stack trace: $stackTrace'); // Debug print
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load reports: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _fetchReports,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trending Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_errorMessage != null)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.grey),
                    onPressed: _fetchReports,
                    tooltip: 'Retry loading data',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load data',
                      style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchReports,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            else if (_reports.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, color: Colors.grey, size: 48),
                      SizedBox(height: 8),
                      Text(
                        'No data available',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildTrendingList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingList() {
    try {
      // Group by title and sum amounts with safe parsing
      final Map<String, double> productData = {};
      
      for (var report in _reports) {
        final title = report.title ?? 'Unknown Product';
        // Use safe parsing for amount
        final amount = _safeToDouble(report.amount);
        
        if (productData.containsKey(title)) {
          productData[title] = productData[title]! + amount;
        } else {
          productData[title] = amount;
        }
      }
      
      // Convert to entries and sort by amount (descending)
      final sortedEntries = productData.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      // Take top 5
      final topProducts = sortedEntries.take(5).toList();
      
      if (topProducts.isEmpty) {
        return const Center(
          child: Text(
            'No products found in selected date range',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }
      
      return Column(
        children: [
          // Header with total count
          if (_reports.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Top ${topProducts.length} products (from ${_reports.length} records)',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          
          // Product list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topProducts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = topProducts[index];
              final double value = product.value;
              final String title = product.key;
              
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: _getColorForRank(index),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${value.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: value >= 0 ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      value >= 0 ? 'Income' : 'Expense',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    } catch (e) {
      return Center(
        child: Text(
          'Error processing data: $e',
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  Color _getColorForRank(int index) {
    switch (index) {
      case 0:
        return Colors.amber[600]!; // Gold
      case 1:
        return Colors.grey[600]!; // Silver
      case 2:
        return Colors.brown[600]!; // Bronze
      default:
        return Colors.blue[600]!; // Default blue
    }
  }
}