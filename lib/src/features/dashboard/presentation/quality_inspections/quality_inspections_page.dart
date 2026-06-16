import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_toolbar_table_scaffold_body.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/quality_inspection_user_access.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/quality_inspections/add_quality_inspection_form_page.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

class QualityInspectionsPage extends ConsumerStatefulWidget {
  const QualityInspectionsPage({super.key, required this.dataSource});

  static const String routeName = 'quality-inspections';
  static const String routePath = '/quality-inspections';

  final DashboardRemoteDataSource dataSource;

  @override
  ConsumerState<QualityInspectionsPage> createState() =>
      _QualityInspectionsPageState();
}

class _QualityInspectionsPageState extends ConsumerState<QualityInspectionsPage> {
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50, 100];
  static const List<String> _headers = <String>[
    'Inspection ID',
    'Project',
    'Section',
    'Contract',
    'Structure Type',
    'Structure',
    'Item',
    'Location',
    'Test Subcategory',
    'NCR Compliance',
    'NCR Date',
    'Closed On',
    'Status',
    'View/Edit',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  String? _selectedProjectId;
  String? _selectedSectionId;
  String? _selectedContractId;
  String? _selectedStructureType;
  String? _selectedStructure;

  int _pageSize = 10;
  int _currentPage = 0;

  bool _loading = true;
  bool _listLoaded = false;
  bool _filtersLoading = false;
  String? _loadError;
  String? _filtersLoadError;

  List<Map<String, dynamic>> _allRows = <Map<String, dynamic>>[];

  List<_FilterOption> _projectOptions = <_FilterOption>[];
  List<_FilterOption> _sectionOptions = <_FilterOption>[];
  List<_FilterOption> _contractOptions = <_FilterOption>[];
  List<_FilterOption> _structureTypeOptions = <_FilterOption>[];
  List<_FilterOption> _structureOptions = <_FilterOption>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadFilters();
      if (mounted) {
        await _loadList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedProjectId != null) count++;
    if (_selectedSectionId != null) count++;
    if (_selectedContractId != null) count++;
    if (_selectedStructureType != null) count++;
    if (_selectedStructure != null) count++;
    return count;
  }

  Map<String, dynamic> get _listFilterPayload {
    final Map<String, dynamic> payload = <String, dynamic>{};
    if (_selectedProjectId != null) {
      payload['project_id_fk'] = _selectedProjectId;
    }
    if (_selectedSectionId != null) {
      final int? sectionId = int.tryParse(_selectedSectionId!);
      payload['section_id_fk'] = sectionId ?? _selectedSectionId;
    }
    if (_selectedContractId != null) {
      payload['contract_id_fk'] = _selectedContractId;
    }
    if (_selectedStructureType != null) {
      payload['structure_type_fk'] = _selectedStructureType;
    }
    if (_selectedStructure != null) {
      payload['structure'] = _selectedStructure;
    }
    return payload;
  }

  Future<void> _loadFilters() async {
    setState(() {
      _filtersLoading = true;
      _filtersLoadError = null;
    });
    try {
      final List<dynamic> results = await Future.wait<dynamic>(
        <Future<Map<String, dynamic>>>[
          widget.dataSource.fetchQualityInspectionProjectFilter(),
          widget.dataSource.fetchQualityInspectionSectionFilter(),
          widget.dataSource.fetchQualityInspectionContractFilter(),
          widget.dataSource.fetchQualityInspectionStructureTypeFilter(),
          widget.dataSource.fetchQualityInspectionStructureFilter(),
        ],
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _projectOptions = _parseProjectFilterOptions(
          _parseFilterRows(results[0] as Map<String, dynamic>),
        );
        _sectionOptions = _parseSectionFilterOptions(
          _parseFilterRows(results[1] as Map<String, dynamic>),
        );
        _contractOptions = _parseContractFilterOptions(
          _parseFilterRows(results[2] as Map<String, dynamic>),
        );
        _structureTypeOptions = _parseStructureTypeFilterOptions(
          _parseFilterRows(results[3] as Map<String, dynamic>),
        );
        _structureOptions = _parseStructureFilterOptions(
          _parseFilterRows(results[4] as Map<String, dynamic>),
        );
        _filtersLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _filtersLoading = false;
        _filtersLoadError = userFriendlyErrorMessage(error);
      });
    }
  }

  Future<void> _loadList() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final Map<String, dynamic> response =
          await widget.dataSource.fetchQualityInspectionList(
            filters: _listFilterPayload,
          );
      final List<Map<String, dynamic>> rows = _parseInspectionRows(response);
      if (!mounted) {
        return;
      }
      setState(() {
        _allRows = rows;
        _loading = false;
        _listLoaded = true;
        _loadError = null;
        _currentPage = 0;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _listLoaded = true;
        _loadError = userFriendlyErrorMessage(error);
        _allRows = <Map<String, dynamic>>[];
      });
    }
  }

  List<Map<String, dynamic>> _parseInspectionRows(
    Map<String, dynamic> response,
  ) {
    final dynamic raw = response['data'] ?? response['result'] ?? response;
    if (raw is! List) {
      return const <Map<String, dynamic>>[];
    }
    return raw
        .whereType<Map>()
        .map(
          (Map<dynamic, dynamic> item) => Map<String, dynamic>.from(
            item.map(
              (dynamic key, dynamic value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> _parseFilterRows(Map<String, dynamic> response) {
    final dynamic raw = response['data'] ?? response['result'] ?? response;
    if (raw is! List) {
      return const <Map<String, dynamic>>[];
    }
    return raw
        .whereType<Map>()
        .map(
          (Map<dynamic, dynamic> item) => Map<String, dynamic>.from(
            item.map(
              (dynamic key, dynamic value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .toList();
  }

  List<_FilterOption> _parseProjectFilterOptions(
    List<Map<String, dynamic>> rows,
  ) {
    final List<_FilterOption> options = <_FilterOption>[];
    final Set<String> seen = <String>{};
    for (final Map<String, dynamic> row in rows) {
      final String id = _string(row['project_id_fk']);
      final String label = _string(row['project_name']);
      if (id.isEmpty || label.isEmpty || seen.contains(id)) {
        continue;
      }
      seen.add(id);
      options.add(_FilterOption(value: id, label: label));
    }
    options.sort(
      ( _FilterOption a, _FilterOption b) => a.label.compareTo(b.label),
    );
    return options;
  }

  List<_FilterOption> _parseSectionFilterOptions(
    List<Map<String, dynamic>> rows,
  ) {
    final List<_FilterOption> options = <_FilterOption>[];
    final Set<String> seen = <String>{};
    for (final Map<String, dynamic> row in rows) {
      final dynamic rawId = row['section_id_fk'];
      if (rawId == null) {
        continue;
      }
      final String id = rawId.toString().trim();
      final String label = _string(row['section_name']);
      if (id.isEmpty || label.isEmpty || seen.contains(id)) {
        continue;
      }
      seen.add(id);
      options.add(_FilterOption(value: id, label: label));
    }
    options.sort(
      ( _FilterOption a, _FilterOption b) => a.label.compareTo(b.label),
    );
    return options;
  }

  List<_FilterOption> _parseContractFilterOptions(
    List<Map<String, dynamic>> rows,
  ) {
    final List<_FilterOption> options = <_FilterOption>[];
    final Set<String> seen = <String>{};
    for (final Map<String, dynamic> row in rows) {
      final String id = _string(row['contract_id_fk']);
      final String label = _string(row['contract_short_name']);
      if (id.isEmpty || label.isEmpty || seen.contains(id)) {
        continue;
      }
      seen.add(id);
      options.add(_FilterOption(value: id, label: label));
    }
    options.sort(
      ( _FilterOption a, _FilterOption b) => a.label.compareTo(b.label),
    );
    return options;
  }

  List<_FilterOption> _parseStructureTypeFilterOptions(
    List<Map<String, dynamic>> rows,
  ) {
    final List<_FilterOption> options = <_FilterOption>[];
    final Set<String> seen = <String>{};
    for (final Map<String, dynamic> row in rows) {
      final String value = _string(row['structure_type_fk']);
      if (value.isEmpty || seen.contains(value)) {
        continue;
      }
      seen.add(value);
      options.add(_FilterOption(value: value, label: value));
    }
    options.sort(
      ( _FilterOption a, _FilterOption b) => a.label.compareTo(b.label),
    );
    return options;
  }

  List<_FilterOption> _parseStructureFilterOptions(
    List<Map<String, dynamic>> rows,
  ) {
    final List<_FilterOption> options = <_FilterOption>[];
    final Set<String> seen = <String>{};
    for (final Map<String, dynamic> row in rows) {
      final String value = _string(row['structure']);
      if (value.isEmpty || seen.contains(value)) {
        continue;
      }
      seen.add(value);
      options.add(_FilterOption(value: value, label: value));
    }
    options.sort(
      ( _FilterOption a, _FilterOption b) => a.label.compareTo(b.label),
    );
    return options;
  }

  List<Map<String, dynamic>> get _filteredRows {
    final String query = _search.trim().toLowerCase();
    if (query.isEmpty) {
      return _allRows;
    }
    return _allRows
        .where(
          (Map<String, dynamic> row) => row.values.any(
            (dynamic value) => _string(value).toLowerCase().contains(query),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filteredRows = _filteredRows;
    final int total = filteredRows.length;
    final int pageCount = total == 0 ? 1 : (total / _pageSize).ceil();
    if (_currentPage >= pageCount) {
      _currentPage = pageCount - 1;
    }
    final int start = total == 0 ? 0 : (_currentPage * _pageSize);
    final int end = total == 0 ? 0 : (start + _pageSize).clamp(0, total);
    final List<Map<String, dynamic>> pageRows = total == 0
        ? const <Map<String, dynamic>>[]
        : filteredRows.sublist(start, end);

    return Scaffold(
      appBar: AppBar(title: const Text('Quality Inspections')),
      bottomNavigationBar: _stickyFooter(
        total: total,
        start: start,
        end: end,
        loading: _loading,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              if (_loadError != null) ...<Widget>[
                MaterialBanner(
                  content: const Text(
                    'Unable to load inspections. Tap retry to try again.',
                  ),
                  actions: <Widget>[
                    TextButton(onPressed: _loadList, child: const Text('Retry')),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Expanded(
                child: AppToolbarTableScaffoldBody(
                  padding: EdgeInsets.zero,
                  toolbar: _toolbar(context, filteredRows),
                  table: _tableCard(context, pageRows),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolbar(BuildContext context, List<Map<String, dynamic>> rows) {
    final int activeFilterCount = _activeFilterCount;
    final Widget searchField = SizedBox(
      width: double.infinity,
      child: TextField(
        controller: _searchController,
        onChanged: (String value) => setState(() {
          _search = value.trim();
          _currentPage = 0;
        }),
        decoration: InputDecoration(
          hintText: 'Search',
          isDense: true,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear',
                  onPressed: () => setState(() {
                    _searchController.clear();
                    _search = '';
                    _currentPage = 0;
                  }),
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            searchField,
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _openFilterDialog,
                          icon: const Icon(Icons.filter_alt_rounded),
                          label: Text(
                            activeFilterCount == 0
                                ? 'Filter'
                                : 'Filter ($activeFilterCount)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              activeFilterCount > 0 ? _clearFilters : null,
                          icon: const Icon(Icons.filter_alt_off_rounded),
                          label: const Text('Clear filter'),
                        ),
                      ),
                    ],
                  ),
                  if (ref.watch(qualityInspectionAccessProvider).canCreateInspection) ...<Widget>[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _onAddTap,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableCard(BuildContext context, List<Map<String, dynamic>> rows) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double tableWidth = _headers.fold<double>(
      0,
      (double sum, String item) => sum + _columnWidth(item),
    );

    if (_loading || !_listLoaded) {
      return Card(
        margin: EdgeInsets.zero,
        child: _loadingPlaceholder(context),
      );
    }

    if (rows.isEmpty &&
        _search.isEmpty &&
        _activeFilterCount == 0 &&
        _loadError == null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No quality inspection records found.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: constraints.maxHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: <Widget>[
                    _tableHeader(context),
                    Expanded(
                      child: rows.isEmpty
                          ? Center(
                              child: Text(
                                'No records match your search or filters.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 10),
                              itemCount: rows.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  _tableRow(
                                context,
                                rows[index],
                                index,
                                isLast: index == rows.length - 1,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tableHeader(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: _headers
            .map(
              (String title) => _cell(
                title,
                width: _columnWidth(title),
                color: colorScheme.onPrimary,
                weight: FontWeight.w700,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _tableRow(
    BuildContext context,
    Map<String, dynamic> row,
    int index, {
    bool isLast = false,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color bg = index.isEven
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.surface;
    final BorderRadius? rowRadius = isLast
        ? const BorderRadius.vertical(bottom: Radius.circular(14))
        : null;

    return ClipRRect(
      borderRadius: rowRadius ?? BorderRadius.zero,
      child: Container(
        color: bg,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: <Widget>[
            _cell(
              _displayInspectionId(row),
              width: _columnWidth('Inspection ID'),
            ),
            _cell(_string(row['project_name']), width: _columnWidth('Project')),
            _cell(_string(row['section_name']), width: _columnWidth('Section')),
            _cell(
              _string(row['contract_short_name']),
              width: _columnWidth('Contract'),
            ),
            _cell(
              _string(row['structure_type_fk']),
              width: _columnWidth('Structure Type'),
            ),
            _cell(_string(row['structure']), width: _columnWidth('Structure')),
            _cell(_string(row['item_name']), width: _columnWidth('Item')),
            _cell(_string(row['location']), width: _columnWidth('Location')),
            _cell(
              _string(row['sub_category']),
              width: _columnWidth('Test Subcategory'),
            ),
            _cell(
              _string(row['ncr_compliance']),
              width: _columnWidth('NCR Compliance'),
            ),
            _cell(_formatDate(row['ncr_date']), width: _columnWidth('NCR Date')),
            _cell(
              _formatDate(row['closed_on']),
              width: _columnWidth('Closed On'),
            ),
            _cell(
              _string(row['inspection_status']),
              width: _columnWidth('Status'),
            ),
            SizedBox(
              width: _columnWidth('View/Edit'),
              child: Center(
                child: _buildRowAction(context, row, colorScheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(
    String value, {
    required double width,
    Color? color,
    FontWeight weight = FontWeight.w600,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          value.isEmpty ? '-' : value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontWeight: weight, fontSize: 13),
        ),
      ),
    );
  }

  Widget _loadingPlaceholder(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading quality inspections...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stickyFooter({
    required int total,
    required int start,
    required int end,
    required bool loading,
  }) {
    if (loading || !_listLoaded) {
      final ColorScheme cs = Theme.of(context).colorScheme;
      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(
              top: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
          child: Text(
            'Loading...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final int pageCount = total == 0 ? 1 : (total / _pageSize).ceil();
    return AppTablePaginationFooter(
      total: total,
      startIndex: start,
      endIndex: end,
      currentPage: _currentPage,
      pageCount: pageCount,
      pageSize: _pageSize,
      pageSizeOptions: _pageSizeOptions,
      onPageSizeChanged: (int value) => setState(() {
        _pageSize = value;
        _currentPage = 0;
      }),
      onPrevious: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
      onNext: end < total ? () => setState(() => _currentPage++) : null,
    );
  }

  Future<void> _clearFilters() async {
    setState(() {
      _selectedProjectId = null;
      _selectedSectionId = null;
      _selectedContractId = null;
      _selectedStructureType = null;
      _selectedStructure = null;
      _currentPage = 0;
    });
    await _loadList();
  }

  Future<void> _openFilterDialog() async {
    if (_filtersLoadError != null || _projectOptions.isEmpty) {
      await _loadFilters();
    }
    if (!mounted) {
      return;
    }
    String? dialogProject = _selectedProjectId;
    String? dialogSection = _selectedSectionId;
    String? dialogContract = _selectedContractId;
    String? dialogStructureType = _selectedStructureType;
    String? dialogStructure = _selectedStructure;
    bool shouldApply = false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Filter'),
              content: SingleChildScrollView(
                child: _filtersLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (_filtersLoadError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Unable to load filter options.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                              ),
                            ),
                          _dialogPickField(
                            label: 'Project',
                            options: _projectOptions,
                            value: dialogProject,
                            onChanged: (String? value) =>
                                setDialogState(() => dialogProject = value),
                          ),
                          const SizedBox(height: 10),
                          _dialogPickField(
                            label: 'Section',
                            options: _sectionOptions,
                            value: dialogSection,
                            onChanged: (String? value) =>
                                setDialogState(() => dialogSection = value),
                          ),
                          const SizedBox(height: 10),
                          _dialogPickField(
                            label: 'Contract',
                            options: _contractOptions,
                            value: dialogContract,
                            onChanged: (String? value) =>
                                setDialogState(() => dialogContract = value),
                          ),
                          const SizedBox(height: 10),
                          _dialogPickField(
                            label: 'Structure Type',
                            options: _structureTypeOptions,
                            value: dialogStructureType,
                            onChanged: (String? value) => setDialogState(
                              () => dialogStructureType = value,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _dialogPickField(
                            label: 'Structure',
                            options: _structureOptions,
                            value: dialogStructure,
                            onChanged: (String? value) =>
                                setDialogState(() => dialogStructure = value),
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
                    shouldApply = true;
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

    if (!shouldApply || !mounted) return;
    setState(() {
      _selectedProjectId = dialogProject;
      _selectedSectionId = dialogSection;
      _selectedContractId = dialogContract;
      _selectedStructureType = dialogStructureType;
      _selectedStructure = dialogStructure;
      _currentPage = 0;
    });
    await _loadList();
  }

  Widget _dialogPickField({
    required String label,
    required List<_FilterOption> options,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final String selectedLabel = value == null
        ? 'All'
        : options
            .firstWhere(
              (_FilterOption o) => o.value == value,
              orElse: () => _FilterOption(value: value, label: value),
            )
            .label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final String? picked = await showModalBottomSheet<String>(
              context: context,
              useSafeArea: true,
              showDragHandle: true,
              builder: (BuildContext context) {
                return ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    ListTile(
                      title: const Text('All'),
                      trailing: value == null
                          ? const Icon(Icons.check_rounded)
                          : null,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    ...options.map(
                      (_FilterOption option) => ListTile(
                        title: Text(option.label),
                        trailing: value == option.value
                            ? const Icon(Icons.check_rounded)
                            : null,
                        onTap: () => Navigator.of(context).pop(option.value),
                      ),
                    ),
                  ],
                );
              },
            );
            onChanged(picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.expand_more_rounded),
            ),
            child: Text(selectedLabel),
          ),
        ),
      ],
    );
  }

  Future<void> _onAddTap() async {
    final QualityInspectionUserAccess access =
        ref.read(qualityInspectionAccessProvider);
    if (!access.canCreateInspection) {
      await AppDialog.show(
        context: context,
        title: 'Not allowed',
        message: 'Only DyHOD and Officers can create quality inspections.',
        type: AppDialogType.info,
      );
      return;
    }
    final bool? saved = await context.pushNamed<bool>(
      AddQualityInspectionFormPage.routeName,
    );
    if (saved == true && mounted) {
      await _loadList();
    }
  }

  Widget? _buildRowAction(
    BuildContext context,
    Map<String, dynamic> row,
    ColorScheme colorScheme,
  ) {
    final QualityInspectionUserAccess access =
        ref.watch(qualityInspectionAccessProvider);
    final int step = QualityInspectionUserAccess.resolveWorkflowStep(row);
    if (!access.canOpenInspection(step)) {
      return null;
    }
    final bool canWork = access.canWorkOnWorkflowStep(step);
    return IconButton(
      tooltip: canWork ? 'View/Edit' : 'View',
      onPressed: () => _onEditTap(row, step),
      icon: Icon(
        canWork ? Icons.edit_square : Icons.visibility_outlined,
        color: colorScheme.primary,
      ),
    );
  }

  Future<void> _onEditTap(Map<String, dynamic> row, int workflowStep) async {
    final QualityInspectionUserAccess access =
        ref.read(qualityInspectionAccessProvider);
    if (!access.canOpenInspection(workflowStep)) {
      await AppDialog.show(
        context: context,
        title: 'Not allowed',
        message: _permissionMessageForStep(workflowStep),
        type: AppDialogType.info,
      );
      return;
    }
    final String id = _string(row['inspection_id']);
    if (id.isEmpty) {
      await AppDialog.show(
        context: context,
        title: 'Edit Quality Inspection',
        message: 'Inspection id is missing for this row.',
        type: AppDialogType.error,
      );
      return;
    }
    final bool? saved = await context.pushNamed<bool>(
      AddQualityInspectionFormPage.routeName,
      queryParameters: <String, String>{'inspection_id': id},
    );
    if (saved == true && mounted) {
      await _loadList();
    }
  }

  String _permissionMessageForStep(int step) {
    switch (step) {
      case 1:
        return 'Only DyHOD and Officers can create quality inspections.';
      case 2:
        return 'Only DyHOD and Officers can raise NCR.';
      case 3:
        return 'Only Contractor and Contractor Rep can respond to raised NCR.';
      case 4:
        return 'Only DyHOD and Officers can close this inspection.';
      case 5:
        return 'This inspection is passed and is view only.';
      default:
        return 'You do not have permission for this action.';
    }
  }


  double _columnWidth(String header) {
    switch (header) {
      case 'Inspection ID':
        return 200;
      case 'Project':
        return 220;
      case 'Section':
        return 120;
      case 'Contract':
        return 280;
      case 'Structure Type':
        return 110;
      case 'Structure':
        return 90;
      case 'Item':
        return 100;
      case 'Location':
        return 100;
      case 'Test Subcategory':
        return 140;
      case 'NCR Compliance':
        return 120;
      case 'NCR Date':
        return 110;
      case 'Closed On':
        return 110;
      case 'Status':
        return 100;
      case 'View/Edit':
        return 80;
      default:
        return 120;
    }
  }

  String _displayInspectionId(Map<String, dynamic> row) {
    final String inspectionNo = _string(row['inspection_no']);
    if (inspectionNo.isNotEmpty) {
      return inspectionNo;
    }
    return _string(row['inspection_id']);
  }

  String _formatDate(dynamic value) {
    final String text = _string(value);
    if (text.isEmpty) {
      return '';
    }
    final DateTime? parsed = DateTime.tryParse(text);
    if (parsed == null) {
      return text;
    }
    final String day = parsed.day.toString().padLeft(2, '0');
    final String month = parsed.month.toString().padLeft(2, '0');
    return '$day-$month-${parsed.year}';
  }

  String _string(dynamic value) {
    if (value == null) return '';
    final String text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }

}

class _FilterOption {
  const _FilterOption({required this.value, required this.label});

  final String value;
  final String label;
}
