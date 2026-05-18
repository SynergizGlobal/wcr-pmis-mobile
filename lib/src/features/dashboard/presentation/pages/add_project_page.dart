import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/add_project_form_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/providers/project_list_provider.dart';

class AddProjectPage extends ConsumerStatefulWidget {
  const AddProjectPage({super.key});

  static const String routeName = 'add-project';
  static const String routePath = '/add-project';

  @override
  ConsumerState<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends ConsumerState<AddProjectPage> {
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50, 100];
  static const int _defaultPageSize = 10;
  static const List<String> _headers = <String>[
    'ID',
    'Name',
    'Status',
    'Type',
    'Railway Zone',
    'Plan Head No.',
    'Sanctioned Amount',
    'Sanctioned Year',
    'Sanctioned Date',
    'Division',
    'Section',
    'Action',
  ];
  static const MethodChannel _fileExportChannel = MethodChannel(
    'wcr_pmis_mobile/file_export',
  );

  String? _selectedStatus;
  String? _selectedType;
  String _searchQuery = '';
  int _pageSize = _defaultPageSize;
  int _currentPage = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Map<String, dynamic>>> projectsAsync = ref.watch(
      projectListProvider,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Project')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: projectsAsync.when(
            data: (List<Map<String, dynamic>> rows) => _content(context, rows),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace _) =>
                _errorView(context, error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _errorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline_rounded, size: 34),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => ref.invalidate(projectListProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, List<Map<String, dynamic>> rows) {
    final List<String> statusOptions = _options(rows, 'project_status');
    final List<String> typeOptions = _options(rows, 'project_type_name');
    final List<Map<String, dynamic>> filtered = _filteredRows(rows);
    final int total = filtered.length;
    final int pageCount = total == 0 ? 1 : (total / _pageSize).ceil();
    if (_currentPage >= pageCount) {
      _currentPage = pageCount - 1;
    }
    final int start = total == 0 ? 0 : (_currentPage * _pageSize);
    final int end = total == 0 ? 0 : (start + _pageSize).clamp(0, total);
    final List<Map<String, dynamic>> pageRows = total == 0
        ? const <Map<String, dynamic>>[]
        : filtered.sublist(start, end);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: AppSelectSheetField<String>(
                  label: 'Project Status',
                  title: 'Select Project Status',
                  items: <String>['All', ...statusOptions],
                  value: _selectedStatus ?? 'All',
                  itemLabelBuilder: (String value) => value,
                  onChanged: (String value) {
                    setState(() {
                      _selectedStatus = value == 'All' ? null : value;
                      _currentPage = 0;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppSelectSheetField<String>(
                  label: 'Project Type',
                  title: 'Select Project Type',
                  items: <String>['All', ...typeOptions],
                  value: _selectedType ?? 'All',
                  itemLabelBuilder: (String value) => value,
                  onChanged: (String value) {
                    setState(() {
                      _selectedType = value == 'All' ? null : value;
                      _currentPage = 0;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (String value) {
                    setState(() {
                      _searchQuery = value.trim();
                      _currentPage = 0;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: (_selectedStatus != null ||
                        _selectedType != null ||
                        _searchQuery.isNotEmpty)
                    ? () => setState(() {
                        _selectedStatus = null;
                        _selectedType = null;
                        _searchQuery = '';
                        _currentPage = 0;
                        _searchController.clear();
                      })
                    : null,
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: filtered.isEmpty ? null : () => _confirmExportCsv(filtered),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Excel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: filtered.isEmpty ? null : () => _confirmExportPdf(filtered),
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('PDF'),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(
            children: <Widget>[
              const Text('Show '),
              DropdownButton<int>(
                value: _pageSize,
                items: _pageSizeOptions
                    .map(
                      (int e) =>
                          DropdownMenuItem<int>(value: e, child: Text('$e')),
                    )
                    .toList(),
                onChanged: (int? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _pageSize = value;
                    _currentPage = 0;
                  });
                },
              ),
              const Text(' entries'),
              const Spacer(),
              SizedBox(
                width: 132,
                child: FilledButton.icon(
                  onPressed: () async {
                    final bool? added = await Navigator.of(
                      context,
                    ).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => const AddProjectFormPage(),
                      ),
                    );
                    if (added == true) {
                      ref.invalidate(projectListProvider);
                    }
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _headers.fold<double>(
                  0,
                  (double sum, String header) => sum + _columnWidth(header),
                ),
                child: Column(
                  children: <Widget>[
                    _tableHeader(context),
                    Expanded(
                      child: ListView.builder(
                        itemCount: pageRows.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _tableRow(context, pageRows[index], index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: _paginationBar(
            total: total,
            start: start,
            end: end,
            pageCount: pageCount,
          ),
        ),
      ],
    );
  }

  Widget _paginationBar({
    required int total,
    required int start,
    required int end,
    required int pageCount,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final String summary = total == 0
        ? 'Showing 0 to 0 of 0 entries'
        : 'Showing ${start + 1} to $end of $total entries';
    final int currentPage = total == 0 ? 0 : (_currentPage + 1);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          summary,
          style: tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxWidth < 430;
            final double buttonWidth = compact ? 92 : 100;
            final double gap = compact ? 8 : 10;
            final double pillHorizontalPadding = compact ? 12 : 18;
            final TextStyle? pageStyle = (compact ? tt.bodySmall : tt.bodySmall)
                ?.copyWith(color: cs.primary, fontWeight: FontWeight.w700);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: buttonWidth, maxWidth: buttonWidth + 14),
                  child: OutlinedButton.icon(
                    onPressed:
                        _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: const Text('Prev'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(buttonWidth, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                SizedBox(width: gap),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: pillHorizontalPadding, vertical: 12),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text('Page $currentPage of $pageCount', style: pageStyle),
                ),
                SizedBox(width: gap),
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: buttonWidth, maxWidth: buttonWidth + 14),
                  child: OutlinedButton.icon(
                    onPressed: end < total ? () => setState(() => _currentPage++) : null,
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.chevron_right_rounded),
                    label: const Text('Next'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(buttonWidth, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _filteredRows(List<Map<String, dynamic>> rows) {
    return rows.where((Map<String, dynamic> row) {
      final String status = _stringValue(row['project_status']).toLowerCase();
      final String type = _stringValue(row['project_type_name']).toLowerCase();
      final bool statusPass = _selectedStatus == null
          ? true
          : status == _selectedStatus!.toLowerCase();
      final bool typePass = _selectedType == null
          ? true
          : type == _selectedType!.toLowerCase();
      final bool searchPass = _searchQuery.isEmpty
          ? true
          : row.values.any(
              (dynamic value) => _stringValue(value).toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            );
      return statusPass && typePass && searchPass;
    }).toList();
  }

  List<String> _options(List<Map<String, dynamic>> rows, String key) {
    final Set<String> values = rows
        .map((Map<String, dynamic> row) => _stringValue(row[key]))
        .where((String value) => value.isNotEmpty && value != '-')
        .toSet();
    final List<String> sorted = values.toList()..sort();
    return sorted;
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

  Widget _tableRow(BuildContext context, Map<String, dynamic> row, int index) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color bg = index.isEven
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.surface;
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          _cell(_stringValue(row['project_id']), width: _columnWidth('ID')),
          _cell(_stringValue(row['project_name']), width: _columnWidth('Name')),
          _cell(_stringValue(row['project_status']), width: _columnWidth('Status')),
          _cell(
            _stringValue(row['project_type_name']),
            width: _columnWidth('Type'),
          ),
          _cell(
            _stringValue(row['railway_zone']),
            width: _columnWidth('Railway Zone'),
          ),
          _cell(
            _stringValue(row['plan_head_number']),
            width: _columnWidth('Plan Head No.'),
          ),
          _cell(
            _stringValue(row['sanctioned_amount']),
            width: _columnWidth('Sanctioned Amount'),
          ),
          _cell(
            _stringValue(row['sanctioned_year']),
            width: _columnWidth('Sanctioned Year'),
          ),
          _cell(
            _stringValue(row['sanctioned_commissioning_date']),
            width: _columnWidth('Sanctioned Date'),
          ),
          _cell(_stringValue(row['division']), width: _columnWidth('Division')),
          _cell(_stringValue(row['sections']), width: _columnWidth('Section')),
          SizedBox(
            width: _columnWidth('Action'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  tooltip: 'Edit',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 30,
                    height: 30,
                  ),
                  visualDensity: VisualDensity.compact,
                  splashRadius: 16,
                  onPressed: () async {
                    final bool? updated = await Navigator.of(
                      context,
                    ).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => AddProjectFormPage(initialData: row),
                      ),
                    );
                    if (updated == true) {
                      ref.invalidate(projectListProvider);
                    }
                  },
                  icon: Icon(
                    Icons.edit_square,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 30,
                    height: 30,
                  ),
                  visualDensity: VisualDensity.compact,
                  splashRadius: 16,
                  onPressed: () => _onDeleteProject(row),
                  icon: Icon(
                    Icons.delete_forever_rounded,
                    size: 18,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontWeight: weight),
        ),
      ),
    );
  }

  double _columnWidth(String header) {
    return switch (header) {
      'ID' => 56,
      'Name' => 210,
      'Status' => 96,
      'Type' => 130,
      'Railway Zone' => 120,
      'Plan Head No.' => 120,
      'Sanctioned Amount' => 155,
      'Sanctioned Year' => 130,
      'Sanctioned Date' => 130,
      'Division' => 96,
      'Section' => 96,
      'Action' => 84,
      _ => 100,
    };
  }

  Future<void> _confirmExportCsv(List<Map<String, dynamic>> rows) async {
    if (!mounted || rows.isEmpty) {
      return;
    }
    await AppDialog.show(
      context: context,
      type: AppDialogType.confirmation,
      leadingIcon: Icons.table_view_rounded,
      title: 'Export to Excel',
      message:
          'Download the project list as an Excel file (.xlsx)? Current filters, search, and visible rows will be included.',
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Export',
          isPrimary: true,
          onPressed: () => _exportCsv(rows),
        ),
      ],
    );
  }

  Future<void> _confirmExportPdf(List<Map<String, dynamic>> rows) async {
    if (!mounted || rows.isEmpty) {
      return;
    }
    await AppDialog.show(
      context: context,
      type: AppDialogType.confirmation,
      leadingIcon: Icons.picture_as_pdf_rounded,
      title: 'Export to PDF',
      message:
          'Download the project list as a PDF? Current filters, search, and visible rows will be included.',
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Export',
          isPrimary: true,
          onPressed: () => _exportPdf(rows),
        ),
      ],
    );
  }

  Future<void> _exportCsv(List<Map<String, dynamic>> rows) async {
    final Excel workbook = Excel.createExcel();
    final String sheetName = workbook.getDefaultSheet() ?? 'Sheet1';
    final Sheet sheet = workbook[sheetName];
    sheet.appendRow(_headers.map(TextCellValue.new).toList());
    for (final Map<String, dynamic> row in rows) {
      sheet.appendRow(<CellValue>[
        TextCellValue(_stringValue(row['project_id'])),
        TextCellValue(_stringValue(row['project_name'])),
        TextCellValue(_stringValue(row['project_status'])),
        TextCellValue(_stringValue(row['project_type_name'])),
        TextCellValue(_stringValue(row['railway_zone'])),
        TextCellValue(_stringValue(row['plan_head_number'])),
        TextCellValue(_stringValue(row['sanctioned_amount'])),
        TextCellValue(_stringValue(row['sanctioned_year'])),
        TextCellValue(_stringValue(row['sanctioned_commissioning_date'])),
        TextCellValue(_stringValue(row['division'])),
        TextCellValue(_stringValue(row['sections'])),
        TextCellValue(''),
      ]);
    }

    final List<int>? encoded = workbook.encode();
    if (encoded == null || encoded.isEmpty) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Excel Export Failed',
        message: 'Unable to generate xlsx file.',
        type: AppDialogType.error,
      );
      return;
    }

    final String fileName =
        'projects_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final String savedPath = await _saveExportFile(
      fileName: fileName,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      bytes: Uint8List.fromList(encoded),
    );
    if (!mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'Excel Saved',
      message: 'File saved to:\n$savedPath',
      type: AppDialogType.success,
    );
  }

  Future<void> _exportPdf(List<Map<String, dynamic>> rows) async {
    final pw.Document doc = pw.Document();
    final List<List<String>> data = rows
        .map(
          (Map<String, dynamic> row) => <String>[
            _pdfSafe(_stringValue(row['project_id'])),
            _pdfSafe(_stringValue(row['project_name'])),
            _pdfSafe(_stringValue(row['project_status'])),
            _pdfSafe(_stringValue(row['project_type_name'])),
            _pdfSafe(_stringValue(row['railway_zone'])),
            _pdfSafe(_stringValue(row['plan_head_number'])),
            _pdfSafe(_stringValue(row['sanctioned_amount'])),
            _pdfSafe(_stringValue(row['sanctioned_year'])),
            _pdfSafe(_stringValue(row['sanctioned_commissioning_date'])),
            _pdfSafe(_stringValue(row['division'])),
            _pdfSafe(_stringValue(row['sections'])),
            '-',
          ],
        )
        .toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Text('Project List', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: _headers,
              data: data,
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ];
        },
      ),
    );

    final String fileName =
        'projects_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final String savedPath = await _saveExportFile(
      fileName: fileName,
      mimeType: 'application/pdf',
      bytes: Uint8List.fromList(await doc.save()),
    );
    if (!mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'PDF Saved',
      message: 'File saved to:\n$savedPath',
      type: AppDialogType.success,
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

    final Directory dir = await _resolveFallbackDirectory();
    final String filePath = '${dir.path}/$fileName';
    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<Directory> _resolveFallbackDirectory() async {
    if (Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }
    return getApplicationDocumentsDirectory();
  }

  String _pdfSafe(String value) {
    const Map<String, String> replacements = <String, String>{
      '–': '-',
      '—': '-',
      '−': '-',
      '“': '"',
      '”': '"',
      '‘': "'",
      '’': "'",
    };
    String normalized = value;
    replacements.forEach((String from, String to) {
      normalized = normalized.replaceAll(from, to);
    });
    return normalized.replaceAll(RegExp(r'[^\x20-\x7E]'), ' ');
  }

  String _stringValue(dynamic value) {
    if (value == null) {
      return '-';
    }
    final String text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  Future<void> _onDeleteProject(Map<String, dynamic> row) async {
    final String? projectId = _safeString(row['project_id']);
    if (projectId == null) {
      await AppDialog.show(
        context: context,
        title: 'Delete Failed',
        message: 'Project id missing. Unable to delete this record.',
        type: AppDialogType.error,
      );
      return;
    }

    bool confirmed = false;
    await AppDialog.show(
      context: context,
      title: 'Delete Project',
      message: 'Delete project $projectId?',
      type: AppDialogType.error,
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Delete',
          isPrimary: true,
          onPressed: () => confirmed = true,
        ),
      ],
    );
    if (!confirmed) {
      return;
    }

    try {
      final Map<String, dynamic> response = await ref
          .read(dashboardRemoteDataSourceProvider)
          .deleteProject(projectId);
      final String message =
          _safeString(response['message']) ?? 'Project deleted successfully';
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Success',
        message: message,
        type: AppDialogType.success,
      );
      ref.invalidate(projectListProvider);
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Delete Failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    }
  }

  String? _safeString(dynamic value) {
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
