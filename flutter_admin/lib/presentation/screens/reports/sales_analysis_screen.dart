import 'package:flutter/material.dart';
import './widgets/report_chart.dart';
import './widgets/date_range_picker.dart';

class SalesAnalysisScreen extends StatefulWidget {
  const SalesAnalysisScreen({super.key});

  @override
  _SalesAnalysisScreenState createState() => _SalesAnalysisScreenState();
}

class _SalesAnalysisScreenState extends State<SalesAnalysisScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Analysis'),
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
                  title: 'Sales Trend',
                  startDate: _startDate,
                  endDate: _endDate,
                ),
                // Add more sales-specific widgets as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}