import 'dart:io';
import 'package:flutter/material.dart' show debugPrint;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import '../models/prediction_record.dart';

class PdfService {
  static Future<void> generateAndShare({
    required PredictionRecord r,
    required String langCode,
    required Map<String, String> localizedData,
  }) async {
    try {
      final fontEn = await PdfGoogleFonts.notoSansRegular();
      final fontEnBold = await PdfGoogleFonts.notoSansBold();

      pw.Font? fallbackFont;

      if (langCode == 'kn') {
        fallbackFont = await PdfGoogleFonts.notoSansKannadaRegular();
      } else if (langCode == 'hi') {
        fallbackFont = await PdfGoogleFonts.notoSansDevanagariRegular();
      } else if (langCode == 'ta') {
        fallbackFont = await PdfGoogleFonts.notoSansTamilRegular();
      } else if (langCode == 'ml') {
        fallbackFont = await PdfGoogleFonts.notoSansMalayalamRegular();
      }

      final theme = pw.ThemeData.withFont(
        base: fontEn,
        bold: fontEnBold,
        fontFallback: fallbackFont != null ? [fallbackFont] : [],
      );

      final pdf = pw.Document(theme: theme);

      final imgFile = File(r.imagePath);
      final hasImage = imgFile.existsSync();
      final imageProvider = hasImage
          ? pw.MemoryImage(imgFile.readAsBytesSync())
          : null;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.teal,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Rubber Tree AI Report',
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.Text(
                        '${r.timestamp.year}-${r.timestamp.month.toString().padLeft(2, '0')}-${r.timestamp.day.toString().padLeft(2, '0')}',
                        style: const pw.TextStyle(color: PdfColors.white)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Highlighted Disease top layer
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.red300, width: 2),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(localizedData['disease_detected_title'] ?? 'DISEASE DETECTED',
                        style: pw.TextStyle(fontSize: 12, color: PdfColors.red800, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text(r.commonName,
                        style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                    pw.SizedBox(height: 12),
                    pw.Row(children: [
                      pw.Text('${localizedData['lbl_confidence'] ?? "Confidence"}: ${(r.confidence * 100).toStringAsFixed(1)}%', 
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                      pw.SizedBox(width: 20),
                      pw.Text('Severity: ${r.severity}', 
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                    ]),
                    if (r.latitude != null) ...[
                      pw.SizedBox(height: 8),
                      pw.Text('Location: ${r.latitude!.toStringAsFixed(6)}, ${r.longitude!.toStringAsFixed(6)}',
                        style: pw.TextStyle(fontSize: 12, color: PdfColors.red700)),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Image Layer
              if (imageProvider != null) ...[
                pw.Center(
                  child: pw.Container(
                    height: 250,
                    decoration: pw.BoxDecoration(
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      border: pw.Border.all(color: PdfColors.grey400, width: 2),
                    ),
                    child: pw.ClipRRect(
                      horizontalRadius: 8,
                      verticalRadius: 8,
                      child: pw.Image(imageProvider, fit: pw.BoxFit.contain),
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // Expanded Detailed Medical Sections
              if (localizedData['sym_text']!.isNotEmpty) 
                _buildSection(localizedData['sym_title']!, localizedData['sym_text']!, PdfColors.blueGrey800),
              
              if (localizedData['cause_text']!.isNotEmpty) 
                _buildSection(localizedData['cause_title']!, localizedData['cause_text']!, PdfColors.orange800),
                
              if (localizedData['treat_text']!.isNotEmpty) 
                _buildSection(localizedData['treat_title']!, localizedData['treat_text']!, PdfColors.blue800),
                
              if (localizedData['prev_text']!.isNotEmpty) 
                _buildSection(localizedData['prev_title']!, localizedData['prev_text']!, PdfColors.green800),
                
              if (localizedData['eco_text']!.isNotEmpty) 
                _buildSection(localizedData['eco_title']!, localizedData['eco_text']!, PdfColors.red800),

              pw.SizedBox(height: 20),
              pw.Center(
                  child: pw.Text('Generated securely by AI Analyzer System',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey))),
            ];
          },
        ),
      );

      // Save directly to the native Downloads folder so the user finds it instantly
      final downloadsDir = await getDownloadsDirectory();
      final baseDir = downloadsDir ?? await getApplicationDocumentsDirectory();
      final saveDir = Directory('${baseDir.path}/RubberTree_Reports');
      if (!saveDir.existsSync()) {
        saveDir.createSync(recursive: true);
      }
      
      final file = File('${saveDir.path}/Diagnosis_${r.timestamp.millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Open the folder and highlight the file instantly on Windows
      if (Platform.isWindows) {
        final winPath = file.path.replaceAll('/', '\\');
        Process.run('explorer.exe', ['/select,', winPath]);
      } else {
        await Share.shareXFiles([XFile(file.path)], text: 'AI Diagnosis Report: ${r.commonName}');
      }
    } catch (e) {
      debugPrint('Error generating PDF: $e');
    }
  }

  static pw.Widget _buildSection(String title, String content, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
          pw.Divider(color: color, thickness: 1),
          pw.SizedBox(height: 8),
          pw.Text(content, style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.6)),
        ],
      ),
    );
  }
}
