import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/add_utility_shifting_form_page.dart';

class UtilityShiftingPage extends StatefulWidget {
  const UtilityShiftingPage({super.key, required this.dataSource});

  static const String routeName = 'utility-shifting';
  static const String routePath = '/utility-shifting';

  final DashboardRemoteDataSource dataSource;

  @override
  State<UtilityShiftingPage> createState() => _UtilityShiftingPageState();
}

class _UtilityShiftingPageState extends State<UtilityShiftingPage>
    with SingleTickerProviderStateMixin {
  static const MethodChannel _fileExportChannel = MethodChannel(
    'wcr_pmis_mobile/file_export',
  );
  static const List<int> _pageSizes = <int>[5, 10, 25, 50, 100];

  late final TabController _tabController;
  bool _loading = false;

  final TextEditingController _utilitySearchCtrl = TextEditingController();
  final TextEditingController _uploadedSearchCtrl = TextEditingController();

  String _utilitySearch = '';
  String _uploadedSearch = '';
  int _utilityPageSize = 10;
  int _uploadedPageSize = 10;
  int _utilityPage = 0;
  int _uploadedPage = 0;

  String? _selectedLocation;
  String? _selectedCategory;
  String? _selectedUtilityType;
  String? _selectedStatus;

  List<Map<String, dynamic>> _utilityRows = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _uploadedRows = <Map<String, dynamic>>[];

  List<_FilterOption> _locations = <_FilterOption>[];
  List<_FilterOption> _categories = <_FilterOption>[];
  List<_FilterOption> _utilityTypes = <_FilterOption>[];
  List<_FilterOption> _statuses = <_FilterOption>[];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging && mounted) {
          setState(() {});
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _utilitySearchCtrl.dispose();
    _uploadedSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filteredUtility = _filteredUtilityRows();
    final _PageSlice utilitySlice = _slice(
      filteredUtility,
      page: _utilityPage,
      pageSize: _utilityPageSize,
    );
    final List<Map<String, dynamic>> filteredUploads = _filteredUploadedRows();
    final _PageSlice uploadSlice = _slice(
      filteredUploads,
      page: _uploadedPage,
      pageSize: _uploadedPageSize,
    );

    final ThemeData theme = Theme.of(context);
    final Color appBarForeground =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Utility Shifting'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: appBarForeground,
          unselectedLabelColor: appBarForeground.withValues(alpha: 0.72),
          indicatorColor: appBarForeground,
          dividerColor: appBarForeground.withValues(alpha: 0.22),
          tabs: const <Tab>[
            Tab(text: 'Utility Shifting'),
            Tab(text: 'Uploaded Utility Shifting Data'),
          ],
        ),
      ),
      bottomNavigationBar: _tabController.index == 0
          ? _stickyFooter(
              total: filteredUtility.length,
              start: utilitySlice.start,
              end: utilitySlice.end,
              page: utilitySlice.page,
              pageCount: utilitySlice.pageCount,
              onPrev: utilitySlice.page > 1
                  ? () => setState(() => _utilityPage = utilitySlice.page - 2)
                  : null,
              onNext: utilitySlice.page < utilitySlice.pageCount
                  ? () => setState(() => _utilityPage = utilitySlice.page)
                  : null,
            )
          : _stickyFooter(
              total: filteredUploads.length,
              start: uploadSlice.start,
              end: uploadSlice.end,
              page: uploadSlice.page,
              pageCount: uploadSlice.pageCount,
              onPrev: uploadSlice.page > 1
                  ? () => setState(() => _uploadedPage = uploadSlice.page - 2)
                  : null,
              onNext: uploadSlice.page < uploadSlice.pageCount
                  ? () => setState(() => _uploadedPage = uploadSlice.page)
                  : null,
            ),
      body: Stack(
        children: <Widget>[
          TabBarView(
            controller: _tabController,
            children: <Widget>[
              _utilityTab(utilitySlice.rows, filteredUtility),
              _uploadsTab(uploadSlice.rows, filteredUploads),
            ],
          ),
          if (_loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _utilityTab(List<Map<String, dynamic>> pageRows, List<Map<String, dynamic>> allRows) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: <Widget>[
          _toolbarBox(
            searchController: _utilitySearchCtrl,
            searchValue: _utilitySearch,
            onSearchChanged: (String value) => setState(() {
              _utilitySearch = value.trim();
              _utilityPage = 0;
            }),
            pageSize: _utilityPageSize,
            onPageSizeChanged: (int value) => setState(() {
              _utilityPageSize = value;
              _utilityPage = 0;
            }),
            primaryLeft: _ActionSpec(
              label: 'Filter ($_activeFilterCount)',
              icon: Icons.filter_alt_rounded,
              onTap: _openFilterDialog,
              tonal: true,
            ),
            primaryRight: _ActionSpec(
              label: 'Clear Filter',
              icon: Icons.filter_alt_off_rounded,
              onTap: _activeFilterCount > 0 ? _clearFilters : null,
            ),
            secondaryLeft: _ActionSpec(
              label: 'Export Excel',
              icon: Icons.download_rounded,
              onTap: allRows.isNotEmpty ? () => _confirmExportUtility(allRows) : null,
            ),
            secondaryRight: _ActionSpec(
              label: 'Add',
              icon: Icons.add_rounded,
              onTap: _showAddComingSoon,
              filled: true,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: _utilityTable(pageRows)),
        ],
      ),
    );
  }

  Widget _uploadsTab(List<Map<String, dynamic>> pageRows, List<Map<String, dynamic>> allRows) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Template',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _confirmDownloadUploadTemplate,
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Download'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _uploadTemplatePlaceholder,
                          icon: const Icon(Icons.upload_rounded),
                          label: const Text('Upload'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _uploadedSearchCtrl,
                    onChanged: (String value) => setState(() {
                      _uploadedSearch = value.trim();
                      _uploadedPage = 0;
                    }),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      isDense: true,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _uploadedSearch.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _uploadedSearchCtrl.clear();
                                setState(() {
                                  _uploadedSearch = '';
                                  _uploadedPage = 0;
                                });
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Text(
                        'Show',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      DropdownButton<int>(
                        value: _uploadedPageSize,
                        items: _pageSizes
                            .map(
                              (int item) => DropdownMenuItem<int>(
                                value: item,
                                child: Text('$item'),
                              ),
                            )
                            .toList(),
                        onChanged: (int? value) {
                          if (value == null) return;
                          setState(() {
                            _uploadedPageSize = value;
                            _uploadedPage = 0;
                          });
                        },
                      ),
                      Text(
                        'entries',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: _uploadsTable(pageRows)),
        ],
      ),
    );
  }

  Widget _toolbarBox({
    required TextEditingController searchController,
    required String searchValue,
    required ValueChanged<String> onSearchChanged,
    required int pageSize,
    required ValueChanged<int> onPageSizeChanged,
    required _ActionSpec primaryLeft,
    required _ActionSpec primaryRight,
    required _ActionSpec secondaryLeft,
    required _ActionSpec secondaryRight,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _actionRow(primaryLeft, primaryRight),
            if (secondaryLeft.label.trim().isNotEmpty ||
                secondaryRight.label.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              _actionRow(secondaryLeft, secondaryRight),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search',
                isDense: true,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchValue.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Text(
                  'Show',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6),
                DropdownButton<int>(
                  value: pageSize,
                  items: _pageSizes
                      .map(
                        (int item) => DropdownMenuItem<int>(
                          value: item,
                          child: Text('$item'),
                        ),
                      )
                      .toList(),
                  onChanged: (int? value) {
                    if (value != null) {
                      onPageSizeChanged(value);
                    }
                  },
                ),
                Text(
                  'entries',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionRow(_ActionSpec left, _ActionSpec right) {
    return Row(
      children: <Widget>[
        Expanded(child: _actionButton(left)),
        const SizedBox(width: 8),
        Expanded(child: _actionButton(right)),
      ],
    );
  }

  Widget _actionButton(_ActionSpec action) {
    if (action.filled) {
      return FilledButton.icon(
        onPressed: action.onTap,
        icon: Icon(action.icon),
        label: Text(action.label),
      );
    }
    if (action.tonal) {
      return FilledButton.tonalIcon(
        onPressed: action.onTap,
        icon: Icon(action.icon),
        label: Text(action.label),
      );
    }
    return OutlinedButton.icon(
      onPressed: action.onTap,
      icon: Icon(action.icon),
      label: Text(action.label),
    );
  }

  Widget _utilityTable(List<Map<String, dynamic>> rows) {
    const List<String> headers = <String>[
      'ID',
      'Description',
      'Utility Type',
      'Custodian',
      'HOD',
      'Execution Agency',
      'Status',
      'Last Update',
      'Actions',
    ];
    return _tableShell(
      headers: headers,
      rowCount: rows.length,
      rowBuilder: (BuildContext context, int index) {
        final Map<String, dynamic> row = rows[index];
        final ColorScheme cs = Theme.of(context).colorScheme;
        final Color bg = index.isEven
            ? cs.primary.withValues(alpha: 0.08)
            : cs.surface;
        return Container(
          color: bg,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              _cell(_string(row['utility_shifting_id']), 130),
              _cell(_string(row['utility_description']), 240),
              _cell(_string(row['utility_type_fk']), 140),
              _cell(_string(row['custodian']), 130),
              _cell(_string(row['user_name']), 120),
              _cell(_string(row['execution_agency_fk']), 140),
              _cell(_string(row['shifting_status_fk']), 120),
              _cell(_string(row['modified_date']), 120),
              SizedBox(
                width: 80,
                child: IconButton(
                  onPressed: () => _openEditUtility(row),
                  icon: Icon(Icons.edit_square, color: cs.primary),
                ),
              ),
            ],
          ),
        );
      },
      emptyText: 'No utility shifting records found.',
    );
  }

  Widget _uploadsTable(List<Map<String, dynamic>> rows) {
    const List<String> headers = <String>[
      'Utility Data ID',
      'Uploaded File',
      'Status',
      'Remarks',
      'Uploaded By',
      'Uploaded On',
    ];
    return _tableShell(
      headers: headers,
      rowCount: rows.length,
      rowBuilder: (BuildContext context, int index) {
        final Map<String, dynamic> row = rows[index];
        final ColorScheme cs = Theme.of(context).colorScheme;
        final Color bg = index.isEven
            ? cs.primary.withValues(alpha: 0.08)
            : cs.surface;
        return Container(
          color: bg,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              _cell(_string(row['utility_data_id']), 120),
              _cell(_string(row['uploaded_file']), 260),
              _cell(_string(row['status']), 100),
              _cell(_string(row['remarks']), 260),
              _cell(_string(row['uploaded_by_user_id_fk']), 130),
              _cell(_string(row['uploaded_on']), 170),
            ],
          ),
        );
      },
      emptyText: 'No uploaded utility shifting data found.',
    );
  }

  Widget _tableShell({
    required List<String> headers,
    required int rowCount,
    required IndexedWidgetBuilder rowBuilder,
    required String emptyText,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Map<String, double> widths = <String, double>{
      'ID': 130,
      'Description': 240,
      'Utility Type': 140,
      'Custodian': 130,
      'HOD': 120,
      'Execution Agency': 140,
      'Status': 120,
      'Last Update': 120,
      'Actions': 80,
      'Utility Data ID': 120,
      'Uploaded File': 260,
      'Remarks': 260,
      'Uploaded By': 130,
      'Uploaded On': 170,
    };
    final double totalWidth = headers.fold<double>(
      0,
      (double sum, String h) => sum + (widths[h] ?? 120),
    );
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalWidth,
                child: Column(
                  children: <Widget>[
                    Container(
                      color: cs.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: headers
                            .map(
                              (String h) => _cell(
                                h,
                                widths[h] ?? 120,
                                color: cs.onPrimary,
                                weight: FontWeight.w700,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: rowCount == 0
                          ? Center(child: Text(emptyText))
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 10),
                              itemCount: rowCount,
                              itemBuilder: rowBuilder,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _cell(
    String value,
    double width, {
    Color? color,
    FontWeight weight = FontWeight.w600,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontWeight: weight),
        ),
      ),
    );
  }

  Widget _stickyFooter({
    required int total,
    required int start,
    required int end,
    required int page,
    required int pageCount,
    required VoidCallback? onPrev,
    required VoidCallback? onNext,
  }) {
    return AppTablePaginationFooter(
      total: total,
      startIndex: total == 0 ? 0 : start - 1,
      endIndex: end,
      currentPage: total == 0 ? 0 : page - 1,
      pageCount: pageCount,
      onPrevious: onPrev,
      onNext: onNext,
    );
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final List<Map<String, dynamic>> responses = await Future.wait<
          Map<String, dynamic>>(<Future<Map<String, dynamic>>>[
        widget.dataSource.fetchUtilityShiftingList(start: 0, length: 500, search: ''),
        widget.dataSource.fetchUtilityShiftingUploadsList(),
        widget.dataSource.fetchUtilityLocationFilter(),
        widget.dataSource.fetchUtilityCategoryFilter(),
        widget.dataSource.fetchUtilityTypeFilter(),
        widget.dataSource.fetchUtilityStatusFilter(),
      ]);
      if (!mounted) {
        return;
      }
      final List<Map<String, dynamic>> utilityRows = _rowsFromAaData(responses[0]);
      final List<Map<String, dynamic>> uploadRows = _rowsFromData(responses[1]);
      setState(() {
        _utilityRows = utilityRows;
        _uploadedRows = uploadRows;
        _locations = _dedupeOptions(
          _rowsFromData(responses[2]).map(
            (Map<String, dynamic> row) => _FilterOption(
              value: _safe(row['location_name']) ?? '',
              label: _safe(row['location_name']) ?? '',
            ),
          ),
        );
        _categories = _dedupeOptions(
          _rowsFromData(responses[3]).map(
            (Map<String, dynamic> row) => _FilterOption(
              value: _safe(row['utility_category_fk']) ?? '',
              label: _safe(row['utility_category_fk']) ?? '',
            ),
          ),
        );
        _utilityTypes = _dedupeOptions(
          _rowsFromData(responses[4]).map(
            (Map<String, dynamic> row) => _FilterOption(
              value: _safe(row['utility_type_fk']) ?? '',
              label: _safe(row['utility_type_fk']) ?? '',
            ),
          ),
        );
        _statuses = _dedupeOptions(
          _rowsFromData(responses[5]).map(
            (Map<String, dynamic> row) => _FilterOption(
              value: _safe(row['shifting_status_fk']) ?? '',
              label: _safe(row['shifting_status_fk']) ?? '',
            ),
          ),
        );
        _selectedLocation = _retain(_selectedLocation, _locations);
        _selectedCategory = _retain(_selectedCategory, _categories);
        _selectedUtilityType = _retain(_selectedUtilityType, _utilityTypes);
        _selectedStatus = _retain(_selectedStatus, _statuses);
        _utilityPage = 0;
        _uploadedPage = 0;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load utility shifting',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Map<String, dynamic>> _filteredUtilityRows() {
    final String query = _utilitySearch.toLowerCase();
    return _utilityRows.where((Map<String, dynamic> row) {
      final bool locationPass = _selectedLocation == null
          ? true
          : (_safe(row['location_name']) ?? '') == _selectedLocation;
      final bool categoryPass = _selectedCategory == null
          ? true
          : (_safe(row['utility_category_fk']) ?? '') == _selectedCategory;
      final bool typePass = _selectedUtilityType == null
          ? true
          : (_safe(row['utility_type_fk']) ?? '') == _selectedUtilityType;
      final bool statusPass = _selectedStatus == null
          ? true
          : (_safe(row['shifting_status_fk']) ?? '') == _selectedStatus;
      final bool searchPass = query.isEmpty
          ? true
          : row.values.any(
              (dynamic v) => _string(v).toLowerCase().contains(query),
            );
      return locationPass && categoryPass && typePass && statusPass && searchPass;
    }).toList();
  }

  List<Map<String, dynamic>> _filteredUploadedRows() {
    final String query = _uploadedSearch.toLowerCase();
    if (query.isEmpty) {
      return _uploadedRows;
    }
    return _uploadedRows.where((Map<String, dynamic> row) {
      return row.values.any((dynamic v) => _string(v).toLowerCase().contains(query));
    }).toList();
  }

  Future<void> _openFilterDialog() async {
    String? location = _selectedLocation;
    String? category = _selectedCategory;
    String? utilityType = _selectedUtilityType;
    String? status = _selectedStatus;
    bool apply = false;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: const Center(child: Text('Filter Utility Shifting')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _dialogPickField(
                      label: 'Location',
                      options: _locations,
                      value: location,
                      onChanged: (String? v) => setStateDialog(() => location = v),
                    ),
                    const SizedBox(height: 10),
                    _dialogPickField(
                      label: 'Category',
                      options: _categories,
                      value: category,
                      onChanged: (String? v) => setStateDialog(() => category = v),
                    ),
                    const SizedBox(height: 10),
                    _dialogPickField(
                      label: 'Utility Type',
                      options: _utilityTypes,
                      value: utilityType,
                      onChanged: (String? v) => setStateDialog(() => utilityType = v),
                    ),
                    const SizedBox(height: 10),
                    _dialogPickField(
                      label: 'Status',
                      options: _statuses,
                      value: status,
                      onChanged: (String? v) => setStateDialog(() => status = v),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    apply = true;
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
    if (!apply || !mounted) {
      return;
    }
    setState(() {
      _selectedLocation = location;
      _selectedCategory = category;
      _selectedUtilityType = utilityType;
      _selectedStatus = status;
      _utilityPage = 0;
    });
  }

  Widget _dialogPickField({
    required String label,
    required List<_FilterOption> options,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String selectedLabel = value == null
        ? 'All'
        : options
                .firstWhere(
                  (_FilterOption option) => option.value == value,
                  orElse: () => _FilterOption(value: value, label: value),
                )
                .label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final String? picked = await _pickOption(
              title: label,
              options: options,
              selected: value,
            );
            if (picked != value) {
              onChanged(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: cs.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    selectedLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.expand_more_rounded, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _pickOption({
    required String title,
    required List<_FilterOption> options,
    required String? selected,
  }) async {
    return showModalBottomSheet<String?>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.72,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  'Select $title',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: options.length + 1,
                  separatorBuilder: (BuildContext context, int index) => Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return ListTile(
                        title: const Text('All', textAlign: TextAlign.center),
                        trailing: selected == null
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(null),
                      );
                    }
                    final _FilterOption option = options[index - 1];
                    final bool isSelected = option.value == selected;
                    return ListTile(
                      title: Text(option.label, textAlign: TextAlign.center),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(option.value),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedLocation = null;
      _selectedCategory = null;
      _selectedUtilityType = null;
      _selectedStatus = null;
      _utilityPage = 0;
    });
  }

  Future<void> _showAddComingSoon() async {
    final bool? added = await context.pushNamed<bool>(AddUtilityShiftingFormPage.routeName);
    if (added == true && mounted) {
      await _loadAll();
    }
  }

  Future<void> _openEditUtility(Map<String, dynamic> row) async {
    final String id = _string(row['utility_shifting_id']);
    if (id.isEmpty) {
      return;
    }
    final bool? saved = await context.pushNamed<bool>(
      AddUtilityShiftingFormPage.routeName,
      queryParameters: <String, String>{'utility_shifting_id': id},
    );
    if (saved == true && mounted) {
      await _loadAll();
    }
  }

  Future<void> _uploadTemplatePlaceholder() async {
    try {
      final FilePickerResult? picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['xlsx'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) {
        return;
      }
      final PlatformFile file = picked.files.single;
      final Uint8List? bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        await AppDialog.show(
          context: context,
          title: 'Upload Failed',
          message: 'Unable to read selected file bytes.',
          type: AppDialogType.error,
        );
        return;
      }
      setState(() => _loading = true);
      final Map<String, dynamic> response =
          await widget.dataSource.uploadUtilityShiftingTemplate(
        fileName: file.name,
        bytes: bytes,
      );
      if (!mounted) return;
      final String message =
          _safe(response['message']) ?? 'Template uploaded successfully.';
      await AppDialog.show(
        context: context,
        title: 'Upload Result',
        message: message,
        type: AppDialogType.success,
      );
      await _loadAll();
    } catch (error) {
      if (!mounted) return;
      await AppDialog.show(
        context: context,
        title: 'Upload Failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _confirmExportUtility(List<Map<String, dynamic>> rows) async {
    await AppDialog.show(
      context: context,
      title: 'Export to Excel',
      message: 'Download current Utility Shifting records to Excel?',
      type: AppDialogType.confirmation,
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Export',
          isPrimary: true,
          onPressed: () => _exportUtilityExcel(rows),
        ),
      ],
    );
  }

  Future<void> _exportUtilityExcel(List<Map<String, dynamic>> rows) async {
    final Excel wb = Excel.createExcel();
    final Sheet sheet = wb[wb.getDefaultSheet() ?? 'Sheet1'];
    sheet.appendRow(<CellValue>[
      TextCellValue('ID'),
      TextCellValue('Description'),
      TextCellValue('Utility Type'),
      TextCellValue('Custodian'),
      TextCellValue('HOD'),
      TextCellValue('Execution Agency'),
      TextCellValue('Status'),
      TextCellValue('Last Update'),
    ]);
    for (final Map<String, dynamic> row in rows) {
      sheet.appendRow(<CellValue>[
        TextCellValue(_string(row['utility_shifting_id'])),
        TextCellValue(_string(row['utility_description'])),
        TextCellValue(_string(row['utility_type_fk'])),
        TextCellValue(_string(row['custodian'])),
        TextCellValue(_string(row['user_name'])),
        TextCellValue(_string(row['execution_agency_fk'])),
        TextCellValue(_string(row['shifting_status_fk'])),
        TextCellValue(_string(row['modified_date'])),
      ]);
    }
    final List<int>? bytes = wb.encode();
    if (bytes == null || bytes.isEmpty) {
      return;
    }
    final String path = await _saveExportFile(
      fileName: 'utility_shifting_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      bytes: Uint8List.fromList(bytes),
    );
    if (!mounted) return;
    await AppDialog.show(
      context: context,
      title: 'Excel Saved',
      message: 'File saved to:\n$path',
      type: AppDialogType.success,
    );
  }

  Future<void> _downloadUploadTemplate() async {
    try {
      final result = await widget.dataSource.downloadUtilityShiftingTemplate();
      final Uint8List bytes = result.bytes;
      if (bytes.isEmpty) {
        throw Exception('Empty template received from server.');
      }
      final String fileName = (result.fileName?.trim().isNotEmpty ?? false)
          ? result.fileName!.trim()
          : 'utility_shifting_template.xlsx';
      final String path = await _saveExportFile(
        fileName: fileName,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        bytes: bytes,
      );
      if (!mounted) return;
      await AppDialog.show(
        context: context,
        title: 'Template Downloaded',
        message: 'File saved to:\n$path',
        type: AppDialogType.success,
      );
    } catch (error) {
      if (!mounted) return;
      await AppDialog.show(
        context: context,
        title: 'Download Failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    }
  }

  Future<void> _confirmDownloadUploadTemplate() async {
    await AppDialog.show(
      context: context,
      title: 'Download Template',
      message:
          'Download the Utility Shifting template file from server?',
      type: AppDialogType.confirmation,
      leadingIcon: Icons.download_for_offline_rounded,
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Download',
          isPrimary: true,
          onPressed: _downloadUploadTemplate,
        ),
      ],
    );
  }

  Future<String> _saveExportFile({
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    if (Platform.isAndroid) {
      try {
        final String? relativePath = await _fileExportChannel.invokeMethod<String>(
          'saveToDownloads',
          <String, dynamic>{
            'fileName': fileName,
            'mimeType': mimeType,
            'bytes': bytes,
            'subdirectory': 'WCR Documents',
          },
        );
        if (relativePath != null && relativePath.isNotEmpty) {
          return relativePath;
        }
      } on MissingPluginException {
      } on PlatformException {
      }
    }
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  _PageSlice _slice(List<Map<String, dynamic>> all, {required int page, required int pageSize}) {
    final int total = all.length;
    final int pageCount = total == 0 ? 1 : (total / pageSize).ceil();
    final int safePage = page.clamp(0, pageCount - 1);
    final int start = total == 0 ? 0 : (safePage * pageSize);
    final int end = total == 0 ? 0 : (start + pageSize).clamp(0, total);
    final List<Map<String, dynamic>> rows = total == 0
        ? const <Map<String, dynamic>>[]
        : all.sublist(start, end);
    return _PageSlice(
      rows: rows,
      start: total == 0 ? 0 : start + 1,
      end: end,
      page: total == 0 ? 0 : safePage + 1,
      pageCount: pageCount,
    );
  }

  List<Map<String, dynamic>> _rowsFromData(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] as List<dynamic>? ?? <dynamic>[];
    return data
        .whereType<Map>()
        .map(
          (Map row) => row.map(
            (dynamic key, dynamic value) => MapEntry(key.toString(), value),
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> _rowsFromAaData(Map<String, dynamic> json) {
    final List<dynamic> data = json['aaData'] as List<dynamic>? ?? <dynamic>[];
    return data
        .whereType<Map>()
        .map(
          (Map row) => row.map(
            (dynamic key, dynamic value) => MapEntry(key.toString(), value),
          ),
        )
        .toList();
  }

  List<_FilterOption> _dedupeOptions(Iterable<_FilterOption> options) {
    final Map<String, _FilterOption> map = <String, _FilterOption>{};
    for (final _FilterOption item in options) {
      if (item.value.isEmpty) continue;
      map.putIfAbsent(item.value, () => item);
    }
    final List<_FilterOption> values = map.values.toList()
      ..sort((_FilterOption a, _FilterOption b) => a.label.compareTo(b.label));
    return values;
  }

  String? _retain(String? value, List<_FilterOption> options) {
    if (value == null) return null;
    return options.any((_FilterOption option) => option.value == value) ? value : null;
  }

  int get _activeFilterCount {
    int c = 0;
    if (_selectedLocation != null) c++;
    if (_selectedCategory != null) c++;
    if (_selectedUtilityType != null) c++;
    if (_selectedStatus != null) c++;
    return c;
  }

  String _string(dynamic value) => _safe(value) ?? '-';

  String? _safe(dynamic value) {
    if (value == null) return null;
    final String text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }
}

class _FilterOption {
  const _FilterOption({required this.value, required this.label});

  final String value;
  final String label;
}

class _ActionSpec {
  const _ActionSpec({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tonal = false,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool tonal;
  final bool filled;
}

class _PageSlice {
  const _PageSlice({
    required this.rows,
    required this.start,
    required this.end,
    required this.page,
    required this.pageCount,
  });

  final List<Map<String, dynamic>> rows;
  final int start;
  final int end;
  final int page;
  final int pageCount;
}
