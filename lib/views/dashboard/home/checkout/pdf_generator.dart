import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class PdfService {
  static Future<void> generateReceiptPdf({
    required Uint8List? signature,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Enrollment Receipt',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),

              pw.Text('Order Number: #00001'),
              pw.Text('Date: 24 Nov 2025'),

              pw.Divider(),

              pw.Text(
                'Payment Summary',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),

              _pdfRow('Course Fee', 'AED 9600'),
              _pdfRow('Admission Fee', 'AED 150'),
              _pdfRow('Discount', '-AED 100'),
              _pdfRow('VAT', 'AED 150'),
              pw.Divider(),
              _pdfRow('Total', 'AED 9,750', bold: true),

              pw.SizedBox(height: 24),

              pw.Text(
                'Signature',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),

              if (signature != null)
                pw.Image(pw.MemoryImage(signature), width: 200, height: 100)
              else
                pw.Text('No signature provided'),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/receipt.pdf');
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }

  static pw.Widget _pdfRow(String left, String right, {bool bold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(left),
        pw.Text(
          right,
          style: pw.TextStyle(
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
