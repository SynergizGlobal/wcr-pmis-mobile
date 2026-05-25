import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_compact_form_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_date_form_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_text_form_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

class AddQualityInspectionFormPage extends StatefulWidget {
  const AddQualityInspectionFormPage({
    super.key,
    required this.dataSource,
    this.inspectionId,
  });

  static const String routeName = 'add-quality-inspection';
  static const String routePath = '/add-quality-inspection';

  final DashboardRemoteDataSource dataSource;

  /// When set, loads inspection-view API and prefills the form.
  final String? inspectionId;

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
    this.qualityNcrId,
  });

  final String parameterId;
  final String parameter;
  final String acceptanceCriteria;
  final String uom;
  final String frequency;
  final String? qualityNcrId;
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
  String? _inspectionNo;
  String? _savedInspectionId;

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

  void _onFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _hasAnyFail =>
      _parameterRows.any(( _TestParameterRow r) => r.passFail == 'Fail');

  bool get _hasRequiredSelections =>
      _project != null &&
      _section != null &&
      _contract != null &&
      _structureType != null &&
      _structure != null &&
      _item != null &&
      _inspectionType != null &&
      _category != null &&
      _subCategory != null;

  bool get _hasRequiredParameters {
    if (_parametersLoading || _parameterRows.isEmpty) {
      return false;
    }
    for (final _TestParameterRow row in _parameterRows) {
      if (row.resultCtrl.text.trim().isEmpty) {
        return false;
      }
      if (row.passFail == null || row.passFail!.isEmpty) {
        return false;
      }
    }
    return true;
  }

  bool get _hasRequiredFollowUp {
    if (!_hasAnyFail) {
      return true;
    }
    return _correctiveActionCtrl.text.trim().isNotEmpty && _targetDate != null;
  }

  bool get _canSubmit =>
      !_loading &&
      !_cascadeBusy &&
      !_parametersLoading &&
      _hasRequiredSelections &&
      _locationCtrl.text.trim().isNotEmpty &&
      _hasRequiredParameters &&
      _hasRequiredFollowUp;

  bool get _canSaveDraft =>
      !_loading && !_cascadeBusy && _project != null;

  bool get _isEditMode =>
      widget.inspectionId != null && widget.inspectionId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final String? editId = widget.inspectionId?.trim();
    if (editId != null && editId.isNotEmpty) {
      _savedInspectionId = editId;
    }
    _locationCtrl.addListener(_onFormChanged);
    _correctiveActionCtrl.addListener(_onFormChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  String get _effectiveInspectionId => _savedInspectionId ?? '';

  @override
  void dispose() {
    _locationCtrl.removeListener(_onFormChanged);
    _correctiveActionCtrl.removeListener(_onFormChanged);
    _locationCtrl.dispose();
    _inspectionByCtrl.dispose();
    _lotBatchCtrl.dispose();
    _correctiveActionCtrl.dispose();
    _clearParameterRows();
    super.dispose();
  }

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
      });
      if (_isEditMode) {
        await _loadInspectionForEdit(widget.inspectionId!.trim());
      } else if (mounted) {
        setState(() => _loading = false);
      }
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
      row.resultCtrl.removeListener(_onFormChanged);
      row.resultCtrl.dispose();
    }
    _parameterRows = <_TestParameterRow>[];
  }

  void _attachParameterListeners() {
    for (final _TestParameterRow row in _parameterRows) {
      row.resultCtrl.addListener(_onFormChanged);
    }
  }

  _QiOption? _findOption(List<_QiOption> items, String id) {
    if (id.isEmpty) {
      return null;
    }
    for (final _QiOption item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  _QiOption _optionOrFallback(
    List<_QiOption> items,
    String id,
    String label,
  ) {
    return _findOption(items, id) ??
        _QiOption(id: id, label: label.isNotEmpty ? label : id);
  }

  _QiOption? _findStructureOption(List<_QiOption> items, String value) {
    if (value.isEmpty) {
      return null;
    }
    final _QiOption? byId = _findOption(items, value);
    if (byId != null) {
      return byId;
    }
    for (final _QiOption item in items) {
      if (item.label == value) {
        return item;
      }
    }
    return _QiOption(id: value, label: value);
  }

  DateTime? _parseApiDate(dynamic value) {
    final String raw = _str(value);
    if (raw.isEmpty) {
      return null;
    }
    String normalized = raw;
    if (normalized.contains(' ')) {
      normalized = normalized.replaceFirst(' ', 'T');
    }
    final int dot = normalized.indexOf('.');
    if (dot > 0) {
      normalized = normalized.substring(0, dot);
    }
    try {
      return DateTime.parse(normalized);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _asStringKeyedMap(dynamic value) {
    if (value is! Map) {
      return <String, dynamic>{};
    }
    return Map<String, dynamic>.from(
      value.map(
        (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
      ),
    );
  }

  String _normFieldKey(String key) =>
      key.toLowerCase().replaceAll('_', '').replaceAll('-', '');

  dynamic _pickMapValue(Map<String, dynamic> map, List<String> keys) {
    final Set<String> wanted = keys.map(_normFieldKey).toSet();
    for (final MapEntry<String, dynamic> entry in map.entries) {
      if (wanted.contains(_normFieldKey(entry.key))) {
        return entry.value;
      }
    }
    return null;
  }

  String _inspectedByFromProject(_QiOption? project) {
    if (project?.raw == null) {
      return '';
    }
    return _str(
      _pickMapValue(
        project!.raw!,
        const <String>['inspectedBy', 'inspected_by'],
      ),
    );
  }

  void _applyInspectionByFromProject(_QiOption? project) {
    _inspectionByCtrl.text = _inspectedByFromProject(project);
  }

  Future<void> _reloadContractsAndStructureTypes(String projectId) async {
    final List<Map<String, dynamic>> results =
        await Future.wait<Map<String, dynamic>>(
      <Future<Map<String, dynamic>>>[
        widget.dataSource.fetchQualityInspectionDropdownContracts(
          projectIdFk: projectId,
        ),
        widget.dataSource.fetchQualityInspectionDropdownStructureTypes(
          projectIdFk: projectId,
        ),
      ],
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _contracts = _parseIdName(results[0], idKey: 'id', nameKey: 'name');
      _structureTypes = _parseStructureTypes(results[1]);
    });
  }

  Future<void> _reloadStructuresAndItems({
    required String projectId,
    required String structureTypeFk,
  }) async {
    final List<Map<String, dynamic>> results =
        await Future.wait<Map<String, dynamic>>(
      <Future<Map<String, dynamic>>>[
        widget.dataSource.fetchQualityInspectionDropdownStructures(
          projectIdFk: projectId,
          structureTypeFk: structureTypeFk,
        ),
        widget.dataSource.fetchQualityInspectionDropdownItems(
          structureTypeFk: structureTypeFk,
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
  }

  Future<void> _reloadSubCategories(String categoryId) async {
    final Map<String, dynamic> response = await widget.dataSource
        .fetchQualityInspectionDropdownSubCategories(categoryIdFk: categoryId);
    if (!mounted) {
      return;
    }
    setState(() => _subCategories = _parseSubCategories(response));
  }

  void _applyNcrRows(List<dynamic> rows) {
    _clearParameterRows();
    final List<_TestParameterRow> out = <_TestParameterRow>[];
    for (final dynamic row in rows) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = _asStringKeyedMap(row);
      final _TestParameterRow paramRow = _TestParameterRow(
        parameterId: _str(map['parameter_id']),
        parameter: _str(map['test_description']),
        acceptanceCriteria: _str(map['acceptance_criteria']),
        uom: _str(map['unit_of_measure']),
        frequency: _str(map['frequency']),
        qualityNcrId: _str(map['quality_ncr_id']).isEmpty
            ? null
            : _str(map['quality_ncr_id']),
      );
      final String result = _str(map['result']);
      if (result.isNotEmpty) {
        paramRow.resultCtrl.text = result;
      }
      final String passFail = _str(map['pass_fail']);
      if (passFail.isNotEmpty) {
        paramRow.passFail = passFail;
      }
      final String ncr = _str(map['is_ncr_required']);
      if (ncr.isNotEmpty) {
        paramRow.ncrRequired = ncr;
      }
      final String fileName = _str(map['file_name']);
      if (fileName.isNotEmpty) {
        paramRow.attachmentName = fileName;
      }
      out.add(paramRow);
    }
    setState(() => _parameterRows = out);
    _attachParameterListeners();
  }

  Future<void> _loadInspectionForEdit(String inspectionId) async {
    try {
      final Map<String, dynamic> response =
          await widget.dataSource.fetchQualityInspectionView(
        inspectionId: inspectionId,
      );
      if (!mounted) {
        return;
      }
      final Map<String, dynamic> data = _asStringKeyedMap(response['data']);
      if (data.isEmpty) {
        throw Exception('Inspection details were not returned.');
      }
      await _applyInspectionView(data);
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadError = null;
        _inspectionNo = _str(data['inspection_no']);
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

  Future<void> _applyInspectionView(Map<String, dynamic> data) async {
    setState(() => _cascadeBusy = true);
    try {
      _locationCtrl.text = _str(data['location']);
      _lotBatchCtrl.text = _str(data['lot_no']);
      _correctiveActionCtrl.text = _str(data['corrective_action_reqd']);
      _targetDate = _parseApiDate(data['action_target_date']);

      final String projectId = _str(data['project_id_fk']);
      _project = _optionOrFallback(
        _projects,
        projectId,
        _str(data['project_name']),
      );
      _applyInspectionByFromProject(_project);
      if (_inspectionByCtrl.text.isEmpty) {
        _inspectionByCtrl.text = _str(data['inspected_by_name']);
        if (_inspectionByCtrl.text.isEmpty) {
          _inspectionByCtrl.text = _str(data['inspected_by_fk']);
        }
      }

      if (projectId.isNotEmpty) {
        await _reloadContractsAndStructureTypes(projectId);
      }

      _section = _optionOrFallback(
        _sections,
        _str(data['section_id_fk']),
        _str(data['section_name']),
      );
      final String contractLabel = _str(data['contract_short_name']).isNotEmpty
          ? _str(data['contract_short_name'])
          : _str(data['contract_name']);
      _contract = _optionOrFallback(
        _contracts,
        _str(data['contract_id_fk']),
        contractLabel,
      );

      final String structureTypeFk = _str(data['structure_type_fk']);
      _structureType = _optionOrFallback(
        _structureTypes,
        structureTypeFk,
        structureTypeFk,
      );

      if (projectId.isNotEmpty && structureTypeFk.isNotEmpty) {
        await _reloadStructuresAndItems(
          projectId: projectId,
          structureTypeFk: structureTypeFk,
        );
      }

      _structure = _findStructureOption(_structures, _str(data['structure']));
      final String itemLabel = _str(data['item_code']).isNotEmpty
          ? '${_str(data['item_name'])} (${_str(data['item_code'])})'
          : _str(data['item_name']);
      _item = _optionOrFallback(_items, _str(data['item_id_fk']), itemLabel);
      _inspectionType = _optionOrFallback(
        _inspectionTypes,
        _str(data['type_id_fk']),
        _str(data['inspection_type']),
      );
      _category = _optionOrFallback(
        _categories,
        _str(data['category_id_fk']),
        _str(data['category']),
      );

      if (_category != null) {
        await _reloadSubCategories(_category!.id);
      }

      _subCategory = _optionOrFallback(
        _subCategories,
        _str(data['sub_category_id_fk']),
        _str(data['sub_category']),
      );

      final dynamic ncrRows = data['ncrRows'];
      if (ncrRows is List && ncrRows.isNotEmpty) {
        _applyNcrRows(ncrRows);
      } else if (_item != null && _category != null && _subCategory != null) {
        await _loadTestParameters();
      }

      if (mounted) {
        setState(() {});
      }
    } finally {
      if (mounted) {
        setState(() => _cascadeBusy = false);
      }
    }
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
      _applyInspectionByFromProject(value);
      _clearParameterRows();
    });
    if (value == null) {
      return;
    }
    setState(() => _cascadeBusy = true);
    try {
      await _reloadContractsAndStructureTypes(value.id);
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
      await _reloadStructuresAndItems(
        projectId: _project!.id,
        structureTypeFk: value.id,
      );
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
      await _reloadSubCategories(value.id);
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
            parameterId: _str(
              map['parameter_id'] ?? map['insp_test_parameter_id'],
            ),
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
      _attachParameterListeners();
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

  String? _firstSubmitMissingRequirement() {
    if (_parametersLoading) {
      return 'Test parameters are still loading. Please wait.';
    }
    if (_project == null) {
      return 'Please select project.';
    }
    if (_section == null) {
      return 'Please select section.';
    }
    if (_contract == null) {
      return 'Please select contract.';
    }
    if (_structureType == null) {
      return 'Please select structure type.';
    }
    if (_structure == null) {
      return 'Please select structure.';
    }
    if (_item == null) {
      return 'Please select item.';
    }
    if (_inspectionType == null) {
      return 'Please select inspection type.';
    }
    if (_category == null) {
      return 'Please select category.';
    }
    if (_subCategory == null) {
      return 'Please select sub-category.';
    }
    if (_locationCtrl.text.trim().isEmpty) {
      return 'Please enter location.';
    }
    if (_parameterRows.isEmpty) {
      return 'Test parameters are required for the selected item.';
    }
    for (final _TestParameterRow row in _parameterRows) {
      if (row.resultCtrl.text.trim().isEmpty) {
        return 'Please enter result for all test parameters.';
      }
      if (row.passFail == null || row.passFail!.isEmpty) {
        return 'Please select Pass / Fail for all test parameters.';
      }
    }
    if (_hasAnyFail) {
      if (_correctiveActionCtrl.text.trim().isEmpty) {
        return 'Please enter corrective action when a test has failed.';
      }
      if (_targetDate == null) {
        return 'Please select target date when a test has failed.';
      }
    }
    return null;
  }

  Future<void> _saveDraft() async {
    if (_project == null) {
      await _showRequired('Please select project to save draft.');
      return;
    }
    await _saveInspection(asDraft: true);
  }

  String _formatSubmitDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _itemFieldValue(String key) {
    if (_item?.raw == null) {
      return '';
    }
    return _str(_pickMapValue(_item!.raw!, <String>[key]));
  }

  void _applySaveResponse(Map<String, dynamic> response) {
    final Map<String, dynamic> data = _asStringKeyedMap(response['data']);
    final String id = _str(data['inspection_id']);
    final String no = _str(data['inspection_no']);
    if (id.isNotEmpty || no.isNotEmpty) {
      setState(() {
        if (id.isNotEmpty) {
          _savedInspectionId = id;
        }
        if (no.isNotEmpty) {
          _inspectionNo = no;
        }
      });
    }
  }

  FormData _buildSaveFormData({required bool asDraft}) {
    final FormData formData = FormData();
    void addField(String name, String value) {
      formData.fields.add(MapEntry<String, String>(name, value));
    }

    addField('inspection_id', _effectiveInspectionId);
    addField('inspection_no', _inspectionNo ?? '');
    addField('inspection_status', asDraft ? 'Draft' : 'Passed');
    addField('project_id_fk', _project?.id ?? '');
    addField('section_id_fk', _section?.id ?? '');
    addField('contract_id_fk', _contract?.id ?? '');
    addField('structure_type_fk', _structureType?.id ?? '');
    addField('structure', _structure?.id ?? '');
    addField('item_id_fk', _item?.id ?? '');
    addField('item_name', _itemFieldValue('item_name'));
    addField('item_code', _itemFieldValue('item_code'));
    addField('type_id_fk', _inspectionType?.id ?? '');
    addField('category_id_fk', _category?.id ?? '');
    addField('sub_category_id_fk', _subCategory?.id ?? '');
    addField('location', _locationCtrl.text.trim());
    addField('lot_no', _lotBatchCtrl.text.trim());
    addField('ncr_compliance', '');
    addField('ncr_compliance_by', '');
    addField('ncr_date', '');
    addField('inspection_step', asDraft ? '1' : '4');

    for (final _TestParameterRow row in _parameterRows) {
      addField('quality_ncr_ids', row.qualityNcrId ?? '');
      addField('parameter_ids', row.parameterId);
      addField('results', row.resultCtrl.text.trim());
      addField('pass_fails', row.passFail ?? '');
      addField('is_ncr_requireds', row.ncrRequired ?? '');
      addField('re_inspected_ons', '');
      addField('revised_results', '');
      addField('revised_pass_fails', '');
      if (row.attachmentBytes != null &&
          row.attachmentName != null &&
          row.attachmentName!.isNotEmpty) {
        formData.files.add(
          MapEntry<String, MultipartFile>(
            'upload_files',
            MultipartFile.fromBytes(
              row.attachmentBytes!,
              filename: row.attachmentName!,
            ),
          ),
        );
      }
    }

    addField('corrective_action_reqd', _correctiveActionCtrl.text.trim());
    addField('action_target_date', _formatSubmitDate(_targetDate));
    addField('corrective_action_taken', '');
    addField('compliance_date', '');
    addField('inspection_closed_on', '');
    return formData;
  }

  bool _responseIndicatesSuccess(Map<String, dynamic> response) {
    if (response['success'] == true) {
      return true;
    }
    final String message = _str(response['message']);
    final String lower = message.toLowerCase();
    return lower.contains('success') ||
        lower.contains('passed') ||
        lower.contains('draft');
  }

  String _responseMessage(
    Map<String, dynamic> response, {
    required bool asDraft,
  }) {
    final String message = _str(response['message']);
    if (message.isNotEmpty) {
      return message;
    }
    return asDraft
        ? 'Inspection saved as draft.'
        : 'Inspection submitted successfully.';
  }

  Future<void> _saveInspection({required bool asDraft}) async {
    if (!asDraft) {
      final String? missing = _firstSubmitMissingRequirement();
      if (missing != null) {
        await _showRequired(missing);
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final Map<String, dynamic> response =
          await widget.dataSource.submitQualityInspectionSaveSubmit(
        formData: _buildSaveFormData(asDraft: asDraft),
      );
      if (!mounted) {
        return;
      }
      if (!_responseIndicatesSuccess(response)) {
        await AppDialog.show(
          context: context,
          title: asDraft ? 'Save draft failed' : 'Submit failed',
          message: _responseMessage(response, asDraft: asDraft),
          type: AppDialogType.error,
        );
        return;
      }
      _applySaveResponse(response);
      await AppDialog.show(
        context: context,
        title: asDraft ? 'Draft saved' : 'Submitted',
        message: _responseMessage(response, asDraft: asDraft),
        type: AppDialogType.success,
      );
      if (mounted) {
        context.pop(true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: asDraft ? 'Save draft failed' : 'Submit failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _submit() async {
    await _saveInspection(asDraft: false);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Quality Inspection' : 'Add Quality Inspection',
        ),
      ),
      body: Stack(
        children: <Widget>[
          SafeArea(
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
                              _isEditMode
                                  ? 'Unable to load inspection for edit.'
                                  : 'Unable to load form.',
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
                              AppTextFormField(
                                controller: _locationCtrl,
                                label: 'Location *',
                                hintText: 'Enter location',
                              ),
                              const SizedBox(height: 10),
                              AppTextFormField(
                                controller: _inspectionByCtrl,
                                label: 'Inspection By',
                                hintText: _project == null
                                    ? 'Select project first'
                                    : '—',
                                readOnly: true,
                                enabled: false,
                              ),
                              const SizedBox(height: 10),
                              AppTextFormField(
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
                                    AppTextFormField(
                                      controller: _correctiveActionCtrl,
                                      label: 'Corrective Action Required *',
                                      hintText: 'Enter corrective action',
                                      minLines: 3,
                                      maxLines: 5,
                                    ),
                                    const SizedBox(height: 10),
                                    AppDateFormField(
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
                            onPressed:
                                _saving || !_canSaveDraft ? null : _saveDraft,
                            child: const Text('Save as draft'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: _saving || !_canSubmit ? null : _submit,
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_saving)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: cs.scrim.withValues(alpha: 0.45),
                  child: Center(
                    child: Material(
                      color: cs.surface,
                      elevation: 6,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Please wait...',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
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
                            child: AppCompactTextFormField(
                              controller: row.resultCtrl,
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

  Widget _paramPassFailCell(_TestParameterRow row) {
    return SizedBox(
      width: _paramColWidth('Pass / Fail'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: AppCompactDropdownField<String>(
          value: row.passFail,
          items: _passFailOptions,
          itemLabelBuilder: (String v) => v,
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
        child: AppCompactDropdownField<String>(
          value: row.ncrRequired,
          items: _ncrOptions,
          itemLabelBuilder: (String v) => v,
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
