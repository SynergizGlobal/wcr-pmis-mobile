import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/inspection/inspection_provider.dart';
import '../../providers/inspection/inspection_state.dart';
import '../../domain/inspection/inspection_item.dart';
import '../../providers/auth/auth_provider.dart';
import '../../core/utils/user_role.dart';
import '../../core/widgets/table_search_header.dart';
import '../../core/widgets/table_pagination_footer.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/global_alert_dialog.dart';
import './widgets/change_executive_dialog.dart';
import '../widgets/delete_rfi_dialog.dart';
import '../../domain/utils/rfi_list_item_mapper.dart';
import './widgets/upload_attachment_dialog.dart';
import './widgets/upload_test_results_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/auth/wcr_unauthorized.dart';
import 'package:wcr_pmis_mobile/src/core/auth/wcr_session_expired_handler.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/wcr_session_expired_error_listener.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';
import '../../core/widgets/app_dropdown.dart';

class InspectionListScreen extends ConsumerStatefulWidget {
  const InspectionListScreen({
    super.key,
    this.rescheduledOnly = false,
  });

  final bool rescheduledOnly;

  @override
  ConsumerState<InspectionListScreen> createState() =>
      _InspectionListScreenState();
}

class _InspectionListScreenState extends ConsumerState<InspectionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(inspectionProvider.notifier)
          .configure(rescheduledOnly: widget.rescheduledOnly);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inspectionProvider);
    final notifier = ref.read(inspectionProvider.notifier);
    final authState = ref.watch(authNotifierProvider);
    final appRole = UserRole.fromLoginResponse(authState.value ?? {});

    final totalItems = state.filteredItems.length;
    final totalPages = (totalItems / state.rowsPerPage).ceil();
    final startIndex = (state.currentPage - 1) * state.rowsPerPage;
    final endIndex = min(state.currentPage * state.rowsPerPage, totalItems);

    final ColorScheme scheme = Theme.of(context).colorScheme;

    final bool sessionExpired = state.error != null &&
        isWcrSessionExpiredError(state.error!);

    return WcrSessionExpiredErrorListener(
      error: state.error,
      child: Scaffold(
        backgroundColor: RfiTheme.scaffoldBackground(context),
        appBar: AppBar(
          title: Text(
            widget.rescheduledOnly
                ? 'RFI RESCHEDULED LIST'
                : 'RFI INSPECTION LIST',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          top: false,
          child: state.isLoading && state.allItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: RfiTheme.surfaceCardDecoration(scheme),
                        child: Column(
                          children: [
                            TableSearchHeader(
                              onSearchChanged: notifier.search,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: AppDropdown<String>(
                                    label: 'Project',
                                    hint: 'All Projects',
                                    value: state.projectFilter.isEmpty
                                        ? null
                                        : state.projectFilter,
                                    items: state.availableProjects,
                                    onChanged: (String? value) =>
                                        notifier.setProjectFilter(value),
                                    itemLabel: (String v) => v,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppDropdown<String>(
                                    label: 'Contract',
                                    hint: 'All Contracts',
                                    value: state.contractFilter.isEmpty
                                        ? null
                                        : state.contractFilter,
                                    items: state.availableContracts,
                                    onChanged: (String? value) =>
                                        notifier.setContractFilter(value),
                                    itemLabel: (String v) => v,
                                  ),
                                ),
                              ],
                            ),
                            if (state.projectFilter.isNotEmpty ||
                                state.contractFilter.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: notifier.clearFilters,
                                  icon: const Icon(Icons.filter_alt_off, size: 16),
                                  label: const Text(
                                    'Clear Filters',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: state.error != null && !sessionExpired
                          ? ErrorStateWidget(
                              compact: true,
                              title: 'Unable to load inspections',
                              message: state.error!,
                              onRetry: () => notifier.fetchInspections(),
                            )
                          : RefreshIndicator(
                              onRefresh: () => notifier.fetchInspections(),
                              child: _buildTableArea(context, ref, state, notifier, appRole),
                            ),
                    ),

                    if (state.error == null && state.filteredItems.isNotEmpty)
                      TablePaginationFooter(
                        startIndex: totalItems == 0 ? 0 : startIndex,

                        endIndex: endIndex,
                        totalItems: totalItems,
                        currentPage: state.currentPage,
                        totalPages: totalPages,
                        pageSize: state.rowsPerPage,
                        onPageSizeChanged: notifier.updateRowsPerPage,
                        onPageChanged: notifier.updatePage,
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTableArea(BuildContext context, WidgetRef ref, InspectionState state,
      InspectionNotifier notifier, UserRole appRole) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    if (state.filteredItems.isEmpty) {
      return SizedBox(
        height: 300,
        child: const Center(child: Text('No entries found')),
      );
    }

    final startIndex = (state.currentPage - 1) * state.rowsPerPage;
    final endIndex = min(startIndex + state.rowsPerPage, state.filteredItems.length);
    final currentPageItems = state.filteredItems.sublist(startIndex, endIndex);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.symmetric(
          horizontal: BorderSide(color: scheme.outlineVariant, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              RfiTheme.tableHeaderBackground(scheme),
            ),
            headingTextStyle: RfiTheme.tableHeaderTextStyle(
              Theme.of(context).textTheme,
              scheme,
            ),
            dataRowMinHeight: 48,
            dataRowMaxHeight: 80,
            dividerThickness: 0.5,
            horizontalMargin: 12,
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('RFI ID')),
              DataColumn(label: Text('Raised Date')),
              DataColumn(label: Text('Scheduled On')),
              DataColumn(label: Text('Contractor\nSubmitted on')),
              DataColumn(label: Text('Structure')),
              DataColumn(label: Text('Element')),
              DataColumn(label: Text('Activity')),
              DataColumn(label: Text('RFI Description')),
              DataColumn(label: Text('Assigned\nContractor')),
              DataColumn(label: Text('Assigned\nEmployer\'s\nEngineer')),
              DataColumn(label: Text('Measurement\nType')),
              DataColumn(label: Text('Total Qty')),
              DataColumn(label: Text('Inspection\nStatus')),
              DataColumn(label: Text('Action')),
            ],
            rows: currentPageItems
                .map<DataRow>(
                    (item) => _buildDataRow(context, ref, item, notifier, appRole))
                .toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(
      BuildContext context, WidgetRef ref, InspectionItem item, InspectionNotifier notifier, UserRole appRole) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle? cellStyle = RfiTheme.tableCellTextStyle(
      Theme.of(context).textTheme,
      scheme,
    );

    return DataRow(
      cells: [
        DataCell(Text(item.rfiId ?? '---', style: cellStyle)),
        DataCell(Text(item.dateOfSubmission ?? '---', style: cellStyle)),
        DataCell(Text(_scheduledOn(item), style: cellStyle)),
        DataCell(Text(_contractorSubmittedOn(item), style: cellStyle)),
        DataCell(Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(item.structure ?? '---', style: cellStyle))),
        DataCell(Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(item.element ?? '---', style: cellStyle))),
        DataCell(Text(item.activity ?? '---', style: cellStyle)),
        DataCell(Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(item.rfiDescription ?? '---', style: cellStyle))),
        DataCell(Text(item.nameOfRepresentative ?? '---', style: cellStyle)),
        DataCell(Container(
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(item.assignedPersonClient ?? '---', style: cellStyle))),
        DataCell(Text(item.measurementType ?? '---', style: cellStyle)),
        DataCell(Text(item.totalQty?.toString() ?? '---', style: cellStyle)),
        DataCell(Text(item.status ?? '---', style: cellStyle)),
        DataCell(Center(
          child: PopupMenuButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.more_vert, size: 20, color: scheme.primary),
            ),
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8,
            color: scheme.surface,
            onSelected: (value) async {
              if (value == 'online') {
                await context.pushNamed(
                  'rfi-inspection-start',
                  extra: <String, dynamic>{
                    'item': item,
                    'isOffline': false,
                  },
                );
                if (context.mounted) {
                  notifier.fetchInspections();
                }
              } else if (value == 'offline') {
                await context.pushNamed(
                  'rfi-inspection-start',
                  extra: <String, dynamic>{
                    'item': item,
                    'isOffline': true,
                  },
                );
                if (context.mounted) {
                  notifier.fetchInspections();
                }
              } else if (value == 'upload_attachments') {
                showDialog(
                  context: context,
                  builder: (context) => UploadAttachmentDialog(rfiId: item.id),
                );
              } else if (value == 'upload_test_results') {
                showDialog(
                  context: context,
                  builder: (context) => UploadTestResultsDialog(rfiId: item.id),
                );
              } else if (value == 'submit') {
                _showPlaceholderDialog(context, 'Submit Inspection');
              } else if (value == 'view') {
                await context.pushNamed(
                  'rfi-detail',
                  pathParameters: <String, String>{
                    'id': item.id.toString(),
                  },
                );
              } else if (value == 'send_validation') {
                _showSendForValidationDialog(context, ref, item);
              } else if (value == 'change_executive') {
                _showChangeExecutiveDialog(context, ref, item);
              } else if (value == 'close') {
                showDialog(
                  context: context,
                  builder: (context) => DeleteRfiDialog(
                    item: inspectionItemToWcr(
                      id: item.id,
                      rfiNo: item.rfiId,
                      project: item.project,
                      work: item.work,
                      structure: item.structure,
                      element: item.element,
                      activity: item.activity,
                      status: item.status,
                      dateOfSubmission: item.dateOfSubmission,
                      assignedPersonClient: item.assignedPersonClient,
                      nameOfRepresentative: item.nameOfRepresentative,
                      createdBy: item.createdBy,
                      approvalStatus: item.approvalStatus,
                      totalQty: item.totalQty?.toString(),
                    ),
                    isClose: true,
                    onSuccess: () => ref
                        .read(inspectionProvider.notifier)
                        .fetchInspections(),
                  ),
                );
              } else if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (context) => DeleteRfiDialog(
                    item: inspectionItemToWcr(
                      id: item.id,
                      rfiNo: item.rfiId,
                      project: item.project,
                      work: item.work,
                      structure: item.structure,
                      element: item.element,
                      activity: item.activity,
                      status: item.status,
                      dateOfSubmission: item.dateOfSubmission,
                      assignedPersonClient: item.assignedPersonClient,
                      nameOfRepresentative: item.nameOfRepresentative,
                      createdBy: item.createdBy,
                      approvalStatus: item.approvalStatus,
                      totalQty: item.totalQty?.toString(),
                    ),
                    onSuccess: () => ref
                        .read(inspectionProvider.notifier)
                        .fetchInspections(),
                  ),
                );
              }
            },
            itemBuilder: (context) {
              final status = item.status?.toUpperCase() ?? '';
              final isEnabled = _canStartInspection(item, appRole);
              final canClose = appRole.canRejectOrClose(status);
              final canDelete = appRole.canDeleteRfi(status);
              
              PopupMenuEntry buildMenuItem(String value, String label, IconData icon, {bool enabled = true, Color? color}) {
                return PopupMenuItem<String>(
                  value: value,
                  enabled: enabled,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: enabled
                            ? (color ?? scheme.primary)
                            : scheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: enabled
                                  ? scheme.onSurface
                                  : scheme.onSurfaceVariant.withValues(
                                      alpha: 0.5,
                                    ),
                            ),
                      ),
                    ],
                  ),
                );
              }

              return <PopupMenuEntry>[
                if (appRole.canStartInspection(status)) ...[
                  buildMenuItem('online', 'Start Inspection Online', Icons.online_prediction, enabled: isEnabled),
                  const PopupMenuDivider(height: 1),
                  buildMenuItem('offline', 'Start Inspection Offline', Icons.offline_pin_outlined, enabled: isEnabled),
                  const PopupMenuDivider(height: 1),
                ],
                buildMenuItem('view', 'View Details', Icons.visibility_outlined, enabled: appRole.canViewRfi(item.status ?? '')),
                if (appRole.canUploadAttachments(status)) ...[
                  const PopupMenuDivider(height: 1),
                  buildMenuItem('upload_attachments', 'Upload Attachments', Icons.attach_file_rounded),
                ],
                if (appRole.canUploadTestResults(status)) ...[
                  const PopupMenuDivider(height: 1),
                  buildMenuItem('upload_test_results', 'Upload Test Results', Icons.biotech_rounded),
                ],
                if (appRole.canSubmitInspection(status)) ...[
                  const PopupMenuDivider(height: 1),
                  buildMenuItem('submit', 'Submit', Icons.check_circle_outline_rounded),
                ],
                if (appRole.canSendForValidation(status)) ...[
                  const PopupMenuDivider(height: 1),
                  buildMenuItem('send_validation', 'Send for Validation', Icons.send_rounded),
                ],
                if (canClose) ...[
                  const PopupMenuDivider(height: 1),
                  buildMenuItem('close', 'Close RFI', Icons.lock_outline_rounded, color: Colors.blue.shade600),
                ],
                if (canDelete) ...[
                  const PopupMenuDivider(height: 1),
                  buildMenuItem(
                    'delete',
                    'Delete RFI',
                    Icons.delete_forever_rounded,
                    color: const Color(0xFFE57373),
                  ),
                ],
                if (appRole.canChangeExecutive(status)) ...[
                  const PopupMenuDivider(height: 1),
                  buildMenuItem('change_executive', 'Change Executive', Icons.person_search_rounded),
                ],
              ];
            },
          ),
        )),
      ],
    );
  }

  void _showPlaceholderDialog(BuildContext context, String actionName) {
    GlobalAlertDialog.show(
      context,
      title: actionName,
      message: '$actionName action is coming soon! This is currently a placeholder.',
      type: DialogType.info,
    );
  }

  void _showSendForValidationDialog(
      BuildContext context, WidgetRef ref, InspectionItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Send'),
        content: const Text('Are you sure you want to send this RFI for validation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(inspectionProvider.notifier)
                    .sendForValidation(item.id);
                if (context.mounted) {
                  GlobalAlertDialog.show(
                    context,
                    title: 'Success',
                    message: 'RFI sent for validation successfully.',
                    type: DialogType.success,
                  );
                }
              } catch (e) {
                if (!context.mounted) {
                  return;
                }
                if (isWcrSessionExpiredError(e)) {
                  await handleWcrSessionExpired(context: context, ref: ref);
                  return;
                }
                final errorStr = userFriendlyErrorMessage(e);
                GlobalAlertDialog.show(
                  context,
                  title: 'Oops! Something went wrong',
                  message: errorStr.contains('400') ||
                          errorStr.toLowerCase().contains('inspection approval status')
                      ? errorStr
                      : 'Unable to send for validation: $errorStr',
                  type: DialogType.error,
                );
              }
            },
            style: RfiTheme.primaryElevated(
              Theme.of(context).colorScheme,
            ).copyWith(
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showChangeExecutiveDialog(
      BuildContext context, WidgetRef ref, InspectionItem item) {
    showDialog(
      context: context,
      builder: (context) => ChangeExecutiveDialog(
        rfiId: item.rfiId ?? '',
        contractId: item.contractId ?? '',
        onSuccess: () => ref.read(inspectionProvider.notifier).fetchInspections(),
      ),
    );
  }

  String _scheduledOn(InspectionItem item) {
    final date = item.dateOfInspection;
    final time = item.timeOfInspection;
    if (date == null || date.isEmpty) return '---';
    if (time == null || time.isEmpty) return date;
    return '$date $time';
  }

  String _contractorSubmittedOn(InspectionItem item) {
    final value = item.contractorSubmittedOn;
    if (value == null || value.isEmpty) return '---';
    return value;
  }

  bool _canStartInspection(InspectionItem item, UserRole appRole) {
    if (item.dateOfInspection == null ||
        item.dateOfInspection!.isEmpty ||
        item.timeOfInspection == null ||
        item.timeOfInspection!.isEmpty) {
      return false;
    }

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      DateTime? parseDate(String? dateStr) {
        if (dateStr == null || dateStr.isEmpty) return null;
        
        if (dateStr.contains('-') && dateStr.indexOf('-') == 4) {
          return DateTime.tryParse(dateStr);
        }

        final parts = dateStr.split('-');
        if (parts.length != 3) return null;

        try {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);

          if (year < 100) {
            year += 2000;
          }
          return DateTime(year, month, day);
        } catch (_) {
          return null;
        }
      }

      final status = item.status?.toUpperCase() ?? '';

      final inspectionDate = parseDate(item.dateOfInspection);
      final submissionDate = parseDate(item.dateOfSubmission);

      if (inspectionDate == null || inspectionDate.isAfter(today)) {
        return false;
      }

      if (submissionDate != null && submissionDate.isAfter(today)) {
        return false;
      }

      if (!appRole.canStartInspection(status)) {
        return false;
      }

      if (appRole == UserRole.engineer || appRole == UserRole.dyHod || appRole == UserRole.dyHodEngineer) {
        final hasMeasurement = item.measurementType != null &&
            item.measurementType!.isNotEmpty &&
            item.totalQty != null;

        if (!hasMeasurement) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
