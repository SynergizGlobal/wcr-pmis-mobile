import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/structures/structure_form_page.dart';

class StructuresPage extends StatefulWidget {
  const StructuresPage({super.key, required this.dataSource});

  static const String routeName = 'structures';
  static const String routePath = '/structures';

  final DashboardRemoteDataSource dataSource;

  @override
  State<StructuresPage> createState() => _StructuresPageState();
}

class _StructuresPageState extends State<StructuresPage> {
  static const List<int> _pageSizes = <int>[5, 10, 25, 50];
  static const double _actionColumnWidth = 64;
  static const double _minProjectColumnWidth = 132;
  static const double _maxProjectColumnWidth = 196;

  bool _loading = false;
  String _search = '';
  String? _selectedProjectId;
  int _pageSize = 10;
  int _page = 0;

  final TextEditingController _searchCtrl = TextEditingController();

  List<_ProjectOption> _projects = <_ProjectOption>[];
  List<_StructureSummaryRow> _rows = <_StructureSummaryRow>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  double _projectColumnWidth(double tableWidth) {
    final double computed = tableWidth * 0.34;
    return computed.clamp(_minProjectColumnWidth, _maxProjectColumnWidth);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        widget.dataSource.fetchProjectsDropdown(),
        widget.dataSource.fetchAllProjectStructureSummaries(),
      ]);
      if (!mounted) {
        return;
      }
      final List<Map<String, dynamic>> projectRows =
          results[0] as List<Map<String, dynamic>>;
      final List<Map<String, dynamic>> summaryRows =
          results[1] as List<Map<String, dynamic>>;

      final Map<String, String> projectNames = <String, String>{};
      final List<_ProjectOption> projects = <_ProjectOption>[];
      for (final Map<String, dynamic> row in projectRows) {
        final String id = _string(row['project_id'] ?? row['projectId']);
        final String name = _string(row['project_name'] ?? row['projectName']);
        if (id.isEmpty) {
          continue;
        }
        projectNames[id] = name;
        projects.add(_ProjectOption(id: id, name: name));
      }
      projects.sort(
        ( _ProjectOption a, _ProjectOption b) => a.id.compareTo(b.id),
      );

      final List<_StructureSummaryRow> rows = <_StructureSummaryRow>[];
      for (final Map<String, dynamic> row in summaryRows) {
        final String projectId = _string(row['projectId'] ?? row['project_id']);
        if (projectId.isEmpty) {
          continue;
        }
        final List<dynamic> types =
            row['structureTypes'] as List<dynamic>? ?? <dynamic>[];
        final List<_StructureTypeSummary> structureTypes =
            <_StructureTypeSummary>[];
        for (final dynamic typeRow in types) {
          if (typeRow is! Map) {
            continue;
          }
          final String type = _string(typeRow['structureType']);
          final String count = _string(typeRow['count']);
          if (type.isEmpty) {
            continue;
          }
          structureTypes.add(
            _StructureTypeSummary(type: type, count: count),
          );
        }
        rows.add(
          _StructureSummaryRow(
            projectId: projectId,
            projectName: projectNames[projectId] ?? projectId,
            structureTypes: structureTypes,
          ),
        );
      }
      rows.sort(
        ( _StructureSummaryRow a, _StructureSummaryRow b) =>
            a.projectId.compareTo(b.projectId),
      );

      setState(() {
        _projects = projects;
        _rows = rows;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load structures',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<_StructureSummaryRow> get _filteredRows {
    final String query = _search.trim().toLowerCase();
    return _rows.where(( _StructureSummaryRow row) {
      if (_selectedProjectId != null && row.projectId != _selectedProjectId) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return row.searchText.contains(query);
    }).toList();
  }

  Future<void> _openAddStructure() async {
    final Object? result = await context.pushNamed(
      StructureFormPage.addRouteName,
    );
    if (result == true && mounted) {
      await _load();
    }
  }

  Future<void> _openEditStructure(String projectId) async {
    final Object? result = await context.pushNamed(
      StructureFormPage.editRouteName,
      queryParameters: <String, String>{'project_id': projectId},
    );
    if (result == true && mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<_StructureSummaryRow> filtered = _filteredRows;
    final int total = filtered.length;
    final int pageCount = total == 0 ? 1 : (total / _pageSize).ceil();
    final int safePage = _page.clamp(0, pageCount - 1);
    if (safePage != _page) {
      _page = safePage;
    }
    final int start = total == 0 ? 0 : safePage * _pageSize;
    final int end = total == 0 ? 0 : (start + _pageSize).clamp(0, total);
    final List<_StructureSummaryRow> pageRows = total == 0
        ? const <_StructureSummaryRow>[]
        : filtered.sublist(start, end);
    final bool hasActiveFilters =
        _selectedProjectId != null || _search.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Structure'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add Structure',
            onPressed: _loading ? null : _openAddStructure,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (String value) => setState(() {
                        _search = value.trim();
                        _page = 0;
                      }),
                      decoration: InputDecoration(
                        hintText: 'Search project',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 36,
                        ),
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {
                                    _search = '';
                                    _page = 0;
                                  });
                                },
                                icon: const Icon(Icons.close_rounded, size: 20),
                              )
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: AppSelectSheetField<String?>(
                            label: 'Project',
                            title: 'Select Project',
                            compact: true,
                            placeholderText: 'All Projects',
                            items: <String?>[
                              null,
                              ..._projects.map(( _ProjectOption p) => p.id),
                            ],
                            value: _selectedProjectId,
                            itemLabelBuilder: (String? value) {
                              if (value == null) {
                                return 'All Projects';
                              }
                              for (final _ProjectOption project in _projects) {
                                if (project.id == value) {
                                  return project.label;
                                }
                              }
                              return value;
                            },
                            onChanged: (String? value) {
                              setState(() {
                                _selectedProjectId = value;
                                _page = 0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: !hasActiveFilters
                              ? null
                              : () {
                                  setState(() {
                                    _selectedProjectId = null;
                                    _search = '';
                                    _searchCtrl.clear();
                                    _page = 0;
                                  });
                                },
                          icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                          label: const Text('Clear'),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: pageRows.isEmpty
                      ? Center(
                          child: Text(
                            _loading
                                ? 'Loading structures...'
                                : 'No structures found.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (
                            BuildContext context,
                            BoxConstraints constraints,
                          ) {
                            final double tableWidth = constraints.maxWidth;
                            final double projectWidth =
                                _projectColumnWidth(tableWidth);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                _buildTableHeader(
                                  context,
                                  tableWidth: tableWidth,
                                  projectWidth: projectWidth,
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: pageRows.length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      return _buildTableRow(
                                        context,
                                        pageRows[index],
                                        index,
                                        tableWidth: tableWidth,
                                        projectWidth: projectWidth,
                                        isLast: index == pageRows.length - 1,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
              AppTablePaginationFooter(
                total: total,
                startIndex: start,
                endIndex: end,
                currentPage: safePage,
                pageCount: pageCount,
                pageSize: _pageSize,
                pageSizeOptions: _pageSizes,
                onPageSizeChanged: (int value) => setState(() {
                  _pageSize = value;
                  _page = 0;
                }),
                onPrevious: safePage > 0
                    ? () => setState(() => _page = safePage - 1)
                    : null,
                onNext: safePage < pageCount - 1
                    ? () => setState(() => _page = safePage + 1)
                    : null,
              ),
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

  Widget _buildTableHeader(
    BuildContext context, {
    required double tableWidth,
    required double projectWidth,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color dividerColor =
        colorScheme.onPrimary.withValues(alpha: 0.35);
    final TextStyle? headerStyle = Theme.of(context).textTheme.labelLarge
        ?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
        );

    return ColoredBox(
      color: colorScheme.primary,
      child: SizedBox(
        width: tableWidth,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _headerCell(
                width: projectWidth,
                showRightBorder: true,
                dividerColor: dividerColor,
                child: Text('Project', style: headerStyle),
              ),
              Expanded(
                child: _headerCell(
                  showRightBorder: true,
                  dividerColor: dividerColor,
                  child: Text('Structures', style: headerStyle),
                ),
              ),
              _headerCell(
                width: _actionColumnWidth,
                showRightBorder: false,
                dividerColor: dividerColor,
                alignment: Alignment.center,
                child: Text('Edit', style: headerStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCell({
    required Widget child,
    required bool showRightBorder,
    required Color dividerColor,
    double? width,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: showRightBorder
          ? BoxDecoration(
              border: Border(right: BorderSide(color: dividerColor)),
            )
          : null,
      alignment: alignment,
      child: child,
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    _StructureSummaryRow row,
    int index, {
    required double tableWidth,
    required double projectWidth,
    required bool isLast,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color rowColor = index.isEven
        ? colorScheme.primary.withValues(alpha: 0.06)
        : colorScheme.surface;
    final BorderRadius? radius = isLast
        ? const BorderRadius.vertical(bottom: Radius.circular(14))
        : null;

    return ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: ColoredBox(
        color: rowColor,
        child: SizedBox(
          width: tableWidth,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _projectCell(row, width: projectWidth),
                Expanded(child: _structuresCell(row)),
                _actionCell(row),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _projectCell(_StructureSummaryRow row, {required double width}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            row.projectLabel,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _structuresCell(_StructureSummaryRow row) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: row.structureTypes.isEmpty
          ? Text(
              'No structures added yet.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: row.structureTypes
                  .map(
                    ( _StructureTypeSummary item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${item.type} - ${item.count}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _actionCell(_StructureSummaryRow row) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: _actionColumnWidth,
      child: Center(
        child: IconButton(
          tooltip: 'Edit Structure',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: _loading ? null : () => _openEditStructure(row.projectId),
          icon: Icon(
            Icons.edit_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  static String _string(dynamic value) => value?.toString().trim() ?? '';
}

class _ProjectOption {
  const _ProjectOption({required this.id, required this.name});

  final String id;
  final String name;

  String get label => name.isEmpty ? id : '$id - $name';
}

class _StructureTypeSummary {
  const _StructureTypeSummary({required this.type, required this.count});

  final String type;
  final String count;
}

class _StructureSummaryRow {
  const _StructureSummaryRow({
    required this.projectId,
    required this.projectName,
    required this.structureTypes,
  });

  final String projectId;
  final String projectName;
  final List<_StructureTypeSummary> structureTypes;

  String get projectLabel =>
      projectName.isEmpty ? projectId : '$projectId - $projectName';

  String get searchText {
    final StringBuffer buffer = StringBuffer('$projectId $projectName ');
    for (final _StructureTypeSummary item in structureTypes) {
      buffer.write('${item.type} ${item.count} ');
    }
    return buffer.toString().toLowerCase();
  }
}
