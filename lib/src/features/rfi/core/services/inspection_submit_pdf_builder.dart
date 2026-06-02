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
    Map<String, dynamic>? submitUser,
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

    final contractorSiteImagePaths = _collectSiteImagePaths(
      state: state,
      rfi: rfi,
      includeEngineerImages: false,
      includeCurrentSessionPaths: !isEngineer,
    );
    final engineerSiteImagePaths = _collectSiteImagePaths(
      state: state,
      rfi: rfi,
      includeEngineerImages: true,
      includeCurrentSessionPaths: isEngineer,
    );
    final contractorSiteImages = await _loadSiteImages(
      contractorSiteImagePaths,
      dio,
    );
    final engineerSiteImages = await _loadSiteImages(
      engineerSiteImagePaths,
      dio,
    );
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(_margin),
        build: (context) => [
          ..._buildPageOne(
            state: state,
            rfi: rfi,
            enclosureNames: enclosureNames,
            isEngineer: isEngineer,
            font: font,
            fontBold: fontBold,
            logo: logo,
          ),
          pw.SizedBox(height: 12),
          ..._buildPartTwoEngineerRemarksPage(
            state: state,
            rfi: rfi,
            isEngineer: isEngineer,
            submitUser: submitUser,
            font: font,
            fontBold: fontBold,
          ),
          pw.SizedBox(height: 14),
          ..._buildPartThreeValidationPage(
            state: state,
            rfi: rfi,
            isEngineer: isEngineer,
            submitUser: submitUser,
            font: font,
            fontBold: fontBold,
          ),
          pw.SizedBox(height: 14),
          ..._buildPageTwo(
            state: state,
            rfi: rfi,
            rfiId: rfiId,
            enclosureNames: enclosureNames,
            isEngineer: isEngineer,
            font: font,
            fontBold: fontBold,
            contractorSiteImages: contractorSiteImages,
            engineerSiteImages: engineerSiteImages,
          ),
        ],
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
    required InspectionItem rfi,
    required bool isEngineer,
    required Map<String, dynamic>? submitUser,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    final status = state.inspectionStatus.trim();
    final isAccepted = _isAcceptedInspectionStatus(status);
    final isRejected = _isRejectedInspectionStatus(status);

    final remarks = _engineerRemarksForPdf(state);
    final contractorRepName =
        isEngineer ? _resolveContractorRepresentativeName(state, rfi) : '';
    final mrvcRepName = isEngineer
        ? _resolveMrvcRepresentativeName(
            rfi: rfi,
            submitUser: submitUser,
            isEngineer: isEngineer,
          )
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
        isAccepted: isEngineer && isAccepted,
        isRejected: isEngineer && isRejected,
      ),
      pw.SizedBox(height: 12),
      _formFieldBox(
        label: 'Remarks:',
        value: remarks,
        font: font,
        fontBold: fontBold,
        minHeight: 44,
      ),
      pw.SizedBox(height: 16),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _signatureBlock(
            title: 'Contractor Representative',
            representativeName: contractorRepName,
            font: font,
            fontBold: fontBold,
          ),
          pw.SizedBox(width: 28),
          _signatureBlock(
            title: 'MRVC Representative',
            representativeName: mrvcRepName,
            font: font,
            fontBold: fontBold,
          ),
        ],
      ),
    ];
  }

  static List<pw.Widget> _buildPartThreeValidationPage({
    required InspectionFormState state,
    required InspectionItem rfi,
    required bool isEngineer,
    required Map<String, dynamic>? submitUser,
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
    final validationRecorded = _isValidationRecorded(rfi);
    final validationRemarks =
        validationRecorded ? _validationRemarksForPdf(rfi) : '';
    final validationComment =
        validationRecorded ? _validationCommentForPdf(rfi) : '';
    final validatedBy =
        validationRecorded && isEngineer ? _validationAuthorForPdf(rfi) : '';
    final validatedOn =
        validationRecorded && isEngineer ? _validationDateForPdf(rfi) : '';
    final approval = validationRecorded
        ? _validationApprovalFlags(rfi.validationStatus)
        : (approved: false, rejected: false);

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
            checked: approval.approved,
            font: font,
            fontBold: fontBold,
          ),
          pw.SizedBox(width: 40),
          _labeledCheckbox(
            label: 'Rejected',
            checked: approval.rejected,
            font: font,
            fontBold: fontBold,
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      _formFieldBox(
        label: 'Remarks:',
        value: validationRemarks,
        font: font,
        fontBold: fontBold,
        minHeight: 28,
      ),
      pw.SizedBox(height: 10),
      _formFieldBox(
        label: 'Comment:',
        value: validationComment,
        font: font,
        fontBold: fontBold,
        minHeight: 36,
      ),
      pw.SizedBox(height: 12),
      _validatedByOnStampZone(
        validatedBy: validatedBy,
        validatedOn: validatedOn,
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
    required List<pw.MemoryImage> contractorSiteImages,
    required List<pw.MemoryImage> engineerSiteImages,
  }) {
    final measurements = state.measurements;

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
        if (contractorSiteImages.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text('Contractor Site Images:',
              style: pw.TextStyle(font: fontBold, fontSize: 10)),
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: contractorSiteImages
                .map(
                  (img) => pw.Image(img, width: 200, height: 120, fit: pw.BoxFit.cover),
                )
                .toList(),
          ),
        ],
        if (engineerSiteImages.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text('Engineer Site Images:',
              style: pw.TextStyle(font: fontBold, fontSize: 10)),
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: engineerSiteImages
                .map(
                  (img) => pw.Image(img, width: 200, height: 120, fit: pw.BoxFit.cover),
                )
                .toList(),
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

  /// Signature area: reserved space for e-stamp with representative name visible.
  static pw.Widget _signatureBlock({
    required String title,
    required String representativeName,
    required pw.Font font,
    required pw.Font fontBold,
    double stampAreaHeight = 112,
  }) {
    final name = representativeName.trim();
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            height: stampAreaHeight,
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600, width: 0.75),
            ),
            alignment: pw.Alignment.bottomCenter,
            child: name.isEmpty
                ? null
                : pw.Center(
                    child: pw.FittedBox(
                      fit: pw.BoxFit.scaleDown,
                      child: pw.Text(
                        name,
                        style: pw.TextStyle(font: fontBold, fontSize: 8),
                        textAlign: pw.TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            title,
            style: pw.TextStyle(font: font, fontSize: 9),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
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
      } else if (!_isEngineerInspectionDetail(detail) &&
          !_isDyHodInspectionDetail(detail)) {
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

  static bool _isDyHodInspectionDetail(InspectionDetail detail) {
    final u = detail.uploadedBy?.trim().toUpperCase() ?? '';
    if (u.isEmpty) return false;
    if (_isContractorInspectionDetail(detail) ||
        _isEngineerInspectionDetail(detail)) {
      return false;
    }
    return u.contains('DYHOD') ||
        u == 'HOD' ||
        u.contains('DATA') ||
        u.contains('ADMIN');
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

  static String _resolveContractorRepresentativeName(
    InspectionFormState state,
    InspectionItem rfi,
  ) {
    final fromState = state.contractorRepresentative.trim();
    if (fromState.isNotEmpty) return fromState;

    final fromRfi = rfi.nameOfRepresentative?.trim();
    if (fromRfi != null && fromRfi.isNotEmpty) return fromRfi;

    final reporting = rfi.representativeReportingToContractor?.trim();
    if (reporting != null && reporting.isNotEmpty) return reporting;

    return '';
  }

  static String _resolveMrvcRepresentativeName({
    required InspectionItem rfi,
    required Map<String, dynamic>? submitUser,
    required bool isEngineer,
  }) {
    if (isEngineer) {
      final submitter = _displayNameFromUser(submitUser);
      if (submitter.isNotEmpty) return submitter;
    }

    final assigned = rfi.assignedPersonClient?.trim();
    if (assigned != null && assigned.isNotEmpty) return assigned;

    return '';
  }

  static String _displayNameFromUser(Map<String, dynamic>? user) {
    if (user == null) return '';
    final userName = user['userName']?.toString().trim();
    if (userName != null && userName.isNotEmpty) return userName;

    final name = user['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;

    final first = user['firstName']?.toString().trim() ?? '';
    final last = user['lastName']?.toString().trim() ?? '';
    final combined = '$first $last'.trim();
    return combined;
  }

  static String _engineerRemarksForPdf(InspectionFormState state) {
    final fromState = state.engineerRemarks.trim();
    if (fromState.isNotEmpty) return fromState;

    return _engineerRemarksFromInspectionDetails(
          state.rfiDetails?.inspectionDetails,
        ) ??
        '';
  }

  static String? _engineerRemarksFromInspectionDetails(
    List<InspectionDetail>? details,
  ) {
    if (details == null || details.isEmpty) return null;

    for (final detail in details) {
      if (!_isEngineerInspectionDetail(detail) && !_isDyHodInspectionDetail(detail)) continue;
      final remarks = detail.engineerRemarks?.trim();
      if (remarks != null && remarks.isNotEmpty) return remarks;
    }
    return null;
  }

  static bool _isAcceptedInspectionStatus(String status) {
    final u = status.trim().toUpperCase();
    return u == 'ACCEPTED' || u == 'APPROVED';
  }

  static bool _isRejectedInspectionStatus(String status) {
    final u = status.trim().toUpperCase();
    return u == 'REJECTED' ||
        u == 'RETURNED_FOR_RECTIFICATION' ||
        u.contains('RECTIFICATION') ||
        status == 'Rectification';
  }

  static bool _isValidationRecorded(InspectionItem rfi) {
    final status = (rfi.validationStatus ?? '').trim().toUpperCase();
    final remarks = (rfi.validationRemarks ?? '').trim();
    final comment = (rfi.validationComments ?? '').trim();
    final author = (rfi.validationAuthor ?? '').trim();

    if (remarks.isNotEmpty || comment.isNotEmpty || author.isNotEmpty) {
      return true;
    }

    if (status.isEmpty) return false;

    const pending = {
      'PENDING',
      'OPEN',
      'IN_PROGRESS',
      'NOT_VALIDATED',
      'AWAITING_VALIDATION',
    };
    if (pending.contains(status)) return false;

    return status == 'APPROVED' ||
        status == 'REJECTED' ||
        status == 'NOR' ||
        status.contains('APPROV') ||
        status.contains('REJECT');
  }

  static String _validationRemarksForPdf(InspectionItem rfi) {
    return (rfi.validationRemarks ?? '').trim();
  }

  static String _validationCommentForPdf(InspectionItem rfi) {
    return (rfi.validationComments ?? '').trim();
  }

  static String _validationAuthorForPdf(InspectionItem rfi) {
    final author = (rfi.validationAuthor ?? '').trim();
    if (author.isNotEmpty) return author;

    return '';
  }

  static String _validationDateForPdf(InspectionItem rfi) {
    final fromValidation = rfi.validationDate?.trim();
    if (fromValidation != null && fromValidation.isNotEmpty) {
      return _displayDate(fromValidation);
    }
    return '';
  }

  static ({bool approved, bool rejected}) _validationApprovalFlags(
    String? validationStatus,
  ) {
    final status = (validationStatus ?? '').trim().toUpperCase();
    if (status.isEmpty) {
      return (approved: false, rejected: false);
    }
    if (status.contains('REJECT') || status.contains('NOT APPROV')) {
      return (approved: false, rejected: true);
    }
    return (approved: true, rejected: false);
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
    for (final detail in rfi.inspectionDetails ?? const <InspectionDetail>[]) {
      addSourcePdf(detail.supportingDocuments, 'Supporting Document');
    }

    // 3. Test report (web: testReportFile — role-specific path on RFI)
    final testReportPath = isEngineer
        ? (rfi.testResEngg?.trim().isNotEmpty == true
            ? rfi.testResEngg
            : rfi.testResCon)
        : rfi.testResCon;
    addSourcePdf(testReportPath, 'Test Report');
    for (final detail in rfi.inspectionDetails ?? const <InspectionDetail>[]) {
      addSourcePdf(detail.testSiteDocuments, 'Test Report');
      addSourcePdf(detail.postTestReportPath, 'Test Report');
    }

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

  static List<String> _collectSiteImagePaths({
    required InspectionFormState state,
    required InspectionItem rfi,
    required bool includeEngineerImages,
    required bool includeCurrentSessionPaths,
  }) {
    final merged = <String>{};

    void addRaw(String? raw) {
      if (raw == null || raw.trim().isEmpty) return;
      final values = _splitPaths(raw);
      for (final value in values) {
        if (value.trim().isNotEmpty) merged.add(value.trim());
      }
    }

    // 1) Freshly selected images in current inspection session.
    if (includeCurrentSessionPaths) {
      for (final path in state.siteImagePaths) {
        if (path.trim().isNotEmpty) merged.add(path.trim());
      }
    }

    // 2) Server-side contractor image paths already saved on RFI.
    addRaw(rfi.imgContractor);

    // 3) Contractor-side inspection detail image paths.
    for (final detail in rfi.inspectionDetails ?? const <InspectionDetail>[]) {
      if (!_isContractorInspectionDetail(detail)) continue;
      addRaw(detail.siteImage);
    }

    if (includeEngineerImages) {
      addRaw(rfi.imgClient);
      for (final detail in rfi.inspectionDetails ?? const <InspectionDetail>[]) {
        if (!_isEngineerInspectionDetail(detail) &&
            !_isDyHodInspectionDetail(detail)) {
          continue;
        }
        addRaw(detail.siteImage);
      }
    }

    return merged.toList();
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
