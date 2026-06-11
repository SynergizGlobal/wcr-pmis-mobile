import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_date_form_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_text_form_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

class DmsUploadDocumentDialog extends StatefulWidget {
  const DmsUploadDocumentDialog({super.key, required this.dataSource});

  final DashboardRemoteDataSource dataSource;

  static Future<bool?> show(
    BuildContext context, {
    required DashboardRemoteDataSource dataSource,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          DmsUploadDocumentDialog(dataSource: dataSource),
    );
  }

  @override
  State<DmsUploadDocumentDialog> createState() =>
      _DmsUploadDocumentDialogState();
}

class _DmsOption {
  const _DmsOption({required this.id, required this.label});

  final String id;
  final String label;
}

class _DmsFolderItem {
  const _DmsFolderItem({
    required this.id,
    required this.name,
    required this.parentId,
    required this.path,
  });

  final int id;
  final String name;
  final int? parentId;
  final String path;
}

class _DmsUploadDocumentDialogState extends State<DmsUploadDocumentDialog> {
  final TextEditingController _fileNameCtrl = TextEditingController();
  final TextEditingController _fileNumberCtrl = TextEditingController();
  final TextEditingController _revisionNoCtrl = TextEditingController(
    text: 'R01',
  );
  final TextEditingController _folderSearchCtrl = TextEditingController();
  final TextEditingController _newFolderCtrl = TextEditingController();

  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  bool _loading = true;
  bool _saving = false;
  bool _creatingFolder = false;
  String? _loadError;
  int _uploadMode = 0;

  List<_DmsOption> _projects = <_DmsOption>[];
  List<_DmsOption> _contracts = <_DmsOption>[];
  List<_DmsOption> _departments = <_DmsOption>[];
  List<_DmsOption> _statuses = <_DmsOption>[];
  List<_DmsFolderItem> _folders = <_DmsFolderItem>[];
  String _folderSearch = '';

