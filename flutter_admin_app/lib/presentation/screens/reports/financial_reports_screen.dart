import 'package:flutter/material.dart';
import './widgets/report_chart.dart';
import './widgets/trending_products.dart';
import './widgets/date_range_picker.dart';

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  _FinancialReportsScreenState createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
      ),
      body: Column(
        children: [
          DateRangePicker(
            onDateRangeSelected: (start, end) {
              setState(() {
                _startDate = start;
                _endDate = end;
              });
            },
          ),
          Expanded(
            child: ListView(
              children: [
                ReportChart(
                  title: 'Revenue Overview',
                  startDate: _startDate,
                  endDate: _endDate,
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
}