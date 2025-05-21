import 'package:flutter/material.dart';
import '../../../data/api/finance_api.dart';
import './widgets/date_range_picker.dart';
import '../../../data/api/service_locator.dart';

class ExportReportScreen extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportReportScreen({
    Key? key,
    this.startDate,
    this.endDate,
  }) : super(key: key);

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
  final FinanceApi _financeApi = ServiceLocator.get<FinanceApi>();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  Future<void> _exportReport() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date range'),
        ),
      );
      return;
    }

    setState(() => _isExporting = true);
    
    try {
      await _financeApi.exportFinancialReport(
        startDate: _startDate!,
        endDate: _endDate!,
        format: _selectedExportFormat.toLowerCase(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully exported report as $_selectedExportFormat'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
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
              startDate: _startDate,
              endDate: _endDate,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportReport,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(_isExporting ? 'Exporting...' : 'Export Report'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}