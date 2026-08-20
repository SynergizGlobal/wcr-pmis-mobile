import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/utils/rfi_file_paths.dart';
import '../../../core/utils/rfi_preview_fetch.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/rfi_remote_media_preview.dart';
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
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 0),
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'RFI Details Preview',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Request For Inspection (RFI)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: reportAsync.when(
                  data: (data) => _buildContent(context, ref, data),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object err, StackTrace stack) => ErrorStateWidget(
                    compact: true,
                    title: 'Unable to load preview',
                    message: userFriendlyErrorMessage(err),
                    onRetry: () =>
                        ref.invalidate(rfiReportDetailsProvider(rfiId)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    _buildInfoItem('Client:', 'West Central Railway'),
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

          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              final crossAxisCount = isSmall ? 1 : 3;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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

          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              final crossAxisCount = isSmall ? 1 : 3;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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

          if (data.measurementDetails != null) ...[
            _buildSectionHeader('Measurement Details'),
            _buildMeasurementTable(data.measurementDetails!),
            const SizedBox(height: 24),
          ],

          if (data.checklistItems.isNotEmpty) ...[
            ..._buildChecklists(data.checklistItems),
          ],

          const SizedBox(height: 24),

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
                  ...extractFilePaths(info.imagesUploadedByContractor).map(
                        (path) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Center(
                            child: _buildFilePreview(context, ref, path),
                          ),
                        ),
                      ),
                ],
                if (info.imagesUploadedByClient?.isNotEmpty == true) ...[
                  const Center(
                      child: Text('Site Images By Inspector',
                          style: TextStyle(fontSize: 16))),
                  const SizedBox(height: 12),
                  ...extractFilePaths(info.imagesUploadedByClient).map(
                        (path) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Center(
                            child: _buildFilePreview(context, ref, path),
                          ),
                        ),
                      ),
                ],
              ],
            ),

          ..._buildEnclosuresSection(context, ref, data, info),
          ..._buildSupportingDocumentsSection(
            context,
            ref,
            extractSupportingDocuments(info.conSupportFilePaths),
          ),
          ..._buildSupportingDocumentsSection(
            context,
            ref,
            extractSupportingDocuments(info.enggSupportFilePaths),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSupportingDocumentsSection(
    BuildContext context,
    WidgetRef ref,
    List<SupportingDocumentEntry> documents,
  ) {
    if (documents.isEmpty) return [];

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return [
      const SizedBox(height: 24),
      ...documents.expand((doc) {
        return [
          Center(
            child: Text(
              doc.sectionTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: scheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          _buildFilePreview(context, ref, doc.filePath),
          const SizedBox(height: 16),
        ];
      }),
    ];
  }

  List<Widget> _buildEnclosuresSection(
    BuildContext context,
    WidgetRef ref,
    RfiReportDetailsData data,
    ReportDetailsInfo info,
  ) {
    final groups = <String, List<String>>{};

    void addGroup(String name, List<String> paths) {
      if (paths.isEmpty) return;
      groups.putIfAbsent(name, () => []).addAll(paths);
    }

    for (final enc in data.enclosures) {
      final name = enc.enclosureName?.trim().isNotEmpty == true
          ? enc.enclosureName!.trim()
          : 'Enclosure';
      addGroup(name, extractFilePaths(enc.file));
    }

    addGroup(
      'Test Site Documents (Contractor)',
      extractFilePaths(info.testSiteDocumentsContractor),
    );

    final entries =
        groups.entries.where((e) => e.value.isNotEmpty).toList();
    if (entries.isEmpty) {
      return [];
    }

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return [
      Center(
        child: Text(
          'Enclosures & Documents',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      const SizedBox(height: 16),
      ...entries.expand((entry) {
        final uniquePaths = entry.value.toSet().toList();
        return [
          Center(
            child: Text(
              entry.key,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...uniquePaths.map(
            (path) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildFilePreview(context, ref, path),
            ),
          ),
          const SizedBox(height: 8),
        ];
      }),
    ];
  }

  Widget _buildFilePreview(BuildContext context, WidgetRef ref, String source) {
    if (source.trim().isEmpty) {
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

    final dio = ref.read(dioProvider);
    final isPdf = RfiPreviewFetch.looksLikePdfPath(source);

    return Container(
      height: isPdf ? 500 : 320,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RfiRemoteMediaPreview(
        source: source,
        dio: dio,
        height: isPdf ? 500 : 320,
        compact: true,
      ),
    );
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
