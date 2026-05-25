import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

class AddQualityInspectionFormPage extends StatefulWidget {
  const AddQualityInspectionFormPage({super.key, required this.dataSource});

  static const String routeName = 'add-quality-inspection';
  static const String routePath = '/add-quality-inspection';

  final DashboardRemoteDataSource dataSource;

  @override
  State<AddQualityInspectionFormPage> createState() =>
      _AddQualityInspectionFormPageState();
}

class _QiOption {
  const _QiOption({required this.id, required this.label, this.raw});

  final String id;
  final String label;
  final Map<String, dynamic>? raw;
}

class _TestParameterRow {
  _TestParameterRow({
    required this.parameterId,
    required this.parameter,
    required this.acceptanceCriteria,
    required this.uom,
    required this.frequency,
  });

  final String parameterId;
  final String parameter;
  final String acceptanceCriteria;
  final String uom;
  final String frequency;
  final TextEditingController resultCtrl = TextEditingController();
  String? passFail;
  String? ncrRequired;
  String? attachmentName;
  Uint8List? attachmentBytes;
}

class _AddQualityInspectionFormPageState
    extends State<AddQualityInspectionFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _inspectionByCtrl = TextEditingController();
  final TextEditingController _lotBatchCtrl = TextEditingController();
  final TextEditingController _correctiveActionCtrl = TextEditingController();

  bool _loading = true;
  bool _cascadeBusy = false;
  bool _saving = false;
  String? _loadError;

  List<_QiOption> _projects = <_QiOption>[];
  List<_QiOption> _sections = <_QiOption>[];
  List<_QiOption> _contracts = <_QiOption>[];
  List<_QiOption> _structureTypes = <_QiOption>[];
  List<_QiOption> _structures = <_QiOption>[];
  List<_QiOption> _items = <_QiOption>[];
  List<_QiOption> _inspectionTypes = <_QiOption>[];
  List<_QiOption> _categories = <_QiOption>[];
  List<_QiOption> _subCategories = <_QiOption>[];

  _QiOption? _project;
  _QiOption? _section;
  _QiOption? _contract;
  _QiOption? _structureType;
  _QiOption? _structure;
  _QiOption? _item;
  _QiOption? _inspectionType;
  _QiOption? _category;
  _QiOption? _subCategory;

  DateTime? _targetDate;
  List<_TestParameterRow> _parameterRows = <_TestParameterRow>[];
  bool _parametersLoading = false;

  static const List<String> _passFailOptions = <String>['Pass', 'Fail'];
  static const List<String> _ncrOptions = <String>['Yes', 'No'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _inspectionByCtrl.dispose();
    _lotBatchCtrl.dispose();
    _correctiveActionCtrl.dispose();
    for (final _TestParameterRow row in _parameterRows) {
      row.resultCtrl.dispose();
    }
    super.dispose();
  }

  bool get _hasAnyFail =>
      _parameterRows.any(( _TestParameterRow r) => r.passFail == 'Fail');

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final List<Map<String, dynamic>> results =
          await Future.wait<Map<String, dynamic>>(
        <Future<Map<String, dynamic>>>[
          widget.dataSource.fetchQualityInspectionDropdownProjects(),
          widget.dataSource.fetchQualityInspectionDropdownSections(),
          widget.dataSource.fetchQualityInspectionDropdownInspectionTypes(),
          widget.dataSource.fetchQualityInspectionDropdownCategories(),
        ],
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _projects = _parseProjects(results[0]);
        _sections = _parseSections(results[1]);
        _inspectionTypes = _parseInspectionTypes(results[2]);
        _categories = _parseCategories(results[3]);
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

  List<dynamic> _dataList(Map<String, dynamic> response) {
    final dynamic raw = response['data'];
    return raw is List ? raw : const <dynamic>[];
  }

  List<_QiOption> _parseProjects(Map<String, dynamic> response) {
    final List<_QiOption> out = <_QiOption>[];
    for (final dynamic row in _dataList(response)) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(
        row.map((dynamic k, dynamic v) => MapEntry(k.toString(), v)),
      );
      final String id = _str(map['projectIdFk'] ?? map['project_id_fk']);
      final String name = _str(map['projectName'] ?? map['project_name']);
      if (id.isEmpty || name.isEmpty) {
        continue;
      }
      out.add(_QiOption(id: id, label: name, raw: map));
    }
    return out;
  }

  List<_QiOption> _parseSections(Map<String, dynamic> response) {
    final List<_QiOption> out = <_QiOption>[];
    for (final dynamic row in _dataList(response)) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(
        row.map((dynamic k, dynamic v) => MapEntry(k.toString(), v)),
      );
      final String id = _str(map['section_id']);
      final String name = _str(map['section_name']);
      if (id.isEmpty || name.isEmpty) {
        continue;
      }
      out.add(_QiOption(id: id, label: name, raw: map));
    }
    return out;
  }

  List<_QiOption> _parseIdName(
    Map<String, dynamic> response, {
    required String idKey,
    required String nameKey,
  }) {
    final List<_QiOption> out = <_QiOption>[];
    for (final dynamic row in _dataList(response)) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(
        row.map((dynamic k, dynamic v) => MapEntry(k.toString(), v)),
      );
      final String id = _str(map[idKey] ?? map['id']);
      final String name = _str(map[nameKey] ?? map['name']);
      if (id.isEmpty || name.isEmpty) {
        continue;
      }
      out.add(_QiOption(id: id, label: name, raw: map));
    }
    return out;
  }

  List<_QiOption> _parseStructureTypes(Map<String, dynamic> response) {
    final List<_QiOption> out = <_QiOption>[];
    for (final dynamic row in _dataList(response)) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(
        row.map((dynamic k, dynamic v) => MapEntry(k.toString(), v)),
      );
      final String type = _str(map['structure_type_fk']);
      if (type.isEmpty) {
        continue;
      }
      out.add(_QiOption(id: type, label: type, raw: map));
    }
    return out;
  }

  List<_QiOption> _parseStructures(Map<String, dynamic> response) {
    final List<_QiOption> out = <_QiOption>[];
    for (final dynamic row in _dataList(response)) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(
        row.map((dynamic k, dynamic v) => MapEntry(k.toString(), v)),
      );
      final String id = _str(map['structure_id_fk']);
      final String name = _str(map['structure_name']);
      if (id.isEmpty || name.isEmpty) {
        continue;
      }
      out.add(_QiOption(id: id, label: name, raw: map));
    }
    return out;
  }

  List<_QiOption> _parseItems(Map<String, dynamic> response) {
    final List<_QiOption> out = <_QiOption>[];
    for (final dynamic row in _dataList(response)) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(
        row.map((dynamic k, dynamic v) => MapEntry(k.toString(), v)),
      );
      final String id = _str(map['item_id']);
      final String name = _str(map['item_name']);
      if (id.isEmpty || name.isEmpty) {
        continue;
      }
      final String code = _str(map['item_code']);
      final String label = code.isEmpty ? name : '$name ($code)';
      out.add(_QiOption(id: id, label: label, raw: map));
    }
    return out;
  }

  List<_QiOption> _parseInspectionTypes(Map<String, dynamic> response) {
    final List<_QiOption> out = <_QiOption>[];
    for (final dynamic row in _dataList(response)) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(
        row.map((dynamic k, dynamic v) => MapEntry(k.toString(), v)),
      );
      final String id = _str(map['insp_type_id']);
      final String name = _str(map['type']);
      if (id.isEmpty || name.isEmpty) {
        continue;
      }
      out.add(_QiOption(id: id, label: name, raw: map));
    }
    return out;
  }

  List<_QiOption> _parseCategories(Map<String, dynamic> response) {
    final List<_QiOption> out = <_QiOption>[];
    for (final dynamic row in _dataList(response)) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(
        row.map((dynamic k, dynamic v) => MapEntry(k.toString(), v)),
      );
      final String id = _str(map['insp_category_id']);
      final String name = _str(map['category']);
      if (id.isEmpty || name.isEmpty) {
        continue;
      }
      out.add(_QiOption(id: id, label: name, raw: map));
    }
    return out;
  }

  List<_QiOption> _parseSubCategories(Map<String, dynamic> response) {
    final List<_QiOption> out = <_QiOption>[];
    for (final dynamic row in _dataList(response)) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(
        row.map((dynamic k, dynamic v) => MapEntry(k.toString(), v)),
      );
      final String id = _str(map['insp_sub_category_id']);
      final String name = _str(map['sub_category']);
      if (id.isEmpty || name.isEmpty) {
        continue;
      }
      out.add(_QiOption(id: id, label: name, raw: map));
    }
    return out;
  }

  void _clearParameterRows() {
    for (final _TestParameterRow row in _parameterRows) {
      row.resultCtrl.dispose();
    }
    _parameterRows = <_TestParameterRow>[];
  }

  Future<void> _onProjectChanged(_QiOption? value) async {
    setState(() {
      _project = value;
      _contract = null;
      _structureType = null;
      _structure = null;
      _item = null;
      _contracts = <_QiOption>[];
      _structureTypes = <_QiOption>[];
      _structures = <_QiOption>[];
      _items = <_QiOption>[];
      _inspectionByCtrl.text = _str(value?.raw?['inspectedBy']);
      _clearParameterRows();
    });
    if (value == null) {
      return;
    }
    setState(() => _cascadeBusy = true);
    try {
      final List<Map<String, dynamic>> results =
          await Future.wait<Map<String, dynamic>>(
        <Future<Map<String, dynamic>>>[
          widget.dataSource.fetchQualityInspectionDropdownContracts(
            projectIdFk: value.id,
          ),
          widget.dataSource.fetchQualityInspectionDropdownStructureTypes(
            projectIdFk: value.id,
          ),
        ],
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _contracts = _parseIdName(
          results[0],
          idKey: 'id',
          nameKey: 'name',
        );
        _structureTypes = _parseStructureTypes(results[1]);
      });
    } finally {
      if (mounted) {
        setState(() => _cascadeBusy = false);
      }
    }
  }

  Future<void> _onStructureTypeChanged(_QiOption? value) async {
    setState(() {
      _structureType = value;
      _structure = null;
      _item = null;
      _structures = <_QiOption>[];
      _items = <_QiOption>[];
      _clearParameterRows();
    });
    if (value == null || _project == null) {
      return;
    }
    setState(() => _cascadeBusy = true);
    try {
      final List<Map<String, dynamic>> results =
          await Future.wait<Map<String, dynamic>>(
        <Future<Map<String, dynamic>>>[
          widget.dataSource.fetchQualityInspectionDropdownStructures(
            projectIdFk: _project!.id,
            structureTypeFk: value.id,
          ),
          widget.dataSource.fetchQualityInspectionDropdownItems(
            structureTypeFk: value.id,
          ),
        ],
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _structures = _parseStructures(results[0]);
        _items = _parseItems(results[1]);
      });
    } finally {
      if (mounted) {
        setState(() => _cascadeBusy = false);
      }
    }
  }

  Future<void> _onCategoryChanged(_QiOption? value) async {
    setState(() {
      _category = value;
      _subCategory = null;
      _subCategories = <_QiOption>[];
      _clearParameterRows();
    });
    if (value == null) {
      return;
    }
    setState(() => _cascadeBusy = true);
    try {
      final Map<String, dynamic> response = await widget.dataSource
          .fetchQualityInspectionDropdownSubCategories(categoryIdFk: value.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _subCategories = _parseSubCategories(response);
      });
    } finally {
      if (mounted) {
        setState(() => _cascadeBusy = false);
      }
    }
  }

  Future<void> _loadTestParameters() async {
    if (_item == null || _category == null || _subCategory == null) {
      setState(_clearParameterRows);
      return;
    }
    setState(() {
      _parametersLoading = true;
      _clearParameterRows();
    });
    try {
      final Map<String, dynamic> response = await widget.dataSource
          .fetchQualityInspectionTestParameters(
            itemIdFk: _item!.id,
            categoryIdFk: _category!.id,
            subCategoryIdFk: _subCategory!.id,
          );
      if (!mounted) {
        return;
      }
      final List<_TestParameterRow> rows = <_TestParameterRow>[];
      for (final dynamic row in _dataList(response)) {
        if (row is! Map) {
          continue;
        }
        final Map<String, dynamic> map = Map<String, dynamic>.from(
          row.map((dynamic k, dynamic v) => MapEntry(k.toString(), v)),
        );
        rows.add(
          _TestParameterRow(
            parameterId: _str(map['insp_test_parameter_id']),
            parameter: _str(map['test_description']),
            acceptanceCriteria: _str(map['acceptance_criteria']),
            uom: _str(map['unit_of_measure']),
            frequency: _str(map['frequency']),
          ),
        );
      }
      setState(() {
        _parameterRows = rows;
        _parametersLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _parametersLoading = false);
      await AppDialog.show(
        context: context,
        title: 'Test parameters',
        message: 'Unable to load test parameters. Check selections and try again.',
        type: AppDialogType.error,
      );
    }
  }

  void _onSubCategoryChanged(_QiOption? value) {
    setState(() => _subCategory = value);
    _loadTestParameters();
  }

  void _onItemChanged(_QiOption? value) {
    setState(() => _item = value);
    _loadTestParameters();
  }

  Future<void> _pickAttachment(_TestParameterRow row) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>[
        'jpg',
        'jpeg',
        'png',
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
      row.attachmentName = file.name;
      row.attachmentBytes = file.bytes;
    });
  }

  Future<void> _pickTargetDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _showRequired(String message) async {
    await AppDialog.show(
      context: context,
      title: 'Required',
      message: message,
      type: AppDialogType.info,
    );
  }

  bool _validateForm() {
    if (_project == null) {
      _showRequired('Please select project.');
      return false;
    }
    if (_section == null) {
      _showRequired('Please select section.');
      return false;
    }
    if (_contract == null) {
      _showRequired('Please select contract.');
      return false;
    }
    if (_structureType == null) {
      _showRequired('Please select structure type.');
      return false;
    }
    if (_structure == null) {
      _showRequired('Please select structure.');
      return false;
    }
    if (_item == null) {
      _showRequired('Please select item.');
      return false;
    }
    if (_inspectionType == null) {
      _showRequired('Please select inspection type.');
      return false;
    }
    if (_category == null) {
      _showRequired('Please select category.');
      return false;
    }
    if (_subCategory == null) {
      _showRequired('Please select sub-category.');
      return false;
    }
    if (_locationCtrl.text.trim().isEmpty) {
      _showRequired('Please enter location.');
      return false;
    }
    if (_parameterRows.isEmpty) {
      _showRequired('Test parameters are required for the selected item.');
      return false;
    }
    for (final _TestParameterRow row in _parameterRows) {
      if (row.resultCtrl.text.trim().isEmpty) {
        _showRequired('Please enter result for all test parameters.');
        return false;
      }
      if (row.passFail == null || row.passFail!.isEmpty) {
        _showRequired('Please select Pass / Fail for all test parameters.');
        return false;
      }
    }
    if (_hasAnyFail) {
      if (_correctiveActionCtrl.text.trim().isEmpty) {
        _showRequired('Please enter corrective action when a test has failed.');
        return false;
      }
      if (_targetDate == null) {
        _showRequired('Please select target date when a test has failed.');
        return false;
      }
    }
    return true;
  }

  Future<void> _saveDraft() async {
    if (!_validateForm()) {
      return;
    }
    await _showPendingApi('Save as draft');
  }

  Future<void> _submit() async {
    if (!_validateForm()) {
      return;
    }
    await _showPendingApi('Submit');
  }

  Future<void> _showPendingApi(String action) async {
    await AppDialog.show(
      context: context,
      title: action,
      message:
          '$action API will be connected next. Form data is ready on the device.',
      type: AppDialogType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Quality Inspection Form')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_loadError != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Unable to load form.',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _loadInitial,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                        children: <Widget>[
                          _sectionCard(
                            title: 'Inspection details',
                            children: <Widget>[
                              _requiredSelect(
                                label: 'Project',
                                items: _projects,
                                value: _project,
                                enabled: !_cascadeBusy,
                                onChanged: ( _QiOption v) => _onProjectChanged(v),
                              ),
                              const SizedBox(height: 10),
                              _requiredSelect(
                                label: 'Section',
                                items: _sections,
                                value: _section,
                                enabled: !_cascadeBusy,
                                onChanged: ( _QiOption v) =>
                                    setState(() => _section = v),
                              ),
                              const SizedBox(height: 10),
                              _requiredSelect(
                                label: 'Contract',
                                items: _contracts,
                                value: _contract,
                                enabled: _project != null && !_cascadeBusy,
                                placeholder: _project == null
                                    ? 'Select project first'
                                    : 'Select',
                                onChanged: ( _QiOption v) =>
                                    setState(() => _contract = v),
                              ),
                              const SizedBox(height: 10),
                              _requiredSelect(
                                label: 'Structure Type',
                                items: _structureTypes,
                                value: _structureType,
                                enabled: _project != null && !_cascadeBusy,
                                placeholder: _project == null
                                    ? 'Select project first'
                                    : 'Select',
                                onChanged: ( _QiOption v) =>
                                    _onStructureTypeChanged(v),
                              ),
                              const SizedBox(height: 10),
                              _requiredSelect(
                                label: 'Structure',
                                items: _structures,
                                value: _structure,
                                enabled:
                                    _structureType != null && !_cascadeBusy,
                                placeholder: _structureType == null
                                    ? 'Select structure type first'
                                    : 'Select',
                                onChanged: ( _QiOption v) =>
                                    setState(() => _structure = v),
                              ),
                              const SizedBox(height: 10),
                              _requiredSelect(
                                label: 'Item',
                                items: _items,
                                value: _item,
                                enabled: _structureType != null && !_cascadeBusy,
                                placeholder: _structureType == null
                                    ? 'Select structure type first'
                                    : 'Select',
                                onChanged: ( _QiOption v) => _onItemChanged(v),
                              ),
                              const SizedBox(height: 10),
                              _requiredSelect(
                                label: 'Inspection Type',
                                items: _inspectionTypes,
                                value: _inspectionType,
                                enabled: !_cascadeBusy,
                                onChanged: ( _QiOption v) =>
                                    setState(() => _inspectionType = v),
                              ),
                              const SizedBox(height: 10),
                              _requiredSelect(
                                label: 'Category',
                                items: _categories,
                                value: _category,
                                enabled: !_cascadeBusy,
                                onChanged: ( _QiOption v) => _onCategoryChanged(v),
                              ),
                              const SizedBox(height: 10),
                              _requiredSelect(
                                label: 'Sub-Category',
                                items: _subCategories,
                                value: _subCategory,
                                enabled: _category != null && !_cascadeBusy,
                                placeholder: _category == null
                                    ? 'Select category first'
                                    : 'Select',
                                onChanged: ( _QiOption v) => _onSubCategoryChanged(v),
                              ),
                              const SizedBox(height: 10),
                              _textField(
                                controller: _locationCtrl,
                                label: 'Location *',
                                hintText: 'Enter location',
                              ),
                              const SizedBox(height: 10),
                              _textField(
                                controller: _inspectionByCtrl,
                                label: 'Inspection By',
                                readOnly: true,
                              ),
                              const SizedBox(height: 10),
                              _textField(
                                controller: _lotBatchCtrl,
                                label: 'Lot/Batch No.',
                                hintText: 'Enter lot or batch number',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _parametersSection(),
                          if (_hasAnyFail) ...<Widget>[
                            const SizedBox(height: 12),
                            Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    _textField(
                                      controller: _correctiveActionCtrl,
                                      label: 'Corrective Action Required *',
                                      hintText: 'Enter corrective action',
                                      minLines: 3,
                                      maxLines: 5,
                                    ),
                                    const SizedBox(height: 10),
                                    _dateField(
                                      label: 'Target Date *',
                                      value: _targetDate,
                                      onTap: _pickTargetDate,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  if (_cascadeBusy && !_loading)
                    Positioned.fill(
                      child: AbsorbPointer(
                        child: ColoredBox(
                          color: Colors.black.withValues(alpha: 0.05),
                          child: const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!_loading && _loadError == null)
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
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: _saving ? null : _saveDraft,
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save as draft'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        child: const Text('Submit'),
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

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _requiredSelect({
    required String label,
    required List<_QiOption> items,
    required _QiOption? value,
    required ValueChanged<_QiOption> onChanged,
    bool enabled = true,
    String placeholder = 'Select',
  }) {
    return AppSelectSheetField<_QiOption>(
      label: '$label *',
      title: 'Select $label',
      items: items,
      value: value,
      enabled: enabled,
      placeholderText: placeholder,
      itemLabelBuilder: ( _QiOption o) => o.label,
      onChanged: onChanged,
    );
  }

  InputBorder get _fieldBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  );

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool readOnly = false,
    int minLines = 1,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _fieldLabel(label),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            border: _fieldBorder,
            enabledBorder: _fieldBorder,
            focusedBorder: _fieldBorder,
            disabledBorder: _fieldBorder,
          ),
        ),
      ],
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    final String display = value == null
        ? 'Select date'
        : DateFormat('dd/MM/yyyy').format(value);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _fieldLabel(label),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: InputDecorator(
            decoration: InputDecoration(
              border: _fieldBorder,
              enabledBorder: _fieldBorder,
              focusedBorder: _fieldBorder,
              suffixIcon: const Icon(Icons.calendar_today_rounded),
            ),
            child: Text(
              display,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: value == null ? colorScheme.onSurfaceVariant : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _parametersSection() {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool canLoad = _item != null && _category != null && _subCategory != null;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (!canLoad)
              Text(
                'Select item, category, and sub-category to load parameters.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              )
            else if (_parametersLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_parameterRows.isEmpty)
              Text(
                'No test parameters returned for this selection.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              )
            else
              _parametersTable(),
          ],
        ),
      ),
    );
  }

  Widget _parametersTable() {
    const List<String> headers = <String>[
      'Parameters',
      'Acceptance Criteria',
      'UOM',
      'Frequency',
      'Result',
      'Pass / Fail',
      'Is NCR Required',
      'Attachment',
    ];
    final ColorScheme cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Column(
              children: <Widget>[
                Container(
                  color: cs.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: headers
                        .map(
                          (String h) => SizedBox(
                            width: _paramColWidth(h),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                h == 'Result' || h == 'Pass / Fail' || h == 'Is NCR Required'
                                    ? '$h *'
                                    : h,
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
                ),
                ..._parameterRows.asMap().entries.map((MapEntry<int, _TestParameterRow> e) {
                  final int index = e.key;
                  final _TestParameterRow row = e.value;
                  final Color bg = index.isEven
                      ? cs.primary.withValues(alpha: 0.06)
                      : cs.surface;
                  return Container(
                    color: bg,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _paramCell(row.parameter, _paramColWidth('Parameters')),
                        _paramCell(
                          row.acceptanceCriteria,
                          _paramColWidth('Acceptance Criteria'),
                        ),
                        _paramCell(row.uom, _paramColWidth('UOM')),
                        _paramCell(row.frequency, _paramColWidth('Frequency')),
                        SizedBox(
                          width: _paramColWidth('Result'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: TextFormField(
                              controller: row.resultCtrl,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Enter here...',
                                hintStyle: _paramFieldHintStyle(context),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        _paramPassFailCell(row),
                        _paramNcrCell(row),
                        SizedBox(
                          width: _paramColWidth('Attachment'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              children: <Widget>[
                                IconButton.filled(
                                  tooltip: 'Attach file',
                                  onPressed: () => _pickAttachment(row),
                                  icon: const Icon(Icons.attach_file_rounded),
                                ),
                                if (row.attachmentName != null)
                                  Text(
                                    row.attachmentName!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _paramCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Text(
          text.isEmpty ? '-' : text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  TextStyle? _paramFieldHintStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
  }

  Widget _paramPassFailCell(_TestParameterRow row) {
    return SizedBox(
      width: _paramColWidth('Pass / Fail'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: DropdownButtonFormField<String>(
          value: row.passFail,
          hint: Text('Select', style: _paramFieldHintStyle(context)),
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: _passFailOptions
              .map(
                (String v) => DropdownMenuItem<String>(value: v, child: Text(v)),
              )
              .toList(),
          onChanged: (String? value) {
            setState(() {
              row.passFail = value;
              if (value == 'Pass') {
                row.ncrRequired = 'No';
              } else if (value == 'Fail') {
                row.ncrRequired = 'Yes';
              } else {
                row.ncrRequired = null;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _paramNcrCell(_TestParameterRow row) {
    return SizedBox(
      width: _paramColWidth('Is NCR Required'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: DropdownButtonFormField<String>(
          value: row.ncrRequired,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: _ncrOptions
              .map(
                (String v) => DropdownMenuItem<String>(value: v, child: Text(v)),
              )
              .toList(),
          onChanged: null,
        ),
      ),
    );
  }

  double _paramColWidth(String header) {
    switch (header) {
      case 'Parameters':
        return 120;
      case 'Acceptance Criteria':
        return 120;
      case 'UOM':
        return 72;
      case 'Frequency':
        return 100;
      case 'Result':
        return 100;
      case 'Pass / Fail':
        return 110;
      case 'Is NCR Required':
        return 120;
      case 'Attachment':
        return 88;
      default:
        return 100;
    }
  }

  String _str(dynamic value) {
    if (value == null) {
      return '';
    }
    final String text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return '';
    }
    return text;
  }
}
