import 'package:flutter/material.dart';
import './widgets/report_chart.dart';
import './widgets/date_range_picker.dart';
import '../../../data/api/finance_api.dart';
import '../../../data/api/service_locator.dart';

class SalesAnalysisScreen extends StatefulWidget {
  const SalesAnalysisScreen({super.key});

  @override
  _SalesAnalysisScreenState createState() => _SalesAnalysisScreenState();
}

class _SalesAnalysisScreenState extends State<SalesAnalysisScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final FinanceApi _financeApi = ServiceLocator.get<FinanceApi>();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _salesData;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Set default date range to last 30 days
    final now = DateTime.now();
    _endDate = now;
    _startDate = now.subtract(const Duration(days: 30));
    
    await _loadSalesData();
  }

  Future<void> _loadSalesData() async {
    if (_startDate == null || _endDate == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use the new getSalesData method from FinanceApi
      final result = await _financeApi.getSalesData(
        startDate: _startDate!,
        endDate: _endDate!,
      );

      if (mounted) {
        setState(() {
          _salesData = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _getErrorMessage(e);
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is TypeError) {
      return 'Data format error - the server returned unexpected data structure';
    } else if (error.toString().contains('type') && error.toString().contains('subtype')) {
      return 'Data type mismatch - please contact support if this persists';
    } else {
      return 'Failed to load sales data: ${error.toString()}';
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSalesData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading sales data...'),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_salesData == null) return const SizedBox.shrink();

    // Safe parsing with proper type conversion
    final totalSales = _parseToDouble(_salesData!['totalSales']) ?? 0.0;
    final totalOrders = _parseToInt(_salesData!['totalOrders']) ?? 0;
    final totalRevenue = _parseToDouble(_salesData!['totalRevenue']) ?? 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green, size: 32),
                      const SizedBox(height: 8),
                      const Text('Total Sales', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                        totalSales.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.blue, size: 32),
                      const SizedBox(height: 8),
                      const Text('Total Orders', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                        totalOrders.toString(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.attach_money, color: Colors.orange, size: 32),
                const SizedBox(width: 8),
                Column(
                  children: [
                    const Text('Total Revenue', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text(
                      '\$${totalRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for safe type conversion
  double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Summary cards
        _buildSummaryCards(),
        const SizedBox(height: 16),
        
        // Chart widget
        ReportChart(
          title: 'Sales Trend',
          startDate: _startDate,
          endDate: _endDate,
        ),
        
        const SizedBox(height: 16),
        
        // Data table
        if (_salesData != null && _salesData!['chartData'] != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Sales Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: (_salesData!['chartData'] as List).length > 5 ? 5 : (_salesData!['chartData'] as List).length,
                      itemBuilder: (context, index) {
                        final chartData = _salesData!['chartData'] as List;
                        final item = chartData[index];
                        final dateStr = item['date']?.toString() ?? '';
                        final dateParts = dateStr.split('-');
                        final orders = _parseToInt(item['orders']) ?? 0;
                        final revenue = _parseToDouble(item['revenue']) ?? 0.0;
                        
                        return ListTile(
                          title: Text(dateParts.length >= 3 ? '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}' : dateStr),
                          subtitle: Text('Orders: $orders'),
                          trailing: Text(
                            '\$${revenue.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadSalesData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DateRangePicker(
              onDateRangeSelected: (start, end) {
                setState(() {
                  _startDate = start;
                  _endDate = end;
                });
                _loadSalesData();
              },
              startDate: _startDate,
              endDate: _endDate,
            ),
          ),
          Expanded(
            child: _isLoading
                ? _buildLoadingWidget()
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }
}