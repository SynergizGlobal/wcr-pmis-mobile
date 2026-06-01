import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfr;

import '../../domain/inspection/enclosure_checklist.dart';
import '../../domain/inspection/inspection_item.dart';
import '../../providers/inspection/inspection_form_state.dart';
import '../utils/rfi_preview_fetch.dart';
import '../utils/user_role.dart';

/// Builds the inspection submit PDF (MRVC-style Part I–III) and appends
/// enclosure/supporting PDFs, then checklist tables (online only).
class InspectionSubmitPdfBuilder {
  static const _margin = 30.0;
  static const _yellow = PdfColor.fromInt(0xFFFFFF00);
  static const _maxPdfPagesPerFile = 12;
  static const _maxTotalAttachmentPages = 80;

  static Future<File> build({
    required InspectionFormState state,
    required UserRole role,
    required bool isOffline,
    required int rfiId,
    required Dio dio,
  }) async {
    final rfi = state.rfiDetails;
    if (rfi == null) {
      throw Exception('RFI details not loaded. Please try again.');
    }

    final isEngineer = role == UserRole.engineer ||
        role == UserRole.dyHodEngineer ||
        role == UserRole.hod ||
        role == UserRole.dyHod;

    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    final logo = await _loadAssetImage('assets/images/mrvc_logo.png');

    final pdf = pw.Document();
    final enclosureNames = _enclosureNames(state, rfi);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(_margin),
        build: (context) => _buildPageOne(
          state: state,
          rfi: rfi,
          enclosureNames: enclosureNames,
          isEngineer: isEngineer,
          font: font,
          fontBold: fontBold,
          logo: logo,
        ),
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(_margin),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: _buildPartTwoEngineerRemarksPage(
            state: state,
            isEngineer: isEngineer,
            isOffline: isOffline,
            font: font,
            fontBold: fontBold,
          ),
        ),
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(_margin),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: _buildPartThreeValidationPage(
            state: state,
            rfi: rfi,
            isOffline: isOffline,
            font: font,
            fontBold: fontBold,
          ),
        ),
      ),
    );

    final siteImages = await _loadSiteImages(state.siteImagePaths, dio);
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(_margin),
        build: (context) => _buildPageTwo(
          state: state,
          rfi: rfi,
          rfiId: rfiId,
          enclosureNames: enclosureNames,
          isEngineer: isEngineer,
          font: font,
          fontBold: fontBold,
          siteImages: siteImages,
        ),
      ),
    );

    final attachmentPages = await _loadAttachmentPdfPages(
      state,
      rfi,
      dio,
      rfiId: rfiId,
      isEngineer: isEngineer,
    );
    var totalAttached = 0;
    for (final attachment in attachmentPages) {
      if (totalAttached >= _maxTotalAttachmentPages) break;
      final rendered = await _renderPdfBytes(attachment.bytes);
      if (rendered.isEmpty) continue;

      for (var i = 0; i < rendered.length; i++) {
        if (totalAttached >= _maxTotalAttachmentPages) break;
        final label = i == 0 ? attachment.label : null;
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(_margin),
            build: (context) => _buildAttachmentPage(
              image: rendered[i],
              label: label,
              fontBold: fontBold,
            ),
          ),
        );
        totalAttached++;
      }
    }

    if (!isOffline && state.enclosureChecklists.isNotEmpty) {
      for (final entry in state.enclosureChecklists.entries) {
        final items = entry.value;
        if (items.isEmpty) continue;
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(_margin),
            build: (context) => _buildChecklistPage(
              enclosureName: entry.key,
              items: items,
              font: font,
              fontBold: fontBold,
            ),
          ),
        );
      }
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/inspection_submit_$rfiId.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static List<String> _enclosureNames(InspectionFormState state, InspectionItem rfi) {
    final names = <String>{};
    if (rfi.enclosuresList != null) {
      names.addAll(rfi.enclosuresList!.where((e) => e.trim().isNotEmpty));
    }
    names.addAll(state.enclosureChecklists.keys);
    for (final enc in rfi.enclosure ?? <Enclosure>[]) {
      final n = enc.enclosureName?.trim();
      if (n != null && n.isNotEmpty) names.add(n);
    }
    return names.toList();
  }

  static List<pw.Widget> _buildPageOne({
    required InspectionFormState state,
    required InspectionItem rfi,
    required List<String> enclosureNames,
    required bool isEngineer,
    required pw.Font font,
    required pw.Font fontBold,
    required pw.MemoryImage? logo,
  }) {
    final contract = rfi.contract ?? '';
    final contractor = rfi.createdBy ?? '';
    final contractorRep =
        state.contractorRepresentative.isNotEmpty
            ? state.contractorRepresentative
            : (rfi.nameOfRepresentative ?? '');
    final submissionDate = _displayDate(rfi.dateOfSubmission);
    final inspectionDate = _displayDate(state.dateOfInspection ?? rfi.dateOfInspection);
    final inspectionTime = state.timeOfInspection ?? rfi.timeOfInspection ?? '';
    final structureLine = [
      rfi.structureType,
      rfi.structure,
      rfi.component,
      rfi.element,
      rfi.activity,
      rfi.rfiDescription,
    ].whereType<String>().where((e) => e.trim().isNotEmpty).join(' / ');
    final rfiDescription = rfi.description ?? rfi.rfiDescription ?? '';

    return [
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 1),
          ),
          padding: const pw.EdgeInsets.all(8),
          child: pw.Column(
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (logo != null)
                    pw.Image(logo, width: 50, height: 50, fit: pw.BoxFit.contain),
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'MUMBAI RAILWAY VIKAS CORPORATION LTD.',
                          style: pw.TextStyle(font: fontBold, fontSize: 14),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '(A PSU of Government of India, Ministry of Railways)',
                          style: pw.TextStyle(font: font, fontSize: 9),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                color: _yellow,
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: pw.Text(
                  'Contract :- $contract',
                  style: pw.TextStyle(font: fontBold, fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Engineer :- M/s. Mumbai Railway Vikas Corporation',
                style: pw.TextStyle(font: font, fontSize: 10),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                width: double.infinity,
                color: _yellow,
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: pw.Text(
                  'Contractor :- $contractor',
                  style: pw.TextStyle(font: fontBold, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Part - I :', style: pw.TextStyle(font: fontBold, fontSize: 12)),
            pw.Text(
              'RFI.No : ${rfi.rfiId ?? ''}',
              style: pw.TextStyle(font: fontBold, fontSize: 11),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        _row(font, 'Name of Contractor\'s Representative :', contractorRep),
        _row(font, 'Date of Submission :', submissionDate),
        _row(font, 'Time of Inspection :', inspectionTime),
        _row(font, 'Date of Inspection :', inspectionDate),
        pw.SizedBox(height: 6),
        pw.Text(
          'Structure Type/Structure/Component/Element/Activity/Rfi-Description :',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(structureLine, style: pw.TextStyle(font: font, fontSize: 9)),
        pw.SizedBox(height: 6),
        pw.Text('Location:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
        pw.Text(state.location, style: pw.TextStyle(font: font, fontSize: 9)),
        pw.SizedBox(height: 6),
        pw.Text('RFI Description:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
          child: pw.Text(rfiDescription, style: pw.TextStyle(font: font, fontSize: 9)),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Enclosures:', style: pw.TextStyle(font: fontBold, fontSize: 11)),
        pw.SizedBox(height: 4),
        ...enclosureNames.asMap().entries.map(
              (e) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
                child: _labeledCheckbox(
                  label: '${e.key + 1}) ${e.value}',
                  checked: true,
                  font: font,
                  fontSize: 9,
                ),
              ),
            ),
      ];
  }

  static List<pw.Widget> _buildPartTwoEngineerRemarksPage({
    required InspectionFormState state,
    required bool isEngineer,
    required bool isOffline,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    final status = state.inspectionStatus.trim();
    final isAccepted = status.toUpperCase() == 'ACCEPTED';
    final isRejected = status.toUpperCase() == 'REJECTED' ||
        status.toUpperCase() == 'RETURNED_FOR_RECTIFICATION' ||
        status == 'Rectification';
    // Online submit: stampEnggPdfFromXml overlays ticks, remarks, and signatures.
    final showApprovalMarks = isOffline && isEngineer;
    final remarks = isOffline && isEngineer && isRejected
        ? state.engineerRemarks.trim()
        : '';

    return [
      pw.Text(
        'Part - II : Engineer\'s Remarks',
        style: pw.TextStyle(font: fontBold, fontSize: 12),
      ),
      pw.SizedBox(height: 10),
      _buildEngineerApprovalTable(
        font: font,
        fontBold: fontBold,
        isAccepted: showApprovalMarks && isAccepted,
        isRejected: showApprovalMarks && isRejected,
      ),
      pw.SizedBox(height: 12),
      _formFieldBox(
        label: 'Remarks:',
        value: remarks,
        font: font,
        fontBold: fontBold,
        minHeight: 40,
      ),
      pw.SizedBox(height: 16),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _signaturePlaceholder(
            title: 'Contractor Representative',
            font: font,
            boxHeight: 92,
          ),
          pw.SizedBox(width: 28),
          _signaturePlaceholder(
            title: 'MRVC Representative',
            font: font,
            boxHeight: 92,
          ),
        ],
      ),
    ];
  }

  /// Fixed page for server [stampPdfFromXml] / validation overlays (web template).
  static List<pw.Widget> _buildPartThreeValidationPage({
    required InspectionFormState state,
    required InspectionItem rfi,
    required bool isOffline,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    final contractorDesc = _inspectionDescriptionForPdf(
      state: state,
      forContractor: true,
    );
    final clientDesc = _inspectionDescriptionForPdf(
      state: state,
      forContractor: false,
    );

    return [
      pw.Text(
        'Part - III : Validation (OPTIONAL)',
        style: pw.TextStyle(font: fontBold, fontSize: 12),
      ),
      pw.SizedBox(height: 10),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _labeledCheckbox(
            label: 'Approved',
            checked: false,
            font: font,
            fontBold: fontBold,
          ),
          pw.SizedBox(width: 40),
          _labeledCheckbox(
            label: 'Rejected',
            checked: false,
            font: font,
            fontBold: fontBold,
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Text('Remarks:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
      pw.SizedBox(height: 4),
      pw.Text('Comment:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
      pw.SizedBox(height: 4),
      _stampReserveBox(
        height: 72,
        value: isOffline ? (rfi.validationStatus ?? '').trim() : '',
        font: font,
      ),
      pw.SizedBox(height: 12),
      _validatedByOnStampZone(
        validatedBy: isOffline ? (rfi.assignedPersonClient ?? '').trim() : '',
        validatedOn: isOffline
            ? DateFormat('yyyy-MM-dd').format(DateTime.now())
            : '',
        font: font,
        fontBold: fontBold,
      ),
      pw.SizedBox(height: 14),
      pw.Text(
        'Inspection Description (Contractor):',
        style: pw.TextStyle(font: fontBold, fontSize: 10),
      ),
      pw.SizedBox(height: 2),
      pw.Text(contractorDesc, style: pw.TextStyle(font: font, fontSize: 9)),
      pw.SizedBox(height: 8),
      pw.Text(
        'Inspection Description (Client):',
        style: pw.TextStyle(font: fontBold, fontSize: 10),
      ),
      pw.SizedBox(height: 2),
      pw.Text(clientDesc, style: pw.TextStyle(font: font, fontSize: 9)),
    ];
  }

  static List<pw.Widget> _buildPageTwo({
    required InspectionFormState state,
    required InspectionItem rfi,
    required int rfiId,
    required List<String> enclosureNames,
    required bool isEngineer,
    required pw.Font font,
    required pw.Font fontBold,
    required List<pw.MemoryImage> siteImages,
  }) {
    final measurements = state.measurements;

    final footerText = isEngineer
        ? 'RFI No. ${rfi.rfiId ?? rfiId} is submitted by Contractor on '
            '${_displayDate(rfi.dateOfSubmission)} and approved by Engineer on '
            '${_displayDate(DateTime.now().toIso8601String())}. '
            'It is a digitally generated document and is electronically signed on '
            '1st page of this RFI.'
        : null;

    return [
        pw.Text('Measurement Record', style: pw.TextStyle(font: fontBold, fontSize: 11)),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: [
            'Type of Measurement',
            'Units',
            'L',
            'B',
            'H',
            'Weight',
            'No.',
            'Total Qty.',
          ],
          headerStyle: pw.TextStyle(font: fontBold, fontSize: 7),
          cellStyle: pw.TextStyle(font: font, fontSize: 7),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          data: measurements
              .map(
                (m) => [
                  m.type == 'Select' ? '' : m.type,
                  m.units == 'Select U' ? '' : m.units,
                  m.l,
                  m.b,
                  m.h,
                  m.weight,
                  m.no,
                  m.totalQty.toStringAsFixed(
                    m.totalQty == m.totalQty.roundToDouble() ? 0 : 2,
                  ),
                ],
              )
              .toList(),
        ),
        pw.SizedBox(height: 12),
        pw.Text('Enclosures', style: pw.TextStyle(font: fontBold, fontSize: 12)),
        ...enclosureNames.asMap().entries.map(
              (e) => pw.Padding(
                padding: const pw.EdgeInsets.only(top: 6),
                child: pw.Text(
                  'Enclosure ${e.key + 1}: ${e.value}',
                  style: pw.TextStyle(font: fontBold, fontSize: 10),
                ),
              ),
            ),
        if (siteImages.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text('Contractor Site Images:',
              style: pw.TextStyle(font: fontBold, fontSize: 10)),
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: siteImages
                .map(
                  (img) => pw.Image(img, width: 200, height: 120, fit: pw.BoxFit.cover),
                )
                .toList(),
          ),
        ],
        if (footerText != null) ...[
          pw.SizedBox(height: 20),
          pw.Text(
            footerText,
            style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey700),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ];
  }

  static pw.Widget _pdfCheckbox({
    required bool checked,
    required pw.Font fontBold,
    double size = 11,
  }) {
    return pw.Container(
      width: size,
      height: size,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
      ),
      child: checked
          ? pw.Text(
              'X',
              style: pw.TextStyle(font: fontBold, fontSize: 8),
            )
          : null,
    );
  }

  static pw.Widget _labeledCheckbox({
    required String label,
    required bool checked,
    required pw.Font font,
    pw.Font? fontBold,
    double fontSize = 10,
  }) {
    final bold = fontBold ?? font;
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        _pdfCheckbox(checked: checked, fontBold: bold),
        pw.SizedBox(width: 6),
        pw.Text(
          label,
          style: pw.TextStyle(font: font, fontSize: fontSize),
        ),
      ],
    );
  }

  static pw.Widget _formFieldBox({
    required String label,
    required String value,
    required pw.Font font,
    required pw.Font fontBold,
    double minHeight = 32,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(font: fontBold, fontSize: 10),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          width: double.infinity,
          constraints: pw.BoxConstraints(minHeight: minHeight),
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey600, width: 0.75),
          ),
          alignment: pw.Alignment.topLeft,
          child: pw.Text(
            value.isEmpty ? ' ' : value,
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildEngineerApprovalTable({
    required pw.Font font,
    required pw.Font fontBold,
    required bool isAccepted,
    required bool isRejected,
  }) {
    const cellPad = pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6);
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(1),
        1: pw.FlexColumnWidth(1),
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: cellPad,
              child: pw.Text(
                'Submitted By',
                style: pw.TextStyle(font: font, fontSize: 9),
              ),
            ),
            pw.Padding(
              padding: cellPad,
              child: pw.Text(
                'Received By',
                style: pw.TextStyle(font: font, fontSize: 9),
              ),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: cellPad,
              child: pw.Text(
                'Contractor',
                style: pw.TextStyle(font: font, fontSize: 9),
              ),
            ),
            pw.Padding(
              padding: cellPad,
              child: pw.Text(
                'Engineer',
                style: pw.TextStyle(font: font, fontSize: 9),
              ),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: _labeledCheckbox(
                label: 'Approved',
                checked: isAccepted,
                font: font,
                fontBold: fontBold,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: _labeledCheckbox(
                label: 'Not Approved',
                checked: isRejected,
                font: font,
                fontBold: fontBold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _signaturePlaceholder({
    required String title,
    required pw.Font font,
    double boxHeight = 92,
  }) {
    return pw.Expanded(
      child: pw.Container(
        height: boxHeight + 22,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey600, width: 0.75),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(font: font, fontSize: 9),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 6),
            pw.Expanded(child: pw.SizedBox()),
          ],
        ),
      ),
    );
  }

  /// Empty bordered area for server-stamped remarks / comment text.
  static pw.Widget _stampReserveBox({
    required double height,
    required String value,
    required pw.Font font,
  }) {
    return pw.Container(
      width: double.infinity,
      height: height,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600, width: 0.75),
      ),
      alignment: pw.Alignment.topLeft,
      child: value.isEmpty
          ? null
          : pw.Text(value, style: pw.TextStyle(font: font, fontSize: 9)),
    );
  }

  /// Label row, reserved value band, then rule line (web stamp targets).
  static pw.Widget _validatedByOnStampZone({
    required String validatedBy,
    required String validatedOn,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    const valueBandHeight = 22.0;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                'Validated By:',
                style: pw.TextStyle(font: fontBold, fontSize: 9),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                'Validated On:',
                style: pw.TextStyle(font: fontBold, fontSize: 9),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
        pw.SizedBox(
          height: valueBandHeight,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                child: pw.Text(
                  validatedBy.isEmpty ? ' ' : validatedBy,
                  style: pw.TextStyle(font: font, fontSize: 9),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  validatedOn.isEmpty ? ' ' : validatedOn,
                  style: pw.TextStyle(font: font, fontSize: 9),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        pw.Divider(thickness: 0.5, color: PdfColors.grey600),
      ],
    );
  }

  static pw.Widget _buildAttachmentPage({
    required pw.MemoryImage image,
    String? label,
    required pw.Font fontBold,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (label != null)
          pw.Text(label, style: pw.TextStyle(font: fontBold, fontSize: 11)),
        pw.Expanded(
          child: pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildChecklistPage({
    required String enclosureName,
    required List<ChecklistItem> items,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Checklist — $enclosureName',
          style: pw.TextStyle(font: fontBold, fontSize: 12),
        ),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: [
            'ID',
            'Description',
            'Contractor Status',
            'Engineer Status',
            'Contractor Remark',
            'Engineer Remark',
          ],
          headerStyle: pw.TextStyle(font: fontBold, fontSize: 7),
          cellStyle: pw.TextStyle(font: font, fontSize: 7),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          data: items.asMap().entries.map((entry) {
            final row = entry.value;
            return [
              '${entry.key + 1}',
              row.checklistDescription ?? '',
              row.contractorStatus ?? '',
              row.engineerStatus ?? '',
              row.contractorRemarks ?? '',
              row.engineerRemark ?? '',
            ];
          }).toList(),
        ),
      ],
    );
  }

  static pw.Widget _row(pw.Font font, String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 180,
            child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 9)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 9)),
          ),
        ],
      ),
    );
  }

  /// Part III: contractor / engineer text from API `descriptionEnclosure`.
  static String _inspectionDescriptionForPdf({
    required InspectionFormState state,
    required bool forContractor,
  }) {
    final fromApi = _descriptionEnclosureFromInspectionDetails(
      state.rfiDetails?.inspectionDetails,
      forContractor: forContractor,
    );
    if (fromApi != null && fromApi.isNotEmpty) return fromApi;

    final fromForm = forContractor
        ? state.contractorDescription.trim()
        : state.clientDescription.trim();
    if (fromForm.isNotEmpty) return fromForm;

    return '-';
  }

  static String? _descriptionEnclosureFromInspectionDetails(
    List<InspectionDetail>? details, {
    required bool forContractor,
  }) {
    if (details == null || details.isEmpty) return null;

    for (final detail in details) {
      if (forContractor) {
        if (!_isContractorInspectionDetail(detail)) continue;
      } else if (!_isEngineerInspectionDetail(detail)) {
        continue;
      }
      final text = _descriptionEnclosureFromDetail(detail);
      if (text != null) return text;
    }
    return null;
  }

  static String? _descriptionEnclosureFromDetail(InspectionDetail detail) {
    final text = detail.descriptionEnclosure?.trim();
    if (text == null || text.isEmpty) return null;
    final location = detail.location?.trim();
    if (location != null && location.isNotEmpty && text == location) {
      return null;
    }
    return text;
  }

  static bool _isContractorInspectionDetail(InspectionDetail detail) {
    return detail.uploadedBy?.trim().toUpperCase() == 'CON';
  }

  static bool _isEngineerInspectionDetail(InspectionDetail detail) {
    final u = detail.uploadedBy?.trim().toUpperCase() ?? '';
    if (u.isEmpty) return false;
    return u == 'ENG' || u == 'ENGG' || u == 'AE' || u.startsWith('ENG');
  }

  static String _displayDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  /// Web [pdfUtils]: merge enclosure → supporting → test report PDFs only.
  /// Do not append prior inspection master PDFs from [inspectionDetails].
  static Future<List<_LabeledPdf>> _loadAttachmentPdfPages(
    InspectionFormState state,
    InspectionItem rfi,
    Dio dio, {
    required int rfiId,
    required bool isEngineer,
  }) async {
    final rfiIdLabel = rfi.rfiId;
    final ordered = <_PathLabel>[];

    void addSourcePdf(String? path, String label) {
      if (path == null || path.trim().isEmpty) return;
      for (final p in _splitPaths(path)) {
        if (!_isPdf(p)) continue;
        if (_isInspectionMasterPdfPath(p, rfiId, rfiIdLabel)) continue;
        ordered.add(_PathLabel(p, label));
      }
    }

    // 1. Enclosures (web: enclosurePdfBlobs)
    for (final path in state.enclosurePaths) {
      addSourcePdf(path, 'Enclosure');
    }
    for (final enc in rfi.enclosure ?? <Enclosure>[]) {
      addSourcePdf(enc.enclosureUploadFile, 'Enclosure');
    }

    // 2. Supporting documents (web: supportingPdfBlobs — form uploads only)
    for (final doc in state.supportingDocuments) {
      addSourcePdf(doc.path, 'Supporting Document');
    }

    // 3. Test report (web: testReportFile — role-specific path on RFI)
    final testReportPath = isEngineer
        ? (rfi.testResEngg?.trim().isNotEmpty == true
            ? rfi.testResEngg
            : rfi.testResCon)
        : rfi.testResCon;
    addSourcePdf(testReportPath, 'Test Report');

    final seen = <String>{};
    final result = <_LabeledPdf>[];
    for (final item in ordered) {
      final key = item.path.trim();
      if (seen.contains(key)) continue;
      seen.add(key);
      final bytes = await _loadFileBytes(item.path, dio);
      if (bytes != null && bytes.isNotEmpty) {
        result.add(_LabeledPdf(item.label, bytes));
      }
    }
    return result;
  }

  static bool _isInspectionMasterPdfPath(
    String path,
    int rfiId,
    String? rfiIdLabel,
  ) {
    final lower = path.trim().toLowerCase();
    if (lower.isEmpty) return false;

    final ids = <String>{rfiId.toString()};
    if (rfiIdLabel != null && rfiIdLabel.trim().isNotEmpty) {
      ids.add(rfiIdLabel.trim().toLowerCase());
    }

    for (final id in ids) {
      if (lower.endsWith('$id.pdf') || lower.contains('/$id.pdf')) {
        return true;
      }
      if (lower.contains('report_$id')) return true;
      if (lower.contains('inspection_submit_$id')) return true;
    }

    if (lower.contains('uploadpdf') ||
        lower.contains('stampedpdf') ||
        lower.contains('stamppdffromxml')) {
      return true;
    }
    return false;
  }

  static Future<List<pw.MemoryImage>> _loadSiteImages(
    List<String> paths,
    Dio dio,
  ) async {
    final images = <pw.MemoryImage>[];
    for (final path in paths) {
      if (_isPdf(path)) continue;
      final bytes = await _loadFileBytes(path, dio);
      if (bytes == null || bytes.isEmpty) continue;
      try {
        images.add(pw.MemoryImage(bytes));
      } catch (e) {
        debugPrint('Skip site image $path: $e');
      }
    }
    return images;
  }

  static Future<List<pw.MemoryImage>> _renderPdfBytes(Uint8List bytes) async {
    if (bytes.length < 4 ||
        bytes[0] != 0x25 ||
        bytes[1] != 0x50 ||
        bytes[2] != 0x44 ||
        bytes[3] != 0x46) {
      return [];
    }
    try {
      final doc = await pdfr.PdfDocument.openData(bytes);
      final pages = <pw.MemoryImage>[];
      final count = doc.pagesCount > _maxPdfPagesPerFile
          ? _maxPdfPagesPerFile
          : doc.pagesCount;
      for (var i = 1; i <= count; i++) {
        final page = await doc.getPage(i);
        final rendered = await page.render(
          width: page.width * 1.5,
          height: page.height * 1.5,
          quality: 72,
        );
        if (rendered != null) {
          pages.add(pw.MemoryImage(rendered.bytes));
        }
        await page.close();
      }
      await doc.close();
      return pages;
    } catch (e) {
      debugPrint('PDF render failed: $e');
      return [];
    }
  }

  static Future<Uint8List?> _loadFileBytes(String path, Dio dio) async {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('data:')) {
      try {
        final comma = trimmed.indexOf(',');
        if (comma < 0) return null;
        return Uint8List.fromList(base64Decode(trimmed.substring(comma + 1)));
      } catch (_) {
        return null;
      }
    }

    if (File(trimmed).existsSync()) {
      return File(trimmed).readAsBytes();
    }

    try {
      return await RfiPreviewFetch.fetchBytes(dio, trimmed);
    } catch (e) {
      debugPrint('Fetch failed for $trimmed: $e');
      return null;
    }
  }

  static List<String> _splitPaths(String data) {
    final trimmed = data.trim();
    if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          return decoded
              .map((item) {
                if (item is Map && item.containsKey('filePath')) {
                  return item['filePath']?.toString();
                }
                if (item is String) return item;
                return null;
              })
              .whereType<String>()
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (_) {}
    }
    return trimmed
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static bool _isPdf(String path) => path.toLowerCase().endsWith('.pdf');

  static Future<pw.MemoryImage?> _loadAssetImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      debugPrint('Logo load failed: $e');
      return null;
    }
  }
}

class _PathLabel {
  final String path;
  final String label;
  _PathLabel(this.path, this.label);
}

class _LabeledPdf {
  final String label;
  final Uint8List bytes;
  _LabeledPdf(this.label, this.bytes);
}
