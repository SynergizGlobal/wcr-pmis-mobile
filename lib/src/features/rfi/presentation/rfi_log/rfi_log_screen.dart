import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/pdf_download_service.dart';
import '../../providers/rfi_log/rfi_log_provider.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';
import '../../domain/rfi_log/rfi_log_item.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/table_pagination_footer.dart';
import '../../core/widgets/global_alert_dialog.dart';
import '../../core/providers/dio_provider.dart';
import 'widgets/rfi_preview_dialog.dart';

class RfiLogScreen extends ConsumerWidget {
  const RfiLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rfiLogNotifierProvider);
    final notifier = ref.read(rfiLogNotifierProvider.notifier);

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: RfiTheme.scaffoldBackground(context),
      appBar: AppBar(
        title: const Text('REQUEST FOR INSPECTION LOG-(RFI LOG)'),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => notifier.fetchRfiLogs(),
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        padding: const EdgeInsets.all(16.0),
                        decoration: RfiTheme.surfaceCardDecoration(scheme),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              onChanged: notifier.setSearchQuery,
                              style: Theme.of(context).textTheme.bodySmall,
                              decoration: InputDecoration(
                                hintText:
                                    'Search by RFI ID, structure, status, name...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: scheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: scheme.surfaceContainerHighest,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: scheme.outlineVariant),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: scheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                            Divider(height: 1, color: scheme.outlineVariant),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: AppDropdown<String>(
                                    label: 'Project',
                                    hint: 'All Projects',
                                    value: state.projectFilter.isEmpty
                                        ? null
                                        : state.projectFilter,
                                    items: state.projectNames,
                                    onChanged: (val) =>
                                        notifier.setProjectFilter(val ?? ''),
                                    enabled: true,
                                    itemLabel: (v) => v,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppDropdown<String>(
                                    label: 'Work',
                                    hint: state.projectFilter.isEmpty
                                        ? 'Select Project first'
                                        : 'All Works',
                                    value: state.workFilter.isEmpty
                                        ? null
                                        : state.workFilter,
                                    items: state.projectFilter.isEmpty
                                        ? []
                                        : state.workNames,
                                    onChanged: (val) =>
                                        notifier.setWorkFilter(val ?? ''),
                                    enabled: state.projectFilter.isNotEmpty,
                                    itemLabel: (v) => v,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppDropdown<String>(
                                    label: 'Contract',
                                    hint: state.workFilter.isEmpty
                                        ? 'Select Work first'
                                        : 'All Contracts',
                                    value: state.contractFilter.isEmpty
                                        ? null
                                        : state.contractFilter,
                                    items: state.workFilter.isEmpty
                                        ? []
                                        : state.contractNames,
                                    onChanged: (val) =>
                                        notifier.setContractFilter(val ?? ''),
                                    enabled: state.workFilter.isNotEmpty,
                                    itemLabel: (v) => v,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            Divider(height: 1, color: Colors.grey.shade200),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Show',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600)),
                                    const SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: AppDropdown<int>(
                                        value: state.entriesPerPage,
                                        items: const [5, 10, 25, 50, 100],
                                        itemLabel: (v) => v.toString(),
                                        width: 80,
                                        onChanged: (val) {
                                          if (val != null) {
                                            notifier.setEntriesPerPage(val);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text('entries',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600)),
                                  ],
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: notifier.clearFilters,
                                  icon:
                                      const Icon(Icons.filter_alt_off, size: 16),
                                  label: const Text('Clear Filters',
                                      style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFD9534F),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(
                                          color: Color(0xFFD9534F), width: 0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (state.isLoading)
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state.errorMessage != null)
                      SliverFillRemaining(
                        child: ErrorStateWidget(
                          onRetry: () => notifier.fetchRfiLogs(),
                          message: 'Failed to load RFI logs. Please try again.',
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
                                headingRowColor: WidgetStateProperty.all(
                                  RfiTheme.tableHeaderBackground(scheme),
                                ),
                                headingTextStyle: RfiTheme.tableHeaderTextStyle(
                                  Theme.of(context).textTheme,
                                  scheme,
                                ),
                                dataTextStyle: RfiTheme.tableCellTextStyle(
                                  Theme.of(context).textTheme,
                                  scheme,
                                ),
                                columnSpacing: 20,
                                horizontalMargin: 12,
                                dividerThickness: 1,
                                columns: const [
                                  DataColumn(label: Text('RFI ID')),
                                  DataColumn(label: Text('RFI Date')),
                                  DataColumn(label: Text('ID Of Structure')),
                                  DataColumn(label: Text('RFI Description')),
                                  DataColumn(label: Text('Assigned\nContractor')),
                                  DataColumn(label: Text('Person')),
                                  DataColumn(label: Text('Date Raised')),
                                  DataColumn(label: Text('Date\nResponded')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Notes')),
                                  DataColumn(label: Text('Preview')),
                                  DataColumn(label: Text('Download')),
                                ],
                                rows: (state.paginatedItems.isEmpty
                                        ? List.generate(
                                            5,
                                            (i) => const RfiLogItem(
                                                  id: 0,
                                                  rfiId: '',
                                                  dateOfSubmission: '',
                                                  structure: '',
                                                  rfiDescription: '',
                                                  rfiRequestedBy: '',
                                                  department: '',
                                                  person: '',
                                                  dateRaised: '',
                                                  status: '',
                                                  project: '',
                                                  work: '',
                                                  contract: '',
                                                  nameOfRepresentative: '',
                                                ))
                                        : state.paginatedItems)
                                    .map((item) {
                                  String displayStatus;
                                  Color statusColor;
                                  final rawStatus = item.status.toUpperCase();
                                  final rawValidation =
                                      (item.validationStatus ?? '').toUpperCase();

                                  if (item.rfiId.isEmpty) {
                                    displayStatus = '';
                                    statusColor = Colors.transparent;
                                  } else if (rawStatus == 'INSPECTION_DONE' &&
                                      rawValidation == 'REJECTED') {
                                    displayStatus = 'Rejected';
                                    statusColor = scheme.error;
                                  } else if (rawStatus == 'INSPECTION_DONE') {
                                    displayStatus = 'Closed';
                                    statusColor = scheme.primary;
                                  } else if (rawStatus == 'CREATED' ||
                                      rawStatus == 'OPEN') {
                                    displayStatus = 'Open';
                                    statusColor = scheme.tertiary;
                                  } else if (rawStatus == 'DELETED') {
                                    displayStatus = 'Deleted';
                                    statusColor = scheme.onSurfaceVariant;
                                  } else if (rawStatus == 'REJECTED') {
                                    displayStatus = 'Rejected';
                                    statusColor = scheme.error;
                                  } else if (rawStatus ==
                                      'UNDER_CON_RECTIFICATION') {
                                    displayStatus = 'Under con. rectification';
                                    statusColor = scheme.secondary;
                                  } else if (rawStatus ==
                                      'UNDER_ENGG_RECTIFICATION') {
                                    displayStatus = 'Under engg. rectification';
                                    statusColor = scheme.secondary;
                                  } else {
                                    displayStatus = item.status;
                                    statusColor = scheme.onSurfaceVariant;
                                  }

                                  return DataRow(
                                    cells: [
                                      DataCell(Text(item.rfiId)),
                                      DataCell(Text(item.dateOfSubmission)),
                                      DataCell(Text(item.structure)),
                                      DataCell(Text(item.rfiDescription)),
                                      DataCell(Tooltip(
                                          message: item.nameOfRepresentative,
                                          child: Text(item
                                                      .nameOfRepresentative
                                                      .length >
                                                  20
                                              ? '${item.nameOfRepresentative.substring(0, 20)}...'
                                              : item.nameOfRepresentative))),
                                      DataCell(Tooltip(
                                          message: item.person,
                                          child: Text(item.person.length > 20
                                              ? '${item.person.substring(0, 20)}...'
                                              : item.person))),
                                      DataCell(Text(item.dateRaised)),
                                      DataCell(Text(item.dateResponded ?? '')),
                                      DataCell(
                                        Text(
                                          displayStatus,
                                          style: TextStyle(
                                              color: statusColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataCell(Tooltip(
                                          message: item.notes ?? '',
                                          child: Text((item.notes ?? '')
                                                      .length >
                                                  20
                                              ? '${item.notes!.substring(0, 20)}...'
                                              : item.notes ?? ''))),
                                      DataCell(
                                        item.rfiId.isEmpty
                                            ? const SizedBox.shrink()
                                            : IconButton(
                                                icon: const Icon(
                                                    Icons.remove_red_eye,
                                                    size: 20,
                                                    color: Colors.blueGrey),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        RfiPreviewDialog(
                                                            rfiId: item.id
                                                                .toString()),
                                                  );
                                                },
                                                tooltip: 'Preview',
                                              ),
                                      ),
                                      DataCell(
                                        !_canShowDownload(item)
                                            ? const SizedBox.shrink()
                                            : IconButton(
                                                icon: const Icon(Icons.download,
                                                    size: 20,
                                                    color: Colors.blueAccent),
                                                onPressed: () {
                                                  if (!_canShowDownload(item)) {
                                                    GlobalAlertDialog.show(
                                                      context,
                                                      title: 'Download unavailable',
                                                      message:
                                                          'Download is available only when eStatus is ENGG_SUCCESS or CON_SUCCESS and Transaction ID is present.',
                                                      type: DialogType.info,
                                                    );
                                                    return;
                                                  }
                                                  final dio = ref.read(dioProvider);
                                                  PdfDownloadService
                                                      .downloadAndOpenPdf(
                                                    context: context,
                                                    dio: dio,
                                                    rfiId: item.rfiId,
                                                    txnId: item.txnId!.trim(),
                                                  );
                                                },
                                                tooltip: 'Download',
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
                      const SliverToBoxAdapter(child: SizedBox(height: 30)),
                    ],
                  ],
                ),
              ),
              if (state.paginatedItems.isNotEmpty)
                TablePaginationFooter(
                  startIndex: (state.currentPage - 1) * state.entriesPerPage,
                  endIndex: ((state.currentPage - 1) * state.entriesPerPage) +
                      state.paginatedItems.length,
                  totalItems: state.filteredItems.length,
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                  onPageChanged: (page) => notifier.setPage(page),
                ),
            ],
          ),
        ),
    ),
  );
}

  static bool _canShowDownload(RfiLogItem item) {
    if (item.rfiId.trim().isEmpty) return false;
    if (item.txnId == null || item.txnId!.trim().isEmpty) return false;

    final eStatus = (item.estatus ?? '').trim().toUpperCase();
    return eStatus == 'ENGG_SUCCESS' || eStatus == 'CON_SUCCESS';
  }
}
