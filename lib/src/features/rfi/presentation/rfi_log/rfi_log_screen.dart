import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/pdf_download_service.dart';
import '../../providers/rfi_log/rfi_log_provider.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';
import '../../domain/common/filter_option.dart';
import '../../domain/rfi_log/rfi_log_dashboard_filter.dart';
import '../../domain/rfi_log/rfi_log_item.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/table_pagination_footer.dart';
import '../../core/widgets/global_alert_dialog.dart';
import '../../core/providers/dio_provider.dart';
import 'widgets/rfi_preview_dialog.dart';

class RfiLogScreen extends ConsumerStatefulWidget {
  const RfiLogScreen({
    super.key,
    this.dashboardFilter = RfiLogDashboardFilter.none,
  });

  final RfiLogDashboardFilter dashboardFilter;

  @override
  ConsumerState<RfiLogScreen> createState() => _RfiLogScreenState();
}

class _RfiLogScreenState extends ConsumerState<RfiLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(rfiLogNotifierProvider.notifier)
          .applyDashboardFilter(widget.dashboardFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rfiLogNotifierProvider);
    final notifier = ref.read(rfiLogNotifierProvider.notifier);

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: RfiTheme.scaffoldBackground(context),
      appBar: AppBar(
        title: Text(widget.dashboardFilter.title),
      ),
      body: SafeArea(
        top: false,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
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
                                  child: AppDropdown<FilterOption>(
                                    label: 'Project',
                                    hint: 'All Projects',
                                    value: _optionById(
                                      state.availableProjects,
                                      state.projectFilter,
                                    ),
                                    items: state.availableProjects,
                                    onChanged: (FilterOption? val) =>
                                        notifier.setProjectFilter(val?.id),
                                    itemLabel: (FilterOption v) => v.name,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppDropdown<FilterOption>(
                                    label: 'Contract',
                                    hint: 'All Contracts',
                                    value: _optionById(
                                      state.availableContracts,
                                      state.contractFilter,
                                    ),
                                    items: state.availableContracts,
                                    onChanged: (FilterOption? val) =>
                                        notifier.setContractFilter(val?.id),
                                    itemLabel: (FilterOption v) => v.name,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            Divider(height: 1, color: Colors.grey.shade200),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: notifier.clearFilters,
                                icon: const Icon(Icons.filter_alt_off, size: 16),
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
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (state.errorMessage != null)
                      SliverFillRemaining(
                        child: ErrorStateWidget(
                          onRetry: () => notifier.fetchRfiLogs(),
                          message: state.errorMessage ??
                              'Failed to load RFI logs. Please try again.',
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
                                  DataColumn(label: Text('RFI Raised\nDate')),
                                  DataColumn(label: Text('ID Of Structure')),
                                  DataColumn(label: Text('RFI Description')),
                                  DataColumn(
                                      label: Text('Contractor\nRepresentative')),
                                  DataColumn(
                                      label: Text("Employer's\nEngineer")),
                                  DataColumn(
                                      label: Text('Date Responded\n(Contractor)')),
                                  DataColumn(
                                      label: Text('Date Responded\n(Engineer)')),
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
                                      DataCell(Text(_cell(item.rfiId))),
                                      DataCell(Text(_cell(item.dateRaised))),
                                      DataCell(Text(_cell(item.structure))),
                                      DataCell(
                                          Text(_cell(item.rfiDescription))),
                                      DataCell(
                                        Tooltip(
                                          message: item.nameOfRepresentative,
                                          child: Text(
                                            _ellipsis(
                                              item.nameOfRepresentative,
                                              28,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Tooltip(
                                          message: item.person,
                                          child: Text(
                                            _ellipsis(item.person, 28),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(_cell(
                                          item.dateRespondedContractor))),
                                      DataCell(Text(
                                          _cell(item.dateRespondedEngineer))),
                                      DataCell(
                                        Text(
                                          displayStatus,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Tooltip(
                                          message: item.notes ?? '',
                                          child: Text(
                                            _ellipsis(item.notes ?? '', 20),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        item.rfiId.isEmpty
                                            ? const SizedBox.shrink()
                                            : IconButton(
                                                icon: const Icon(
                                                  Icons.remove_red_eye,
                                                  size: 20,
                                                  color: Colors.blueGrey,
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        RfiPreviewDialog(
                                                      rfiId: item.id.toString(),
                                                    ),
                                                  );
                                                },
                                                tooltip: 'Preview',
                                              ),
                                      ),
                                      DataCell(
                                        !_canShowDownload(item)
                                            ? const SizedBox.shrink()
                                            : IconButton(
                                                icon: const Icon(
                                                  Icons.download,
                                                  size: 20,
                                                  color: Colors.blueAccent,
                                                ),
                                                onPressed: () {
                                                  if (!_canShowDownload(item)) {
                                                    GlobalAlertDialog.show(
                                                      context,
                                                      title:
                                                          'Download unavailable',
                                                      message:
                                                          'Download is available only when eStatus is ENGG_SUCCESS or CON_SUCCESS and Transaction ID is present.',
                                                      type: DialogType.info,
                                                    );
                                                    return;
                                                  }
                                                  final dio =
                                                      ref.read(dioProvider);
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
                  pageSize: state.entriesPerPage,
                  onPageSizeChanged: notifier.setEntriesPerPage,
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

  static String _cell(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty ||
        text.toLowerCase() == 'n/a' ||
        text.toLowerCase() == 'null') {
      return '-';
    }
    return text;
  }

  static String _ellipsis(String value, int max) {
    final String text = _cell(value);
    if (text == '-' || text.length <= max) return text;
    return '${text.substring(0, max)}...';
  }

  FilterOption? _optionById(List<FilterOption> options, String id) {
    if (id.trim().isEmpty) return null;
    for (final FilterOption option in options) {
      if (option.id == id) return option;
    }
    return null;
  }
}
