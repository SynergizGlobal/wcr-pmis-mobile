import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';


import '../../providers/rfi_details/rfi_details_provider.dart';
import '../../domain/rfi_details/rfi_inspection_model.dart';
import '../../domain/rfi_details/enclosure_checklist_item.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/network/environment.dart';
import '../../core/utils/rfi_preview_fetch.dart';
import '../../core/widgets/rfi_remote_media_preview.dart';
import '../../core/providers/dio_provider.dart';
import '../../core/widgets/global_alert_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';

class ViewRfiDetailsScreen extends ConsumerStatefulWidget {
  final int rfiId;
  const ViewRfiDetailsScreen({super.key, required this.rfiId});

  @override
  ConsumerState<ViewRfiDetailsScreen> createState() => _ViewRfiDetailsScreenState();
}

class _ViewRfiDetailsScreenState extends ConsumerState<ViewRfiDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rfiDetailsNotifierProvider.notifier).fetchRfiDetails(widget.rfiId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rfiDetailsNotifierProvider);

    return Scaffold(
      backgroundColor: RfiTheme.scaffoldBackground(context),
      appBar: AppBar(
        title: const Text('RFI Details'),
      ),
      body: SafeArea(
        top: false,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(RfiDetailsState state) {
    final BuildContext ctx = context;
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.detailModel == null) {
      return Center(
        child: ErrorStateWidget(
          onRetry: () => ref
              .read(rfiDetailsNotifierProvider.notifier)
              .fetchRfiDetails(widget.rfiId),
          message: 'Failed to load details.',
        ),
      );
    }

    final detail = state.detailModel;
    if (detail == null) {
      return const Center(child: Text("No data found"));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(ctx, 'Project Info', [
            _InfoRow('Project', detail.project),
            _InfoRow('Contract', detail.contract),
            _InfoRow('Work', detail.work),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard(ctx, 'Structure Info', [
            _InfoRow('Structure Type', detail.structureType),
            _InfoRow('Structure', detail.structure),
            _InfoRow('Component', detail.component),
            _InfoRow('Element', detail.element),
            _InfoRow('Activity', detail.activity),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard(ctx, 'RFI Meta', [
            _InfoRow('RFI No.', detail.rfiId),
            _InfoRow('Type of RFI', detail.typeOfRFI),
            _InfoRow('Status', detail.status),
            _InfoRow('Description', detail.rfiDescription),
            _InfoRow('Created By', detail.createdBy),
            _InfoRow('Submission Date', detail.dateOfSubmission),
          ]),
          const SizedBox(height: 16),
          if (detail.measurements != null)
            _buildInfoCard(ctx, 'Measurements', [
               _InfoRow('Type', detail.measurements!.measurementType),
               _InfoRow('Units', detail.measurements!.units),
               _InfoRow('Total Qty', detail.measurements!.totalQty?.toString()),
            ]),
          if (detail.measurements != null) const SizedBox(height: 16),
          
          _buildEnclosuresCard(ctx, state),
          const SizedBox(height: 16),
          _buildInspectionsCard(ctx, state.inspections),
        ],
      ),
    );
  }

  Widget _buildEnclosuresCard(BuildContext context, RfiDetailsState state) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final detail = state.detailModel!;
    
    final Map<String, List<Map<String, dynamic>>> fileGroups = {};
    if (detail.enclosure != null) {
      for (var e in detail.enclosure!) {
        if (e is Map) {
          final name = e['enclosureName'] as String? ?? 'Unnamed';
          fileGroups.putIfAbsent(name, () => []).add(e.cast<String, dynamic>());
        }
      }
    }

    final Set<String> allNames = {};
    if (detail.enclosuresList != null) allNames.addAll(detail.enclosuresList!);
    allNames.addAll(fileGroups.keys);
    if (detail.enclosures != null && detail.enclosures!.isNotEmpty) {
      if (detail.enclosures!.contains(',')) {
        allNames.addAll(detail.enclosures!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
      } else {
        allNames.add(detail.enclosures!);
      }
    }

    if (allNames.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: RfiTheme.elevatedCardDecoration(scheme),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enclosures & Checklists',
            style: RfiTheme.cardTitleStyle(textTheme, scheme),
          ),
          Divider(height: 24, color: scheme.outlineVariant),
          ...allNames.where((e) => e.isNotEmpty).map((name) {
            final hasChecklist = state.enclosureChecklists.containsKey(name);
            final checklistItems = state.enclosureChecklists[name];
            final files = fileGroups[name] ?? [];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: RfiTheme.insetPanelDecoration(scheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.folder_open, color: scheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      if (hasChecklist)
                        TextButton.icon(
                          onPressed: () => _showChecklistDialog(context, name, checklistItems!),
                          icon: const Icon(Icons.fact_check, size: 14),
                          label: const Text('View Checklist', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            foregroundColor: scheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                  if (files.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    ...files.map((f) {
                      final dynamic rawId = f['id'];
                      final int? enclosureId = rawId is int
                          ? rawId
                          : int.tryParse(rawId?.toString() ?? '');
                      final uploadPath =
                          f['enclosureUploadFile'] as String? ?? '';

                      final String previewSource = enclosureId != null
                          ? 'api/rfi/view-enclosure?id=$enclosureId'
                          : uploadPath;
                      final String downloadUrl = enclosureId != null
                          ? '${Environment.baseUrl}api/rfi/view-enclosure?id=$enclosureId'
                          : _getPublicUrl(uploadPath);

                      final fileName = uploadPath.isNotEmpty
                          ? uploadPath
                              .replaceAll(r'\', '/')
                              .split('/')
                              .last
                          : 'Document.pdf';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.insert_drive_file_outlined,
                                size: 14, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                fileName,
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.visibility,
                                  size: 18, color: scheme.primary),
                              onPressed: () =>
                                  _viewEnclosure(previewSource, fileName),
                              tooltip: 'View Document',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                            IconButton(
                              icon: Icon(Icons.download,
                                  size: 18, color: scheme.secondary),
                              onPressed: () =>
                                  _downloadEnclosure(downloadUrl, fileName),
                              tooltip: 'Download Document',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else if (!hasChecklist)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'No files or checklist attached.',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showChecklistDialog(BuildContext context, String title, List<EnclosureChecklistItem> items) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final ColorScheme scheme = Theme.of(dialogContext).colorScheme;
        return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.99,
          constraints: const BoxConstraints(maxHeight: 900),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  RfiTheme.dialogHeader(
                    dialogContext,
                    title: title,
                    icon: Icons.fact_check,
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: Icon(Icons.close, color: scheme.onPrimary),
                    ),
                  ),
                ],
              ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_turned_in_outlined,
                        size: 48,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No checklist items found',
                        style: Theme.of(dialogContext).textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: RfiTheme.dataTable(
                      dialogContext,
                      columnSpacing: 24,
                      dataRowMinHeight: 56,
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Contractor')),
                        DataColumn(label: Text('Engineer')),
                        DataColumn(label: Text('Contractor Remark')),
                        DataColumn(label: Text('Engineer Remark')),
                      ],
                      rows: items.asMap().entries.map((entry) {
                        final idx = entry.key + 1;
                        final item = entry.value;
                        final isEven = idx % 2 == 0;
                        final TextTheme tt =
                            Theme.of(dialogContext).textTheme;
                        final ColorScheme cs =
                            Theme.of(dialogContext).colorScheme;
                        return DataRow(
                          color: WidgetStateProperty.all(
                            RfiTheme.tableRowBackground(cs, even: isEven),
                          ),
                          cells: [
                            DataCell(Text('$idx')),
                            DataCell(
                              SizedBox(
                                width: 250,
                                child: Text(
                                  item.checklistDescription ?? '-',
                                  style: tt.bodySmall?.copyWith(height: 1.4),
                                ),
                              ),
                            ),
                            DataCell(_buildStatusBadge(item.contractorStatus)),
                            DataCell(_buildStatusBadge(item.engineerStatus)),
                            DataCell(Text(item.contractorRemarks ?? '-')),
                            DataCell(Text(item.engineerRemark ?? '-')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
      },
    );
  }

  Widget _buildStatusBadge(String? status) {
    if (status == null || status.isEmpty || status == '-') {
      return Text('-', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant));
    }

    final normalized = status.toUpperCase().trim();
    Color color;
    Color bgColor;

    if (normalized == 'YES' || normalized == 'OK' || normalized == 'PASS') {
      color = const Color(0xFF15803D);
      bgColor = const Color(0xFFDCFCE7);
    } else if (normalized == 'NO' || normalized == 'FAIL') {
      color = const Color(0xFFB91C1C);
      bgColor = const Color(0xFFFEE2E2);
    } else {
      color = const Color(0xFF7C3AED);
      bgColor = const Color(0xFFF5F3FF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        normalized,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _viewEnclosure(String url, [String? title]) async {
    await RfiMediaViewerDialog.show(
      context,
      source: url,
      dio: ref.read(dioProvider),
      title: title ?? url.split('/').last,
    );
  }

  void _downloadEnclosure(String url, [String? preferredFileName]) async {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final dio = ref.read(dioProvider);

      final dir = await getApplicationDocumentsDirectory();
      
      String fileName = preferredFileName ?? url.split('/').last;
      if (url.contains('view-enclosure?id=')) {
        final id = url.split('=').last;
        if (fileName.contains('=') || fileName.isEmpty) {
          fileName = 'enclosure_$id.pdf'; // Default to pdf for enclosure view
        }
      }
      
      fileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final savePath = '${dir.path}/$fileName';

      await dio.download(
        url,
        savePath,
        options: Options(extra: {'silentError': true}),
      );
      
      final file = File(savePath);
      if (!await file.exists() || await file.length() == 0) {
        throw Exception('Downloaded file is empty or missing');
      }

      final bytes = await file.readAsBytes();
      if (bytes.length > 15) {
        final header = String.fromCharCodes(bytes.sublist(0, 15)).toLowerCase();
        if (header.contains('<!doctype') || header.contains('<html')) {
          await file.delete();
          throw Exception('Server returned an error page instead of the file');
        }
      }

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      await OpenFile.open(savePath);
      
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      GlobalAlertDialog.show(
        context,
        title: 'Download failed',
        message: 'Download failed: ${e.toString()}',
        type: DialogType.error,
      );
    }
  }

  Widget _buildInfoCard(BuildContext context, String title, List<_InfoRow> rows) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: RfiTheme.elevatedCardDecoration(scheme),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: RfiTheme.cardTitleStyle(textTheme, scheme)),
          Divider(height: 24, color: scheme.outlineVariant),
          ...rows.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '${r.label}:',
                    style: RfiTheme.cardLabelStyle(textTheme, scheme),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    r.value ?? '-',
                    style: RfiTheme.cardValueStyle(textTheme, scheme),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInspectionsCard(
    BuildContext context,
    List<RfiInspectionModel> inspections,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    if (inspections.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: RfiTheme.elevatedCardDecoration(scheme),
        padding: const EdgeInsets.all(16),
        child: Text(
          'No inspections assigned yet.',
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: RfiTheme.elevatedCardDecoration(scheme),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inspections', style: RfiTheme.cardTitleStyle(textTheme, scheme)),
          Divider(height: 24, color: scheme.outlineVariant),
          for (int i = 0; i < inspections.length; i++) ...[
            _buildInspectionItem(context, inspections[i]),
            if (i < inspections.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Divider(
                  height: 1,
                  color: scheme.outlineVariant,
                  thickness: 1,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInspectionItem(BuildContext context, RfiInspectionModel insp) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isContractor = insp.uploadedBy?.toUpperCase() == 'CON';
    final String roleTitle = isContractor ? 'Inspected by Contractor' : 'Inspected by Engineer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleTitle,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  if (insp.dateOfInspection != null)
                    Text(
                      '${insp.dateOfInspection} ${insp.timeOfInspection ?? ""}',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoRow('Location', insp.location).buildNode(context),
        _InfoRow('Status', insp.inspectionStatus).buildNode(context),
        _InfoRow('Lab Test', insp.testInsiteLab).buildNode(context),
        if (isContractor) ...[
          if (insp.descriptionEnclosure != null &&
              insp.descriptionEnclosure!.isNotEmpty)
            _InfoRow('Description', insp.descriptionEnclosure)
                .buildNode(context),
        ] else ...[
          if (insp.engineerRemarks != null && insp.engineerRemarks!.isNotEmpty)
            _InfoRow('Description', insp.engineerRemarks).buildNode(context)
          else if (insp.descriptionEnclosure != null &&
              insp.descriptionEnclosure!.isNotEmpty)
            _InfoRow('Description', insp.descriptionEnclosure)
                .buildNode(context),
        ],
        
        const SizedBox(height: 16),
        Text(
          'Media & Documents',
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (insp.selfiePath != null && insp.selfiePath!.isNotEmpty)
                _buildMediaTile(
                  context,
                  title: 'Selfie',
                  path: insp.selfiePath!,
                  icon: Icons.face,
                ),
              if (insp.siteImage != null && insp.siteImage!.isNotEmpty)
                _buildMediaTile(
                  context,
                  title: isContractor ? 'Contractor site images' : 'Engineer site images',
                  path: insp.siteImage!,
                  icon: Icons.camera_alt,
                ),
              if (insp.testSiteDocuments != null && insp.testSiteDocuments!.isNotEmpty)
                _buildMediaTile(
                  context,
                  title: 'Document',
                  path: insp.testSiteDocuments!,
                  icon: Icons.picture_as_pdf,
                  isDocument: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaTile(
    BuildContext context, {
    required String title,
    required String path,
    required IconData icon,
    bool isDocument = false,
  }) {
    final url = _getPublicUrl(path);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _viewEnclosure(url, title),
      child: Container(
        width: 130,
        height: 110,
        margin: const EdgeInsets.only(right: 12),
        decoration: RfiTheme.insetPanelDecoration(scheme),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(7)),
                ),
                child: Icon(icon, color: scheme.primary, size: 32),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _getPublicUrl(String path) => RfiPreviewFetch.resolvePublicUrl(path);
}

class _InfoRow {
  final String label;
  final String? value;
  _InfoRow(this.label, this.value);

  Widget buildNode(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label:',
              style: RfiTheme.cardLabelStyle(textTheme, scheme)
                  ?.copyWith(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? '-',
              style: RfiTheme.cardValueStyle(textTheme, scheme)
                  ?.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}


