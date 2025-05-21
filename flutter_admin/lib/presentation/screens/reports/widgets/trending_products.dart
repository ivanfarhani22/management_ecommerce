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

  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);
    try {
      // Get the raw reports data
      final List<Map<String, dynamic>> rawReports = await _financeApi.getAllFinances();
      
      // Convert raw data to FinancialReport objects
      final reports = rawReports.map((data) => FinancialReport.fromJson(data)).toList();
      
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reports: $e')),
      );
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
            const Text(
              'Trending Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_reports.isEmpty)
              const Center(child: Text('No data available'))
            else
              _buildTrendingList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingList() {
    // Group by title and sum amounts using Map<String, dynamic>
    final Map<String, dynamic> productData = {};
    
    for (var report in _reports) {
      if (productData.containsKey(report.title)) {
        productData[report.title] = (productData[report.title] as double) + report.amount;
      } else {
        productData[report.title] = report.amount;
      }
    }
    
    // Sort by amount (descending)
    final sortedEntries = productData.entries.toList()
      ..sort((a, b) => (b.value as double).compareTo(a.value as double));
    
    // Take top 5
    final topProducts = sortedEntries.take(5).toList();
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topProducts.length,
      itemBuilder: (context, index) {
        final product = topProducts[index];
        final double value = product.value as double;
        
        return ListTile(
          title: Text(product.key),
          trailing: Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: value >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Text('${index + 1}'),
          ),
        );
      },
    );
  }
}