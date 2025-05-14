import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExcelExporter {
  /// Exports a list of data to an Excel file
  static Future<File> exportToExcel(
    List<List<dynamic>> data, {
    String? filename,
    List<String>? headers,
  }) async {
    // Create a new Excel document
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Add headers if provided
    if (headers != null) {
      sheet.appendRow(headers);
    }

    // Add data rows
    for (var row in data) {
      sheet.appendRow(row);
    }

    // Save the file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${filename ?? 'export_${DateTime.now().millisecondsSinceEpoch}.xlsx'}');
    
    // Write the file
    await file.writeAsBytes(excel.save()!);

    return file;
  }

  /// Exports a map of data to an Excel file with multiple sheets
  static Future<File> exportMultiSheetExcel(
    Map<String, List<List<dynamic>>> sheetsData, {
    String? filename,
  }) async {
    final excel = Excel.createExcel();

    // Remove default sheet
    if (excel.tables.keys.isNotEmpty) {
      excel.delete('Sheet1');
    }

    // Create sheets and populate data
    sheetsData.forEach((sheetName, data) {
      final sheet = excel[sheetName];
      
      for (var row in data) {
        sheet.appendRow(row);
      }
    });

    // Save the file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${filename ?? 'multi_sheet_export_${DateTime.now().millisecondsSinceEpoch}.xlsx'}');
    
    // Write the file
    await file.writeAsBytes(excel.save()!);

    return file;
  }
}