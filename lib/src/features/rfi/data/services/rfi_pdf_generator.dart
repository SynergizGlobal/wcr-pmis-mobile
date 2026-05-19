import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdfx/pdfx.dart' as pdfr;
import '../../domain/rfi_log/rfi_report_details.dart';
import '../../core/network/environment.dart';
import '../../core/utils/rfi_preview_fetch.dart';

class RfiPdfGenerator {
  static const _primaryColor = PdfColor.fromInt(0xFF13617A); // Dark Blue
  static const _headerTextColor = PdfColors.white;

  static Future<void> generateAndOpen({
    required String rfiId,
    required RfiReportDetailsData data,
  }) async {
    final isIos = !kIsWeb && Platform.isIOS;
    final pdf = pw.Document();

    // iOS print preview can hang when runtime font fetching is slow/unavailable.
    // Use built-in fonts on iOS for deterministic PDF generation.
    final pw.Font font;
    final pw.Font fontBold;
    if (isIos) {
      font = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    } else {
      // Use Noto Sans for broader Unicode support on other platforms.
      font = await PdfGoogleFonts.notoSansRegular();
      fontBold = await PdfGoogleFonts.notoSansBold();
    }

    final dio = _createDio();
    final info = data.reportDetails;

    // 1. Parallel loading of initial assets (Logo from project assets, selfies from network)
    final List<pw.MemoryImage?> initialAssets = await Future.wait([
      _loadAssetImage('assets/images/mrvc_logo.png'),
      _loadImage(info.selfieContractor, dio),
      _loadImage(info.selfieClient, dio),
    ]);

    final mrvcLogo = initialAssets[0];
    final contractorSelfie = initialAssets[1];
    final inspectorSelfie = initialAssets[2];

    // 2. Extract paths from all possible attachment fields (Exhaustive collection)
    final contractorPaths = _extractPaths(info.imagesUploadedByContractor?.isNotEmpty == true
        ? info.imagesUploadedByContractor
        : info.conSupportFilePaths);
    final clientPaths = _extractPaths(info.imagesUploadedByClient?.isNotEmpty == true
        ? info.imagesUploadedByClient
        : info.enggSupportFilePaths);
    
    final testSitePaths = _extractPaths(info.testSiteDocumentsContractor);
    final testResultConPaths = _extractPaths(info.testResultContractor);
    final testResultEngPaths = _extractPaths(info.testResultEngineer);

    // Other attachment fields (attachmentData string, attachments list)
    final otherAttachmentPaths = _extractPaths(info.attachmentData);
    final listAttachmentPaths = <String>[];
    for (final att in info.attachments) {
      if (att is Map && att.containsKey('filePath')) {
        listAttachmentPaths.add(att['filePath'].toString());
      } else if (att is String) {
        listAttachmentPaths.add(att);
      }
    }

    // Enclosures
    final enclosurePaths = <String>[];
    for (final enclosure in data.enclosures) {
      if (enclosure.file != null) {
        enclosurePaths.addAll(_extractPaths(enclosure.file));
      }
    }

    // Categorization Helpers
    bool isPdf(String path) => path.toLowerCase().endsWith('.pdf');

    Future<List<pw.MemoryImage>> loadOnlyImages(List<String> paths) async {
       return await _loadImages(paths.where((p) => !isPdf(p)).toList(), dio);
    }

    Future<List<pw.MemoryImage>> loadPdfClips(List<String> paths) async {
       final pdfs = paths.where((p) => isPdf(p)).toList();
       if (pdfs.isEmpty) return [];
       final List<List<pw.MemoryImage>> pagesList = await Future.wait(pdfs.map((p) => _loadPdfPages(p, dio)));
       return pagesList.expand((x) => x).toList();
    }

    // 3. Parallel loading of all categories back into report sections
    final results = await Future.wait([
      loadOnlyImages(contractorPaths),
      loadOnlyImages(clientPaths),
      loadOnlyImages(testSitePaths),
      loadOnlyImages(testResultConPaths),
      loadOnlyImages(testResultEngPaths),
      loadOnlyImages(otherAttachmentPaths),
      loadOnlyImages(listAttachmentPaths),
      loadOnlyImages(enclosurePaths),
      // All PDF clips globally
      loadPdfClips([
        ...contractorPaths,
        ...clientPaths,
        ...testSitePaths,
        ...testResultConPaths,
        ...testResultEngPaths,
        ...otherAttachmentPaths,
        ...listAttachmentPaths,
        ...enclosurePaths
      ]),
    ]);

    // Guardrails for mobile preview stability (especially iOS).
    List<pw.MemoryImage> cap(List<pw.MemoryImage> images, int max) =>
        images.length <= max ? images : images.sublist(0, max);

    final contractorSiteImages = cap(results[0], isIos ? 6 : 12);
    final clientSiteImages = cap(results[1], isIos ? 6 : 12);
    final testDocs = cap(results[2], isIos ? 4 : 8);
    final testResultCon = cap(results[3], isIos ? 4 : 8);
    final testResultEng = cap(results[4], isIos ? 4 : 8);
    final otherImages = cap(results[5], isIos ? 4 : 8);
    final listImages = cap(results[6], isIos ? 4 : 8);
    final enclosureImages = cap(results[7], isIos ? 4 : 8);
    final pdfAttachmentsPages = isIos ? <pw.MemoryImage>[] : cap(results[8], 12);


    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        maxPages: 500, // FURTHER INCREASED FOR STABILITY
        margin: const pw.EdgeInsets.all(32),
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey),
          ),
        ),
        build: (context) {
          // Merge other site images (excluding categorised ones)
          final otherGeneralImages = [
            ...otherImages,
            ...listImages,
            ...enclosureImages
          ];

          return [
            _buildHeaderSection(data, mrvcLogo, font, fontBold),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'REQUEST FOR INSPECTION (RFI) REPORT',
                style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 14,
                    decoration: pw.TextDecoration.underline),
              ),
            ),
            pw.SizedBox(height: 15),
            _buildMainInfoTable(data, font, fontBold),
            pw.SizedBox(height: 15),
            _buildInspectionDatesTable(data, font, fontBold),
            pw.SizedBox(height: 10),
            _buildDescriptionSection(info, font, fontBold),
            pw.SizedBox(height: 20),

            if (data.measurementDetails != null) ...[
              _buildSectionHeader('Measurement Details', fontBold),
              _buildMeasurementTable(data.measurementDetails!, font, fontBold),
              pw.SizedBox(height: 20),
            ],

            if (data.checklistItems.isNotEmpty) ...[
              _buildSectionHeader('Checklist Items', fontBold),
              ..._buildChecklistSection(data.checklistItems, font, fontBold),
              pw.SizedBox(height: 20),
            ],

            _buildSectionHeader('Validation Status & Remarks', fontBold),
            _buildValidationSection(info, font, fontBold),
            pw.SizedBox(height: 30),

            if (contractorSelfie != null) ...[
              pw.Center(
                  child: pw.Text('Contractor Selfie:',
                      style: pw.TextStyle(font: fontBold, fontSize: 11))),
              pw.SizedBox(height: 8),
              pw.Center(
                  child: pw.Image(contractorSelfie,
                      width: 250, height: 250, fit: pw.BoxFit.contain)),
              pw.SizedBox(height: 20),
            ],
            if (inspectorSelfie != null) ...[
              pw.Center(
                  child: pw.Text('Inspector Selfie:',
                      style: pw.TextStyle(font: fontBold, fontSize: 11))),
              pw.SizedBox(height: 8),
              pw.Center(
                  child: pw.Image(inspectorSelfie,
                      width: 250, height: 250, fit: pw.BoxFit.contain)),
              pw.SizedBox(height: 20),
            ],

            if (contractorSiteImages.isNotEmpty) ...[
              pw.Center(
                  child: pw.Text('Site Images By Contractor:',
                      style: pw.TextStyle(font: fontBold, fontSize: 11))),
              pw.SizedBox(height: 8),
              ..._buildImageGrid(contractorSiteImages),
              pw.SizedBox(height: 20),
            ],

            if (clientSiteImages.isNotEmpty) ...[
              pw.Center(
                  child: pw.Text('Site Images By Inspector:',
                      style: pw.TextStyle(font: fontBold, fontSize: 11))),
              pw.SizedBox(height: 8),
              ..._buildImageGrid(clientSiteImages),
              pw.SizedBox(height: 20),
            ],

            if (otherGeneralImages.isNotEmpty) ...[
              pw.Center(
                  child: pw.Text('Site Images & Attachments:',
                      style: pw.TextStyle(font: fontBold, fontSize: 11))),
              pw.SizedBox(height: 8),
              ..._buildImageGrid(otherGeneralImages),
              pw.SizedBox(height: 20),
            ],

            if (testDocs.isNotEmpty ||
                testResultCon.isNotEmpty ||
                testResultEng.isNotEmpty) ...[
              _buildSectionHeader('Test Documents & Results', fontBold),
              pw.SizedBox(height: 10),
              if (testDocs.isNotEmpty) ...[
                pw.Text('Test Site Documents (Contractor):',
                    style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ..._buildImageGrid(testDocs),
                pw.SizedBox(height: 15),
              ],
              if (testResultCon.isNotEmpty) ...[
                pw.Text('Test Result (Contractor):',
                    style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ..._buildImageGrid(testResultCon),
                pw.SizedBox(height: 15),
              ],
              if (testResultEng.isNotEmpty) ...[
                pw.Text('Test Result (Engineer):',
                    style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ..._buildImageGrid(testResultEng),
                pw.SizedBox(height: 15),
              ],
            ],

            if (pdfAttachmentsPages.isNotEmpty) ...[
              _buildSectionHeader('Extracted PDF Attachment Content', fontBold),
              pw.SizedBox(height: 10),
              ...pdfAttachmentsPages.map((pageImg) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 20),
                    decoration: pw.BoxDecoration(
                      border:
                          pw.Border.all(color: PdfColors.grey300, width: 0.5),
                    ),
                    child: pw.Center(
                      child: pw.Image(
                        pageImg,
                        width: 480,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  )),
            ],
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    if (isIos) {
      // iOS fallback: skip native preview (which can spin indefinitely on heavy docs).
      // Share/open the generated PDF directly so user can print from system sheet.
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'RFI_Report_$rfiId.pdf',
      );
      return;
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'RFI_Report_$rfiId.pdf',
    );
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
    ));
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
    return dio;
  }

  // Load image from project assets
  static Future<pw.MemoryImage?> _loadAssetImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      debugPrint('Error loading asset image $assetPath: $e');
      return null;
    }
  }

  static Future<pw.MemoryImage?> _loadImage(String? url, Dio dio) async {
    if (url == null || url.isEmpty || url.toLowerCase().endsWith('.pdf')) {
      return null;
    }

    // Skip WebP as it is unsupported by the pdf library
    if (url.toLowerCase().endsWith('.webp')) {
      debugPrint('Skipping WebP image: $url');
      return null;
    }

    try {
      final Uint8List bytes = await RfiPreviewFetch.fetchBytes(dio, url);

      bool isValid = false;
      if (bytes.length > 4 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
        isValid = true; // JPEG
      } else if (bytes.length > 8 && bytes[0] == 0x89 && bytes[1] == 0x50) {
        isValid = true; // PNG
      }

      if (!isValid) {
        debugPrint('Invalid image format for $url');
        return null;
      }

      try {
        return pw.MemoryImage(bytes);
      } catch (e) {
        debugPrint('Failed to decode image $url: $e');
        return null;
      }
    } catch (e) {
      debugPrint('Error loading image $url: $e');
    }
    return null;
  }

  static List<String> _extractPaths(String? data) {
    if (data == null || data.isEmpty) return [];

    final trimmed = data.trim();
    if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
      try {
        final decoded = json.decode(trimmed);
        if (decoded is List) {
          return decoded
              .map((item) {
                if (item is Map && item.containsKey('filePath')) {
                  return item['filePath']?.toString();
                } else if (item is String) {
                  return item;
                }
                return null;
              })
              .whereType<String>()
              .toList();
        } else if (decoded is Map) {
          if (decoded.containsKey('filePath')) {
            return [decoded['filePath']?.toString() ?? ''];
          }
        }
      } catch (e) {
        debugPrint('Error parsing JSON paths segments: $e');
      }
    }

    return data
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.contains('":'))
        .toList();
  }

  static Future<List<pw.MemoryImage>> _loadImages(List<String> paths, Dio dio) async {
    final List<pw.MemoryImage?> images = await Future.wait(
      paths.map((path) => _loadImage(path, dio)),
    );
    return images.whereType<pw.MemoryImage>().toList();
  }

  static Future<List<pw.MemoryImage>> _loadPdfPages(String url, Dio dio) async {
    try {
      final Uint8List bytes = await RfiPreviewFetch.fetchBytes(dio, url);
      if (bytes.length < 4 ||
          bytes[0] != 0x25 ||
          bytes[1] != 0x50 ||
          bytes[2] != 0x44 ||
          bytes[3] != 0x46) {
        return [];
      }

      final doc = await pdfr.PdfDocument.openData(bytes);
        final pages = <pw.MemoryImage>[];
        // Guardrail: rendering too many PDF pages can block print preview on mobile.
        final maxPagesToRender = doc.pagesCount > 5 ? 5 : doc.pagesCount;
        for (int i = 1; i <= maxPagesToRender; i++) {
          final page = await doc.getPage(i);
          // Scale down for better performance and memory
          final pageImage = await page.render(
            width: page.width * 1.2,
            height: page.height * 1.2,
            quality: 65,
          );
          if (pageImage != null) {
            pages.add(pw.MemoryImage(pageImage.bytes));
          }
          await page.close();
        }
      await doc.close();
      return pages;
    } catch (e) {
      debugPrint('Error rendering PDF pages for $url: $e');
    }
    return [];
  }

  static String _resolveUrl(String url) => RfiPreviewFetch.resolvePublicUrl(url);

  static List<pw.Widget> _buildImageGrid(List<pw.MemoryImage> images) {
    final List<pw.Widget> widgets = [];
    for (int i = 0; i < images.length; i += 2) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Image(images[i], width: 220, height: 200, fit: pw.BoxFit.contain),
                ),
              ),
              if (i + 1 < images.length)
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Image(images[i + 1], width: 220, height: 200, fit: pw.BoxFit.contain),
                  ),
                )
              else
                pw.Expanded(child: pw.SizedBox()),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  static List<pw.Widget> _buildChecklistSection(List<ChecklistItem> items, pw.Font font, pw.Font fontBold) {
     final Map<String, List<ChecklistItem>> grouped = {};
     for (var item in items) {
       final name = item.enclosureName ?? 'General Checklist';
       grouped.putIfAbsent(name, () => []).add(item);
     }

     final List<pw.Widget> widgets = [];
     grouped.forEach((name, groupItems) {
       widgets.add(
         pw.Padding(
           padding: const pw.EdgeInsets.only(top: 10, bottom: 5),
           child: pw.Text(name, style: pw.TextStyle(font: fontBold, fontSize: 10, color: _primaryColor)),
         )
       );
       
       widgets.add(
         pw.Table(
           border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
           columnWidths: {
             0: const pw.FixedColumnWidth(25),
             1: const pw.FlexColumnWidth(3),
             2: const pw.FlexColumnWidth(1),
             3: const pw.FlexColumnWidth(1),
             4: const pw.FlexColumnWidth(2),
           },
           children: [
             pw.TableRow(
               decoration: const pw.BoxDecoration(color: PdfColors.grey100),
               children: [
                 _buildTableHeaderCell('#', fontBold),
                 _buildTableHeaderCell('Description', fontBold),
                 _buildTableHeaderCell('Con Status', fontBold),
                 _buildTableHeaderCell('AE Status', fontBold),
                 _buildTableHeaderCell('Remarks', fontBold),
               ],
             ),
             ...groupItems.asMap().entries.map((entry) {
               final idx = entry.key + 1;
               final item = entry.value;
               return pw.TableRow(
                 children: [
                   _buildTableCell(idx.toString(), font),
                   _buildTableCell(item.checklistDescription ?? '---', font),
                   _buildTableCell(item.conStatus ?? '---', font),
                   _buildTableCell(item.aeStatus ?? '---', font),
                   _buildTableCell(
                     'Con: ${item.contractorRemark ?? "-"}\nAE: ${item.aeRemark ?? "-"}',
                     font,
                   ),
                 ],
               );
             }),
           ],
         )
       );
     });

     return widgets;
  }

  static pw.Widget _buildHeaderSection(
      RfiReportDetailsData data, pw.MemoryImage? logo, pw.Font font, pw.Font fontBold) {
    final info = data.reportDetails;
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Mumbai Rail Vikas Corporation',
                    style: pw.TextStyle(font: fontBold, fontSize: 16),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Client:',
                    style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'Mumbai Rail Vikas Corporation',
                    style: pw.TextStyle(font: fontBold, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (logo != null)
              pw.Image(logo, height: 40, width: 80, fit: pw.BoxFit.contain),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              'RFI Status: ',
              style: pw.TextStyle(font: fontBold, fontSize: 11),
            ),
            pw.Text(
              info.rfiStatus ?? 'N/A',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 11,
                color: info.rfiStatus?.toLowerCase() == 'active'
                    ? PdfColors.green
                    : PdfColors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildMainInfoTable(
      RfiReportDetailsData data, pw.Font font, pw.Font fontBold) {
    final info = data.reportDetails;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.2),
      },
      children: [
        _buildTwoColRow('Consultant:', 'N/A', 'RFI ID:', info.rfiId, font, fontBold),
        _buildTwoColRow('Project:', info.project, 'Date of Submission:',
            info.dateOfCreation, font, fontBold),
        _buildTwoColRow('Work:', info.work, 'Contract:', info.contract, font, fontBold),
        _buildTwoColRow(
            'Contract ID:', info.contractId, 'Structure Type:', info.structureType, font, fontBold),
        _buildTwoColRow(
            'Structure:', info.structure, 'Component:', info.component, font, fontBold),
        _buildTwoColRow('Element:', info.element, 'Activity:', info.activity, font, fontBold),
        _buildTwoColRow('RFI Description:', info.rfiDescription, 'Type of RFI:',
            info.typeOfRfi, font, fontBold),
        _buildTwoColRow('Enclosures:', info.enclosures, 'Contractor:', info.contractor,
            font, fontBold),
        _buildTwoColRow("Contractor's Representative:", info.contractorRepresentative,
            'Client Representative:', info.clientRepresentative, font, fontBold),
      ],
    );
  }

  static pw.Widget _buildInspectionDatesTable(
      RfiReportDetailsData data, pw.Font font, pw.Font fontBold) {
    final info = data.reportDetails;
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.2),
      },
      children: [
        _buildFullWidthLabelRow('Contractor Inspected Date:', info.conInspDate, font, fontBold),
        _buildTwoColRow('Proposed Time:', info.proposedInspectionTime, 'Actual Time:',
            info.actualInspectionTime, font, fontBold),
        _buildTwoColRow('Proposed Inspection Date:', info.proposedDateOfInspection,
            'Actual Inspection Date:', info.actualDateOfInspection, font, fontBold),
        _buildTwoColRow('Contractor Location:', info.conLocation, 'Client Location:',
            info.clientLocation, font, fontBold),
        _buildTwoColRow('Inspection Test Type:', info.typeOfTest, 'Test Approval By Inspector:',
            info.testStatus, font, fontBold),
        _buildTwoColRow('Chainage:', info.chainage, 'DyHod:', info.dyHodUserName, font, fontBold),
      ],
    );
  }

  static pw.TableRow _buildTwoColRow(String l1, String? v1, String l2, String? v2,
      pw.Font font, pw.Font fontBold) {
    return pw.TableRow(
      children: [
        _buildLabelCell(l1, fontBold),
        _buildValueCell(v1, font),
        _buildLabelCell(l2, fontBold),
        _buildValueCell(v2, font),
      ],
    );
  }

  static pw.TableRow _buildFullWidthLabelRow(
      String label, String? value, pw.Font font, pw.Font fontBold) {
    return pw.TableRow(
      children: [
        _buildLabelCell(label, fontBold),
        pw.Expanded(
          flex: 3,
          child: _buildValueCell(value, font),
        ),
        pw.SizedBox(),
        pw.SizedBox(),
      ],
    );
  }

  static pw.Widget _buildLabelCell(String label, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(label, style: pw.TextStyle(font: fontBold, fontSize: 9)),
    );
  }

  static pw.Widget _buildValueCell(String? value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(value?.isNotEmpty == true ? value! : '---',
          style: pw.TextStyle(font: font, fontSize: 9)),
    );
  }

  static pw.Widget _buildDescriptionSection(
      ReportDetailsInfo info, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Description:', style: pw.TextStyle(font: fontBold, fontSize: 9)),
        pw.SizedBox(height: 4),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
          ),
          child: pw.Text(info.descriptionByContractor ?? '---',
              style: pw.TextStyle(font: font, fontSize: 9)),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionHeader(String title, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      color: _primaryColor,
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(font: fontBold, fontSize: 10, color: _headerTextColor),
      ),
    );
  }

  static pw.Widget _buildMeasurementTable(
      MeasurementDetails details, pw.Font font, pw.Font fontBold) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _primaryColor),
          children: [
            _buildTableHeaderCell('Type', fontBold),
            _buildTableHeaderCell('Length', fontBold),
            _buildTableHeaderCell('Breadth', fontBold),
            _buildTableHeaderCell('Height', fontBold),
            _buildTableHeaderCell('Count', fontBold),
            _buildTableHeaderCell('Total Quantity', fontBold),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell(details.measurementType ?? '---', font),
            _buildTableCell(details.l?.toString() ?? '---', font),
            _buildTableCell(details.b?.toString() ?? '---', font),
            _buildTableCell(details.h?.toString() ?? '---', font),
            _buildTableCell(details.no?.toString() ?? '---', font),
            _buildTableCell(details.totalQty?.toString() ?? '---', font),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeaderCell(String label, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(label,
          style: pw.TextStyle(font: fontBold, fontSize: 9, color: _headerTextColor)),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 9)),
    );
  }

  static pw.Widget _buildValidationSection(
      ReportDetailsInfo info, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text('Status: ', style: pw.TextStyle(font: fontBold, fontSize: 10)),
              pw.Text(info.validationStatus ?? '---',
                  style: pw.TextStyle(font: font, fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Text('Remarks: ', style: pw.TextStyle(font: fontBold, fontSize: 10)),
              pw.Text(info.remarks ?? '---',
                  style: pw.TextStyle(font: font, fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Comment: ', style: pw.TextStyle(font: fontBold, fontSize: 10)),
              pw.Expanded(
                child: pw.Text(info.validationComments ?? '---',
                    style: pw.TextStyle(font: font, fontSize: 10)),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Engineer Remarks: ',
                  style: pw.TextStyle(font: fontBold, fontSize: 10)),
              pw.Expanded(
                child: pw.Text(info.engineerRemarks ?? '---',
                    style: pw.TextStyle(font: font, fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
