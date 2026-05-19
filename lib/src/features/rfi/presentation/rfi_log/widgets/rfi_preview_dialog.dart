import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/utils/rfi_preview_fetch.dart';
import '../../../providers/rfi_log/rfi_report_details_provider.dart';
import '../../../domain/rfi_log/rfi_report_details.dart';
import '../../../data/services/rfi_pdf_generator.dart';
import '../../../core/widgets/global_alert_dialog.dart';

class RfiPreviewDialog extends ConsumerWidget {
  final String rfiId;

  const RfiPreviewDialog({super.key, required this.rfiId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(rfiReportDetailsProvider(rfiId));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: reportAsync.when(
            data: (data) => FloatingActionButton.extended(
              onPressed: () async {
                var loaderOpen = false;
                // Show loading indicator while generating print document.
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );
                loaderOpen = true;
                try {
                  await RfiPdfGenerator.generateAndOpen(
                    rfiId: rfiId,
                    data: data,
                  ).timeout(const Duration(seconds: 90));
                } on TimeoutException {
                  if (context.mounted) {
                    if (loaderOpen) {
                      Navigator.of(context, rootNavigator: true).pop();
                      loaderOpen = false;
                    }
                    GlobalAlertDialog.show(
                      context,
                      title: 'Print preview timeout',
                      message:
                          'Generating this report is taking too long. Please retry.',
                      type: DialogType.error,
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    if (loaderOpen) {
                      Navigator.of(context, rootNavigator: true).pop();
                      loaderOpen = false;
                    }
                    GlobalAlertDialog.show(
                      context,
                      title: 'Could not open print preview',
                      message:
                          'Unable to generate the report right now. Please try again.',
                      type: DialogType.error,
                    );
                  }
                } finally {
                  if (context.mounted && loaderOpen) {
                    Navigator.of(context, rootNavigator: true)
                        .pop(); // Close loader
                  }
                }
              },
              label: const Text('Print Report'),
              icon: const Icon(Icons.print, color: Colors.white),
              backgroundColor: const Color(0xFF50589C),
              foregroundColor: Colors.white,
              tooltip: 'Print RFI Report',
            ),
            loading: () => null,
            error: (_, __) => null,
          ),
          body: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            'RFI Details Preview',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.normal),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Request For Inspection (RFI)',
                            style: TextStyle(fontSize: 18, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Body
              Expanded(
                child: reportAsync.when(
                  data: (data) => _buildContent(context, ref, data),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text(
                      'Error loading RFI details: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, RfiReportDetailsData data) {
    final info = data.reportDetails;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client and RFI Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    _buildInfoItem('Client:', 'Mumbai Rail Vikas Corporation'),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('RFI Status:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      info.rfiStatus ?? 'N/A',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: info.rfiStatus?.toLowerCase() == 'active'
                            ? Colors.green
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Top Info Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              final crossAxisCount = isSmall ? 1 : 3;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // Keep tiles taller to prevent text overflow on smaller screens
                // and with larger accessibility font sizes.
                childAspectRatio: isSmall ? 3.4 : 2.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                padding: EdgeInsets.zero,
                children: [
                  _buildInfoItem('Consultant:', 'N/A'),
                  _buildInfoItem('RFI ID:', info.rfiId),
                  _buildInfoItem('Date of Submission:', info.dateOfCreation),
                  _buildInfoItem('Project:', info.project),
                  _buildInfoItem('Work:', info.work),
                  _buildInfoItem('Contract:', info.contract),
                  _buildInfoItem('Contract ID:', info.contractId),
                  _buildInfoItem('Structure Type:', info.structureType),
                  _buildInfoItem('Structure:', info.structure),
                  _buildInfoItem('Component:', info.component),
                  _buildInfoItem('Element:', info.element),
                  _buildInfoItem('Activity:', info.activity),
                  _buildInfoItem('Rfi Description:', info.rfiDescription),
                  _buildInfoItem('Type of Rfi:', info.typeOfRfi),
                  _buildInfoItem('Enclosures:', info.enclosures),
                  _buildInfoItem('Contractor:', info.contractor),
                  _buildInfoItem("Contractor's Representative:",
                      info.contractorRepresentative),
                  _buildInfoItem(
                      'Client Representative:', info.clientRepresentative),
                ],
              );
            },
          ),

          const Divider(height: 48),

          // Bottom Info Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              final crossAxisCount = isSmall ? 1 : 3;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // Keep tiles taller to prevent text overflow on smaller screens
                // and with larger accessibility font sizes.
                childAspectRatio: isSmall ? 3.4 : 2.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                padding: EdgeInsets.zero,
                children: [
                  _buildInfoItem(
                      'Contractor Inspected Date:', info.conInspDate),
                  _buildInfoItem('Proposed Inspection Date:',
                      info.proposedDateOfInspection),
                  _buildInfoItem(
                      'Actual Inspection Date:', info.actualDateOfInspection),
                  _buildInfoItem('Proposed Time:', info.proposedInspectionTime),
                  _buildInfoItem('Actual Time:', info.actualInspectionTime),
                  _buildInfoItem('Chainage:', info.chainage),
                  _buildInfoItem('Description:', info.descriptionByContractor),
                  _buildInfoItem('Contractor Location:', info.conLocation),
                  _buildInfoItem('Client Location:', info.clientLocation),
                  _buildInfoItem('Inspection Test Type:', info.typeOfTest),
                  _buildInfoItem(
                      'Test Report Approval By Inspector:', info.testStatus),
                  _buildInfoItem('DyHod:', info.dyHodUserName),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Measurement Details
          if (data.measurementDetails != null) ...[
            _buildSectionHeader('Measurement Details'),
            _buildMeasurementTable(data.measurementDetails!),
            const SizedBox(height: 24),
          ],

          // Checklists
          if (data.checklistItems.isNotEmpty) ...[
            ..._buildChecklists(data.checklistItems),
          ],

          const SizedBox(height: 24),

          // Validation Status & Remarks
          _buildSectionHeader('Validation Status & Remarks'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Status: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Flexible(
                      child: Text(
                        info.validationStatus?.isNotEmpty == true
                            ? info.validationStatus!
                            : '---',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Remarks: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Flexible(
                      child: Text(
                        info.validationComments?.isNotEmpty == true
                            ? info.validationComments!
                            : '---',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Engineer Remarks: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Flexible(
                      child: Text(
                        info.engineerRemarks?.isNotEmpty == true
                            ? info.engineerRemarks!
                            : '---',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Selfies & Site Images Section
          if (info.selfieContractor != null ||
              info.selfieClient != null ||
              info.imagesUploadedByContractor?.isNotEmpty == true ||
              info.imagesUploadedByClient?.isNotEmpty == true)
            Column(
              children: [
                if (info.selfieContractor != null) ...[
                  const Center(
                      child: Text('Contractor Selfie',
                          style: TextStyle(fontSize: 16))),
                  const SizedBox(height: 12),
                  Center(child: _buildFilePreview(context, ref, info.selfieContractor!)),
                  const SizedBox(height: 24),
                ],
                if (info.selfieClient != null) ...[
                  const Center(
                      child: Text('Inspector Selfie',
                          style: TextStyle(fontSize: 16))),
                  const SizedBox(height: 12),
                  Center(child: _buildFilePreview(context, ref, info.selfieClient!)),
                  const SizedBox(height: 24),
                ],
                if (info.imagesUploadedByContractor?.isNotEmpty == true) ...[
                  const Center(
                      child: Text('Site Images By Contractor',
                          style: TextStyle(fontSize: 16))),
                  const SizedBox(height: 12),
                  ...info.imagesUploadedByContractor!
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .map((path) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Center(child: _buildFilePreview(context, ref, path)),
                          )),
                ],
                if (info.imagesUploadedByClient?.isNotEmpty == true) ...[
                  const Center(
                      child: Text('Site Images By Inspector',
                          style: TextStyle(fontSize: 16))),
                  const SizedBox(height: 12),
                  ...info.imagesUploadedByClient!
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .map((path) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Center(child: _buildFilePreview(context, ref, path)),
                          )),
                ],
              ],
            ),

          // Enclosures Section
          if (data.enclosures.isNotEmpty) ...[
            Center(
              child: Text(
                'Enclosures Uploaded',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            ...data.enclosures.map((enc) => Column(
                  children: [
                    Center(
                      child: Text(
                        enc.enclosureName ?? 'Attachment',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (enc.file != null)
                      Center(child: _buildFilePreview(context, ref, enc.file!)),
                    const SizedBox(height: 24),
                  ],
                )),
          ]
        ],
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context, WidgetRef ref, String url) {
    if (url.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    final String lowerUrl = url.toLowerCase();
    final bool isPDF = lowerUrl.endsWith('.pdf');
    final Dio dio = ref.read(dioProvider);

    if (isPDF) {
      return Container(
        height: 500,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _PdfRemoteViewer(source: url, dio: dio),
      );
    }

    return _RemoteImageLoader(source: url, dio: dio);
  }

  Widget _buildInfoItem(String label, String? value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        Flexible(
          child: Text(
            value?.isNotEmpty == true ? value! : '---',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade600,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMeasurementTable(MeasurementDetails details) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
          dividerThickness: 0.5,
          columns: const [
            DataColumn(
                label: Text('Type',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Units',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Length',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Breadth',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Height',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Weight',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Count',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Total Quantity',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text(details.measurementType ?? '---')),
              DataCell(Text(details.units ?? '---')),
              DataCell(Text(details.l?.toString() ?? '---')),
              DataCell(Text(details.b?.toString() ?? '---')),
              DataCell(Text(details.h?.toString() ?? '---')),
              DataCell(Text(details.weight?.toString() ?? '---')),
              DataCell(Text(details.no?.toString() ?? '---')),
              DataCell(Text(details.totalQty?.toString() ?? '---')),
            ]),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChecklists(List<ChecklistItem> items) {
    final Map<String, List<ChecklistItem>> grouped = {};
    for (var item in items) {
      final key = item.enclosureName ?? 'General Checklist';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final widgets = <Widget>[];

    grouped.forEach((groupName, groupItems) {
      widgets.add(_buildSectionHeader(groupName));
      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
              dividerThickness: 0.5,
              dataRowMinHeight: 48,
              dataRowMaxHeight: double.infinity,
              columns: const [
                DataColumn(
                    label: Text('ID',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Description',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Contractor Status',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('AE Status',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Contractor Remarks',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('AE Remarks',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: groupItems.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final item = entry.value;

                final isHeading =
                    item.checklistDescription?.startsWith('Heading_') == true;
                final desc = isHeading
                    ? item.checklistDescription!.replaceFirst('Heading_', '')
                    : item.checklistDescription ?? '---';

                return DataRow(
                  color: isHeading
                      ? WidgetStateProperty.all(Colors.grey.shade50)
                      : null,
                  cells: [
                    DataCell(Text(isHeading ? '' : idx.toString())),
                    DataCell(Container(
                      width: 300,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        desc,
                        style: TextStyle(
                          fontWeight:
                              isHeading ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    )),
                    DataCell(Text(isHeading
                        ? ''
                        : (item.conStatus?.isNotEmpty == true
                            ? item.conStatus!
                            : '---'))),
                    DataCell(Text(isHeading
                        ? ''
                        : (item.aeStatus?.isNotEmpty == true
                            ? item.aeStatus!
                            : '---'))),
                    DataCell(Text(isHeading
                        ? ''
                        : (item.contractorRemark?.isNotEmpty == true
                            ? item.contractorRemark!
                            : '---'))),
                    DataCell(Text(isHeading
                        ? ''
                        : (item.aeRemark?.isNotEmpty == true
                            ? item.aeRemark!
                            : '---'))),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
    });

    return widgets;
  }
}

class _RemoteImageLoader extends StatefulWidget {
  final String source;
  final Dio dio;

  const _RemoteImageLoader({required this.source, required this.dio});

  @override
  State<_RemoteImageLoader> createState() => _RemoteImageLoaderState();
}

class _RemoteImageLoaderState extends State<_RemoteImageLoader> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      // Add a small staggered delay to avoid concurrent connection limits
      await Future.delayed(
          Duration(milliseconds: 100 + (widget.source.hashCode % 500)));

      final Uint8List bytes =
          await RfiPreviewFetch.fetchBytes(widget.dio, widget.source);

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Image load error for ${widget.source}: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        color: Colors.grey[100],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _imageBytes == null) {
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, color: Colors.grey, size: 48),
            const SizedBox(height: 8),
            Text('Failed to load image',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(
        _imageBytes!,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _PdfRemoteViewer extends StatefulWidget {
  final String source;
  final Dio dio;

  const _PdfRemoteViewer({required this.source, required this.dio});

  @override
  State<_PdfRemoteViewer> createState() => _PdfRemoteViewerState();
}

class _PdfRemoteViewerState extends State<_PdfRemoteViewer> {
  PdfControllerPinch? _pdfController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      // Add a small staggered delay to avoid concurrent connection limits
      await Future.delayed(
          Duration(milliseconds: 200 + (widget.source.hashCode % 500)));

      final Uint8List bytes =
          await RfiPreviewFetch.fetchBytes(widget.dio, widget.source);

      _pdfController = PdfControllerPinch(
        document: PdfDocument.openData(bytes),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('PDF load error for ${widget.source}: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _pdfController == null) {
      final ColorScheme scheme = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.picture_as_pdf,
                  color: scheme.onSurfaceVariant, size: 48),
              const SizedBox(height: 8),
              Text(
                'PDF unavailable',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  _error!.length > 120
                      ? '${_error!.substring(0, 120)}...'
                      : _error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                    _pdfController?.dispose();
                    _pdfController = null;
                  });
                  _loadPdf();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return PdfViewPinch(controller: _pdfController!);
  }
}
