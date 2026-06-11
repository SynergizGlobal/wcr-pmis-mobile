import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_date_form_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_text_form_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/core/widgets/app_multi_select_dropdown.dart';

class DmsUploadLetterDialog extends StatefulWidget {
  const DmsUploadLetterDialog({super.key, required this.dataSource});

  final DashboardRemoteDataSource dataSource;

  static Future<bool?> show(
    BuildContext context, {
    required DashboardRemoteDataSource dataSource,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => DmsUploadLetterDialog(dataSource: dataSource),
    );
  }

  @override
  State<DmsUploadLetterDialog> createState() => _DmsUploadLetterDialogState();
}

class _DmsOption {
  const _DmsOption({required this.id, required this.label});

  final String id;
  final String label;
}

class _DmsUserOption {
  const _DmsUserOption({
    required this.userId,
    required this.userName,
    required this.emailId,
  });

  final String userId;
  final String userName;
  final String emailId;

  String get displayLabel {
    if (emailId.isEmpty) {
      return userName;
    }
    return '$userName ($emailId)';
  }
}

class _DmsUploadLetterDialogState extends State<DmsUploadLetterDialog> {
  static const List<String> _categories = <String>[
    'Contract',
    'Technical',
    'Commercial',
    'Legal',
    'Administrative',
  ];
  static const List<String> _requiredResponseOptions = <String>['Yes', 'No'];

  final TextEditingController _letterNumberCtrl = TextEditingController();
  final TextEditingController _subjectCtrl = TextEditingController();
  final TextEditingController _keyInfoCtrl = TextEditingController();

  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  List<_DmsOption> _projects = <_DmsOption>[];
  List<_DmsOption> _contracts = <_DmsOption>[];
  List<_DmsOption> _departments = <_DmsOption>[];
  List<_DmsOption> _statuses = <_DmsOption>[];
  List<_DmsUserOption> _users = <_DmsUserOption>[];

  String? _category;
  _DmsOption? _project;
  _DmsOption? _contract;
  _DmsUserOption? _toUser;
  List<_DmsUserOption> _ccUsers = <_DmsUserOption>[];
  String? _requiredResponse;
  _DmsOption? _department;
  _DmsOption? _status;
  DateTime? _letterDate;
  DateTime? _dueDate;
  String? _attachmentName;
  Uint8List? _attachmentBytes;

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  @override
  void dispose() {
    _letterNumberCtrl.dispose();
    _subjectCtrl.dispose();
    _keyInfoCtrl.dispose();
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
        widget.dataSource.searchDmsUsers(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _projects = _mapOptions(results[0] as List<Map<String, dynamic>>);
        _contracts = _mapOptions(results[1] as List<Map<String, dynamic>>);
        _departments = _mapIdNameOptions(results[2] as List<Map<String, dynamic>>);
        _statuses = _mapIdNameOptions(results[3] as List<Map<String, dynamic>>);
        _users = _mapUsers(results[4] as List<Map<String, dynamic>>);
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

  List<_DmsUserOption> _mapUsers(List<Map<String, dynamic>> rows) {
    return rows
        .map(
          (Map<String, dynamic> row) => _DmsUserOption(
            userId: _str(row['userId']),
            userName: _str(row['userName']),
            emailId: _str(row['emailId']),
          ),
        )
        .where((_DmsUserOption u) => u.userName.isNotEmpty)
        .toList();
  }

  String _str(dynamic value) {
    if (value == null) {
      return '';
    }
    final String text = value.toString().trim();
    return text.toLowerCase() == 'null' ? '' : text;
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

  Future<void> _pickLetterDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _letterDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _letterDate = picked);
    }
  }

  Future<void> _pickDueDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  String? _validate({required bool requireAttachment}) {
    if (_category == null || _category!.isEmpty) {
      return 'Please select category.';
    }
    if (_project == null) {
      return 'Please select project.';
    }
    if (_contract == null) {
      return 'Please select contract.';
    }
    if (_letterNumberCtrl.text.trim().isEmpty) {
      return 'Please enter letter number.';
    }
    if (_letterDate == null) {
      return 'Please select letter date.';
    }
    if (_toUser == null) {
      return 'Please select To recipient.';
    }
    if (_subjectCtrl.text.trim().isEmpty) {
      return 'Please enter subject.';
    }
    if (_requiredResponse == null) {
      return 'Please select required response.';
    }
    if (_status == null) {
      return 'Please select status.';
    }
    if (_department == null) {
      return 'Please select department.';
    }
    if (requireAttachment &&
        (_attachmentBytes == null || _attachmentName == null)) {
      return 'Please attach a document.';
    }
    return null;
  }

  Map<String, dynamic> _buildDto(String action) {
    return <String, dynamic>{
      'correspondenceId': null,
      'category': _category,
      'projectName': _project!.label,
      'contractName': _contract!.label,
      'letterNumber': _letterNumberCtrl.text.trim(),
      'letterDate': _apiDateFormat.format(_letterDate!),
      'to': _toUser!.userName,
      'subject': _subjectCtrl.text.trim(),
      'keyInformation': _keyInfoCtrl.text.trim(),
      'requiredResponse': _requiredResponse,
      'dueDate': _dueDate == null ? '' : _apiDateFormat.format(_dueDate!),
      'currentStatus': int.tryParse(_status!.id) ?? _status!.id,
      'department': int.tryParse(_department!.id) ?? _department!.id,
      'cc': _ccUsers.map(( _DmsUserOption u) => u.userName).toList(),
      'referenceLetters': <String>[],
      'action': action,
      'removedExistingFiles': <String>[],
    };
  }

