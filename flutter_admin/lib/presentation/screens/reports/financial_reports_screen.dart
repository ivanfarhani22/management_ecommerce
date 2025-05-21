import 'package:flutter/material.dart';
import '../../../data/api/finance_api.dart';
import './widgets/report_chart.dart';
import './widgets/trending_products.dart';
import './widgets/date_range_picker.dart';
import '../../../data/api/service_locator.dart';
import 'export_report_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchFinanceSummary();
  }

  Future<void> _fetchFinanceSummary() async {
    setState(() => _isLoading = true);
    try {
      final summary = await _financeApi.getFinanceSummary();
      
      setState(() {
        _financeSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load financial summary: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExportReportScreen(
                    startDate: _startDate,
                    endDate: _endDate,
                  ),
                ),
              );
            },
            tooltip: 'Export Report',
          ),
        ],
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
          ),
          // Chart Type Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('Chart Type:'),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedChartType,
                  items: const [
                    DropdownMenuItem(value: 'bar', child: Text('Bar')),
                    DropdownMenuItem(value: 'line', child: Text('Line')),
                    DropdownMenuItem(value: 'pie', child: Text('Pie')),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedChartType = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
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
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    // Access values directly from the Map<String, dynamic>
    final totalIncome = _financeSummary!['totalIncome'] as num? ?? 0.0;
    final totalExpenses = _financeSummary!['totalExpenses'] as num? ?? 0.0;
    final balance = _financeSummary!['balance'] as num? ?? 0.0;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Income',
              '\$${totalIncome.toStringAsFixed(2)}',
              Colors.green,
              Icons.arrow_upward,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Total Expenses',
              '\$${totalExpenses.toStringAsFixed(2)}',
              Colors.red,
              Icons.arrow_downward,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Balance',
              '\$${balance.toStringAsFixed(2)}',
              balance >= 0 ? Colors.green : Colors.red,
              Icons.account_balance_wallet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}