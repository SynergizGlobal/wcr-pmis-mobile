import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/dms_upload_document_dialog.dart';

class DmsDocumentsTab extends StatefulWidget {
  const DmsDocumentsTab({super.key, required this.dataSource});

  final DashboardRemoteDataSource dataSource;

  @override
  State<DmsDocumentsTab> createState() => _DmsDocumentsTabState();
}

class _DmsDocumentsTabState extends State<DmsDocumentsTab> {
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50, 100];
  static const List<String> _headers = <String>[
    'File Type',
    'File Number',
    'File Name',
    'Revision No',
    'Status',
    'Project Name',
    'Contract Name',
    'Path',
    'Created By',
    'Date Uploaded',
    'Revision Date',
    'Department',
    'Actions',
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
      final Map<String, dynamic> response = await widget.dataSource
          .fetchDocumentsFilterData(start: start, length: _pageSize);
      if (!mounted) {
        return;
      }
      final List<Map<String, dynamic>> rows = _parseRows(response);
      setState(() {
        _rows = rows;
        _recordsTotal = _parseInt(
          response['recordsTotal'],
          fallback: rows.length,
        );
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
    final String datePart = raw.contains(' ') ? raw.split(' ').first : raw;
    try {
      return _displayDateFormat.format(DateTime.parse(datePart));
    } catch (_) {
      return raw;
    }
  }

  String _fileTypeLabel(dynamic value) {
    final String raw = _str(value);
    if (raw.isEmpty) {
      return '-';
    }
    if (raw.contains('/')) {
      return raw.split('/').last;
    }
    return raw;
  }

  List<Map<String, dynamic>> get _filteredRows {
    if (_search.trim().isEmpty) {
      return _rows;
    }
    final String q = _search.trim().toLowerCase();
    return _rows.where((Map<String, dynamic> row) {
      final String haystack = <String>[
        _fileTypeLabel(row['fileType']),
        _str(row['fileNumber']),
        _str(row['fileName']),
        _str(row['revisionNumber']),
        _str(row['status']),
        _str(row['projectName']),
        _str(row['contractName']),
        _str(row['path']),
        _str(row['department']),
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

  Future<void> _openUploadDocument() async {
    final bool? saved = await DmsUploadDocumentDialog.show(
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
      message: 'Document drafts will be connected in the next update.',
      type: AppDialogType.info,
    );
  }

  Future<void> _showRowDetails(Map<String, dynamic> row) async {
    await AppDialog.show(
      context: context,
      title: _str(row['fileName']).isEmpty ? 'Document' : _str(row['fileName']),
      message: <String>[
        'File Number: ${_str(row['fileNumber'])}',
        'Revision: ${_str(row['revisionNumber'])}',
        'Status: ${_str(row['status'])}',
        'Project: ${_str(row['projectName'])}',
        'Path: ${_str(row['path'])}',
        'Department: ${_str(row['department'])}',
      ].join('\n'),
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
                onPressed: _loading ? null : _openUploadDocument,
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text('Upload'),
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
        const SizedBox(height: 12),
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
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
                    'No documents found.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                  ),
                );
              }
              return _tableCard(visibleRows, cs, constraints.maxHeight);
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
      final double stripeAlpha = cs.brightness == Brightness.dark ? 0.14 : 0.08;
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
          _cell(_fileTypeLabel(row['fileType']), 'File Type', cs),
          _cell(_str(row['fileNumber']), 'File Number', cs),
          _cell(_str(row['fileName']), 'File Name', cs),
          _cell(_str(row['revisionNumber']), 'Revision No', cs),
          _cell(_str(row['status']), 'Status', cs),
          _cell(_str(row['projectName']), 'Project Name', cs),
          _cell(_str(row['contractName']), 'Contract Name', cs),
          _cell(_str(row['path']), 'Path', cs),
          _cell(_str(row['createdBy']), 'Created By', cs),
          _cell(_formatDate(row['dateUploaded']), 'Date Uploaded', cs),
          _cell(_formatDate(row['revisionDate']), 'Revision Date', cs),
          _cell(_str(row['department']), 'Department', cs),
          _actionsCell(row, cs),
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

  Widget _actionsCell(Map<String, dynamic> row, ColorScheme cs) {
    return SizedBox(
      width: _columnWidth('Actions'),
      child: Center(
        child: IconButton(
          tooltip: 'Details',
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant),
          onPressed: () => _showRowDetails(row),
        ),
      ),
    );
  }

  double _columnWidth(String header) {
    switch (header) {
      case 'File Type':
        return 80;
      case 'File Number':
        return 180;
      case 'File Name':
        return 220;
      case 'Revision No':
        return 90;
      case 'Status':
        return 90;
      case 'Project Name':
        return 180;
      case 'Contract Name':
        return 260;
      case 'Path':
        return 180;
      case 'Created By':
        return 110;
      case 'Date Uploaded':
        return 110;
      case 'Revision Date':
        return 110;
      case 'Department':
        return 110;
      case 'Actions':
        return 56;
      default:
        return 120;
    }
  }
}
