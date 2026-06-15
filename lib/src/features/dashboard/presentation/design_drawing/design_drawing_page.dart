import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/structures/widgets/structure_document_preview_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

class DesignDrawingPage extends StatefulWidget {
  const DesignDrawingPage({super.key, required this.dataSource});

  static const String routeName = 'design-drawing';
  static const String routePath = '/design-drawing';

  final DashboardRemoteDataSource dataSource;

  @override
  State<DesignDrawingPage> createState() => _DesignDrawingPageState();
}

class _DesignDrawingPageState extends State<DesignDrawingPage>
    with SingleTickerProviderStateMixin {
  static const List<int> _pageSizes = <int>[5, 10, 25, 50, 100];

  late final TabController _tabController;
  Timer? _designSearchDebounce;
  bool _loading = false;

  final TextEditingController _designSearchCtrl = TextEditingController();
  final TextEditingController _uploadSearchCtrl = TextEditingController();

  String _designSearch = '';
  String _uploadSearch = '';
  int _designPageSize = 10;
  int _uploadPageSize = 10;
  int _designPage = 0;
  int _uploadPage = 0;
  int _designTotal = 0;

  String? _selectedContract;
  String? _selectedStructureType;
  String? _selectedDrawingType;

  List<Map<String, dynamic>> _designRows = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _uploadRows = <Map<String, dynamic>>[];

  List<_FilterOption> _contractOptions = <_FilterOption>[];
  List<_FilterOption> _structureTypeOptions = <_FilterOption>[];
  List<_FilterOption> _drawingTypeOptions = <_FilterOption>[];

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
    _designSearchDebounce?.cancel();
    _tabController.dispose();
    _designSearchCtrl.dispose();
    _uploadSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filteredUploads = _filteredUploadRows();
    final _PageSlice uploadSlice = _slice(
      filteredUploads,
      page: _uploadPage,
      pageSize: _uploadPageSize,
    );
    final int designPageCount =
        _designTotal == 0 ? 1 : (_designTotal / _designPageSize).ceil();
    final int designStart =
        _designTotal == 0 ? 0 : (_designPage * _designPageSize) + 1;
    final int designEnd = _designTotal == 0
        ? 0
        : ((_designPage + 1) * _designPageSize).clamp(0, _designTotal);

    final ThemeData theme = Theme.of(context);
    final Color appBarForeground =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design & Drawing'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: appBarForeground,
          unselectedLabelColor: appBarForeground.withValues(alpha: 0.72),
          indicatorColor: appBarForeground,
          dividerColor: appBarForeground.withValues(alpha: 0.22),
          tabs: const <Tab>[
            Tab(text: 'Update Design & Drawing'),
            Tab(text: 'Uploaded Design Data'),
          ],
        ),
      ),
      bottomNavigationBar: _tabController.index == 0
          ? _stickyFooter(
              total: _designTotal,
              start: designStart,
              end: designEnd,
              page: _designTotal == 0 ? 0 : _designPage + 1,
              pageCount: designPageCount,
              onPrev: _designPage > 0
                  ? () {
                      setState(() => _designPage -= 1);
                      _loadDesigns();
                    }
                  : null,
              onNext: _designPage + 1 < designPageCount
                  ? () {
                      setState(() => _designPage += 1);
                      _loadDesigns();
                    }
                  : null,
            )
          : _stickyFooter(
              total: filteredUploads.length,
              start: uploadSlice.start,
              end: uploadSlice.end,
              page: uploadSlice.page,
              pageCount: uploadSlice.pageCount,
              onPrev: uploadSlice.page > 1
                  ? () => setState(() => _uploadPage = uploadSlice.page - 2)
                  : null,
              onNext: uploadSlice.page < uploadSlice.pageCount
                  ? () => setState(() => _uploadPage = uploadSlice.page)
                  : null,
            ),
      body: Stack(
        children: <Widget>[
          TabBarView(
            controller: _tabController,
            children: <Widget>[
              _designTab(),
              _uploadsTab(uploadSlice.rows),
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

  Widget _designTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: <Widget>[
          _designToolbar(),
          const SizedBox(height: 10),
          Expanded(child: _designTable(_designRows)),
        ],
      ),
    );
  }

  Widget _designToolbar() {
    final bool narrow = MediaQuery.sizeOf(context).width < 720;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppSelectSheetField<_FilterOption>(
              label: 'Contract',
              title: 'Select Contract',
              items: _contractOptions,
              value: _selectedContractOption,
              itemLabelBuilder: (_FilterOption option) => option.label,
              onChanged: (_FilterOption option) => _onContractChanged(option.value),
              placeholderText: 'Select',
              compact: true,
            ),
            const SizedBox(height: 10),
            AppSelectSheetField<_FilterOption>(
              label: 'Structure Type',
              title: 'Select Structure Type',
              items: _structureTypeOptions,
              value: _selectedStructureTypeOption,
              itemLabelBuilder: (_FilterOption option) => option.label,
              onChanged: (_FilterOption option) =>
                  _onStructureTypeChanged(option.value),
              placeholderText: 'Select',
              compact: true,
            ),
            const SizedBox(height: 10),
            AppSelectSheetField<_FilterOption>(
              label: 'Drawing Type',
              title: 'Select Drawing Type',
              items: _drawingTypeOptions,
              value: _selectedDrawingTypeOption,
              itemLabelBuilder: (_FilterOption option) => option.label,
              onChanged: (_FilterOption option) =>
                  _onDrawingTypeChanged(option.value),
              placeholderText: 'Select',
              compact: true,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _activeFilterCount > 0 ? _clearFilters : null,
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: const Text('Clear Filter'),
              ),
            ),
            const SizedBox(height: 10),
            narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _designSearchField(),
                      const SizedBox(height: 8),
                      _entriesDropdown(
                        value: _designPageSize,
                        onChanged: (int value) {
                          setState(() {
                            _designPageSize = value;
                            _designPage = 0;
                          });
                          _loadDesigns();
                        },
                      ),
                    ],
                  )
                : Row(
                    children: <Widget>[
                      Expanded(child: _designSearchField()),
                      const SizedBox(width: 12),
                      _entriesDropdown(
                        value: _designPageSize,
                        onChanged: (int value) {
                          setState(() {
                            _designPageSize = value;
                            _designPage = 0;
                          });
                          _loadDesigns();
                        },
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _designSearchField() {
    return TextField(
      controller: _designSearchCtrl,
      onChanged: _onDesignSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search designs...',
        isDense: true,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _designSearch.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _designSearchCtrl.clear();
                  _onDesignSearchChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _entriesDropdown({
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text('Show ', style: TextStyle(fontSize: 12)),
        DropdownButton<int>(
          value: value,
          items: _pageSizes
              .map(
                (int size) => DropdownMenuItem<int>(
                  value: size,
                  child: Text('$size'),
                ),
              )
              .toList(),
          onChanged: (int? next) {
            if (next != null) {
              onChanged(next);
            }
          },
        ),
        const Text(' entries', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _designTable(List<Map<String, dynamic>> rows) {
    const List<String> headers = <String>[
      'PMIS Drawing No.',
      'Structure Type',
      'Structure',
      'Title',
      'Drawing Type',
      'Drawing No',
      'Last Update',
      'Actions',
    ];
    return _tableShell(
      headers: headers,
      rowCount: rows.length,
      emptyText: 'No design records found.',
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
              _cell(_string(row['design_seq_id']), 220),
              _cell(_string(row['structure_type_fk']), 120),
              _cell(_string(row['structure_id_fk']), 150),
              _cell(_string(row['drawing_title']), 220),
              _cell(_string(row['drawing_type_fk']), 120),
              _cell(_string(row['drawing_no']), 110),
              _cell(_string(row['modified_date']), 110),
              SizedBox(
                width: 72,
                child: IconButton(
                  tooltip: 'Edit',
                  onPressed: () => _showComingSoon('Edit design'),
                  icon: Icon(Icons.edit_note_rounded, color: cs.primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _uploadsTab(List<Map<String, dynamic>> rows) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _uploadSearchCtrl,
                    onChanged: (String value) => setState(() {
                      _uploadSearch = value.trim();
                      _uploadPage = 0;
                    }),
                    decoration: InputDecoration(
                      hintText: 'Search uploads...',
                      isDense: true,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _uploadSearch.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _uploadSearchCtrl.clear();
                                setState(() {
                                  _uploadSearch = '';
                                  _uploadPage = 0;
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
                      _entriesDropdown(
                        value: _uploadPageSize,
                        onChanged: (int value) => setState(() {
                          _uploadPageSize = value;
                          _uploadPage = 0;
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: _uploadsTable(rows)),
        ],
      ),
    );
  }

  Widget _uploadsTable(List<Map<String, dynamic>> rows) {
    const List<String> headers = <String>[
      'Uploaded File',
      'Status',
      'Remarks',
      'Uploaded By',
      'Uploaded On',
    ];
    return _tableShell(
      headers: headers,
      rowCount: rows.length,
      emptyText: 'No uploaded design data found.',
      rowBuilder: (BuildContext context, int index) {
        final Map<String, dynamic> row = rows[index];
        final ColorScheme cs = Theme.of(context).colorScheme;
        final Color bg = index.isEven
            ? cs.primary.withValues(alpha: 0.08)
            : cs.surface;
        final String fileName = _string(row['uploaded_file']);
        final String status = _string(row['status']);
        return Container(
          color: bg,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 260,
                child: InkWell(
                  onTap: fileName == '-'
                      ? null
                      : () => _openUploadedFile(row),
                  child: Text(
                    fileName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: fileName == '-'
                          ? cs.onSurface
                          : cs.primary,
                      decoration: fileName == '-'
                          ? TextDecoration.none
                          : TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _statusCell(status, 100),
              _cell(_string(row['remarks']), 280),
              _cell(_string(row['uploaded_by_user_id_fk']), 130),
              _cell(_formatUploadedOn(row['uploaded_on']), 170),
            ],
          ),
        );
      },
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
      'PMIS Drawing No.': 220,
      'Structure Type': 120,
      'Structure': 150,
      'Title': 220,
      'Drawing Type': 120,
      'Drawing No': 110,
      'Last Update': 110,
      'Actions': 72,
      'Uploaded File': 260,
      'Status': 100,
      'Remarks': 280,
      'Uploaded By': 130,
      'Uploaded On': 170,
    };
    final double totalWidth = headers.fold<double>(
      0,
      (double sum, String header) => sum + (widths[header] ?? 120),
    );
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: rowCount == 0
          ? Center(child: Text(emptyText))
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalWidth,
                    height: constraints.maxHeight,
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: cs.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: headers
                                .map(
                                  (String header) => SizedBox(
                                    width: widths[header] ?? 120,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        header,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: cs.onPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: rowCount,
                            itemBuilder: rowBuilder,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _cell(String value, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          value,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget _statusCell(String status, double width) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String normalized = status.trim().toLowerCase();
    Color color = cs.onSurface;
    if (normalized == 'pass' || normalized == 'success') {
      color = Colors.green.shade700;
    } else if (normalized == 'fail' || normalized == 'failed') {
      color = Colors.red.shade700;
    }
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          status,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
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

  _FilterOption? get _selectedContractOption => _optionForValue(
    _contractOptions,
    _selectedContract,
  );

  _FilterOption? get _selectedStructureTypeOption => _optionForValue(
    _structureTypeOptions,
    _selectedStructureType,
  );

  _FilterOption? get _selectedDrawingTypeOption => _optionForValue(
    _drawingTypeOptions,
    _selectedDrawingType,
  );

  int get _activeFilterCount {
    int count = 0;
    if (_selectedContract != null) {
      count++;
    }
    if (_selectedStructureType != null) {
      count++;
    }
    if (_selectedDrawingType != null) {
      count++;
    }
    return count;
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      await Future.wait(<Future<void>>[
        _reloadFilters(),
        _loadDesigns(),
        _loadUploads(),
      ]);
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load design data',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _reloadFilters() async {
    final List<List<Map<String, dynamic>>> responses =
        await Future.wait<List<Map<String, dynamic>>>(
      <Future<List<Map<String, dynamic>>>>[
        widget.dataSource.fetchDesignContractFilter(
          contractIdFk: _selectedContract,
          structureTypeFk: _selectedStructureType,
          drawingTypeFk: _selectedDrawingType,
        ),
        widget.dataSource.fetchDesignStructureTypeFilter(
          contractIdFk: _selectedContract,
          structureTypeFk: _selectedStructureType,
          drawingTypeFk: _selectedDrawingType,
        ),
        widget.dataSource.fetchDesignDrawingTypeFilter(
          contractIdFk: _selectedContract,
          structureTypeFk: _selectedStructureType,
          drawingTypeFk: _selectedDrawingType,
        ),
      ],
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _contractOptions = _contractOptionsFromRows(responses[0]);
      _structureTypeOptions = _simpleOptionsFromRows(
        responses[1],
        valueKey: 'structure_type_fk',
        labelKey: 'structure_type_fk',
      );
      _drawingTypeOptions = _simpleOptionsFromRows(
        responses[2],
        valueKey: 'drawing_type_fk',
        labelKey: 'drawing_type_fk',
      );
      _selectedContract = _retain(_selectedContract, _contractOptions);
      _selectedStructureType =
          _retain(_selectedStructureType, _structureTypeOptions);
      _selectedDrawingType = _retain(_selectedDrawingType, _drawingTypeOptions);
    });
  }

  Future<void> _loadDesigns() async {
    final ({List<Map<String, dynamic>> rows, int total}) result =
        await widget.dataSource.fetchDesignsList(
      start: _designPage * _designPageSize,
      length: _designPageSize,
      search: _designSearch,
      contractIdFk: _selectedContract,
      structureTypeFk: _selectedStructureType,
      drawingTypeFk: _selectedDrawingType,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _designRows = result.rows;
      _designTotal = result.total;
    });
  }

  Future<void> _loadUploads() async {
    final List<Map<String, dynamic>> rows =
        await widget.dataSource.fetchDesignUploadsList();
    if (!mounted) {
      return;
    }
    setState(() {
      _uploadRows = rows;
      _uploadPage = 0;
    });
  }

  Future<void> _applyFiltersAndReload() async {
    setState(() {
      _loading = true;
      _designPage = 0;
    });
    try {
      await _reloadFilters();
      await _loadDesigns();
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to apply filters',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onContractChanged(String? value) {
    setState(() {
      _selectedContract = value;
      _designPage = 0;
    });
    _applyFiltersAndReload();
  }

  void _onStructureTypeChanged(String? value) {
    setState(() {
      _selectedStructureType = value;
      _designPage = 0;
    });
    _applyFiltersAndReload();
  }

  void _onDrawingTypeChanged(String? value) {
    setState(() {
      _selectedDrawingType = value;
      _designPage = 0;
    });
    _applyFiltersAndReload();
  }

  void _clearFilters() {
    setState(() {
      _selectedContract = null;
      _selectedStructureType = null;
      _selectedDrawingType = null;
      _designPage = 0;
    });
    _applyFiltersAndReload();
  }

  void _onDesignSearchChanged(String value) {
    _designSearchDebounce?.cancel();
    _designSearchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _designSearch = value.trim();
        _designPage = 0;
      });
      _loadDesigns();
    });
  }

  Future<void> _openUploadedFile(Map<String, dynamic> row) async {
    final String fileName = _safe(row['uploaded_file']) ?? '';
    if (fileName.isEmpty) {
      return;
    }
    if (!mounted) {
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
    try {
      final Uint8List bytes = await widget.dataSource.fetchDesignUploadFileBytes(
        fileName: fileName,
        designDataId: _safe(row['design_data_id']),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context, rootNavigator: true).pop();
      await showStructureDocumentPreview(
        context: context,
        dataSource: widget.dataSource,
        localBytes: bytes,
        localFileName: fileName,
        title: fileName,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      Navigator.of(context, rootNavigator: true).pop();
      await AppDialog.show(
        context: context,
        title: 'Unable to open file',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    }
  }

  Future<void> _showComingSoon(String action) async {
    await AppDialog.show(
      context: context,
      title: action,
      message: '$action will be available in a future update.',
      type: AppDialogType.info,
    );
  }

  List<Map<String, dynamic>> _filteredUploadRows() {
    if (_uploadSearch.isEmpty) {
      return _uploadRows;
    }
    final String query = _uploadSearch.toLowerCase();
    return _uploadRows.where((Map<String, dynamic> row) {
      return <String>[
        _safe(row['uploaded_file']) ?? '',
        _safe(row['status']) ?? '',
        _safe(row['remarks']) ?? '',
        _safe(row['uploaded_by_user_id_fk']) ?? '',
        _safe(row['uploaded_on']) ?? '',
      ].any((String value) => value.toLowerCase().contains(query));
    }).toList();
  }

  List<_FilterOption> _contractOptionsFromRows(
    List<Map<String, dynamic>> rows,
  ) {
    final Map<String, _FilterOption> map = <String, _FilterOption>{};
    for (final Map<String, dynamic> row in rows) {
      final String id = _safe(row['contract_id_fk']) ?? '';
      if (id.isEmpty) {
        continue;
      }
      final String shortName = _safe(row['contract_short_name']) ?? '';
      map[id] = _FilterOption(
        value: id,
        label: shortName.isEmpty ? id : '$id - $shortName',
      );
    }
    final List<_FilterOption> values = map.values.toList()
      ..sort((_FilterOption a, _FilterOption b) => a.label.compareTo(b.label));
    return values;
  }

  List<_FilterOption> _simpleOptionsFromRows(
    List<Map<String, dynamic>> rows, {
    required String valueKey,
    required String labelKey,
  }) {
    final Map<String, _FilterOption> map = <String, _FilterOption>{};
    for (final Map<String, dynamic> row in rows) {
      final String value = _safe(row[valueKey]) ?? '';
      if (value.isEmpty) {
        continue;
      }
      final String label = _safe(row[labelKey]) ?? value;
      map[value] = _FilterOption(value: value, label: label);
    }
    final List<_FilterOption> values = map.values.toList()
      ..sort((_FilterOption a, _FilterOption b) => a.label.compareTo(b.label));
    return values;
  }

  _FilterOption? _optionForValue(List<_FilterOption> options, String? value) {
    if (value == null) {
      return null;
    }
    for (final _FilterOption option in options) {
      if (option.value == value) {
        return option;
      }
    }
    return null;
  }

  String? _retain(String? value, List<_FilterOption> options) {
    if (value == null) {
      return null;
    }
    return options.any((_FilterOption option) => option.value == value)
        ? value
        : null;
  }

  _PageSlice _slice(List<Map<String, dynamic>> all, {
    required int page,
    required int pageSize,
  }) {
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

  String _string(dynamic value) => _safe(value) ?? '-';

  String _formatUploadedOn(dynamic value) {
    final String raw = _safe(value) ?? '';
    if (raw.isEmpty) {
      return '-';
    }
    if (raw.contains('.')) {
      return raw.split('.').first;
    }
    return raw;
  }

  String? _safe(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }
}

class _FilterOption {
  const _FilterOption({required this.value, required this.label});

  final String value;
  final String label;
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
