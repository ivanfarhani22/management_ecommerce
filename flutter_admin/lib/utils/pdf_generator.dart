import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PDFGenerator {
  /// Generates a simple PDF with text content
  static Future<File> generateTextPDF(
    String title, 
    List<String> content, {
    PdfPageFormat? pageFormat,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat ?? PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title, 
                style: pw.TextStyle(
                  fontSize: 24, 
                  fontWeight: pw.FontWeight.bold
                )
              ),
              pw.SizedBox(height: 20),
              ...content.map(
                (text) => pw.Text(
                  text, 
                  style: pw.TextStyle(fontSize: 12)
                )
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Creates a PDF from a list of images
  static Future<File> generateImagePDF(
    List<File> images, {
    PdfPageFormat? pageFormat,
  }) async {
    final pdf = pw.Document();

    for (var image in images) {
      final pdfImage = pw.MemoryImage(image.readAsBytesSync());
      
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat ?? PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pdfImage),
            );
          },
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}