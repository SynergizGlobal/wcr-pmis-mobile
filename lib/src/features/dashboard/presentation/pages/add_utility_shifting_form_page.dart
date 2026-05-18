import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_step_header.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

String _normJsonKey(String s) =>
    s.toLowerCase().replaceAll('_', '').replaceAll('-', '');

Map<String, dynamic> _asStringKeyedMap(dynamic data) {
  if (data is! Map) {
    return <String, dynamic>{};
  }
  final Map<Object?, Object?> map = data as Map<Object?, Object?>;
  return Map<String, dynamic>.fromEntries(
    map.entries.map(
      (MapEntry<Object?, Object?> e) =>
          MapEntry<String, dynamic>(e.key.toString(), e.value),
    ),
  );
}

bool _shouldReplaceMergedValue(dynamic existing, dynamic v) {
  if (existing == null) {
    return true;
  }
  if (v is! List) {
    return false;
  }
  if (existing is! List) {
    return true;
  }
  return existing.isEmpty;
}

Map<String, dynamic> _mergedUtilityFormRoot(Map<String, dynamic> root) {
  Map<String, dynamic> merged = Map<String, dynamic>.from(root);
  void pullFrom(dynamic node) {
    if (node is! Map) {
      return;
    }
    final Map<String, dynamic> inner = _asStringKeyedMap(node);
    inner.forEach((String k, dynamic v) {
      final dynamic existing = merged[k];
      if (_shouldReplaceMergedValue(existing, v)) {
        merged[k] = v;
      }
    });
  }

  for (final String key in <String>[
    'data',
    'model',
    'result',
    'body',
    'response',
    'payload',
  ]) {
    pullFrom(merged[key]);
  }
  return merged;
}

dynamic _mapGetIgnoreCase(Map<String, dynamic> m, String wanted) {
  final String wl = wanted.toLowerCase();
  for (final MapEntry<String, dynamic> e in m.entries) {
    if (e.key.toLowerCase() == wl) {
      return e.value;
    }
  }
  return null;
}

List<dynamic>? _firstNonEmptyList(Map<String, dynamic> m, List<String> keys) {
  for (final String k in keys) {
    final dynamic v = m[k] ?? _mapGetIgnoreCase(m, k);
    if (v is List && v.isNotEmpty) {
      return v;
    }
  }
  for (final MapEntry<String, dynamic> e in m.entries) {
    if (e.value is! List || (e.value as List<dynamic>).isEmpty) {
      continue;
    }
    final String en = _normJsonKey(e.key);
    for (final String k in keys) {
      if (en == _normJsonKey(k)) {
        return e.value as List<dynamic>;
      }
    }
  }
  return null;
}

List<dynamic> _utilityFormList(Map<String, dynamic> m, List<String> keys) =>
    _firstNonEmptyList(m, keys) ?? const <dynamic>[];

String _pickMapValue(Map<String, dynamic> map, List<String> keys) {
  for (final String key in keys) {
    final dynamic value = map[key] ?? _mapGetIgnoreCase(map, key);
    final String parsed = value?.toString().trim() ?? '';
    if (parsed.isNotEmpty && parsed.toLowerCase() != 'null') {
      return parsed;
    }
  }
  return '';
}

