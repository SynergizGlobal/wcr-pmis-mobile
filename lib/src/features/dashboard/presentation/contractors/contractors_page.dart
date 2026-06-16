import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_toolbar_table_scaffold_body.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/contractors/contractor_form_page.dart';

class ContractorsPage extends StatefulWidget {
  const ContractorsPage({super.key, required this.dataSource});

  static const String routeName = 'contractors';
  static const String routePath = '/contractors';

  final DashboardRemoteDataSource dataSource;

  @override
  State<ContractorsPage> createState() => _ContractorsPageState();
}

class _ContractorsPageState extends State<ContractorsPage> {
  static const MethodChannel _fileExportChannel = MethodChannel(
    'wcr_pmis_mobile/file_export',
  );
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50, 100];
  static const List<String> _headers = <String>[
    'Contractor ID',
    'Contractor Name',
    'PAN Number',
    'Specialization',
    'Address',
    'Primary Contact',
    'Phone Number',
    'Email',
    'Action',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  bool _loading = false;
  int _pageSize = 10;
  int _currentPage = 0;
  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadAll());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filteredRows = _filteredRows(_rows);
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
      appBar: AppBar(title: const Text('Contractor')),
      bottomNavigationBar: _stickyFooter(total: total, start: start, end: end),
      body: Stack(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: AppToolbarTableScaffoldBody(
              toolbar: _toolbar(context, filteredRows),
              table: _tableCard(context, pageRows),
            ),
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

  Widget _toolbar(BuildContext context, List<Map<String, dynamic>> rows) {
    final bool canExport = rows.isNotEmpty;
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
    final Widget actionsBox = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(
            alpha: 0.6,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: canExport ? () => _confirmExportExcel(rows) : null,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Export Excel'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: _onAddTap,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            ),
          ),
        ],
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 1, top: 12, right: 12, left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            searchField,
            const SizedBox(height: 10),
            actionsBox,
            const SizedBox(height: 10),
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
                          ? const Center(
                              child: Text('No contractor records found.'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _cell(_stringValue(row['contractorId']), width: _columnWidth('Contractor ID')),
            _cell(
              _stringValue(row['contractorName']),
              width: _columnWidth('Contractor Name'),
            ),
            _cell(_stringValue(row['panNumber']), width: _columnWidth('PAN Number')),
            _cell(
              _specialization(row),
              width: _columnWidth('Specialization'),
            ),
            _cell(_stringValue(row['address']), width: _columnWidth('Address')),
            _cell(
              _stringValue(row['primaryContact']),
              width: _columnWidth('Primary Contact'),
            ),
            _cell(
              _stringValue(row['phoneNumber']),
              width: _columnWidth('Phone Number'),
            ),
            _cell(_stringValue(row['email']), width: _columnWidth('Email')),
            SizedBox(
              width: _columnWidth('Action'),
              child: Center(
                child: IconButton(
                  tooltip: 'Edit',
                  onPressed: () => _onEditTap(row),
                  icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                ),
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
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontWeight: weight, fontSize: 13),
        ),
      ),
    );
  }

  Widget _stickyFooter({
    required int total,
    required int start,
    required int end,
  }) {
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

  Future<void> _reloadAll() async {
    setState(() => _loading = true);
    try {
      final List<Map<String, dynamic>> rows =
          await widget.dataSource.fetchContractorsList();
      if (!mounted) {
        return;
      }
      setState(() {
        _rows = rows;
        _currentPage = 0;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load contractors',
        message: 'Please check your connection and try again.',
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onAddTap() async {
    final bool? saved = await context.pushNamed<bool>(
      ContractorFormPage.routeName,
    );
    if (saved == true) {
      await _reloadAll();
    }
  }

  Future<void> _onEditTap(Map<String, dynamic> row) async {
    final String id = _stringValue(row['contractorId']);
    if (id.isEmpty) {
      return;
    }
    final bool? saved = await context.pushNamed<bool>(
      ContractorFormPage.routeName,
      queryParameters: <String, String>{'contractor_id': id},
    );
    if (saved == true) {
      await _reloadAll();
    }
  }

  Future<void> _confirmExportExcel(List<Map<String, dynamic>> rows) async {
    await AppDialog.show(
      context: context,
      type: AppDialogType.confirmation,
      leadingIcon: Icons.table_view_rounded,
      title: 'Export to Excel',
      message:
          'Download ${rows.length} contractor record(s) as an Excel file (.xlsx)?',
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Export',
          isPrimary: true,
          onPressed: () => _exportExcel(rows),
        ),
      ],
    );
  }

  Future<void> _exportExcel(List<Map<String, dynamic>> rows) async {
    final Excel workbook = Excel.createExcel();
    final Sheet sheet = workbook[workbook.getDefaultSheet() ?? 'Sheet1'];
    sheet.appendRow(
      _headers
          .where((String h) => h != 'Action')
          .map((String h) => TextCellValue(h))
          .toList(),
    );
    for (final Map<String, dynamic> row in rows) {
      sheet.appendRow(<CellValue?>[
        TextCellValue(_stringValue(row['contractorId'])),
        TextCellValue(_stringValue(row['contractorName'])),
        TextCellValue(_stringValue(row['panNumber'])),
        TextCellValue(_specialization(row)),
        TextCellValue(_stringValue(row['address'])),
        TextCellValue(_stringValue(row['primaryContact'])),
        TextCellValue(_stringValue(row['phoneNumber'])),
        TextCellValue(_stringValue(row['email'])),
      ]);
    }
    final List<int>? bytes = workbook.encode();
    if (bytes == null || bytes.isEmpty) {
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
        'contractors_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final String savedPath = await _saveExportFile(
      fileName: fileName,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      bytes: Uint8List.fromList(bytes),
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

  List<Map<String, dynamic>> _filteredRows(List<Map<String, dynamic>> rows) {
    if (_search.isEmpty) {
      return rows;
    }
    final String query = _search.toLowerCase();
    return rows.where((Map<String, dynamic> row) {
      return <String>[
        _stringValue(row['contractorId']),
        _stringValue(row['contractorName']),
        _stringValue(row['panNumber']),
        _specialization(row),
        _stringValue(row['address']),
        _stringValue(row['primaryContact']),
        _stringValue(row['phoneNumber']),
        _stringValue(row['email']),
        _stringValue(row['contractorShortCode']),
      ].any((String value) => value.toLowerCase().contains(query));
    }).toList();
  }

  String _specialization(Map<String, dynamic> row) {
    return _stringValue(row['specilaization'] ?? row['specialization']);
  }

  String _stringValue(dynamic raw) {
    if (raw == null) {
      return '';
    }
    final String value = raw.toString().trim();
    if (value.isEmpty || value.toLowerCase() == 'null') {
      return '';
    }
    return value;
  }

  double _columnWidth(String title) {
    return switch (title) {
      'Contractor ID' => 120,
      'Contractor Name' => 260,
      'PAN Number' => 120,
      'Specialization' => 150,
      'Address' => 280,
      'Primary Contact' => 130,
      'Phone Number' => 130,
      'Email' => 180,
      'Action' => 72,
      _ => 130,
    };
  }
}
