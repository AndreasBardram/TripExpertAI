import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../models/travel_plan.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfGenerator {
  static Future<Uint8List> _fetchNetworkImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  static Future<pw.Font> _loadFont(String path) async {
    final data = await rootBundle.load(path);
    return pw.Font.ttf(data);
  }

  static Future<void> generateAndSharePdf(List<TravelPlan> recommendations) async {
    final pdf = pw.Document();

    final fontRegular = await _loadFont('assets/fonts/NotoSans-Regular.ttf');
    final fontBold = await _loadFont('assets/fonts/NotoSans-Bold.ttf');
    final fontItalic = await _loadFont('assets/fonts/NotoSans-Italic.ttf');

    final fontJP = await _loadFont('assets/fonts/NotoSansJP-Regular.ttf');
    final fontKR = await _loadFont('assets/fonts/NotoSansKR-Regular.ttf');
    final fontSC = await _loadFont('assets/fonts/NotoSansSC-Regular.ttf');
    final fontThai = await _loadFont('assets/fonts/NotoSansThai-Regular.ttf');
    final fontArabic = await _loadFont('assets/fonts/NotoKufiArabic-Regular.ttf');

    for (var plan in recommendations) {
      pw.MemoryImage? image;
      if (plan.imageUrl != null) {
        final imageData = await _fetchNetworkImage(plan.imageUrl!);
        image = pw.MemoryImage(imageData);
      }

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Container(
            margin: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(15),
                    border: pw.Border.all(color: PdfColors.grey, width: 0.5),
                    color: PdfColors.white,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (plan.header != null)
                        pw.Text(
                          plan.header!,
                          style: pw.TextStyle(
                            font: _selectFont(plan.header!, fontBold, fontJP, fontKR, fontSC, fontThai, fontArabic),
                            fontSize: 20,
                          ),
                        ),
                      if (plan.title != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 4.0),
                          child: pw.Text(
                            plan.title!,
                            style: pw.TextStyle(
                              font: _selectFont(plan.title!, fontBold, fontJP, fontKR, fontSC, fontThai, fontArabic),
                              fontSize: 18,
                            ),
                          ),
                        ),
                      if (plan.date != null && plan.location != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 8.0),
                          child: pw.Text(
                            "${plan.date} at ${plan.location}",
                            style: pw.TextStyle(
                              font: _selectFont("${plan.date} at ${plan.location}", fontItalic, fontJP, fontKR, fontSC, fontThai, fontArabic),
                              fontSize: 12,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                        ),
                      if (plan.description != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 8.0),
                          child: pw.Text(
                            plan.description!,
                            style: pw.TextStyle(
                              font: _selectFont(plan.description!, fontRegular, fontJP, fontKR, fontSC, fontThai, fontArabic),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (plan.openingHours != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 8.0),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: plan.openingHours!
                                .map((hour) => pw.Padding(
                                      padding: const pw.EdgeInsets.only(top: 4.0),
                                      child: pw.Text(
                                        hour,
                                        style: pw.TextStyle(
                                          font: _selectFont(hour, fontRegular, fontJP, fontKR, fontSC, fontThai, fontArabic),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      if (plan.address != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 8.0),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Address: ',
                                style: pw.TextStyle(
                                  font: _selectFont('Address:', fontItalic, fontJP, fontKR, fontSC, fontThai, fontArabic),
                                  fontSize: 12,
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  plan.address!,
                                  style: pw.TextStyle(
                                    font: _selectFont(plan.address!, fontItalic, fontJP, fontKR, fontSC, fontThai, fontArabic),
                                    fontSize: 12,
                                    color: PdfColors.blue,
                                    decoration: pw.TextDecoration.underline,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (plan.website != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 8.0),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Website: ',
                                style: pw.TextStyle(
                                  font: _selectFont('Website:', fontItalic, fontJP, fontKR, fontSC, fontThai, fontArabic),
                                  fontSize: 12,
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  plan.website!,
                                  style: pw.TextStyle(
                                    font: _selectFont(plan.website!, fontItalic, fontJP, fontKR, fontSC, fontThai, fontArabic),
                                    fontSize: 12,
                                    color: PdfColors.blue,
                                    decoration: pw.TextDecoration.underline,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (plan.rating != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 8.0),
                          child: pw.Text(
                            'Rating (${plan.userRatingsTotal} reviews): ${plan.rating}/5',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (plan.priceLevel != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 8.0),
                          child: pw.Text(
                            'Price Level: ${plan.priceLevel}/5',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (image != null)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 16),
                    child: pw.ClipRRect(
                      horizontalRadius: 15.0,
                      verticalRadius: 15.0,
                      child: pw.Image(image, height: 225, fit: pw.BoxFit.cover),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'travel_plan.pdf');
  }

  static pw.Font _selectFont(String text, pw.Font primaryFont, pw.Font fontJP, pw.Font fontKR, pw.Font fontSC, pw.Font fontThai, pw.Font fontArabic) {
    final regexJP = RegExp(r'[\u3040-\u30FF\u31F0-\u31FF]');
    final regexKR = RegExp(r'[\uAC00-\uD7AF]');
    final regexSC = RegExp(r'[\u4E00-\u9FFF]');
    final regexThai = RegExp(r'[\u0E00-\u0E7F]');
    final regexArabic = RegExp(r'[\u0600-\u06FF\u0750-\u077F]');

    if (regexJP.hasMatch(text)) return fontJP;
    if (regexKR.hasMatch(text)) return fontKR;
    if (regexSC.hasMatch(text)) return fontSC;
    if (regexThai.hasMatch(text)) return fontThai;
    if (regexArabic.hasMatch(text)) return fontArabic;

    return primaryFont;
  }
}