String _inferOptionId(Map<String, dynamic> map) {
  final String picked = _pickMapValue(map, const <String>[
    'id',
    'value',
    'work_id_pk',
    'work_id_fk',
    'utility_type_id_pk',
    'utility_type_fk',
    'utility_category_id_pk',
    'utility_category_fk',
    'execution_agency_id_pk',
    'execution_agency_fk',
    'contract_id_pk',
    'contract_id_fk',
    'contract_id',
    'impacted_contract_id_fk',
    'requirement_stage_id_pk',
    'requirement_stage_fk',
    'requirement_state_fk',
    'impacted_element_id_pk',
    'impacted_element_fk',
    'impacted_element',
    'unit_id_pk',
    'unit_fk',
    'status_id_pk',
    'shifting_status_fk',
    'hod_id_pk',
    'hod_fk',
    'utility_shifting_file_type_id_pk',
    'utility_shifting_file_type_fk',
    'file_type_fk',
    'filetype_id',
  ]);
  if (picked.isNotEmpty) {
    return picked;
  }
  for (final MapEntry<String, dynamic> e in map.entries) {
    final String key = e.key.toString().toLowerCase();
    final String val = e.value?.toString().trim() ?? '';
    if (val.isEmpty || val.toLowerCase() == 'null') {
      continue;
    }
    if (key.endsWith('_fk') ||
        key.endsWith('_pk') ||
        key.endsWith('_id') ||
        key == 'id') {
      return val;
    }
  }
  return '';
}

String _inferOptionLabel(Map<String, dynamic> map) {
  final String picked = _pickMapValue(map, const <String>[
    'label',
    'name',
    'text',
    'title',
    'display_name',
    'project_name',
    'work_name',
    'contract_name',
    'contract_code',
    'contract_short_name',
    'utility_type',
    'utility_type_name',
    'utility_category',
    'utility_category_name',
    'execution_agency',
    'execution_agency_name',
    'agency_name',
    'stage_name',
    'requirement_stage',
    'requirement_stage_name',
    'requirement_state',
    'element_name',
    'impacted_element',
    'unit_name',
    'status_name',
    'shifting_status',
    'hod_name',
    'description',
    'location_name',
    'execution_agency_fk',
    'utility_type_fk',
    'utility_category_fk',
    'requirement_stage_fk',
    'requirement_state_fk',
    'unit_fk',
    'shifting_status_fk',
    'utility_shifting_file_type_fk',
    'file_type_name',
    'filetype_name',
    'file_type',
  ]);
  if (picked.isNotEmpty) {
    return picked.length > 120 ? '${picked.substring(0, 117)}...' : picked;
  }
  for (final MapEntry<String, dynamic> e in map.entries) {
    final String key = e.key.toString().toLowerCase();
    final String val = e.value?.toString().trim() ?? '';
    if (val.isEmpty || val.toLowerCase() == 'null') {
      continue;
    }
    if (key.endsWith('_fk') || key.endsWith('_pk')) {
      continue;
    }
    if (key.endsWith('_name') ||
        key == 'name' ||
        key.contains('label') ||
        key.contains('title') ||
        key.contains('description')) {
      return val.length > 120 ? '${val.substring(0, 117)}...' : val;
    }
  }
  for (final MapEntry<String, dynamic> e in map.entries) {
    final String key = e.key.toString().toLowerCase();
    final String val = e.value?.toString().trim() ?? '';
    if (val.isEmpty || val.toLowerCase() == 'null') {
      continue;
    }
    if (key.endsWith('_fk') || key.endsWith('_pk')) {
      continue;
    }
    if (key == 'id' && map.length > 1) {
      continue;
    }
    if (val.length > 120) {
      continue;
    }
    return val;
  }
  return '';
}

class _ProgressRow {
  _ProgressRow()
      : id =
            '${DateTime.now().microsecondsSinceEpoch}_${identityHashCode(Object())}',
        workCtrl = TextEditingController();

  final String id;
  final TextEditingController workCtrl;
  DateTime? date;

  void dispose() {
    workCtrl.dispose();
  }
}

class _AttachmentRow {
  _AttachmentRow()
      : id =
            '${DateTime.now().microsecondsSinceEpoch}_${identityHashCode(Object())}',
        nameCtrl = TextEditingController();

  final String id;
  final TextEditingController nameCtrl;
  _OptionItem? fileType;
  Uint8List? bytes;
  String? pickedFileName;

  void dispose() {
    nameCtrl.dispose();
  }
}

class AddUtilityShiftingFormPage extends StatefulWidget {
  const AddUtilityShiftingFormPage({super.key, required this.dataSource});