  Future<void> _submit({required String action, required bool requireAttachment}) async {
    final String? missing = _validate(requireAttachment: requireAttachment);
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
          await widget.dataSource.uploadCorrespondenceLetter(
        dto: _buildDto(action),
        documentBytes: _attachmentBytes,
        documentFileName: _attachmentName,
      );
      if (!mounted) {
        return;
      }
      final String message = _str(response['message']);
      final bool success = response['success'] == true ||
          message.toLowerCase().contains('success');
      if (!success) {
        await AppDialog.show(
          context: context,
          title: 'Upload failed',
          message: message.isNotEmpty ? message : 'Unable to upload letter.',
          type: AppDialogType.error,
        );
        return;
      }
      await AppDialog.show(
        context: context,
        title: action == 'Send' ? 'Sent' : 'Draft saved',
        message: message.isNotEmpty ? message : 'Letter saved successfully.',
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

  Widget _categoryField() {
    return AppSelectSheetField<String>(
      label: 'Category *',
      title: 'Select Category',
      items: _categories,
      value: _category,
      itemLabelBuilder: (String v) => v,
      onChanged: (String v) => setState(() => _category = v),
    );
  }

  Widget _projectField() {
    return AppSelectSheetField<_DmsOption>(
      label: 'Project Name *',
      title: 'Select Project',
      items: _projects,
      value: _project,
      placeholderText: 'Search Project...',
      itemLabelBuilder: ( _DmsOption o) => o.label,
      onChanged: ( _DmsOption v) => setState(() => _project = v),
    );
  }

  Widget _contractField() {
    return AppSelectSheetField<_DmsOption>(
      label: 'Contract Name *',
      title: 'Select Contract',
      items: _contracts,
      value: _contract,
      placeholderText: 'Search Contract...',
      itemLabelBuilder: ( _DmsOption o) => o.label,
      onChanged: ( _DmsOption v) => setState(() => _contract = v),
    );
  }

  Widget _toField() {
    return AppSelectSheetField<_DmsUserOption>(
      label: 'To *',
      title: 'Select Recipient',
      items: _users,
      value: _toUser,
      placeholderText: 'Search recipient...',
      itemLabelBuilder: ( _DmsUserOption u) => u.displayLabel,
      onChanged: ( _DmsUserOption v) => setState(() => _toUser = v),
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
                      'Upload Letter',
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
                          _categoryField(),
                          const SizedBox(height: 10),
                          _projectField(),
                          const SizedBox(height: 10),
                          _contractField(),
                          const SizedBox(height: 10),
                          AppTextFormField(
                            controller: _letterNumberCtrl,
                            label: 'Letter Number *',
                            hintText: 'Enter letter number',
                          ),
                          const SizedBox(height: 10),
                          AppDateFormField(
                            label: 'Letter Date *',
                            value: _letterDate,
                            onTap: _pickLetterDate,
                          ),
                          const SizedBox(height: 10),
                          _toField(),
                          const SizedBox(height: 10),
                          AppMultiSelectDropdown<_DmsUserOption>(
                            label: 'CC',
                            hint: 'Search CC recipients...',
                            items: _users,
                            selectedItems: _ccUsers,
                            itemLabel: ( _DmsUserOption u) => u.displayLabel,
                            onChanged: (List<_DmsUserOption> value) =>
                                setState(() => _ccUsers = value),
                          ),
                          const SizedBox(height: 10),
                          AppTextFormField(
                            controller: _subjectCtrl,
                            label: 'Subject *',
                            hintText: 'Enter subject',
                            minLines: 2,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 10),
                          AppTextFormField(
                            controller: _keyInfoCtrl,
                            label: 'Key Information',
                            hintText: 'Enter key information',
                            minLines: 2,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 10),
                          AppSelectSheetField<String>(
                            label: 'Required Response *',
                            title: 'Required Response',
                            items: _requiredResponseOptions,
                            value: _requiredResponse,
                            placeholderText: 'Select Required Response',
                            itemLabelBuilder: (String v) => v,
                            onChanged: (String v) =>
                                setState(() => _requiredResponse = v),
                          ),
                          const SizedBox(height: 10),
                          AppDateFormField(
                            label: 'Due Date',
                            value: _dueDate,
                            onTap: _pickDueDate,
                          ),
                          const SizedBox(height: 10),
                          AppSelectSheetField<_DmsOption>(
                            label: 'Status *',
                            title: 'Select Status',
                            items: _statuses,
                            value: _status,
                            placeholderText: 'Select Status',
                            itemLabelBuilder: ( _DmsOption o) => o.label,
                            onChanged: ( _DmsOption v) => setState(() => _status = v),
                          ),
                          const SizedBox(height: 10),
                          AppSelectSheetField<_DmsOption>(
                            label: 'Department *',
                            title: 'Select Department',
                            items: _departments,
                            value: _department,
                            placeholderText: 'Search Department...',
                            itemLabelBuilder: ( _DmsOption o) => o.label,
                            onChanged: ( _DmsOption v) =>
                                setState(() => _department = v),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: _pickAttachment,
                            icon: const Icon(Icons.attach_file_rounded),
                            label: Text(
                              _attachmentName ?? 'Attachment * — Choose file',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (!_loading && _loadError == null)
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
                        onPressed: _saving
                            ? null
                            : () => _submit(
                                  action: 'Send',
                                  requireAttachment: true,
                                ),
                        child: const Text('Send'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: _saving
                            ? null
                            : () => _submit(
                                  action: 'Save as Draft',
                                  requireAttachment: false,
                                ),
                        child: const Text('Save as draft'),
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
