import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
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

  // Helper methods for safe type conversion
  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Request storage permission
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Check Android version for appropriate permission
      if (Platform.version.contains('Android')) {
        // For Android 11+ (API 30+), use MANAGE_EXTERNAL_STORAGE
        if (await Permission.manageExternalStorage.isDenied) {
          final status = await Permission.manageExternalStorage.request();
          if (status.isDenied) {
            // Fallback to storage permission
            final storageStatus = await Permission.storage.request();
            return storageStatus.isGranted;
          }
          return status.isGranted;
        }
        return true;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true; // iOS doesn't need explicit permission for app documents
  }

  // Save file to device storage
  Future<String> _saveFileToDevice(Uint8List fileBytes, String fileName) async {
    try {
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      Directory directory;
      if (Platform.isAndroid) {
        // Try to save to Downloads folder on Android
        try {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            // Fallback to external storage directory
            final externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              directory = Directory('${externalDir.path}/Download');
              if (!await directory.exists()) {
                await directory.create(recursive: true);
              }
            } else {
              // Final fallback to app documents
              directory = await getApplicationDocumentsDirectory();
            }
          }
        } catch (e) {
          // If all else fails, use app documents directory
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        // Save to Documents folder on iOS
        directory = await getApplicationDocumentsDirectory();
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(fileBytes);
      return file.path;
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  // Generate filename based on format and date
  String _generateFileName() {
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    final extension = _selectedExportFormat.toLowerCase();
    return 'financial_report_$dateStr.$extension';
  }

  // Download file from URL (if API provides download URL)
  Future<void> _downloadFromUrl(String url) async {
    try {
      final Uri downloadUri = Uri.parse(url);
      if (await canLaunchUrl(downloadUri)) {
        await launchUrl(
          downloadUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Cannot open download URL');
      }
    } catch (e) {
      throw Exception('Failed to download from URL: $e');
    }
  }

  // Open file location
  Future<void> _openFileLocation(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved to: $filePath'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Copy Path',
              onPressed: () {
                // Add clipboard functionality if needed
                // Clipboard.setData(ClipboardData(text: filePath));
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved to: $filePath'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _exportReport() async {
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date range'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isExporting = true);
    
    try {
      final result = await _financeApi.exportFinancialReport(
        startDate: _startDate!,
        endDate: _endDate!,
        format: _selectedExportFormat.toLowerCase(),
      );
      
      // Handle the response from the API
      String message = 'Report generated successfully';
      String? filePath;
      bool hasActualDownload = false;
      
      // Check if API returns file data directly
      if (result.containsKey('fileData') || result.containsKey('file') || result.containsKey('data')) {
        // Case 1: API returns file bytes directly
        final fileData = result['fileData'] ?? result['file'] ?? result['data'];
        if (fileData is List<int>) {
          final fileBytes = Uint8List.fromList(fileData);
          final fileName = _generateFileName();
          filePath = await _saveFileToDevice(fileBytes, fileName);
          message = 'Report downloaded and saved successfully';
          hasActualDownload = true;
        } else if (fileData is String && fileData.startsWith('data:')) {
          // Handle base64 encoded file
          filePath = await _handleBase64File(fileData);
          message = 'Report downloaded successfully';
          hasActualDownload = true;
        }
      } else if (result.containsKey('downloadUrl') || result.containsKey('url')) {
        // Case 2: API returns download URL
        final downloadUrl = result['downloadUrl'] ?? result['url'];
        if (downloadUrl != null && downloadUrl.toString().isNotEmpty) {
          await _downloadFromUrl(downloadUrl.toString());
          message = 'Report download initiated';
          hasActualDownload = true;
        }
      }
      
      // If no actual download happened, show server-side generation message
      if (!hasActualDownload) {
        if (result.containsKey('message')) {
          message = result['message']?.toString() ?? message;
        }
        // Updated message - no mention of dashboard
        message += '\nNote: If file is not downloaded, please contact support for assistance.';
      }
      
      // Handle error status
      if (result.containsKey('status')) {
        final status = result['status']?.toString();
        if (status == 'error') {
          throw Exception(result['error']?.toString() ?? 'Export failed');
        }
      }
      
      // Show summary information with safe type conversion
      if (result.containsKey('summary')) {
        final summary = result['summary'] as Map<String, dynamic>?;
        if (summary != null) {
          final count = _parseToInt(summary['count']);
          final totalIncome = _parseToDouble(summary['totalIncome']);
          message = '$message\n\nSummary:\nRecords: $count\nTotal Income: \$${totalIncome.toStringAsFixed(2)}';
        }
      }
      
      if (mounted) {
        _showResultDialog(message, hasActualDownload, filePath);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to export report';
        
        // Handle different error types
        if (e is TypeError) {
          errorMessage = 'Data format error - please try again or contact support';
        } else if (e.toString().contains('permission')) {
          errorMessage = 'Storage permission required to save file';
        } else if (e.toString().contains('network') || e.toString().contains('connection')) {
          errorMessage = 'Network error - please check your internet connection';
        } else {
          errorMessage = 'Failed to export report: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _exportReport,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  // Handle base64 encoded files
  Future<String> _handleBase64File(String base64Data) async {
    try {
      // Extract file type and data from data URL
      final RegExp dataUrlRegex = RegExp(r'data:([^;]+);base64,(.+)');
      final match = dataUrlRegex.firstMatch(base64Data);
      
      if (match != null) {
        final mimeType = match.group(1);
        final base64String = match.group(2);
        
        if (base64String != null) {
          final bytes = base64Decode(base64String);
          String extension = 'pdf';
          
          if (mimeType?.contains('excel') == true || 
              mimeType?.contains('spreadsheet') == true ||
              mimeType?.contains('xlsx') == true) {
            extension = 'xlsx';
          } else if (mimeType?.contains('csv') == true) {
            extension = 'csv';
          }
          
          final fileName = 'financial_report_${DateTime.now().toIso8601String().substring(0, 10)}.$extension';
          return await _saveFileToDevice(bytes, fileName);
        }
      }
      throw Exception('Invalid base64 data format');
    } catch (e) {
      throw Exception('Failed to process file data: $e');
    }
  }

  // Show result dialog with appropriate actions - Updated without dashboard reference
  void _showResultDialog(String message, bool hasDownload, String? filePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                hasDownload ? Icons.check_circle : Icons.info_outline,
                color: hasDownload ? Colors.green : Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasDownload ? 'Download Complete' : 'Report Generated',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
              if (!hasDownload) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'The file was generated on the server but not downloaded to your device. Please contact support if you need assistance accessing the file.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (!hasDownload)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showContactSupport();
                },
                icon: const Icon(Icons.support_agent),
                label: const Text('Contact Support'),
              ),
            if (hasDownload && filePath != null)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openFileLocation(filePath);
                },
                icon: const Icon(Icons.folder_open),
                label: const Text('Open File'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show contact support options instead of opening dashboard
  void _showContactSupport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.support_agent, color: Colors.blue),
              SizedBox(width: 8),
              Text('Contact Support'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need help accessing your exported report? Here are ways to contact support:',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Email: support@your-app-domain.com'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Phone: +1-XXX-XXX-XXXX'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Hours: Mon-Fri 9AM-5PM'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _launchEmail();
              },
              icon: Icon(Icons.email),
              label: Text('Send Email'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Launch email client
  Future<void> _launchEmail() async {
    const String email = 'support@your-app-domain.com'; // Replace with your actual support email
    const String subject = 'Export Report Issue';
    final String body = 'Hi Support Team,\n\nI need assistance with accessing my exported financial report.\n\nExport Details:\n- Format: $_selectedExportFormat\n- Date Range: ${_startDate?.toString().split(' ')[0]} to ${_endDate?.toString().split(' ')[0]}\n- Export Time: ${DateTime.now()}\n\nPlease help me access the file.\n\nThank you.';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw Exception('Cannot launch email client');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open email client: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Export Report',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Range Picker Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DateRangePicker(
                    onDateRangeSelected: (start, end) {
                      setState(() {
                        _startDate = start;
                        _endDate = end;
                      });
                    },
                    startDate: _startDate,
                    endDate: _endDate,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Export Options Card
              Card(
                elevation: 2,
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
                          prefixIcon: Icon(Icons.file_download),
                        ),
                        items: _exportOptions
                            .map((format) => DropdownMenuItem(
                                  value: format,
                                  child: Row(
                                    children: [
                                      Icon(_getFormatIcon(format), size: 20),
                                      const SizedBox(width: 8),
                                      Text(format),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedExportFormat = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Export Button
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
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              
              // Info Card
              Card(
                color: Colors.blue.shade50,
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Files will be saved to your device\'s Downloads folder (Android) or Documents folder (iOS). Make sure you have sufficient storage space.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get format icon
  IconData _getFormatIcon(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'csv':
        return Icons.table_chart;
      case 'excel':
        return Icons.grid_on;
      default:
        return Icons.file_download;
    }
  }
}