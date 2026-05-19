import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/user_role.dart';
import '../../providers/auth/auth_provider.dart';
import '../../data/services/rfi_pdf_generator.dart';
import '../../providers/validation/validation_provider.dart';
import '../../core/widgets/table_search_header.dart';
import '../../core/widgets/table_pagination_footer.dart';
import '../rfi_log/widgets/rfi_preview_dialog.dart';
import '../../data/rfi_log/rfi_log_repository.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/global_alert_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';

class ValidationScreen extends ConsumerWidget {
  const ValidationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final appRole = UserRole.fromLoginResponse(authState.value ?? {});
    final state = ref.watch(validationNotifierProvider);
    final notifier = ref.read(validationNotifierProvider.notifier);
    final canEdit = appRole.canEditValidation;

    // Listen for validation action errors and show a clean dialog
    ref.listen(validationNotifierProvider.select((s) => s.actionErrorMessage),
        (previous, next) {
      if (next != null && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Validation Error'),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(
                next,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  notifier.clearActionError();
                  Navigator.pop(context);
                  notifier.fetchValidations();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });

    final totalItems = state.filteredItems.length;
    final totalPages = (totalItems / state.entriesPerPage).ceil();
    final startIndex = (state.currentPage - 1) * state.entriesPerPage;
    final endIndex = (state.currentPage * state.entriesPerPage).clamp(0, totalItems);

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: RfiTheme.scaffoldBackground(context),
      appBar: AppBar(
        title: const Text('RFI VALIDATION'),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => notifier.fetchValidations(),
          child: Column(
          children: [
            // Sticky Filter Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: RfiTheme.surfaceCardDecoration(scheme),
                child: TableSearchHeader(
                  rowsPerPage: state.entriesPerPage,
                  onRowsPerPageChanged: (val) {
                    if (val != null) notifier.setEntriesPerPage(val);
                  },
                  onSearchChanged: notifier.setSearchQuery,
                  searchHint: 'Search by RFI ID, status, remarks...',
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Loading, Error, or List Content
                  if (state.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.errorMessage != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ErrorStateWidget(
                        onRetry: () => notifier.fetchValidations(),
                        message: 'Failed to load validations. Please try again.',
                      ),
                    )
                  else if (state.filteredItems.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text('No Validation Data found'),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: scheme.outlineVariant),
                              color: scheme.surface,
                            ),
                            child: DataTable(
                              dataRowMaxHeight: canEdit ? 95 : 60,
                              dataRowMinHeight: 48,
                              headingRowColor: WidgetStateProperty.all(
                                RfiTheme.tableHeaderBackground(scheme),
                              ),
                              headingTextStyle: RfiTheme.tableHeaderTextStyle(
                                Theme.of(context).textTheme,
                                scheme,
                              ),
                              dataTextStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: scheme.onSurface,
                                    fontSize: 12,
                                  ),
                              columnSpacing: 20,
                              horizontalMargin: 12,
                              dividerThickness: 1,
                              columns: canEdit
                                  ? const [
                                      DataColumn(label: Text('RFI ID')),
                                      DataColumn(label: Text('Preview')),
                                      DataColumn(label: Text('Download')),
                                      DataColumn(label: Text('Remarks')),
                                      DataColumn(label: Text('Comments')),
                                      DataColumn(label: Text('Action')),
                                    ]
                                  : const [
                                      DataColumn(label: Text('RFI ID')),
                                      DataColumn(label: Text('Preview')),
                                      DataColumn(label: Text('Download')),
                                      DataColumn(label: Text('Remarks')),
                                      DataColumn(label: Text('Status')),
                                    ],
                              rows: state.paginatedItems.map((item) {
                                final bool isOpen = item.status == null ||
                                    item.status!.isEmpty ||
                                    item.status!.toLowerCase() == 'null';
                                final String? currentStatus =
                                    isOpen ? null : item.status!.toUpperCase();

                                ui.Color statusColor;
                                if (currentStatus == 'APPROVED') {
                                  statusColor = Colors.green;
                                } else if (currentStatus == 'REJECTED') {
                                  statusColor = Colors.red;
                                } else if (currentStatus == 'UNDER_ENGG_RECTIFICATION' ||
                                    currentStatus == 'RETURNED_FOR_CLARIFICATION') {
                                  statusColor = Colors.deepOrange;
                                } else {
                                  statusColor = Colors.orange;
                                }

                                final int rfiId = item.longRfiId;
                                final String pendingRemarks =
                                    state.pendingRemarks[rfiId] ?? 'Select';
                                final String pendingComments =
                                    state.pendingComments[rfiId] ?? '';
                                final bool isInputValid =
                                    pendingRemarks != 'Select' &&
                                        pendingComments.trim().isNotEmpty;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(item.stringRfiId)),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.remove_red_eye,
                                            size: 20, color: Colors.blueGrey),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => RfiPreviewDialog(
                                                rfiId: item.longRfiId.toString()),
                                          );
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.download,
                                            size: 20, color: Colors.blueAccent),
                                        onPressed: () async {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (_) => const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                          );

                                          try {
                                            final repository = ref
                                                .read(rfiLogRepositoryProvider);
                                            final reportData = await repository
                                                .fetchRfiReportDetails(
                                                    item.longRfiId.toString());

                                            await RfiPdfGenerator.generateAndOpen(
                                              rfiId: item.stringRfiId,
                                              data: reportData,
                                            );
                                          } catch (e) {
                                            if (context.mounted) {
                                              GlobalAlertDialog.show(
                                                context,
                                                title: 'PDF generation failed',
                                                message:
                                                    'Failed to generate PDF: ${e.toString()}',
                                                type: DialogType.error,
                                              );
                                            }
                                          } finally {
                                            if (context.mounted) {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    // Remarks Column
                                    DataCell(
                                      isOpen
                                          ? canEdit
                                              ? SizedBox(
                                                  width: 120,
                                                  child: AppDropdown<String>(
                                                    value:
                                                        pendingRemarks == 'Select'
                                                            ? null
                                                            : pendingRemarks,
                                                    hint: 'Select',
                                                    items: const [
                                                      'NONO',
                                                      'NONOC (C)',
                                                      'NOR'
                                                    ],
                                                    itemLabel: (s) => s,
                                                    onChanged: (val) {
                                                      if (val != null) {
                                                        notifier
                                                            .updatePendingRemarks(
                                                                rfiId, val);
                                                      }
                                                    },
                                                  ),
                                                )
                                              : const Text(
                                                  'Validation Pending',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                )
                                          : Text(
                                              (item.remarks == null ||
                                                      item.remarks!
                                                              .toLowerCase() ==
                                                          'null' ||
                                                      item.remarks!.isEmpty)
                                                  ? 'Validation Pending'
                                                  : item.remarks!,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold)),
                                    ),
                                    // Comments Column (dyHOD only)
                                    if (canEdit)
                                      DataCell(
                                        isOpen
                                            ? SizedBox(
                                                width: 250,
                                                child: TextField(
                                                  maxLines: 2,
                                                  maxLength: 500,
                                                  style: const TextStyle(
                                                      fontSize: 11),
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    hintText: 'Enter your comment',
                                                    hintStyle: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey),
                                                    fillColor: Colors.grey.shade50,
                                                    filled: true,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(4),
                                                      borderSide: BorderSide(
                                                          color:
                                                              Colors.grey.shade300),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(4),
                                                      borderSide: BorderSide(
                                                          color:
                                                              Colors.grey.shade300),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 6),
                                                    counterText: "",
                                                  ),
                                                  onChanged: (val) => notifier
                                                      .updatePendingComment(
                                                          rfiId, val),
                                                ),
                                              )
                                            : Text(
                                                item.comment ?? '',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey.shade700),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                      ),
                                    // Action (dyHOD) or Status (Engineer) Column
                                    DataCell(
                                      isOpen
                                          ? canEdit
                                              ? state.isValidating
                                                  ? const Center(
                                                      child: SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child:
                                                              CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2.5)))
                                                  : SizedBox(
                                                      width: 130,
                                                      child: AppDropdown<String>(
                                                        value: null,
                                                        hint: 'Select Action',
                                                        items: const [
                                                          'Approved',
                                                          'Rejected',
                                                          'Rectify'
                                                        ],
                                                        itemLabel: (s) => s,
                                                        enabled: isInputValid,
                                                        onChanged: (val) {
                                                          if (val == null) {
                                                            return;
                                                          }
                                                          final payloadAction =
                                                              switch (val) {
                                                            'Approved' =>
                                                              'APPROVED',
                                                            'Rejected' =>
                                                              'REJECTED',
                                                            'Rectify' =>
                                                              'Returned_For_Clarification',
                                                            _ => null,
                                                          };
                                                          if (payloadAction ==
                                                              null) {
                                                            return;
                                                          }
                                                          GlobalAlertDialog.show(
                                                            context,
                                                            title:
                                                                'Confirm action',
                                                            message:
                                                                'Are you sure you want to mark this as "$val"?',
                                                            type:
                                                                DialogType.confirm,
                                                            confirmText:
                                                                'Confirm',
                                                            cancelText:
                                                                'Cancel',
                                                            onConfirm: () {
                                                              notifier
                                                                  .validateItem(
                                                                item.longRfiId,
                                                                item
                                                                    .longRfiValidateId,
                                                                payloadAction,
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    )
                                              : const Text(
                                                  'Validation Pending',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                )
                                          : Text(
                                              currentStatus ?? '',
                                              style: TextStyle(
                                                  color: statusColor,
                                                  fontSize: 11,
                                                  fontWeight: ui.FontWeight.bold),
                                            ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Sticky Pagination
            if (state.filteredItems.isNotEmpty)
              TablePaginationFooter(
                startIndex: startIndex,
                endIndex: endIndex,
                totalItems: totalItems,
                currentPage: state.currentPage,
                totalPages: totalPages,
                onPageChanged: (page) => notifier.setPage(page),
              ),
          ],
        ),
      ),
    ),
  );
}
}
