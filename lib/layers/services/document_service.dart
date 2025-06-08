import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
  
class DocumentService {
  String stripHtmlTags(String html) {
    final tagRegex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    final cleaned = html.replaceAll(tagRegex, '');
    return cleaned
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim(); // Normalize whitespace
  }

   String extractHtmlTitle(String html) {
    final titleRegex = RegExp(r'<title>(.*?)<\/title>|<h2>(.*?)<\/h2>|<h3>(.*?)<\/h3>|<h4>(.*?)<\/h4>|<h5>(.*?)<\/h5>|<h6>(.*?)<\/h6>', caseSensitive: false);
    final match = titleRegex.firstMatch(html);
    return match != null ? match.group(1)?.trim() ?? '' : '';
  }

  Future<void> generatePdfFromHtml(String htmlContent) async {
    final pdf = pw.Document();
    final plainText = stripHtmlTags(htmlContent);
    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  extractHtmlTitle(htmlContent).isEmpty ? 'Summary' : extractHtmlTitle(htmlContent),
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(plainText),
              ],
            ),
      ),
    );
    // Preview or print or save
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
