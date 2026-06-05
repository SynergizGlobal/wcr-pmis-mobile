import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/dms_documents_tab.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/dms_upload_letter_dialog.dart';

class DmsPage extends StatefulWidget {
  const DmsPage({super.key, required this.dataSource});

  static const String routeName = 'dms';
  static const String routePath = '/dms';

  final DashboardRemoteDataSource dataSource;

  @override
  State<DmsPage> createState() => _DmsPageState();
}

enum _DmsTab {
  correspondence('Correspondence', Icons.forum_outlined),
  documents('Documents', Icons.description_outlined),
  folders('Folders', Icons.folder_outlined),
  filterForm('Filter Form', Icons.tune_rounded);

  const _DmsTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _DmsPageState extends State<DmsPage> {
  _DmsTab _selectedTab = _DmsTab.correspondence;
  final Set<_DmsTab> _visitedTabs = <_DmsTab>{_DmsTab.correspondence};

  void _selectTab(_DmsTab tab) {
    if (_selectedTab == tab) {
      return;
    }
    setState(() {
      _selectedTab = tab;
      _visitedTabs.add(tab);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('DMS')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _tabStrip(context),
          Divider(
            height: 1,
            thickness: 1,
            color: cs.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.45),
          ),
          Expanded(child: _tabBody()),
        ],
      ),
    );
  }

  Widget _tabStrip(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? cs.surfaceContainerHighest.withValues(alpha: 0.45)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.55),
          ),
          boxShadow: isDark
              ? null
              : <BoxShadow>[
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List<Widget>.generate(_DmsTab.values.length, (int index) {
                final _DmsTab tab = _DmsTab.values[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 4,
                    right: index == _DmsTab.values.length - 1 ? 0 : 4,
                  ),
                  child: _DmsTabPill(
                    label: tab.label,
                    icon: tab.icon,
                    selected: tab == _selectedTab,
                    onTap: () => _selectTab(tab),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabBody() {
    final int tabIndex = _DmsTab.values.indexOf(_selectedTab);
    return IndexedStack(
      index: tabIndex,
      sizing: StackFit.expand,
      children: <Widget>[
        _visitedTabs.contains(_DmsTab.correspondence)
            ? _CorrespondenceTab(dataSource: widget.dataSource)
            : const SizedBox.shrink(),
        _visitedTabs.contains(_DmsTab.documents)
            ? DmsDocumentsTab(dataSource: widget.dataSource)
            : const SizedBox.shrink(),
        _visitedTabs.contains(_DmsTab.folders)
            ? const _DmsPlaceholderTab(label: 'Folders')
            : const SizedBox.shrink(),
        _visitedTabs.contains(_DmsTab.filterForm)
            ? const _DmsPlaceholderTab(label: 'Filter Form')
            : const SizedBox.shrink(),
      ],
    );
  }
}

class _DmsTabPill extends StatelessWidget {
  const _DmsTabPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final Color selectedBackground = cs.primary;
    final Color selectedForeground = cs.onPrimary;
    final Color unselectedForeground = isDark
        ? cs.onSurface.withValues(alpha: 0.78)
        : cs.onSurface.withValues(alpha: 0.72);
    final Color unselectedIcon = isDark
        ? cs.onSurfaceVariant.withValues(alpha: 0.95)
        : cs.onSurface.withValues(alpha: 0.58);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? selectedBackground
                : (isDark ? cs.surface.withValues(alpha: 0.35) : cs.surface),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? selectedBackground.withValues(alpha: 0.9)
                  : cs.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.65),
            ),
            boxShadow: selected && !isDark
                ? <BoxShadow>[
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: selected ? selectedForeground : unselectedIcon,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected ? selectedForeground : unselectedForeground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DmsPlaceholderTab extends StatelessWidget {
  const _DmsPlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        '$label will be connected next.',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: cs.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _CorrespondenceTab extends StatefulWidget {
  const _CorrespondenceTab({required this.dataSource});

  final DashboardRemoteDataSource dataSource;

  @override
  State<_CorrespondenceTab> createState() => _CorrespondenceTabState();
}

class _CorrespondenceTabState extends State<_CorrespondenceTab> {
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50, 100];
  static const List<String> _headers = <String>[
    'Reference Number',
    'Category',
    'Letter No',
    'From',
    'To',
    'Subject',
    'Required Response',
    'Due Date',
    'Project',
    'Contract',
    'Status',
    'Department',
    'Attachment',
    'Type',
  ];

  final TextEditingController _searchController = TextEditingController();
  final DateFormat _displayDateFormat = DateFormat('dd-MM-yyyy');

  String _search = '';
  int _pageSize = 10;
  int _currentPage = 0;
  int _recordsTotal = 0;

  bool _loading = true;
  String? _loadError;
  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadList());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadList() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final int start = _currentPage * _pageSize;
      final Map<String, dynamic> response =
          await widget.dataSource.fetchCorrespondenceFilterData(
        start: start,
        length: _pageSize,
      );
      if (!mounted) {
        return;
      }
      final List<Map<String, dynamic>> rows = _parseRows(response);
      setState(() {
        _rows = rows;
        _recordsTotal = _parseInt(response['recordsTotal'], fallback: rows.length);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadError = error.toString();
        _rows = <Map<String, dynamic>>[];
      });
    }
  }

  List<Map<String, dynamic>> _parseRows(Map<String, dynamic> response) {
    final dynamic raw = response['data'];
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

  int _parseInt(dynamic value, {required int fallback}) {
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _str(dynamic value) {
    if (value == null) {
      return '';
    }
    final String text = value.toString().trim();
    return text.toLowerCase() == 'null' ? '' : text;
  }

  String _formatDate(dynamic value) {
    final String raw = _str(value);
    if (raw.isEmpty) {
      return '-';
    }
    try {
      return _displayDateFormat.format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  List<Map<String, dynamic>> get _filteredRows {
    if (_search.trim().isEmpty) {
      return _rows;
    }
    final String q = _search.trim().toLowerCase();
    return _rows.where((Map<String, dynamic> row) {
      final String haystack = <String>[
        _str(row['referenceNumber']),
        _str(row['category']),
        _str(row['letterNumber']),
        _str(row['from']),
        _str(row['to']),
        _str(row['subject']),
        _str(row['projectName']),
        _str(row['contractName']),
        _str(row['currentStatus']),
        _str(row['department']),
        _str(row['type']),
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  int get _pageCount {
    if (_recordsTotal == 0) {
      return 1;
    }
    return (_recordsTotal / _pageSize).ceil();
  }

  Future<void> _openUploadLetter() async {
    final bool? saved = await DmsUploadLetterDialog.show(
      context,
      dataSource: widget.dataSource,
    );
    if (saved == true && mounted) {
      await _loadList();
    }
  }

  Future<void> _openDraftsInfo() async {
    await AppDialog.show(
      context: context,
      title: 'Drafts',
      message: 'Draft letters list will be connected in the next update.',
      type: AppDialogType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final List<Map<String, dynamic>> visibleRows = _filteredRows;
    final int start = _currentPage * _pageSize;
    final int end = (_currentPage * _pageSize + visibleRows.length).clamp(
      0,
      _recordsTotal == 0 ? visibleRows.length : _recordsTotal,
    );

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool narrow = constraints.maxWidth < 520;
              final Widget uploadButton = FilledButton.icon(
                onPressed: _loading ? null : _openUploadLetter,
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text('Upload Letter'),
              );
              final Widget draftsButton = FilledButton.tonalIcon(
                onPressed: _loading ? null : _openDraftsInfo,
                icon: const Icon(Icons.drafts_outlined, size: 18),
                label: const Text('Drafts'),
              );
              final Widget searchField = TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search_rounded),
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (String value) => setState(() => _search = value),
              );

              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: uploadButton),
                        const SizedBox(width: 8),
                        Expanded(child: draftsButton),
                      ],
                    ),
                    const SizedBox(height: 8),
                    searchField,
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Flexible(child: uploadButton),
                  const SizedBox(width: 8),
                  Flexible(child: draftsButton),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 2,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: searchField,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (_loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_loadError != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _loadError!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _loadList,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (visibleRows.isEmpty) {
                return Center(
                  child: Text(
                    'No correspondence records found.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return _tableCard(
                context,
                visibleRows,
                cs,
                constraints.maxHeight,
              );
            },
          ),
        ),
        AppTablePaginationFooter(
          total: _recordsTotal,
          startIndex: _recordsTotal == 0 ? 0 : start,
          endIndex: _recordsTotal == 0 ? 0 : end,
          currentPage: _currentPage,
          pageCount: _pageCount,
          pageSize: _pageSize,
          pageSizeOptions: _pageSizeOptions,
          onPageSizeChanged: (int size) {
            setState(() {
              _pageSize = size;
              _currentPage = 0;
            });
            _loadList();
          },
          onPrevious: _currentPage > 0 && !_loading
              ? () {
                  setState(() => _currentPage -= 1);
                  _loadList();
                }
              : null,
          onNext: _currentPage < _pageCount - 1 && !_loading
              ? () {
                  setState(() => _currentPage += 1);
                  _loadList();
                }
              : null,
        ),
      ],
    );
  }

  Widget _tableCard(
    BuildContext context,
    List<Map<String, dynamic>> rows,
    ColorScheme cs,
    double maxHeight,
  ) {
    final double tableWidth = _headers.fold<double>(
      0,
      (double sum, String header) => sum + _columnWidth(header),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: maxHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _tableHeader(cs),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: rows.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _tableRow(rows[index], index, cs);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _tableRowBackground(ColorScheme cs, int index) {
    if (index.isEven) {
      final double stripeAlpha =
          cs.brightness == Brightness.dark ? 0.14 : 0.08;
      return cs.primary.withValues(alpha: stripeAlpha);
    }
    return cs.surface;
  }

  Widget _tableHeader(ColorScheme cs) {
    return Container(
      color: cs.primary,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: _headers
            .map(
              (String h) => SizedBox(
                width: _columnWidth(h),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    h,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _tableRow(Map<String, dynamic> row, int index, ColorScheme cs) {
    return Container(
      color: _tableRowBackground(cs, index),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _cell(_str(row['referenceNumber']), 'Reference Number', cs),
          _cell(_str(row['category']), 'Category', cs),
          _letterCell(_str(row['letterNumber']), cs),
          _cell(_str(row['from']), 'From', cs),
          _cell(_str(row['to']), 'To', cs),
          _cell(_str(row['subject']), 'Subject', cs),
          _cell(_str(row['requiredResponse']), 'Required Response', cs),
          _cell(_formatDate(row['dueDate']), 'Due Date', cs),
          _cell(_str(row['projectName']), 'Project', cs),
          _cell(_str(row['contractName']), 'Contract', cs),
          _cell(_str(row['currentStatus']), 'Status', cs),
          _cell(_str(row['department']), 'Department', cs),
          _cell(_str(row['attachment']), 'Attachment', cs),
          _cell(_str(row['type']), 'Type', cs),
        ],
      ),
    );
  }

  Widget _cell(String text, String header, ColorScheme cs) {
    return SizedBox(
      width: _columnWidth(header),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text.isEmpty ? '-' : text,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: cs.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _letterCell(String text, ColorScheme cs) {
    return SizedBox(
      width: _columnWidth('Letter No'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text.isEmpty ? '-' : text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  double _columnWidth(String header) {
    switch (header) {
      case 'Reference Number':
        return 130;
      case 'Category':
        return 100;
      case 'Letter No':
        return 90;
      case 'From':
        return 120;
      case 'To':
        return 160;
      case 'Subject':
        return 180;
      case 'Required Response':
        return 120;
      case 'Due Date':
        return 100;
      case 'Project':
        return 200;
      case 'Contract':
        return 260;
      case 'Status':
        return 90;
      case 'Department':
        return 120;
      case 'Attachment':
        return 90;
      case 'Type':
        return 90;
      default:
        return 120;
    }
  }
}
