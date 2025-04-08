import 'package:flutter/material.dart';
import './widgets/date_range_picker.dart';

class ExportReportScreen extends StatefulWidget {
  const ExportReportScreen({super.key});

  @override
  _ExportReportScreenState createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _exportOptions = [
    'PDF',
    'CSV',
    'Excel',
  ];
  String _selectedExportFormat = 'PDF';

  void _exportReport() {
    // Implement export logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting report as $_selectedExportFormat'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DateRangePicker(
              onDateRangeSelected: (start, end) {
                setState(() {
                  _startDate = start;
                  _endDate = end;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedExportFormat,
              decoration: const InputDecoration(
                labelText: 'Export Format',
                border: OutlineInputBorder(),
              ),
              items: _exportOptions
                  .map((format) => DropdownMenuItem(
                        value: format,
                        child: Text(format),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedExportFormat = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startDate != null && _endDate != null
                  ? _exportReport
                  : null,
              child: const Text('Export Report'),
            ),
          ],
        ),
      ),
    );
  }
}