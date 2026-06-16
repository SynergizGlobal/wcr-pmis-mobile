import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_toolbar_table_scaffold_body.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

enum _P6UploadKind {
  baseline('Baseline', '/upload-p6-new-data', false),
  revisedBaseline('Revised Baseline', '/revised-p6-new-activities', true),
  update('Update', '/update-p6-new-activities', true);

  const _P6UploadKind(this.label, this.endpoint, this.includeFobId);

  final String label;
  final String endpoint;
  final bool includeFobId;
}

class _P6Option {
  const _P6Option({required this.value, required this.label});

  final String value;
  final String label;
}

class StructureP6UpdatePage extends StatefulWidget {
  const StructureP6UpdatePage({super.key, required this.dataSource});

  static const String routeName = 'structure-p6-update';
  static const String routePath = '/structure-p6-update';

  final DashboardRemoteDataSource dataSource;

  @override
  State<StructureP6UpdatePage> createState() => _StructureP6UpdatePageState();
}

class _StructureP6UpdatePageState extends State<StructureP6UpdatePage> {
  static const MethodChannel _fileExportChannel = MethodChannel(
    'wcr_pmis_mobile/file_export',
  );
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50, 100];
  static const List<String> _headers = <String>[
    'Contract ID',
    'Data Type',
    'Data Date',
    'Status',
    'Uploaded File',
    'Uploaded By',
    'Uploaded Date',
  ];

  final TextEditingController _searchController = TextEditingController();
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  String _search = '';
  bool _loading = false;

  String? _selectedContract;
  String? _selectedUploadType;
  String? _selectedStatus;

  int _pageSize = 10;
  int _currentPage = 0;

  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  List<_P6Option> _contractOptions = <_P6Option>[];
  List<_P6Option> _uploadTypeOptions = <_P6Option>[];
  List<_P6Option> _statusOptions = <_P6Option>[];

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
      appBar: AppBar(title: const Text('Structure P6 Update')),
      bottomNavigationBar: _stickyFooter(total: total, start: start, end: end),
      body: Stack(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: AppToolbarTableScaffoldBody(
              toolbar: _toolbar(context),
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

  Widget _toolbar(BuildContext context) {
    final int activeFilterCount = _activeFilterCount;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
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
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest
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
                          label: Text('Filter ($activeFilterCount)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              activeFilterCount > 0 ? _clearFilters : null,
                          icon: const Icon(Icons.filter_alt_off_rounded),
                          label: const Text('Clear Filter'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _showAddMenu,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add'),
                    ),
                  ),
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
                              child: Text('No P6 upload records found.'),
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
              _stringValue(row['contract_id_fk']),
              width: _columnWidth('Contract ID'),
            ),
            _cell(
              _stringValue(row['upload_type']),
              width: _columnWidth('Data Type'),
            ),
            _cell(
              _stringValue(row['data_date']),
              width: _columnWidth('Data Date'),
            ),
            _cell(
              _stringValue(row['soft_delete_status_fk']),
              width: _columnWidth('Status'),
            ),
            _cell(
              _stringValue(row['p6_file_path']),
              width: _columnWidth('Uploaded File'),
            ),
            _cell(
              _stringValue(row['uploaded_by_user_id_fk']),
              width: _columnWidth('Uploaded By'),
            ),
            _cell(
              _stringValue(row['uploaded_date']),
              width: _columnWidth('Uploaded Date'),
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
      final List<List<Map<String, dynamic>>> responses =
          await Future.wait<List<Map<String, dynamic>>>(
        <Future<List<Map<String, dynamic>>>>[
          widget.dataSource.fetchP6NewActivityData(
            contractIdFk: _selectedContract,
            statusFk: _selectedStatus,
            uploadType: _selectedUploadType,
          ),
          widget.dataSource.fetchP6NewDataContractsFilter(),
          widget.dataSource.fetchP6NewDataUploadTypesFilter(),
          widget.dataSource.fetchP6NewDataStatusFilter(),
        ],
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _rows = responses[0];
        _contractOptions = _dedupeOptions(
          responses[1].map(_contractOptionFromRow),
        );
        _uploadTypeOptions = _dedupeOptions(
          responses[2].map(_uploadTypeOptionFromRow),
        );
        _statusOptions = _dedupeOptions(
          responses[3].map(_statusOptionFromRow),
        );
        _selectedContract = _retainValid(_selectedContract, _contractOptions);
        _selectedUploadType =
            _retainValid(_selectedUploadType, _uploadTypeOptions);
        _selectedStatus = _retainValid(_selectedStatus, _statusOptions);
        _currentPage = 0;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load P6 data',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedContract = null;
      _selectedUploadType = null;
      _selectedStatus = null;
      _currentPage = 0;
    });
    _reloadAll();
  }

  Future<void> _openFilterDialog() async {
    String? dialogContract = _selectedContract;
    String? dialogUploadType = _selectedUploadType;
    String? dialogStatus = _selectedStatus;
    bool shouldApply = false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Center(child: Text('Filter P6 Data')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _dialogDropdown(
                      label: 'Contract',
                      options: _contractOptions,
                      value: dialogContract,
                      onChanged: (String? value) =>
                          setDialogState(() => dialogContract = value),
                    ),
                    const SizedBox(height: 10),
                    _dialogDropdown(
                      label: 'Upload Type',
                      options: _uploadTypeOptions,
                      value: dialogUploadType,
                      onChanged: (String? value) =>
                          setDialogState(() => dialogUploadType = value),
                    ),
                    const SizedBox(height: 10),
                    _dialogDropdown(
                      label: 'Status',
                      options: _statusOptions,
                      value: dialogStatus,
                      onChanged: (String? value) =>
                          setDialogState(() => dialogStatus = value),
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

    if (!shouldApply || !mounted) {
      return;
    }
    setState(() {
      _selectedContract = dialogContract;
      _selectedUploadType = dialogUploadType;
      _selectedStatus = dialogStatus;
      _currentPage = 0;
    });
    await _reloadAll();
  }

  Future<void> _showAddMenu() async {
    final _P6UploadKind? picked = await showModalBottomSheet<_P6UploadKind>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _P6UploadKind.values
                .map(
                  (_P6UploadKind kind) => ListTile(
                    leading: const Icon(Icons.upload_file_rounded),
                    title: Text(kind.label),
                    onTap: () => Navigator.of(context).pop(kind),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    if (picked != null && mounted) {
      await _openUploadDialog(picked);
    }
  }

  Future<void> _openUploadDialog(_P6UploadKind kind) async {
    bool dialogLoading = true;
    bool dialogSaving = false;
    String? loadError;
    List<_P6Option> projects = <_P6Option>[];
    List<_P6Option> allContracts = <_P6Option>[];
    _P6Option? selectedProject;
    _P6Option? selectedContract;
    DateTime? dataDate;
    String? pickedFileName;
    Uint8List? pickedBytes;

    try {
      final Map<String, dynamic> bootstrap =
          await widget.dataSource.fetchP6NewDataFormBootstrap();
      projects = _optionsFromList(
        bootstrap['projectsList'] as List<dynamic>? ?? <dynamic>[],
        idKeys: const <String>['project_id_fk'],
        labelKeys: const <String>['project_name'],
      );
      allContracts = _optionsFromList(
        bootstrap['contractsList'] as List<dynamic>? ?? <dynamic>[],
        idKeys: const <String>['contract_id', 'contract_id_fk'],
        labelKeys: const <String>['contract_short_name', 'contract_name'],
      );
      dialogLoading = false;
    } catch (error) {
      loadError = userFriendlyErrorMessage(error);
      dialogLoading = false;
    }

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: !dialogSaving,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            List<_P6Option> contractOptions = allContracts;
            if (selectedProject != null) {
              final String prefix = selectedProject!.value;
              final List<_P6Option> filtered = allContracts
                  .where(
                    (_P6Option c) => c.value.startsWith(prefix),
                  )
                  .toList();
              if (filtered.isNotEmpty) {
                contractOptions = filtered;
              }
            }

            Future<void> pickDate() async {
              final DateTime now = DateTime.now();
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: dataDate ?? now,
                firstDate: DateTime(2000),
                lastDate: DateTime(now.year + 10),
              );
              if (picked != null) {
                setDialogState(() => dataDate = picked);
              }
            }

            Future<void> pickFile() async {
              final FilePickerResult? result =
                  await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: <String>['xlsx', 'xls'],
                withData: true,
              );
              if (result == null || result.files.isEmpty) {
                return;
              }
              final PlatformFile file = result.files.first;
              if (file.bytes == null) {
                return;
              }
              setDialogState(() {
                pickedBytes = file.bytes;
                pickedFileName = file.name;
              });
            }

            Future<void> downloadFormat() async {
              try {
                final ({Uint8List bytes, String? fileName}) downloaded =
                    await widget.dataSource.downloadP6NewDataFileFormat();
                if (downloaded.bytes.isEmpty) {
                  throw Exception('Empty file format received from server.');
                }
                final String fileName = downloaded.fileName?.trim().isNotEmpty ==
                        true
                    ? downloaded.fileName!.trim()
                    : 'p6_data_file_format.xlsx';
                final String savedPath = await _saveExportFile(
                  fileName: fileName,
                  mimeType:
                      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                  bytes: downloaded.bytes,
                );
                if (!context.mounted) {
                  return;
                }
                await AppDialog.show(
                  context: context,
                  title: 'File format saved',
                  message: 'Template saved to:\n$savedPath',
                  type: AppDialogType.success,
                );
              } catch (error) {
                if (!context.mounted) {
                  return;
                }
                await AppDialog.show(
                  context: context,
                  title: 'Download failed',
                  message: userFriendlyErrorMessage(error),
                  type: AppDialogType.error,
                );
              }
            }

            Future<void> submit() async {
              if (selectedProject == null) {
                await AppDialog.show(
                  context: context,
                  type: AppDialogType.info,
                  title: 'Required',
                  message: 'Please select a project.',
                );
                return;
              }
              if (selectedContract == null) {
                await AppDialog.show(
                  context: context,
                  type: AppDialogType.info,
                  title: 'Required',
                  message: 'Please select a contract.',
                );
                return;
              }
              if (dataDate == null) {
                await AppDialog.show(
                  context: context,
                  type: AppDialogType.info,
                  title: 'Required',
                  message: 'Please select a data date.',
                );
                return;
              }
              if (pickedBytes == null || pickedBytes!.isEmpty) {
                await AppDialog.show(
                  context: context,
                  type: AppDialogType.info,
                  title: 'Required',
                  message: 'Please upload an Excel (.xlsx) file.',
                );
                return;
              }
              setDialogState(() => dialogSaving = true);
              try {
                await widget.dataSource.submitP6NewDataUpload(
                  endpoint: kind.endpoint,
                  projectIdFk: selectedProject!.value,
                  contractIdFk: selectedContract!.value,
                  dataDate: _apiDateFormat.format(dataDate!),
                  fileName: pickedFileName ?? 'p6_upload.xlsx',
                  bytes: pickedBytes!,
                  includeFobId: kind.includeFobId,
                );
                if (!context.mounted) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                await AppDialog.show(
                  context: context,
                  title: 'Uploaded',
                  message: '${kind.label} uploaded successfully.',
                  type: AppDialogType.success,
                );
                if (mounted) {
                  await _reloadAll();
                }
              } catch (error) {
                if (!context.mounted) {
                  return;
                }
                await AppDialog.show(
                  context: context,
                  title: 'Upload failed',
                  message: userFriendlyErrorMessage(error),
                  type: AppDialogType.error,
                );
              } finally {
                if (context.mounted) {
                  setDialogState(() => dialogSaving = false);
                }
              }
            }

            return AlertDialog(
              title: Text('Add ${kind.label}'),
              content: dialogLoading
                  ? const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : loadError != null
                  ? Text(loadError)
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AppSelectSheetField<_P6Option>(
                            label: 'Project *',
                            title: 'Select Project',
                            items: projects,
                            value: selectedProject,
                            itemLabelBuilder: (_P6Option o) => o.label,
                            onChanged: (_P6Option value) => setDialogState(() {
                              selectedProject = value;
                              selectedContract = null;
                            }),
                            placeholderText: 'Select project',
                            enabled: !dialogSaving,
                          ),
                          const SizedBox(height: 10),
                          AppSelectSheetField<_P6Option>(
                            label: 'Contract *',
                            title: 'Select Contract',
                            items: contractOptions,
                            value: selectedContract,
                            itemLabelBuilder: (_P6Option o) => o.label,
                            onChanged: (_P6Option value) => setDialogState(
                              () => selectedContract = value,
                            ),
                            placeholderText: 'Select contract',
                            enabled: !dialogSaving && selectedProject != null,
                          ),
                          const SizedBox(height: 10),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Data Date *'),
                            subtitle: Text(
                              dataDate == null
                                  ? 'Select date'
                                  : _apiDateFormat.format(dataDate!),
                            ),
                            trailing: const Icon(Icons.calendar_month_rounded),
                            onTap: dialogSaving ? null : pickDate,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: dialogSaving ? null : pickFile,
                            icon: const Icon(Icons.upload_file_rounded),
                            label: Text(
                              pickedFileName ?? 'Upload Excel (.xlsx)',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text.rich(
                            TextSpan(
                              style: Theme.of(context).textTheme.bodySmall,
                              children: <InlineSpan>[
                                const TextSpan(
                                  text:
                                      'Note: Please make sure the uploading P6 data file will be in the given format. ',
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: dialogSaving ? null : downloadFormat,
                                    child: Text(
                                      'Click here for the file format',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              actions: <Widget>[
                TextButton(
                  onPressed: dialogSaving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: dialogLoading || loadError != null || dialogSaving
                      ? null
                      : submit,
                  child: dialogSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<_P6Option> _optionsFromList(
    List<dynamic> rows, {
    required List<String> idKeys,
    required List<String> labelKeys,
  }) {
    final List<_P6Option> out = <_P6Option>[];
    final Set<String> seen = <String>{};
    for (final dynamic row in rows) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = row.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      );
      String id = '';
      for (final String key in idKeys) {
        final String parsed = _safeString(map[key]) ?? '';
        if (parsed.isNotEmpty) {
          id = parsed;
          break;
        }
      }
      if (id.isEmpty || !seen.add(id)) {
        continue;
      }
      String label = '';
      for (final String key in labelKeys) {
        final String parsed = _safeString(map[key]) ?? '';
        if (parsed.isNotEmpty) {
          label = parsed;
          break;
        }
      }
      out.add(_P6Option(value: id, label: label.isEmpty ? id : label));
    }
    return out;
  }

  List<_P6Option> _dedupeOptions(Iterable<_P6Option> options) {
    final Map<String, _P6Option> byValue = <String, _P6Option>{};
    for (final _P6Option option in options) {
      if (option.value.isEmpty) {
        continue;
      }
      byValue.putIfAbsent(option.value, () => option);
    }
    final List<_P6Option> values = byValue.values.toList()
      ..sort(
        (_P6Option a, _P6Option b) =>
            a.label.toLowerCase().compareTo(b.label.toLowerCase()),
      );
    return values;
  }

  _P6Option _contractOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['contract_id']) ??
        _safeString(row['contract_id_fk']) ??
        '';
    final String label = _safeString(row['contract_short_name']) ??
        _safeString(row['contract_name']) ??
        value;
    return _P6Option(value: value, label: label);
  }

  _P6Option _uploadTypeOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['upload_type']) ?? '';
    return _P6Option(value: value, label: value);
  }

  _P6Option _statusOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['soft_delete_status_fk']) ?? '';
    return _P6Option(value: value, label: value);
  }

  String? _retainValid(String? selected, List<_P6Option> options) {
    if (selected == null) {
      return null;
    }
    final bool exists =
        options.any((_P6Option item) => item.value == selected);
    return exists ? selected : null;
  }

  double _columnWidth(String header) {
    return switch (header) {
      'Contract ID' => 120,
      'Data Type' => 130,
      'Data Date' => 120,
      'Status' => 100,
      'Uploaded File' => 220,
      'Uploaded By' => 130,
      'Uploaded Date' => 170,
      _ => 120,
    };
  }

  String _stringValue(dynamic value) => _safeString(value) ?? '-';

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

  int get _activeFilterCount {
    int count = 0;
    if (_selectedContract != null) count++;
    if (_selectedUploadType != null) count++;
    if (_selectedStatus != null) count++;
    return count;
  }

  List<Map<String, dynamic>> _filteredRows(List<Map<String, dynamic>> rows) {
    final String query = _search.toLowerCase();
    if (query.isEmpty) {
      return rows;
    }
    return rows.where((Map<String, dynamic> row) {
      return row.values.any(
        (dynamic value) => _stringValue(value).toLowerCase().contains(query),
      );
    }).toList();
  }

  Widget _dialogDropdown({
    required String label,
    required List<_P6Option> options,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextStyle? labelStyle = Theme.of(context).textTheme.titleMedium
        ?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        );
    final String selectedLabel = value == null
        ? 'All'
        : options
              .firstWhere(
                (_P6Option option) => option.value == value,
                orElse: () => _P6Option(value: value, label: value),
              )
              .label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(label, style: labelStyle),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final String? picked = await _pickFilterOption(
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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
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
                  const SizedBox(width: 8),
                  Icon(Icons.expand_more_rounded, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _pickFilterOption({
    required String title,
    required List<_P6Option> options,
    required String? selected,
  }) async {
    return showModalBottomSheet<String?>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
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
                    color: Theme.of(context).colorScheme.outlineVariant
                        .withValues(alpha: 0.6),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return ListTile(
                        title: const Text('All'),
                        trailing: selected == null
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(null),
                      );
                    }
                    final _P6Option option = options[index - 1];
                    final bool isSelected = option.value == selected;
                    return ListTile(
                      title: Text(
                        option.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
}