  _DmsOption? _project;
  _DmsOption? _contract;
  _DmsOption? _department;
  _DmsOption? _status;
  _DmsFolderItem? _selectedFolder;
  DateTime? _revisionDate;
  String? _attachmentName;
  Uint8List? _attachmentBytes;

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  @override
  void dispose() {
    _fileNameCtrl.dispose();
    _fileNumberCtrl.dispose();
    _revisionNoCtrl.dispose();
    _folderSearchCtrl.dispose();
    _newFolderCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
        widget.dataSource.fetchDmsProjectNames(),
        widget.dataSource.fetchDmsContractNames(),
        widget.dataSource.fetchDmsDepartments(),
        widget.dataSource.fetchDmsStatuses(),
        widget.dataSource.fetchDmsFolders(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _projects = _mapOptions(results[0] as List<Map<String, dynamic>>);
        _contracts = _mapOptions(results[1] as List<Map<String, dynamic>>);
        _departments = _mapIdNameOptions(results[2] as List<Map<String, dynamic>>);
        _statuses = _mapIdNameOptions(results[3] as List<Map<String, dynamic>>);
        _folders = _mapFolders(results[4] as List<Map<String, dynamic>>);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadError = error.toString();
      });
    }
  }

  List<_DmsOption> _mapOptions(List<Map<String, dynamic>> rows) {
    return rows
        .map(
          (Map<String, dynamic> row) => _DmsOption(
            id: _str(row['id']),
            label: _str(row['name']).isNotEmpty ? _str(row['name']) : _str(row['id']),
          ),
        )
        .where((_DmsOption o) => o.id.isNotEmpty || o.label.isNotEmpty)
        .toList();
  }

  List<_DmsOption> _mapIdNameOptions(List<Map<String, dynamic>> rows) {
    return rows
        .map(
          (Map<String, dynamic> row) => _DmsOption(
            id: _str(row['id']),
            label: _str(row['name']),
          ),
        )
        .where((_DmsOption o) => o.label.isNotEmpty)
        .toList();
  }

  List<_DmsFolderItem> _mapFolders(List<Map<String, dynamic>> rows) {
    final Map<int, Map<String, dynamic>> byId = <int, Map<String, dynamic>>{};
    for (final Map<String, dynamic> row in rows) {
      final int? id = int.tryParse(_str(row['id']));
      if (id == null) {
        continue;
      }
      byId[id] = row;
    }

    String folderPath(int id) {
      final Map<String, dynamic>? row = byId[id];
      if (row == null) {
        return '';
      }
      final String name = _str(row['name']);
      final int? parentId = int.tryParse(_str(row['parentId']));
      if (parentId == null || !byId.containsKey(parentId)) {
        return name;
      }
      final String parentPath = folderPath(parentId);
      return parentPath.isEmpty ? name : '$parentPath/$name';
    }

    final List<_DmsFolderItem> folders = byId.entries
        .map((MapEntry<int, Map<String, dynamic>> entry) {
          final Map<String, dynamic> row = entry.value;
          final int? parentId = int.tryParse(_str(row['parentId']));
          return _DmsFolderItem(
            id: entry.key,
            name: _str(row['name']),
            parentId: parentId,
            path: folderPath(entry.key),
          );
        })
        .where((_DmsFolderItem f) => f.name.isNotEmpty)
        .toList()
      ..sort(
        ( _DmsFolderItem a, _DmsFolderItem b) => a.path.compareTo(b.path),
      );
    return folders;
  }

  List<_DmsFolderItem> get _visibleFolders {
    if (_folderSearch.trim().isEmpty) {
      return _folders;
    }
    final String q = _folderSearch.trim().toLowerCase();
    return _folders
        .where(
          (_DmsFolderItem f) =>
              f.name.toLowerCase().contains(q) ||
              f.path.toLowerCase().contains(q),
        )
        .toList();
  }

  String _str(dynamic value) {
    if (value == null) {
      return '';
    }
    final String text = value.toString().trim();
    return text.toLowerCase() == 'null' ? '' : text;
  }

  Future<void> _pickRevisionDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _revisionDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _revisionDate = picked);
    }
  }

  Future<void> _pickAttachment() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>[
        'png',
        'jpg',
        'jpeg',
        'pdf',
        'xls',
        'xlsx',
        'doc',
        'docx',
      ],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final PlatformFile file = result.files.first;
    setState(() {
      _attachmentName = file.name;
      _attachmentBytes = file.bytes;
    });
  }

  Future<void> _createFolder() async {
    final String name = _newFolderCtrl.text.trim();
    if (name.isEmpty) {
      await AppDialog.show(
        context: context,
        title: 'Required',
        message: 'Please enter a folder name.',
        type: AppDialogType.info,
      );
      return;
    }
    setState(() => _creatingFolder = true);
    try {
      final Map<String, dynamic> response =
          await widget.dataSource.createDmsFolder(
        name: name,
        parentId: _selectedFolder?.id,
      );
      if (!mounted) {
        return;
      }
      final int? newId = int.tryParse(_str(response['id']));
      await _reloadFolders(selectId: newId);
      _newFolderCtrl.clear();
      if (mounted) {
        await AppDialog.show(
          context: context,
          title: 'Folder created',
          message: 'Folder "$name" was added successfully.',
          type: AppDialogType.success,
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Create folder failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _creatingFolder = false);
      }
    }
  }

  Future<void> _reloadFolders({int? selectId}) async {
    final List<Map<String, dynamic>> rows = await widget.dataSource.fetchDmsFolders();
    if (!mounted) {
      return;
    }
    final List<_DmsFolderItem> folders = _mapFolders(rows);
    _DmsFolderItem? selected;
    if (selectId != null) {
      for (final _DmsFolderItem folder in folders) {
        if (folder.id == selectId) {
          selected = folder;
          break;
        }
      }
    } else if (_selectedFolder != null) {
      for (final _DmsFolderItem folder in folders) {
        if (folder.id == _selectedFolder!.id) {
          selected = folder;
          break;
        }
      }
    }
    setState(() {
      _folders = folders;
      _selectedFolder = selected;
    });
  }

  String? _validate() {
    if (_fileNameCtrl.text.trim().isEmpty) {
      return 'Please enter file name.';
    }
    if (_fileNumberCtrl.text.trim().isEmpty) {
      return 'Please enter file number.';
    }
    if (_revisionNoCtrl.text.trim().isEmpty) {
      return 'Please enter revision number.';
    }
    if (_revisionDate == null) {
      return 'Please select revision date.';
    }
    if (_project == null) {
      return 'Please select project name.';
    }
    if (_contract == null) {
      return 'Please select contract name.';
    }
    if (_selectedFolder == null) {
      return 'Please select a folder.';
    }
    if (_department == null) {
      return 'Please select department.';
    }
    if (_status == null) {
      return 'Please select status.';
    }
    if (_attachmentBytes == null || _attachmentName == null) {
      return 'Please choose a document file.';
    }
    return null;
  }

  Map<String, dynamic> _buildDto() {
    return <String, dynamic>{
      'fileName': _fileNameCtrl.text.trim(),
      'fileNumber': _fileNumberCtrl.text.trim(),
      'revisionNo': _revisionNoCtrl.text.trim(),
      'revisionDate': _apiDateFormat.format(_revisionDate!),
      'projectName': _project!.label,
      'contractName': _contract!.label,
      'department': int.tryParse(_department!.id) ?? _department!.id,
      'currentStatus': int.tryParse(_status!.id) ?? _status!.id,
      'path': _selectedFolder!.path,
      'folderId': _selectedFolder!.id,
    };
  }

  Future<void> _submit() async {
    final String? missing = _validate();
    if (missing != null) {
      await AppDialog.show(
        context: context,
        title: 'Required',
        message: missing,
        type: AppDialogType.info,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final Map<String, dynamic> response =
          await widget.dataSource.uploadDmsDocument(
        dto: _buildDto(),
        fileBytes: _attachmentBytes!,
        fileName: _attachmentName!,
      );
      if (!mounted) {
        return;
      }
      final String message = _str(response['message']);
      final bool success = response['success'] == true ||
          message.toLowerCase().contains('success');
      if (!success && message.isNotEmpty && !message.toLowerCase().contains('uploaded')) {
        await AppDialog.show(
          context: context,
          title: 'Upload failed',
          message: message,
          type: AppDialogType.error,
        );
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Uploaded',
        message: message.isNotEmpty ? message : 'Document uploaded successfully.',
        type: AppDialogType.success,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Upload failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _uploadModeSelector(ColorScheme cs) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _modeChip(
              label: 'Single Upload',
              selected: _uploadMode == 0,
              onTap: () => setState(() => _uploadMode = 0),
            ),
          ),
          Expanded(
            child: _modeChip(
              label: 'Bulk Upload',
              selected: _uploadMode == 1,
              onTap: () => setState(() => _uploadMode = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? cs.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: selected
                ? Border(
                    bottom: BorderSide(color: cs.primary, width: 2.5),
                  )
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _folderSection(ColorScheme cs) {
    final List<_DmsFolderItem> visible = _visibleFolders;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Select Folder *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _folderSearchCtrl,
          decoration: const InputDecoration(
            hintText: 'Search folders...',
            prefixIcon: Icon(Icons.search_rounded),
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onChanged: (String value) => setState(() => _folderSearch = value),
        ),
        const SizedBox(height: 8),
        Text(
          'Selected Folder: ${_selectedFolder?.path ?? 'None'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: visible.isEmpty
              ? Center(
                  child: Text(
                    'No folders match your search.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final _DmsFolderItem folder = visible[index];
                    final bool selected = _selectedFolder?.id == folder.id;
                    return ListTile(
                      dense: true,
                      selected: selected,
                      selectedTileColor: cs.primary.withValues(alpha: 0.08),
                      leading: Icon(
                        Icons.folder_outlined,
                        color: selected ? cs.primary : cs.onSurfaceVariant,
                        size: 20,
                      ),
                      title: Text(
                        folder.name,
                        style: TextStyle(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? cs.primary : cs.onSurface,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: folder.path == folder.name
                          ? null
                          : Text(
                              folder.path,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                      onTap: () => setState(() => _selectedFolder = folder),
                    );
                  },
                ),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: AppTextFormField(
                controller: _newFolderCtrl,
                label: 'New Folder Name',
                hintText: 'Enter folder name',
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _creatingFolder || _saving ? null : _createFolder,
              icon: _creatingFolder
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.create_new_folder_outlined, size: 18),
              label: const Text('Add Folder'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Live Preview: ${_selectedFolder?.path ?? '—'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _singleUploadForm(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppTextFormField(
          controller: _fileNameCtrl,
          label: 'File Name *',
          hintText: 'Enter file name',
        ),
        const SizedBox(height: 10),
        AppTextFormField(
          controller: _fileNumberCtrl,
          label: 'File Number *',
          hintText: 'Enter file number',
        ),
        const SizedBox(height: 10),
        AppTextFormField(
          controller: _revisionNoCtrl,
          label: 'Revision No *',
          hintText: 'R01',
        ),
        const SizedBox(height: 10),
        AppDateFormField(
          label: 'Revision Date *',
          value: _revisionDate,
          onTap: _pickRevisionDate,
        ),
        const SizedBox(height: 10),
        AppSelectSheetField<_DmsOption>(
          label: 'Project Name *',
          title: 'Select Project',
          items: _projects,
          value: _project,
          placeholderText: 'Search Project...',
          itemLabelBuilder: (_DmsOption o) => o.label,
          onChanged: (_DmsOption v) => setState(() => _project = v),
        ),
        const SizedBox(height: 10),
        AppSelectSheetField<_DmsOption>(
          label: 'Contract Name *',
          title: 'Select Contract',
          items: _contracts,
          value: _contract,
          placeholderText: 'Search Contract...',
          itemLabelBuilder: (_DmsOption o) => o.label,
          onChanged: (_DmsOption v) => setState(() => _contract = v),
        ),
        const SizedBox(height: 14),
        _folderSection(cs),
        const SizedBox(height: 14),
        AppSelectSheetField<_DmsOption>(
          label: 'Department *',
          title: 'Select Department',
          items: _departments,
          value: _department,
          placeholderText: 'Search Department...',
          itemLabelBuilder: (_DmsOption o) => o.label,
          onChanged: (_DmsOption o) => setState(() => _department = o),
        ),
        const SizedBox(height: 10),
        AppSelectSheetField<_DmsOption>(
          label: 'Status *',
          title: 'Select Status',
          items: _statuses,
          value: _status,
          placeholderText: 'Select Status',
          itemLabelBuilder: (_DmsOption o) => o.label,
          onChanged: (_DmsOption o) => setState(() => _status = o),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _pickAttachment,
          icon: const Icon(Icons.attach_file_rounded),
          label: Text(
            _attachmentName ?? 'Document File * — Choose file',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
          maxWidth: 720,
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: cs.primary,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Upload Documents',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: cs.onPrimary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _loadError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              _loadError!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _loadLookups,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _uploadModeSelector(cs),
                          const SizedBox(height: 14),
                          if (_uploadMode == 0)
                            _singleUploadForm(cs)
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 48),
                              child: Text(
                                'Bulk upload will be connected in the next update.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            if (!_loading && _loadError == null && _uploadMode == 0)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  border: Border(
                    top: BorderSide(color: cs.outlineVariant),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            if (_saving)
              const LinearProgressIndicator(minHeight: 2),
          ],
        ),
      ),
    );
  }
}