  static const String routeName = 'add-utility-shifting-form';
  static const String routePath = '/add-utility-shifting-form';

  final DashboardRemoteDataSource dataSource;

  @override
  State<AddUtilityShiftingFormPage> createState() =>
      _AddUtilityShiftingFormPageState();
}

class _AddUtilityShiftingFormPageState
    extends State<AddUtilityShiftingFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _saving = false;
  int _currentStep = 0;

  List<_OptionItem> _projects = <_OptionItem>[];
  List<_OptionItem> _executionAgencies = <_OptionItem>[];
  List<_OptionItem> _hods = <_OptionItem>[];
  List<_OptionItem> _utilityTypes = <_OptionItem>[];
  List<_OptionItem> _utilityCategories = <_OptionItem>[];
  List<_OptionItem> _impactedContracts = <_OptionItem>[];
  List<_OptionItem> _requirementStages = <_OptionItem>[];
  List<_OptionItem> _impactedElements = <_OptionItem>[];
  List<_OptionItem> _units = <_OptionItem>[];
  List<_OptionItem> _statuses = <_OptionItem>[];
  List<_OptionItem> _fileTypes = <_OptionItem>[];

  final List<_ProgressRow> _progressRows = <_ProgressRow>[];
  final List<_AttachmentRow> _attachmentRows = <_AttachmentRow>[];

  _OptionItem? _project;
  _OptionItem? _executionAgency;
  _OptionItem? _hod;
  _OptionItem? _utilityType;
  _OptionItem? _utilityCategory;
  _OptionItem? _impactedContract;
  _OptionItem? _requirementStage;
  _OptionItem? _impactedElement;
  _OptionItem? _unit;
  _OptionItem? _status;

  final TextEditingController _utilityDescriptionCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _custodianCtrl = TextEditingController();
  final TextEditingController _referenceNumberCtrl = TextEditingController();
  final TextEditingController _executedByCtrl = TextEditingController();
  final TextEditingController _chainageCtrl = TextEditingController();
  final TextEditingController _latitudeCtrl = TextEditingController();
  final TextEditingController _longitudeCtrl = TextEditingController();
  final TextEditingController _affectedStructuresCtrl = TextEditingController();
  final TextEditingController _scopeCtrl = TextEditingController();
  final TextEditingController _completedCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();

  DateTime? _identificationDate;
  DateTime? _targetDate;
  DateTime? _startDate;
  DateTime? _completionDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadForm());
  }

  @override
  void dispose() {
    _utilityDescriptionCtrl.dispose();
    _locationCtrl.dispose();
    _custodianCtrl.dispose();
    _referenceNumberCtrl.dispose();
    _executedByCtrl.dispose();
    _chainageCtrl.dispose();
    _latitudeCtrl.dispose();
    _longitudeCtrl.dispose();
    _affectedStructuresCtrl.dispose();
    _scopeCtrl.dispose();
    _completedCtrl.dispose();
    _remarksCtrl.dispose();
    for (final _ProgressRow r in _progressRows) {
      r.dispose();
    }
    for (final _AttachmentRow r in _attachmentRows) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Utility Shifting')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: AppStepHeader(
                title: 'Utility Setup',
                currentStep: _currentStep,
                stepTitles: const <String>[
                  'Basic Utility',
                  'Impact & Timeline',
                  'Progress & attachments',
                ],
                chipLabels: const <String>['Basic', 'Impact', 'Files'],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                        children: <Widget>[
                          if (_currentStep == 0) _stepBasic(),
                          if (_currentStep == 1) _stepImpact(),
                          if (_currentStep == 2) _stepProgressAttachments(),
                        ],
                      ),
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                  top: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving
                            ? null
                            : () => setState(() => _currentStep -= 1),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saving
                          ? null
                          : _currentStep == 2
                          ? _submit
                          : _nextStep,
                      icon: Icon(
                        _currentStep == 2
                            ? Icons.save_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        _currentStep == 2 ? 'Save Utility' : 'Continue',
                      ),
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

  Widget _stepBasic() {
    return Column(
      children: <Widget>[
        _grid(<Widget>[
          _selectField(
            label: 'Project',
            title: 'Select Project',
            value: _project,
            items: _projects,
            onChanged: (_OptionItem value) => setState(() => _project = value),
            placeholder: 'Select Project',
          ),
          _selectField(
            label: 'Execution Agency *',
            title: 'Select Execution Agency',
            value: _executionAgency,
            items: _executionAgencies,
            onChanged: (_OptionItem value) =>
                setState(() => _executionAgency = value),
            placeholder: 'Select Execution Agency',
          ),
          _selectField(
            label: 'HOD *',
            title: 'Select HOD',
            value: _hod,
            items: _hods,
            onChanged: (_OptionItem value) => setState(() => _hod = value),
            placeholder: 'Select HOD',
          ),
          _selectField(
            label: 'Utility type *',
            title: 'Select utility type',
            value: _utilityType,
            items: _utilityTypes,
            onChanged: (_OptionItem value) =>
                setState(() => _utilityType = value),
            placeholder: 'Select utility type',
          ),
          _selectField(
            label: 'Utility category',
            title: 'Select utility category',
            value: _utilityCategory,
            items: _utilityCategories,
            onChanged: (_OptionItem value) =>
                setState(() => _utilityCategory = value),
            placeholder: 'Select utility category',
          ),
          _textField(
            controller: _utilityDescriptionCtrl,
            label: 'Utility Description *',
            hint: 'Enter Utility Description',
            maxLines: 2,
          ),
          _textField(
            controller: _locationCtrl,
            label: 'Location Name',
            hint: 'Enter Location Name',
          ),
          _textField(
            controller: _custodianCtrl,
            label: 'Custodian',
            hint: 'Enter Custodian',
          ),
          _dateField(
            label: 'Identification Date',
            value: _identificationDate,
            onPick: (DateTime value) =>
                setState(() => _identificationDate = value),
          ),
          _textField(
            controller: _referenceNumberCtrl,
            label: 'Reference Number',
            hint: 'Enter Reference Number',
          ),
          _textField(
            controller: _executedByCtrl,
            label: 'Executed By',
            hint: 'Enter Executed By',
          ),
          _textField(
            controller: _chainageCtrl,
            label: 'Chainage',
            hint: 'Enter Chainage',
          ),
        ]),
      ],
    );
  }

  Widget _stepImpact() {
    return Column(
      children: <Widget>[
        _grid(<Widget>[
          _textField(
            controller: _latitudeCtrl,
            label: 'Latitude',
            hint: 'Enter Latitude',
          ),
          _textField(
            controller: _longitudeCtrl,
            label: 'Longitude',
            hint: 'Enter Longitude',
          ),
          _selectField(
            label: 'Impacted contract *',
            title: 'Select impacted contract',
            value: _impactedContract,
            items: _impactedContracts,
            onChanged: (_OptionItem value) =>
                setState(() => _impactedContract = value),
            placeholder: 'Select impacted contract',
          ),
          _selectField(
            label: 'Requirement stage *',
            title: 'Select requirement stage',
            value: _requirementStage,
            items: _requirementStages,
            onChanged: (_OptionItem value) =>
                setState(() => _requirementStage = value),
            placeholder: 'Select requirement stage',
          ),
          _selectField(
            label: 'Impacted element',
            title: 'Select impacted element',
            value: _impactedElement,
            items: _impactedElements,
            onChanged: (_OptionItem value) =>
                setState(() => _impactedElement = value),
            placeholder: 'Select impacted element',
          ),
          _textField(
            controller: _affectedStructuresCtrl,
            label: 'Affected Structures',
            hint: 'Enter Affected Structures',
          ),
          _dateField(
            label: 'Target Date',
            value: _targetDate,
            onPick: (DateTime value) => setState(() => _targetDate = value),
          ),
          _textField(
            controller: _scopeCtrl,
            label: 'Scope',
            hint: 'Enter Scope',
          ),
          _textField(
            controller: _completedCtrl,
            label: 'Completed',
            hint: 'Enter Completed',
          ),
          _selectField(
            label: 'Unit',
            title: 'Select unit',
            value: _unit,
            items: _units,
            onChanged: (_OptionItem value) => setState(() => _unit = value),
            placeholder: 'Select unit',
          ),
          _dateField(
            label: 'Start Date',
            value: _startDate,
            onPick: (DateTime value) => setState(() => _startDate = value),
          ),
          _selectField(
            label: 'Status',
            title: 'Select status',
            value: _status,
            items: _statuses,
            onChanged: (_OptionItem value) => setState(() => _status = value),
            placeholder: 'Select status',
          ),
          _dateField(
            label: 'Completion Date',
            value: _completionDate,
            onPick: (DateTime value) => setState(() => _completionDate = value),
          ),
        ]),
      ],
    );
  }

  Widget _stepProgressAttachments() {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _stepSectionTitle(context, 'Progress details'),
        if (_progressRows.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'No progress entries yet. Tap add to include updates.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        for (int i = 0; i < _progressRows.length; i++)
          _progressRowCard(context, i, _progressRows[i]),
        Center(
          child: FilledButton.tonalIcon(
            onPressed: _saving ? null : _addProgressRow,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add progress'),
          ),
        ),
        const SizedBox(height: 20),
        _stepSectionTitle(context, 'Attachments', requiredField: true),
        if (_attachmentRows.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'At least one attachment is required before save.',
              style: tt.bodyMedium?.copyWith(color: cs.error),
            ),
          ),
        for (int i = 0; i < _attachmentRows.length; i++)
          _attachmentRowCard(context, i, _attachmentRows[i]),
        Center(
          child: FilledButton.tonalIcon(
            onPressed: _saving ? null : _addAttachmentRow,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add attachment'),
          ),
        ),
        const SizedBox(height: 16),
        _textField(
          controller: _remarksCtrl,
          label: 'Remarks',
          hint: 'Enter remarks',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _stepSectionTitle(
    BuildContext context,
    String title, {
    bool requiredField = false,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
          if (requiredField)
            Text(
              '*',
              style: tt.titleMedium?.copyWith(
                color: cs.error,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }

  Widget _progressRowCard(BuildContext context, int index, _ProgressRow row) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.65)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Progress ${index + 1}',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Remove',
                  style: IconButton.styleFrom(
                    backgroundColor: cs.errorContainer,
                    foregroundColor: cs.onErrorContainer,
                  ),
                  onPressed: _saving ? null : () => _removeProgressRow(index),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _dateField(
              label: 'Progress date',
              value: row.date,
              onPick: (DateTime value) => setState(() => row.date = value),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: row.workCtrl,
              maxLines: 4,
              maxLength: 1000,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Progress of work',
                hintText: 'Enter progress details',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              buildCounter: (
                BuildContext _, {
                required int currentLength,
                required bool isFocused,
                required int? maxLength,
              }) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$currentLength/${maxLength ?? 1000}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachmentRowCard(
    BuildContext context,
    int index,
    _AttachmentRow row,
  ) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.65)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Attachment ${index + 1}',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Remove',
                  style: IconButton.styleFrom(
                    backgroundColor: cs.errorContainer,
                    foregroundColor: cs.onErrorContainer,
                  ),
                  onPressed: _saving ? null : () => _removeAttachmentRow(index),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppSelectSheetField<_OptionItem>(
              label: _fileTypes.isNotEmpty ? 'File type *' : 'File type',
              title: 'Select file type',
              items: _fileTypes,
              value: row.fileType,
              itemLabelBuilder: (_OptionItem option) => option.label,
              onChanged: (_OptionItem value) =>
                  setState(() => row.fileType = value),
              placeholderText: _fileTypes.isNotEmpty
                  ? 'Select file type'
                  : 'No file types from server',
              enabled: _fileTypes.isNotEmpty,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: row.nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'Enter file name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _saving ? null : () => _pickAttachmentFile(row),
              icon: const Icon(Icons.attach_file_rounded),
              label: Text(row.bytes == null ? 'Upload file' : 'Change file'),
            ),
            if (row.pickedFileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  row.pickedFileName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addProgressRow() {
    setState(() => _progressRows.add(_ProgressRow()));
  }

  void _removeProgressRow(int index) {
    setState(() {
      _progressRows[index].dispose();
      _progressRows.removeAt(index);
    });
  }

  void _addAttachmentRow() {
    setState(() => _attachmentRows.add(_AttachmentRow()));
  }

  void _removeAttachmentRow(int index) {
    setState(() {
      _attachmentRows[index].dispose();
      _attachmentRows.removeAt(index);
    });
  }

  Future<void> _pickAttachmentFile(_AttachmentRow row) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final PlatformFile file = result.files.first;
      final Uint8List? bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        if (!mounted) {
          return;
        }
        await AppDialog.show(
          context: context,
          type: AppDialogType.info,
          title: 'File not loaded',
          message:
              'Could not read file bytes. Pick a smaller file or try again.',
        );
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        row.bytes = bytes;
        row.pickedFileName = file.name;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        type: AppDialogType.error,
        title: 'Upload failed',
        message: 'Unable to pick this file.',
      );
    }
  }

  Widget _grid(List<Widget> children) {
    const double gapH = 12;
    const double gapV = 10;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = constraints.maxWidth;
        final int cols = w >= 900 ? 3 : (w >= 600 ? 2 : 1);
        if (cols == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < children.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: gapV),
                children[i],
              ],
            ],
          );
        }
        final List<Widget> rows = <Widget>[];
        for (int i = 0; i < children.length; i += cols) {
          final List<Widget> rowCells = <Widget>[];
          for (int j = 0; j < cols; j++) {
            final int idx = i + j;
            rowCells.add(
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: j == 0 ? 0 : gapH / 2,
                    right: j == cols - 1 ? 0 : gapH / 2,
                  ),
                  child: idx < children.length
                      ? children[idx]
                      : const SizedBox.shrink(),
                ),
              ),
            );
          }
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowCells,
            ),
          );
          if (i + cols < children.length) {
            rows.add(const SizedBox(height: gapV));
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onPick,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final DateTime now = DateTime.now();
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 20),
          lastDate: DateTime(now.year + 20),
        );
        if (picked != null) {
          onPick(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          value == null
              ? 'Select date'
              : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _selectField({
    required String label,
    required String title,
    required String placeholder,
    required _OptionItem? value,
    required List<_OptionItem> items,
    required ValueChanged<_OptionItem> onChanged,
  }) {
    return AppSelectSheetField<_OptionItem>(
      label: label,
      title: title,
      items: items,
      value: value,
      onChanged: onChanged,
      itemLabelBuilder: (_OptionItem option) => option.label,
      placeholderText: placeholder,
    );
  }

  Future<void> _loadForm() async {
    setState(() => _loading = true);
    try {
      final Map<String, dynamic> data = await widget.dataSource
          .fetchAddUtilityShiftingFormData();
      if (!mounted) return;
      final Map<String, dynamic> merged = _mergedUtilityFormRoot(data);
      setState(() {
        _projects = _toOptions(
          _utilityFormList(merged, const <String>[
            'projectsList',
            'projectList',
            'workList',
            'worksList',
          ]),
        );
        _executionAgencies = _toOptions(
          _utilityFormList(merged, const <String>[
            'utilityExecutionAgencyList',
            'executionAgencyList',
            'execution_agency_list',
            'utility_execution_agency_list',
            'utilityExecutionagencyList',
          ]),
        );
        _hods = _toOptions(
          _utilityFormList(merged, const <String>[
            'utilityHODList',
            'utilityHodList',
            'hodList',
            'hod_list',
            'utility_hod_list',
          ]),
        );
        _utilityTypes = _toOptions(
          _utilityFormList(merged, const <String>[
            'utilityTypeList',
            'utility_type_list',
            'utilityTypesList',
          ]),
        );
        _utilityCategories = _toOptions(
          _utilityFormList(merged, const <String>[
            'utilityCategoryList',
            'utility_category_list',
            'utilityCategoriesList',
          ]),
        );
        _impactedContracts = _toOptions(
          _utilityFormList(merged, const <String>[
            'impactedContractsList',
            'impactedContractList',
            'impacted_contract_list',
            'contractsList',
            'contractList',
          ]),
        );
        _requirementStages = _toOptions(
          _utilityFormList(merged, const <String>[
            'reqStageList',
            'requirementStageList',
            'requirement_stage_list',
            'requirementStagesList',
          ]),
        );
        _impactedElements = _toOptions(
          _utilityFormList(merged, const <String>[
            'impactedElementList',
            'impacted_element_list',
            'impactedElementsList',
          ]),
        );
        _units = _toOptions(
          _utilityFormList(merged, const <String>[
            'unitList',
            'unit_list',
            'unitsList',
          ]),
        );
        _statuses = _toOptions(
          _utilityFormList(merged, const <String>[
            'statusList',
            'shiftingStatusList',
            'shifting_status_list',
            'utilityStatusList',
          ]),
        );
        _fileTypes = _toOptions(
          _utilityFormList(merged, const <String>[
            'utilityshiftingfiletypeList',
            'utilityShiftingFileTypeList',
            'utility_shifting_file_type_list',
            'utilityShiftingFiletypeList',
            'fileTypeList',
            'file_type_list',
          ]),
        );
      });
    } catch (error) {
      if (!mounted) return;
      await AppDialog.show(
        context: context,
        type: AppDialogType.error,
        title: 'Unable to Load Form',
        message: 'Could not fetch Add Utility form data. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _nextStep() {
    final bool valid = _validateStep(_currentStep);
    if (!valid) return;
    setState(() => _currentStep += 1);
  }

  bool _validateStep(int step) {
    if (step == 0) {
      if (_executionAgency == null || _hod == null || _utilityType == null) {
        _showRequiredMessage(
          'Please select Execution Agency, HOD and Utility Type.',
        );
        return false;
      }
      if (_utilityDescriptionCtrl.text.trim().isEmpty) {
        _showRequiredMessage('Utility Description is required.');
        return false;
      }
      return true;
    }
    if (step == 1) {
      if (_impactedContract == null || _requirementStage == null) {
        _showRequiredMessage(
          'Please select impacted contract and requirement stage.',
        );
        return false;
      }
      return true;
    }
    if (step == 2) {
      if (_attachmentRows.isEmpty) {
        _showRequiredMessage(
          'Add at least one attachment. File type, name, and file are required.',
        );
        return false;
      }
      for (final _AttachmentRow r in _attachmentRows) {
        if (r.nameCtrl.text.trim().isEmpty ||
            r.bytes == null ||
            r.bytes!.isEmpty) {
          _showRequiredMessage(
            'Each attachment needs a display name and uploaded file.',
          );
          return false;
        }
        if (_fileTypes.isNotEmpty && r.fileType == null) {
          _showRequiredMessage('Select a file type for each attachment.');
          return false;
        }
      }
      return true;
    }
    return true;
  }

  Future<void> _showRequiredMessage(String message) async {
    await AppDialog.show(
      context: context,
      type: AppDialogType.info,
      title: 'Required Details',
      message: message,
    );
  }

  Future<void> _submit() async {
    if (!_validateStep(0) || !_validateStep(1) || !_validateStep(2)) {
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.dataSource.submitAddUtilityShifting(
        payload: _buildPayload(),
      );
      if (!mounted) return;
      await AppDialog.show(
        context: context,
        type: AppDialogType.success,
        title: 'Saved',
        message: 'Utility shifting details saved successfully.',
      );
      if (!mounted) return;
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      await AppDialog.show(
        context: context,
        type: AppDialogType.error,
        title: 'Save Failed',
        message:
            'Unable to save utility shifting details. Please verify data and retry.',
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Map<String, dynamic> _buildPayload() {
    String formatDate(DateTime? date) {
      if (date == null) return '';
      return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    return <String, dynamic>{
      'work_id_fk': _project?.id ?? '',
      'execution_agency_fk': _executionAgency?.id ?? '',
      'hod_fk': _hod?.id ?? '',
      'utility_type_fk': _utilityType?.id ?? '',
      'utility_category_fk': _utilityCategory?.id ?? '',
      'utility_description': _utilityDescriptionCtrl.text.trim(),
      'location_name': _locationCtrl.text.trim(),
      'owner_name': _custodianCtrl.text.trim(),
      'identification': formatDate(_identificationDate),
      'reference_number': _referenceNumberCtrl.text.trim(),
      'executed_by': _executedByCtrl.text.trim(),
      'chainage': _chainageCtrl.text.trim(),
      'latitude': _latitudeCtrl.text.trim(),
      'longitude': _longitudeCtrl.text.trim(),
      'impacted_contract_id_fk': _impactedContract?.id ?? '',
      'requirement_stage_fk': _requirementStage?.id ?? '',
      'impacted_element_fk': _impactedElement?.id ?? '',
      'affected_structures': _affectedStructuresCtrl.text.trim(),
      'planned_completion_date': formatDate(_targetDate),
      'scope': _scopeCtrl.text.trim(),
      'completed': _completedCtrl.text.trim(),
      'unit_fk': _unit?.id ?? '',
      'start_date': formatDate(_startDate),
      'shifting_status_fk': _status?.id ?? '',
      'shifting_completion_date': formatDate(_completionDate),
      'remarks': _remarksCtrl.text.trim(),
      'progress_details': <Map<String, String>>[
        for (final _ProgressRow r in _progressRows)
          if (r.workCtrl.text.trim().isNotEmpty || r.date != null)
            <String, String>{
              'progress_date': formatDate(r.date),
              'progress_of_work': r.workCtrl.text.trim(),
            },
      ],
      'attachment_details': <Map<String, dynamic>>[
        for (final _AttachmentRow r in _attachmentRows)
          <String, dynamic>{
            'file_type_fk': r.fileType?.id ?? '',
            'name': r.nameCtrl.text.trim(),
            'original_filename': r.pickedFileName ?? '',
            if (r.bytes != null && r.bytes!.isNotEmpty)
              'file_base64': base64Encode(r.bytes!),
          },
      ],
    };
  }

  List<_OptionItem> _toOptions(List<dynamic> raw) {
    final List<_OptionItem> items = <_OptionItem>[];
    final Set<String> seen = <String>{};
    for (final dynamic row in raw) {
      if (row is String) {
        final String s = row.trim();
        if (s.isEmpty) {
          continue;
        }
        if (!seen.add(s)) {
          continue;
        }
        items.add(_OptionItem(id: s, label: s));
        continue;
      }
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = _asStringKeyedMap(row);
      String id = _inferOptionId(map);
      String label = _inferOptionLabel(map);
      if (label.isEmpty) {
        continue;
      }
      if (id.isEmpty) {
        id = label;
      }
      final String dedupe = '${id}_$label';
      if (!seen.add(dedupe)) {
        continue;
      }
      items.add(_OptionItem(id: id, label: label));
    }
    return items;
  }
}

class _OptionItem {
  const _OptionItem({required this.id, required this.label});

  final String id;
  final String label;
}
