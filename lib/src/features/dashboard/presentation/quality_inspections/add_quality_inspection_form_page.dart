import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_compact_form_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_date_form_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_form_field_style.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_text_form_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/quality_inspection_user_access.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

class AddQualityInspectionFormPage extends ConsumerStatefulWidget {
  const AddQualityInspectionFormPage({
    super.key,
    required this.dataSource,
    this.inspectionId,
  });

  static const String routeName = 'add-quality-inspection';
  static const String routePath = '/add-quality-inspection';

  final DashboardRemoteDataSource dataSource;

  final String? inspectionId;

  @override
  ConsumerState<AddQualityInspectionFormPage> createState() =>
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
    required this.categoryId,
    required this.categoryLabel,
    required this.subCategoryId,
    required this.subCategoryLabel,
    this.qualityNcrId,
  });

  final String parameterId;
  final String parameter;
  final String acceptanceCriteria;
  final String uom;
  final String frequency;
  final String categoryId;
  final String categoryLabel;
  final String subCategoryId;
  final String subCategoryLabel;
  final String? qualityNcrId;
  final TextEditingController resultCtrl = TextEditingController();
  final TextEditingController revisedResultCtrl = TextEditingController();
  String? passFail;
  String? revisedPassFail;
  String? ncrRequired;
  String? attachmentName;
  Uint8List? attachmentBytes;
}

class _AddQualityInspectionFormPageState
    extends ConsumerState<AddQualityInspectionFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _inspectionByCtrl = TextEditingController();
  final TextEditingController _lotBatchCtrl = TextEditingController();
  final TextEditingController _correctiveActionCtrl = TextEditingController();
  final TextEditingController _correctiveActionTakenCtrl =
      TextEditingController();
  final TextEditingController _commentsCtrl = TextEditingController();

  int _workflowStep = 1;
  DateTime? _complianceDate;
  DateTime? _closedOn;
  String? _finalAttachmentName;
  Uint8List? _finalAttachmentBytes;

  bool _loading = true;
  bool _cascadeBusy = false;
  bool _saving = false;
  String? _loadError;
  String? _inspectionNo;
  String? _savedInspectionId;
  String _inspectedByFk = '';

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
  List<_QiOption> _selectedCategories = <_QiOption>[];
  List<_QiOption> _selectedSubCategories = <_QiOption>[];

  DateTime? _targetDate;
  bool? _isCorrectionRequired;
  List<_TestParameterRow> _parameterRows = <_TestParameterRow>[];
  bool _parametersLoading = false;

  static const List<String> _passFailOptions = <String>['Pass', 'Fail'];
  static const List<String> _ncrOptions = <String>['Yes', 'No'];

  void _onFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Pass+Yes or Fail+Yes — correction required is forced Yes (radios disabled).
  bool get _correctionRequiredLocked =>
      _parameterRows.any(( _TestParameterRow r) => r.ncrRequired == 'Yes');

  bool get _isViewOnly =>
      _effectiveWorkflowStep >= 5 ||
      (_isEditMode && !_access.canWorkOnWorkflowStep(_effectiveWorkflowStep));

  bool get _showCorrectionRequiredSection {
    if (_parameterRows.isEmpty) {
      return false;
    }
    if (_canEditCreateFields) {
      return _parameterRows.any(
        ( _TestParameterRow r) =>
            (r.passFail == 'Pass' || r.passFail == 'Fail') &&
            (r.ncrRequired == 'Yes' || r.ncrRequired == 'No'),
      );
    }
    return _effectiveWorkflowStep >= 3 &&
        (_isCorrectionRequired == true ||
            _isCorrectionRequired == false ||
            _correctiveActionCtrl.text.trim().isNotEmpty ||
            _targetDate != null ||
            _correctionRequiredLocked);
  }

  bool get _showCorrectiveActionFields {
    if (!_showCorrectionRequiredSection) {
      return false;
    }
    if (_correctionRequiredLocked) {
      return true;
    }
    return _isCorrectionRequired == true;
  }

  bool get _showRespondFields =>
      _effectiveWorkflowStep >= 3 && _showCorrectiveActionFields;

  bool get _showClosureSection => _effectiveWorkflowStep >= 4;

  bool get _hasRequiredSelections =>
      _project != null &&
      _section != null &&
      _contract != null &&
      _structureType != null &&
      _structure != null &&
      _item != null &&
      _inspectionType != null &&
      _selectedCategories.isNotEmpty &&
      _selectedSubCategories.isNotEmpty;

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
      if (_showNcrColumn && _requiresNcrSelection) {
        if (row.ncrRequired == null || row.ncrRequired!.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  bool get _requiresNcrSelection =>
      _canEditCreateFields || _canEditRaiseNcrFields;

  bool get _hasRequiredFollowUp {
    if (!_showCorrectionRequiredSection) {
      return true;
    }
    if (!_correctionRequiredLocked && _isCorrectionRequired == null) {
      return false;
    }
    if (!_showCorrectiveActionFields) {
      return true;
    }
    return _correctiveActionCtrl.text.trim().isNotEmpty && _targetDate != null;
  }

  void _syncCorrectionRequiredFromParameters() {
    if (_correctionRequiredLocked) {
      _isCorrectionRequired = true;
      return;
    }
    if (_canEditCreateFields) {
      final bool hasNcrNoRow = _parameterRows.any(
        ( _TestParameterRow r) =>
            (r.passFail == 'Pass' || r.passFail == 'Fail') &&
            r.ncrRequired == 'No',
      );
      if (!hasNcrNoRow) {
        _isCorrectionRequired = null;
      }
    }
  }

  /// Value shown on [SegmentedButton]; never leaves the widget in an invalid state.
  bool? _correctionRequiredSegmentValue() {
    if (_correctionRequiredLocked) {
      return true;
    }
    if (_isCorrectionRequired != null) {
      return _isCorrectionRequired;
    }
    if (_correctiveActionCtrl.text.trim().isNotEmpty || _targetDate != null) {
      return true;
    }
    if (_effectiveWorkflowStep >= 3 &&
        (_correctiveActionCtrl.text.trim().isNotEmpty ||
            _targetDate != null ||
            _correctionRequiredLocked ||
            _isCorrectionRequired == true)) {
      return true;
    }
    return null;
  }

  bool get _canSubmit {
    if (_loading || _cascadeBusy || _parametersLoading) {
      return false;
    }
    if (_canEditRespondFields) {
      return _correctiveActionTakenCtrl.text.trim().isNotEmpty &&
          _complianceDate != null;
    }
    if (_canEditRaiseNcrFields) {
      return _hasRaiseNcrRequirements;
    }
    if (_canEditClosureFields) {
      return _hasClosureRequirements;
    }
    if (_isViewOnly || !_canEditCreateFields) {
      return false;
    }
    return _hasRequiredSelections &&
        _locationCtrl.text.trim().isNotEmpty &&
        _hasRequiredParameters &&
        _hasRequiredFollowUp;
  }

  bool get _hasRaiseNcrRequirements {
    if (_parameterRows.isEmpty) {
      return false;
    }
    for (final _TestParameterRow row in _parameterRows) {
      if (row.passFail == 'Fail' &&
          (row.ncrRequired == null || row.ncrRequired!.isEmpty)) {
        return false;
      }
    }
    return true;
  }

  bool get _hasClosureRequirements =>
      _closedOn != null && _commentsCtrl.text.trim().isNotEmpty;

  bool get _canSaveDraft =>
      _canEditCreateFields && !_loading && !_cascadeBusy && _project != null;

  bool get _isEditMode =>
      widget.inspectionId != null && widget.inspectionId!.trim().isNotEmpty;

  QualityInspectionUserAccess get _access =>
      ref.watch(qualityInspectionAccessProvider);

  int get _effectiveWorkflowStep => _isEditMode ? _workflowStep : 1;

  bool get _canEditCreateFields =>
      _effectiveWorkflowStep == 1 &&
      (_access.isItAdmin || _access.canCreateInspection);

  bool get _canEditRaiseNcrFields =>
      _effectiveWorkflowStep == 2 &&
      (_access.isItAdmin || _access.canRaiseNcr);

  bool get _canEditRespondFields =>
      !_isViewOnly &&
      _effectiveWorkflowStep == 3 &&
      (_access.isItAdmin || _access.canRespondToNcr);

  bool get _canEditClosureFields =>
      !_isViewOnly &&
      _effectiveWorkflowStep == 4 &&
      (_access.isItAdmin || _access.canCloseInspection);

  bool get _canEditInspectionMetadata =>
      !_isViewOnly && (_canEditCreateFields || _canEditClosureFields);

  bool get _showNcrColumn =>
      _effectiveWorkflowStep >= 1 && _effectiveWorkflowStep <= 4;

  bool get _canEditNcrFields =>
      _canEditCreateFields || _canEditRaiseNcrFields;

  bool get _showReinspectionColumns => false;

  String get _pageTitle {
    if (_isViewOnly) {
      return 'View Quality Inspection';
    }
    if (!_isEditMode) {
      return 'Add Quality Inspection';
    }
    switch (_effectiveWorkflowStep) {
      case 2:
        return 'Raise NCR';
      case 3:
        return _canEditRespondFields ? 'Respond to NCR' : 'View Quality Inspection';
      case 4:
        return 'Complete inspection';
      default:
        return 'Edit Quality Inspection';
    }
  }

  String get _submitButtonLabel {
    switch (_effectiveWorkflowStep) {
      case 1:
        return _parameterRows.any(( _TestParameterRow r) => r.ncrRequired == 'Yes')
            ? 'Raise NCR'
            : 'Submit';
      case 2:
        return 'Raise NCR';
      case 3:
        return 'Submit';
      case 4:
        return 'Submit';
      default:
        return 'Submit';
    }
  }

  @override
  void initState() {
    super.initState();
    final String? editId = widget.inspectionId?.trim();
    if (editId != null && editId.isNotEmpty) {
      _savedInspectionId = editId;
    }
    _locationCtrl.addListener(_onFormChanged);
    _correctiveActionCtrl.addListener(_onFormChanged);
    _correctiveActionTakenCtrl.addListener(_onFormChanged);
    _commentsCtrl.addListener(_onFormChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  String get _effectiveInspectionId => _savedInspectionId ?? '';

  @override
  void dispose() {
    _locationCtrl.removeListener(_onFormChanged);
    _correctiveActionCtrl.removeListener(_onFormChanged);
    _correctiveActionTakenCtrl.removeListener(_onFormChanged);
    _commentsCtrl.removeListener(_onFormChanged);
    _locationCtrl.dispose();
    _inspectionByCtrl.dispose();
    _lotBatchCtrl.dispose();
    _correctiveActionCtrl.dispose();
    _correctiveActionTakenCtrl.dispose();
    _commentsCtrl.dispose();
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
        if (!_access.canCreateInspection) {
          setState(() {
            _loading = false;
            _loadError =
                'You do not have permission to create quality inspections.';
          });
        } else {
          setState(() => _loading = false);
        }
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadError = userFriendlyErrorMessage(error);
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
      out.add(
        _QiOption(
          id: id,
          label: _formatIdNameLabel(id, name),
          raw: map,
        ),
      );
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

  static String _formatIdNameLabel(String id, String name) {
    if (id.isEmpty) {
      return name;
    }
    if (name.isEmpty) {
      return id;
    }
    return '$id - $name';
  }

  List<_QiOption> _parseIdName(
    Map<String, dynamic> response, {
    required String idKey,
    required String nameKey,
    bool labelWithId = false,
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
      out.add(
        _QiOption(
          id: id,
          label: labelWithId ? _formatIdNameLabel(id, name) : name,
          raw: map,
        ),
      );
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

  String _subCategorySelectionKey(_QiOption sub) {
    final String parentId = _str(sub.raw?['parent_category_id_fk']);
    if (parentId.isEmpty) {
      return sub.id;
    }
    return '$parentId|${sub.id}';
  }

  String _subCategoryDisplayLabel(_QiOption sub) {
    final String parentLabel = _str(sub.raw?['parent_category_label']);
    if (parentLabel.isNotEmpty) {
      return '$parentLabel - ${sub.label}';
    }
    return sub.label;
  }

  List<({ _QiOption category, List<_QiOption> subs })> get _subCategoryGroups {
    final List<({ _QiOption category, List<_QiOption> subs })> groups =
        <({ _QiOption category, List<_QiOption> subs })>[];
    for (final _QiOption category in _selectedCategories) {
      final List<_QiOption> subs = _subCategories
          .where(( _QiOption sub) => _subBelongsToCategory(sub, category))
          .toList();
      if (subs.isNotEmpty) {
        groups.add((category: category, subs: subs));
      }
    }
    return groups;
  }

  List<_QiOption> _parseSubCategories(
    Map<String, dynamic> response, {
    String? parentCategoryId,
    String? parentCategoryLabel,
  }) {
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
      if (parentCategoryId != null && parentCategoryId.isNotEmpty) {
        map['parent_category_id_fk'] = parentCategoryId;
      }
      if (parentCategoryLabel != null && parentCategoryLabel.isNotEmpty) {
        map['parent_category_label'] = parentCategoryLabel;
      }
      out.add(_QiOption(id: id, label: name, raw: map));
    }
    return out;
  }

  List<String> _parseIdList(dynamic value) {
    if (value == null) {
      return const <String>[];
    }
    if (value is List) {
      return value
          .map((dynamic item) => _str(item))
          .where((String id) => id.isNotEmpty)
          .toList();
    }
    final String text = _str(value);
    if (text.isEmpty) {
      return const <String>[];
    }
    if (text.contains(',')) {
      return text
          .split(',')
          .map((String part) => part.trim())
          .where((String id) => id.isNotEmpty)
          .toList();
    }
    return <String>[text];
  }

  List<_QiOption> _optionsForIds(
    List<_QiOption> pool,
    List<String> ids,
    List<String> fallbackLabels,
  ) {
    final List<_QiOption> out = <_QiOption>[];
    for (int i = 0; i < ids.length; i++) {
      final String id = ids[i];
      _QiOption? match;
      for (final _QiOption option in pool) {
        if (option.id == id) {
          match = option;
          break;
        }
      }
      if (match != null) {
        out.add(match);
        continue;
      }
      final String label =
          i < fallbackLabels.length ? fallbackLabels[i] : id;
      out.add(_QiOption(id: id, label: label.isEmpty ? id : label));
    }
    return out;
  }

  bool _subBelongsToCategory(_QiOption sub, _QiOption category) {
    final String parentId = _str(sub.raw?['parent_category_id_fk']);
    if (parentId.isEmpty) {
      return true;
    }
    return parentId == category.id;
  }

  Iterable<({ _QiOption category, _QiOption subCategory })>
  _selectedCategorySubCategoryPairs() sync* {
    for (final _QiOption category in _selectedCategories) {
      for (final _QiOption subCategory in _selectedSubCategories) {
        if (_subBelongsToCategory(subCategory, category)) {
          yield (category: category, subCategory: subCategory);
        }
      }
    }
  }

  List<({String key, String title, List<_TestParameterRow> rows})>
  get _parameterGroups {
    final List<
        ({String key, String title, List<_TestParameterRow> rows})> groups =
        <({String key, String title, List<_TestParameterRow> rows})>[];
    final Map<String, List<_TestParameterRow>> grouped =
        <String, List<_TestParameterRow>>{};
    for (final _TestParameterRow row in _parameterRows) {
      final String key = '${row.categoryId}|${row.subCategoryId}';
      grouped.putIfAbsent(key, () => <_TestParameterRow>[]).add(row);
    }
    for (final MapEntry<String, List<_TestParameterRow>> entry
        in grouped.entries) {
      final _TestParameterRow first = entry.value.first;
      groups.add(
        (
          key: entry.key,
          title: '${first.categoryLabel} - ${first.subCategoryLabel}',
          rows: entry.value,
        ),
      );
    }
    return groups;
  }

  void _clearParameterRows() {
    for (final _TestParameterRow row in _parameterRows) {
      row.resultCtrl.removeListener(_onFormChanged);
      row.resultCtrl.dispose();
      row.revisedResultCtrl.dispose();
    }
    _parameterRows = <_TestParameterRow>[];
    _isCorrectionRequired = null;
  }

  void _attachParameterListeners() {
    for (final _TestParameterRow row in _parameterRows) {
      row.resultCtrl.addListener(_onFormChanged);
      row.revisedResultCtrl.addListener(_onFormChanged);
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
    if (project?.raw != null) {
      _inspectedByFk = _str(
        _pickMapValue(
          project!.raw!,
          const <String>[
            'inspected_by_fk',
            'inspectedByFk',
            'inspected_by',
            'inspectedBy',
          ],
        ),
      );
    }
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
      _contracts = _parseIdName(
        results[0],
        idKey: 'id',
        nameKey: 'name',
        labelWithId: true,
      );
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

  Future<void> _reloadSubCategoriesForSelectedCategories() async {
    if (_selectedCategories.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _subCategories = <_QiOption>[];
        _selectedSubCategories = <_QiOption>[];
      });
      return;
    }
    final List<_QiOption> merged = <_QiOption>[];
    final Set<String> seen = <String>{};
    for (final _QiOption category in _selectedCategories) {
      final Map<String, dynamic> response = await widget.dataSource
          .fetchQualityInspectionDropdownSubCategories(
            categoryIdFk: category.id,
          );
      for (final _QiOption option in _parseSubCategories(
        response,
        parentCategoryId: category.id,
        parentCategoryLabel: category.label,
      )) {
        final String key = '${category.id}|${option.id}';
        if (seen.add(key)) {
          merged.add(option);
        }
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _subCategories = merged;
      _selectedSubCategories = _selectedSubCategories
          .where(
            ( _QiOption sub) => _selectedCategories.any(
              ( _QiOption cat) => merged.any(
                ( _QiOption candidate) =>
                    candidate.id == sub.id &&
                    _subBelongsToCategory(candidate, cat),
              ),
            ),
          )
          .toList();
    });
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
        categoryId: _str(
          map['category_id_fk'] ??
              map['insp_category_id'] ??
              map['category_id'],
        ),
        categoryLabel: _str(map['category']),
        subCategoryId: _str(
          map['sub_category_id_fk'] ??
              map['insp_sub_category_id'] ??
              map['sub_category_id'],
        ),
        subCategoryLabel: _str(map['sub_category']),
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
      final String revisedResult = _str(map['revised_result']);
      if (revisedResult.isNotEmpty) {
        paramRow.revisedResultCtrl.text = revisedResult;
      }
      final String revisedPassFail = _str(map['revised_pass_fail']);
      if (revisedPassFail.isNotEmpty) {
        paramRow.revisedPassFail = revisedPassFail;
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
      final int step = QualityInspectionUserAccess.resolveWorkflowStep(data);
      if (!_access.canOpenInspection(step)) {
        setState(() {
          _loading = false;
          _loadError =
              'You do not have permission to open this inspection at the current stage.';
        });
        return;
      }
      setState(() {
        _loading = false;
        _loadError = null;
        _inspectionNo = _str(data['inspection_no']);
        _workflowStep = step;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadError = userFriendlyErrorMessage(error);
      });
    }
  }

  Future<void> _applyInspectionView(Map<String, dynamic> data) async {
    setState(() => _cascadeBusy = true);
    try {
      _workflowStep = QualityInspectionUserAccess.resolveWorkflowStep(data);
      _locationCtrl.text = _str(data['location']);
      _lotBatchCtrl.text = _str(data['lot_no']);
      _correctiveActionCtrl.text = _str(data['corrective_action_reqd']);
      _correctiveActionTakenCtrl.text = _str(data['corrective_action_taken']);
      _targetDate = _parseApiDate(data['action_target_date']);
      _complianceDate = _parseApiDate(data['compliance_date']);
      _closedOn = _parseApiDate(data['inspection_closed_on']);
      _commentsCtrl.text = _str(data['comments']);
      final String finalAttachment = _str(data['final_attachment']);
      if (finalAttachment.isNotEmpty) {
        _finalAttachmentName = finalAttachment.split('/').last;
      }
      final String correctionFlag =
          _str(data['is_correction_required']).toLowerCase();
      if (correctionFlag == 'yes') {
        _isCorrectionRequired = true;
      } else if (correctionFlag == 'no') {
        _isCorrectionRequired = false;
      } else if (_correctiveActionCtrl.text.trim().isNotEmpty ||
          _targetDate != null) {
        _isCorrectionRequired = true;
      }

      final String projectId = _str(data['project_id_fk']);
      _project = _optionOrFallback(
        _projects,
        projectId,
        _str(data['project_name']),
      );
      _applyInspectionByFromProject(_project);
      _inspectedByFk = _str(data['inspected_by_fk']);
      if (_inspectionByCtrl.text.isEmpty) {
        _inspectionByCtrl.text = _str(data['inspected_by_name']);
        if (_inspectionByCtrl.text.isEmpty) {
          _inspectionByCtrl.text = _inspectedByFk;
        }
      }
      final String loadedId = _str(data['inspection_id']);
      if (loadedId.isNotEmpty) {
        _savedInspectionId = loadedId;
      }
      final String loadedNo = _str(data['inspection_no']);
      if (loadedNo.isNotEmpty) {
        _inspectionNo = loadedNo;
      }

      if (projectId.isNotEmpty) {
        await _reloadContractsAndStructureTypes(projectId);
      }

      _section = _optionOrFallback(
        _sections,
        _str(data['section_id_fk']),
        _str(data['section_name']),
      );
      final String contractId = _str(data['contract_id_fk']);
      final String contractName = _str(data['contract_short_name']).isNotEmpty
          ? _str(data['contract_short_name'])
          : _str(data['contract_name']);
      _contract = _optionOrFallback(
        _contracts,
        contractId,
        _formatIdNameLabel(contractId, contractName),
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

      final String structureId = _str(data['structure_id_fk']).isNotEmpty
          ? _str(data['structure_id_fk'])
          : _str(data['structure']);
      _structure = _findStructureOption(_structures, structureId);
      final String itemLabel = _str(data['item_code']).isNotEmpty
          ? '${_str(data['item_name'])} (${_str(data['item_code'])})'
          : _str(data['item_name']);
      _item = _optionOrFallback(_items, _str(data['item_id_fk']), itemLabel);
      _inspectionType = _optionOrFallback(
        _inspectionTypes,
        _str(data['type_id_fk']),
        _str(data['inspection_type']),
      );
      _selectedCategories = _optionsForIds(
        _categories,
        _parseIdList(data['category_id_fk']),
        _parseIdList(data['category']),
      );
      if (_selectedCategories.isEmpty) {
        final String singleCategoryId = _str(data['category_id_fk']);
        final String singleCategoryName = _str(data['category']);
        if (singleCategoryId.isNotEmpty) {
          _selectedCategories = <_QiOption>[
            _optionOrFallback(
              _categories,
              singleCategoryId,
              singleCategoryName,
            ),
          ];
        }
      }

      if (_selectedCategories.isNotEmpty) {
        await _reloadSubCategoriesForSelectedCategories();
      }

      _selectedSubCategories = _optionsForIds(
        _subCategories,
        _parseIdList(data['sub_category_id_fk']),
        _parseIdList(data['sub_category']),
      );
      if (_selectedSubCategories.isEmpty) {
        final String singleSubId = _str(data['sub_category_id_fk']);
        final String singleSubName = _str(data['sub_category']);
        if (singleSubId.isNotEmpty) {
          _selectedSubCategories = <_QiOption>[
            _optionOrFallback(_subCategories, singleSubId, singleSubName),
          ];
        }
      }

      final dynamic ncrRows = data['ncrRows'];
      if (ncrRows is List && ncrRows.isNotEmpty) {
        _applyNcrRows(ncrRows);
        _hydrateSelectionsFromParameterRows();
        if (_selectedCategories.isNotEmpty) {
          await _reloadSubCategoriesForSelectedCategories();
          _hydrateSelectionsFromParameterRows();
        }
      } else if (_item != null &&
          _selectedCategories.isNotEmpty &&
          _selectedSubCategories.isNotEmpty) {
        await _loadTestParameters();
      }

      _syncCorrectionRequiredFromParameters();
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

  void _hydrateSelectionsFromParameterRows() {
    if (_parameterRows.isEmpty) {
      return;
    }
    final Set<String> categoryIds = <String>{};
    final Set<String> subCategoryIds = <String>{};
    for (final _TestParameterRow row in _parameterRows) {
      if (row.categoryId.isNotEmpty) {
        categoryIds.add(row.categoryId);
      }
      if (row.subCategoryId.isNotEmpty) {
        subCategoryIds.add(row.subCategoryId);
      }
    }
    if (categoryIds.isNotEmpty && _selectedCategories.isEmpty) {
      _selectedCategories = _optionsForIds(
        _categories,
        categoryIds.toList(),
        _parameterRows.map(( _TestParameterRow r) => r.categoryLabel).toList(),
      );
    }
    if (subCategoryIds.isNotEmpty && _selectedSubCategories.isEmpty) {
      _selectedSubCategories = _optionsForIds(
        _subCategories,
        subCategoryIds.toList(),
        _parameterRows
            .map(( _TestParameterRow r) => r.subCategoryLabel)
            .toList(),
      );
    }
  }

  Future<void> _onCategoriesChanged(List<_QiOption> values) async {
    setState(() {
      _selectedCategories = values;
      _selectedSubCategories = <_QiOption>[];
      _subCategories = <_QiOption>[];
      _clearParameterRows();
    });
    if (values.isEmpty) {
      return;
    }
    setState(() => _cascadeBusy = true);
    try {
      await _reloadSubCategoriesForSelectedCategories();
    } finally {
      if (mounted) {
        setState(() => _cascadeBusy = false);
      }
    }
  }

  Future<void> _onSubCategoriesChanged(List<_QiOption> values) async {
    setState(() => _selectedSubCategories = values);
    await _loadTestParameters();
  }

  Future<void> _loadTestParameters() async {
    if (_item == null ||
        _selectedCategories.isEmpty ||
        _selectedSubCategories.isEmpty) {
      setState(_clearParameterRows);
      return;
    }
    final List<({ _QiOption category, _QiOption subCategory })> pairs =
        _selectedCategorySubCategoryPairs().toList();
    if (pairs.isEmpty) {
      setState(_clearParameterRows);
      return;
    }
    setState(() {
      _parametersLoading = true;
      _clearParameterRows();
    });
    try {
      final List<_TestParameterRow> rows = <_TestParameterRow>[];
      for (final ({ _QiOption category, _QiOption subCategory }) pair in pairs) {
        final Map<String, dynamic> response = await widget.dataSource
            .fetchQualityInspectionTestParameters(
              itemIdFk: _item!.id,
              categoryIdFk: pair.category.id,
              subCategoryIdFk: pair.subCategory.id,
            );
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
              categoryId: pair.category.id,
              categoryLabel: pair.category.label,
              subCategoryId: pair.subCategory.id,
              subCategoryLabel: pair.subCategory.label,
            ),
          );
        }
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _parameterRows = rows;
        _parametersLoading = false;
      });
      _attachParameterListeners();
      _syncCorrectionRequiredFromParameters();
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

  Future<void> _pickClosedOn() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _closedOn ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && mounted) {
      setState(() => _closedOn = picked);
    }
  }

  Future<void> _pickFinalAttachment() async {
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
      _finalAttachmentName = file.name;
      _finalAttachmentBytes = file.bytes;
    });
  }

  Future<void> _pickComplianceDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _complianceDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && mounted) {
      setState(() => _complianceDate = picked);
    }
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
    if (_effectiveWorkflowStep >= 2 &&
        _effectiveInspectionId.isEmpty &&
        !_canEditCreateFields) {
      return 'Inspection ID is missing. Open the inspection from the list and try again.';
    }
    if (_canEditRespondFields) {
      if (_correctiveActionTakenCtrl.text.trim().isEmpty) {
        return 'Please enter corrective action taken.';
      }
      if (_complianceDate == null) {
        return 'Please select compliance date.';
      }
      return null;
    }
    if (_canEditRaiseNcrFields) {
      if (!_hasRaiseNcrRequirements) {
        return 'Please set Is NCR Required for all failed test parameters.';
      }
      return null;
    }
    if (_canEditClosureFields) {
      if (_closedOn == null) {
        return 'Please select closed on date.';
      }
      if (_commentsCtrl.text.trim().isEmpty) {
        return 'Please enter comments.';
      }
      return null;
    }
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
    if (_selectedCategories.isEmpty) {
      return 'Please select at least one category.';
    }
    if (_selectedSubCategories.isEmpty) {
      return 'Please select at least one sub-category.';
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
      if (_showNcrColumn && _requiresNcrSelection) {
        if (row.ncrRequired == null || row.ncrRequired!.isEmpty) {
          return 'Please select Is NCR Required (Yes/No) for all test parameters.';
        }
      }
    }
    if (_showCorrectionRequiredSection &&
        !_correctionRequiredLocked &&
        _isCorrectionRequired == null) {
      return 'Please select Is Correction Required (Yes/No).';
    }
    if (_showCorrectiveActionFields) {
      if (_correctiveActionCtrl.text.trim().isEmpty) {
        return 'Please enter corrective action required.';
      }
      if (_targetDate == null) {
        return 'Please select target date.';
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
    String id = _str(data['inspection_id']);
    String no = _str(data['inspection_no']);
    if (id.isEmpty) {
      id = _str(response['inspection_id']);
    }
    if (no.isEmpty) {
      no = _str(response['inspection_no']);
    }
    if (id.isEmpty || no.isEmpty) {
      final String fromMessage = _str(response['message']);
      if (no.isEmpty) {
        final RegExp noMatch = RegExp(
          r'INSP/[A-Za-z0-9_./\s()\-]+/\d{4}/\d{4}',
        );
        final Match? m = noMatch.firstMatch(fromMessage);
        if (m != null) {
          no = m.group(0)!.trim();
        }
      }
      if (id.isEmpty) {
        final RegExp idMatch = RegExp(r'inspection\s*id\s*[:=]?\s*(\d+)', caseSensitive: false);
        final Match? m = idMatch.firstMatch(fromMessage);
        if (m != null) {
          id = m.group(1)!.trim();
        }
      }
    }
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

  String _isCorrectionRequiredValue() {
    if (_correctionRequiredLocked || _isCorrectionRequired == true) {
      return 'Yes';
    }
    if (_isCorrectionRequired == false) {
      return 'No';
    }
    if (_correctiveActionCtrl.text.trim().isNotEmpty || _targetDate != null) {
      return 'Yes';
    }
    return 'No';
  }

  String _structureNameForSubmit() {
    if (_structure == null) {
      return '';
    }
    final String fromRaw = _str(_structure!.raw?['structure_name']);
    if (fromRaw.isNotEmpty) {
      return fromRaw;
    }
    return _structure!.label;
  }

  /// True when submitting with NCR Raised in one shot (create or raise-NCR edit).
  bool _shouldSubmitAsNcrRaised({required bool asDraft}) {
    if (asDraft) {
      return false;
    }
    if (_effectiveWorkflowStep != 1 && _effectiveWorkflowStep != 2) {
      return false;
    }
    return _parameterRows.any(( _TestParameterRow r) => r.ncrRequired == 'Yes');
  }

  List<String> _failedParameterNames() {
    return _parameterRows
        .where(( _TestParameterRow r) => r.passFail == 'Fail')
        .map(( _TestParameterRow r) => r.parameter.trim())
        .where((String name) => name.isNotEmpty)
        .toList();
  }

  List<String> _ncrRequestedParameterNames() {
    return _parameterRows
        .where(( _TestParameterRow r) => r.ncrRequired == 'Yes')
        .map(( _TestParameterRow r) => r.parameter.trim())
        .where((String name) => name.isNotEmpty)
        .toList();
  }

  int _submitInspectionStep({required bool asDraft}) {
    if (asDraft) {
      return _effectiveWorkflowStep <= 1 ? 1 : _effectiveWorkflowStep;
    }
    if (_shouldSubmitAsNcrRaised(asDraft: false)) {
      return 3;
    }
    return _effectiveWorkflowStep + 1;
  }

  String _inspectionStatusForSubmit({required bool asDraft}) {
    if (asDraft) {
      return 'Draft';
    }
    if (_shouldSubmitAsNcrRaised(asDraft: false)) {
      return 'NCR Raised';
    }
    switch (_effectiveWorkflowStep) {
      case 1:
        return 'In Progress';
      case 2:
        return 'NCR Raised';
      case 3:
        return 'Rectification Submitted';
      case 4:
        return 'Passed';
      default:
        return 'In Progress';
    }
  }

  FormData _buildContractorRespondFormData() {
    final FormData formData = FormData();
    void addField(String name, String value) {
      formData.fields.add(MapEntry<String, String>(name, value));
    }
    addField('inspection_id', _effectiveInspectionId);
    addField('inspection_no', _inspectionNo ?? '');
    addField('contract_id_fk', _contract?.id ?? '');
    addField('inspection_status', 'Rectification Submitted');
    addField('inspection_step', '4');
    addField('submitted_via', 'MOBILE');
    addField('corrective_action_taken', _correctiveActionTakenCtrl.text.trim());
    addField('compliance_date', _formatSubmitDate(_complianceDate));
    return formData;
  }

  FormData _buildEngineerClosureFormData() {
    final FormData formData = FormData();
    void addField(String name, String value) {
      formData.fields.add(MapEntry<String, String>(name, value));
    }
    addField('inspection_id', _effectiveInspectionId);
    addField('inspection_no', _inspectionNo ?? '');
    addField('contract_id_fk', _contract?.id ?? '');
    addField('inspection_status', 'Passed');
    addField('inspection_step', '5');
    addField('submitted_via', 'MOBILE');
    for (final _TestParameterRow row in _parameterRows) {
      addField('quality_ncr_ids', row.qualityNcrId ?? '');
      addField('parameter_names', row.parameter);
      addField('parameter_ids', row.parameterId);
      addField('results', row.resultCtrl.text.trim());
      addField('pass_fails', row.passFail ?? '');
      addField('is_ncr_requireds', row.ncrRequired ?? '');
      addField('re_inspected_ons', '');
      addField('revised_results', row.revisedResultCtrl.text.trim());
      addField('revised_pass_fails', row.revisedPassFail ?? '');
    }
    if (_finalAttachmentBytes != null &&
        _finalAttachmentName != null &&
        _finalAttachmentName!.isNotEmpty) {
      formData.files.add(
        MapEntry<String, MultipartFile>(
          'final_attachment',
          MultipartFile.fromBytes(
            _finalAttachmentBytes!,
            filename: _finalAttachmentName!,
          ),
        ),
      );
    }
    addField('inspection_closed_on', _formatSubmitDate(_closedOn));
    addField('comments', _commentsCtrl.text.trim());
    return formData;
  }

  FormData _buildSaveFormData({required bool asDraft}) {
    if (!asDraft && _canEditRespondFields) {
      return _buildContractorRespondFormData();
    }
    if (!asDraft && _canEditClosureFields) {
      return _buildEngineerClosureFormData();
    }

    final FormData formData = FormData();
    void addField(String name, String value) {
      formData.fields.add(MapEntry<String, String>(name, value));
    }

    final int submitStep = _submitInspectionStep(asDraft: asDraft);

    addField('inspection_id', _effectiveInspectionId);
    addField('inspection_no', _inspectionNo ?? '');
    addField('contract_id_fk', _contract?.id ?? '');
    addField(
      'inspection_status',
      _inspectionStatusForSubmit(asDraft: asDraft),
    );
    addField('inspection_step', '$submitStep');
    addField('submitted_via', 'MOBILE');
    addField('inspected_by_fk', _inspectedByFk);
    addField('project_id_fk', _project?.id ?? '');
    addField('section_id_fk', _section?.id ?? '');
    addField('structure_type_fk', _structureType?.id ?? '');
    addField('structure_id_fk', _structure?.id ?? '');
    addField('structure_name', _structureNameForSubmit());
    addField('item_id_fk', _item?.id ?? '');
    addField('item_name', _itemFieldValue('item_name'));
    addField('item_code', _itemFieldValue('item_code'));
    addField('type_id_fk', _inspectionType?.id ?? '');
    for (final _QiOption category in _selectedCategories) {
      addField('category_id_fk', category.id);
    }
    for (final _QiOption subCategory in _selectedSubCategories) {
      addField('sub_category_id_fk', subCategory.id);
    }
    addField('location', _locationCtrl.text.trim());
    addField('lot_no', _lotBatchCtrl.text.trim());
    addField('is_correction_required', _isCorrectionRequiredValue());
    addField(
      'corrective_action_reqd',
      _showCorrectiveActionFields ? _correctiveActionCtrl.text.trim() : '',
    );
    addField(
      'action_target_date',
      _showCorrectiveActionFields ? _formatSubmitDate(_targetDate) : '',
    );

    for (final _TestParameterRow row in _parameterRows) {
      addField('quality_ncr_ids', row.qualityNcrId ?? '');
      addField('parameter_names', row.parameter);
      addField('parameter_ids', row.parameterId);
      addField('results', row.resultCtrl.text.trim());
      addField('pass_fails', row.passFail ?? '');
      addField('is_ncr_requireds', row.ncrRequired ?? '');
      addField('re_inspected_ons', '');
      addField('revised_results', row.revisedResultCtrl.text.trim());
      addField('revised_pass_fails', row.revisedPassFail ?? '');
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

    if (_shouldSubmitAsNcrRaised(asDraft: asDraft)) {
      for (final String name in _failedParameterNames()) {
        addField('failed_parameters', name);
      }
      for (final String name in _ncrRequestedParameterNames()) {
        addField('ncr_requested_parameters', name);
      }
    }

    addField('ncr_compliance', _canEditRespondFields ? 'Yes' : '');
    addField('ncr_compliance_by', '');
    addField('ncr_date', _canEditRespondFields ? _formatSubmitDate(_complianceDate) : '');
    addField('corrective_action_taken', _correctiveActionTakenCtrl.text.trim());
    addField('compliance_date', _formatSubmitDate(_complianceDate));
    addField('inspection_closed_on', _formatSubmitDate(_closedOn));
    addField('comments', _commentsCtrl.text.trim());
    return formData;
  }

  bool _responseIndicatesSuccess(Map<String, dynamic> response) {
    final String message = _str(response['message']);
    final String lower = message.toLowerCase();
    if (lower.contains('failed') || lower.contains('error')) {
      return false;
    }
    if (response['success'] == true) {
      return true;
    }
    return lower.contains('successfully') ||
        lower.contains('saved successfully') ||
        lower.contains('passed successfully') ||
        (lower.contains('draft') && lower.contains('saved'));
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
        message: userFriendlyErrorMessage(error),
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
        title: Text(_pageTitle),
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
                              _loadError ??
                                  (_isEditMode
                                      ? 'Unable to load inspection for edit.'
                                      : 'Unable to load form.'),
                              textAlign: TextAlign.center,
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
                                enabled:
                                    _canEditInspectionMetadata && !_cascadeBusy,
                                onChanged: ( _QiOption v) => _onProjectChanged(v),
                              ),
                              const SizedBox(height: 10),
                              _requiredSelect(
                                label: 'Section',
                                items: _sections,
                                value: _section,
                                enabled:
                                    _canEditInspectionMetadata && !_cascadeBusy,
                                onChanged: ( _QiOption v) =>
                                    setState(() => _section = v),
                              ),
                              const SizedBox(height: 10),
                              _requiredSelect(
                                label: 'Contract',
                                items: _contracts,
                                value: _contract,
                                enabled:
                                    _canEditInspectionMetadata &&
                                    _project != null &&
                                    !_cascadeBusy,
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
                                enabled:
                                    _canEditInspectionMetadata &&
                                    _project != null &&
                                    !_cascadeBusy,
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
                                    _canEditInspectionMetadata &&
                                    _structureType != null &&
                                    !_cascadeBusy,
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
                                enabled:
                                    _canEditInspectionMetadata &&
                                    _structureType != null &&
                                    !_cascadeBusy,
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
                                enabled:
                                    _canEditInspectionMetadata && !_cascadeBusy,
                                onChanged: ( _QiOption v) =>
                                    setState(() => _inspectionType = v),
                              ),
                              const SizedBox(height: 10),
                              _requiredMultiSelect(
                                label: 'Category',
                                items: _categories,
                                selected: _selectedCategories,
                                enabled:
                                    _canEditInspectionMetadata && !_cascadeBusy,
                                placeholder: 'Select categories',
                                onChanged: _onCategoriesChanged,
                              ),
                              const SizedBox(height: 10),
                              _requiredGroupedSubCategoryMultiSelect(
                                enabled:
                                    _canEditInspectionMetadata &&
                                    _selectedCategories.isNotEmpty &&
                                    !_cascadeBusy,
                              ),
                              const SizedBox(height: 10),
                              AppTextFormField(
                                controller: _locationCtrl,
                                label: 'Location *',
                                hintText: 'Enter location',
                                readOnly: !_canEditInspectionMetadata,
                                enabled: _canEditInspectionMetadata,
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
                                readOnly: !_canEditInspectionMetadata,
                                enabled: _canEditInspectionMetadata,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _parametersSection(),
                          if (_showCorrectionRequiredSection) ...<Widget>[
                            const SizedBox(height: 12),
                            _correctionRequiredSection(context),
                          ],
                          if (_showRespondFields) ...<Widget>[
                            const SizedBox(height: 12),
                            _respondFieldsSection(),
                          ],
                          if (_showClosureSection) ...<Widget>[
                            const SizedBox(height: 12),
                            _closureSection(),
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
                if (!_loading && _loadError == null && !_isViewOnly)
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
                        if (_canSaveDraft) ...<Widget>[
                          Expanded(
                            child: FilledButton.tonal(
                              onPressed:
                                  _saving || !_canSaveDraft ? null : _saveDraft,
                              child: const Text('Save as draft'),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: FilledButton(
                            onPressed: _saving ||
                                    !_access.canWorkOnWorkflowStep(
                                      _effectiveWorkflowStep,
                                    ) ||
                                    !_canSubmit
                                ? null
                                : _submit,
                            child: Text(_submitButtonLabel),
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

  Widget _requiredGroupedSubCategoryMultiSelect({
    required bool enabled,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<({ _QiOption category, List<_QiOption> subs })> groups =
        _subCategoryGroups;
    final String placeholder = _selectedCategories.isEmpty
        ? 'Select category first'
        : 'Select sub-categories';
    final String summary = _selectedSubCategories.isEmpty
        ? placeholder
        : _selectedSubCategories
            .map(_subCategoryDisplayLabel)
            .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Sub-Category *',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: !enabled || groups.isEmpty
              ? null
              : () async {
                  final Set<String> tempSelected = _selectedSubCategories
                      .map(_subCategorySelectionKey)
                      .toSet();
                  final List<_QiOption>? picked =
                      await showModalBottomSheet<List<_QiOption>>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (
                          BuildContext context,
                          StateSetter setSheetState,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Select Sub-Category',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Flexible(
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: groups.expand((
                                      ({ _QiOption category, List<_QiOption> subs }) group,
                                    ) {
                                      return <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            4,
                                            10,
                                            4,
                                            4,
                                          ),
                                          child: Text(
                                            group.category.label.toUpperCase(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.4,
                                                ),
                                          ),
                                        ),
                                        ...group.subs.map((
                                          _QiOption sub,
                                        ) {
                                          final String key =
                                              _subCategorySelectionKey(sub);
                                          return CheckboxListTile(
                                            value: tempSelected.contains(key),
                                            title: Text(sub.label),
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            onChanged: (bool? checked) {
                                              setSheetState(() {
                                                if (checked ?? false) {
                                                  tempSelected.add(key);
                                                } else {
                                                  tempSelected.remove(key);
                                                }
                                              });
                                            },
                                          );
                                        }),
                                      ];
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {
                                          final List<_QiOption> result =
                                              <_QiOption>[];
                                          for (final String key
                                              in tempSelected) {
                                            for (final _QiOption sub
                                                in _subCategories) {
                                              if (_subCategorySelectionKey(
                                                    sub,
                                                  ) ==
                                                  key) {
                                                result.add(sub);
                                                break;
                                              }
                                            }
                                          }
                                          Navigator.of(context).pop(result);
                                        },
                                        child: const Text('Apply'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                  if (picked != null) {
                    await _onSubCategoriesChanged(picked);
                  }
                },
          child: InputDecorator(
            decoration: AppFormFieldStyle.decoration(
              context,
              hintText: placeholder,
              filled: _selectedSubCategories.isNotEmpty,
            ),
            child: Text(
              summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _selectedSubCategories.isEmpty
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
              ),
            ),
          ),
        ),
        if (_selectedSubCategories.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedSubCategories
                .map(
                  ( _QiOption option) => Chip(
                    label: Text(_subCategoryDisplayLabel(option)),
                    visualDensity: VisualDensity.compact,
                    deleteIcon: enabled
                        ? const Icon(Icons.close_rounded, size: 16)
                        : null,
                    onDeleted: !enabled
                        ? null
                        : () async {
                            final List<_QiOption> next =
                                List<_QiOption>.from(_selectedSubCategories)
                                  ..removeWhere(
                                    ( _QiOption o) =>
                                        _subCategorySelectionKey(o) ==
                                        _subCategorySelectionKey(option),
                                  );
                            await _onSubCategoriesChanged(next);
                          },
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _requiredMultiSelect({
    required String label,
    required List<_QiOption> items,
    required List<_QiOption> selected,
    required Future<void> Function(List<_QiOption>) onChanged,
    bool enabled = true,
    String placeholder = 'Select',
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String summary = selected.isEmpty
        ? placeholder
        : selected.map(( _QiOption o) => o.label).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '$label *',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: !enabled
              ? null
              : () async {
                  final List<_QiOption>? picked =
                      await showModalBottomSheet<List<_QiOption>>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    builder: (BuildContext context) {
                      final Set<String> tempSelected = selected
                          .map(( _QiOption o) => o.id)
                          .toSet();
                      return StatefulBuilder(
                        builder: (
                          BuildContext context,
                          StateSetter setSheetState,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Select $label',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Flexible(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: items.length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final _QiOption item = items[index];
                                      return CheckboxListTile(
                                        value: tempSelected.contains(item.id),
                                        title: Text(item.label),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        onChanged: (bool? checked) {
                                          setSheetState(() {
                                            if (checked ?? false) {
                                              tempSelected.add(item.id);
                                            } else {
                                              tempSelected.remove(item.id);
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {
                                          final List<_QiOption> result =
                                              items
                                                  .where(
                                                    ( _QiOption item) =>
                                                        tempSelected
                                                            .contains(item.id),
                                                  )
                                                  .toList();
                                          Navigator.of(context).pop(result);
                                        },
                                        child: const Text('Apply'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                  if (picked != null) {
                    await onChanged(picked);
                  }
                },
          child: InputDecorator(
            decoration: AppFormFieldStyle.decoration(
              context,
              hintText: placeholder,
              filled: selected.isNotEmpty,
            ),
            child: Text(
              summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected.isEmpty
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
              ),
            ),
          ),
        ),
        if (selected.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selected
                .map(
                  ( _QiOption option) => Chip(
                    label: Text(option.label),
                    visualDensity: VisualDensity.compact,
                    deleteIcon: enabled
                        ? const Icon(Icons.close_rounded, size: 16)
                        : null,
                    onDeleted: !enabled
                        ? null
                        : () async {
                            final List<_QiOption> next =
                                List<_QiOption>.from(selected)
                                  ..removeWhere(
                                    ( _QiOption o) => o.id == option.id,
                                  );
                            await onChanged(next);
                          },
                  ),
                )
                .toList(),
          ),
        ],
      ],
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

  Widget _correctionRequiredSection(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool locked = _correctionRequiredLocked;
    final bool? segmentValue = _correctionRequiredSegmentValue();
    final bool allowEmptySelection = segmentValue == null;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Is Correction Required?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SegmentedButton<bool>(
                    emptySelectionAllowed: allowEmptySelection,
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(value: true, label: Text('Yes')),
                      ButtonSegment<bool>(value: false, label: Text('No')),
                    ],
                    selected: segmentValue == null
                        ? <bool>{}
                        : <bool>{segmentValue},
                    onSelectionChanged: locked || !_canEditCreateFields
                        ? null
                        : (Set<bool> selection) {
                            if (selection.isEmpty) {
                              setState(() {
                                _isCorrectionRequired = null;
                                _correctiveActionCtrl.clear();
                                _targetDate = null;
                              });
                              return;
                            }
                            final bool yes = selection.first;
                            setState(() {
                              _isCorrectionRequired = yes;
                              if (!yes) {
                                _correctiveActionCtrl.clear();
                                _targetDate = null;
                              }
                            });
                          },
                  ),
                ),
              ],
            ),
            if (_showCorrectiveActionFields) ...<Widget>[
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool narrow = constraints.maxWidth < 560;
                  final Widget actionField = AppTextFormField(
                    controller: _correctiveActionCtrl,
                    label: 'Corrective Action Required',
                    hintText: 'Enter corrective action',
                    minLines: 3,
                    maxLines: 5,
                    readOnly: !_canEditCreateFields,
                    enabled: _canEditCreateFields,
                  );
                  final Widget dateField = AppDateFormField(
                    label: 'Target Date',
                    value: _targetDate,
                    onTap: _pickTargetDate,
                    enabled: _canEditCreateFields,
                  );
                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        actionField,
                        const SizedBox(height: 10),
                        dateField,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 3, child: actionField),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: dateField),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _respondFieldsSection() {
    return _sectionCard(
      title: 'Corrective action',
      children: <Widget>[
        AppTextFormField(
          controller: _correctiveActionTakenCtrl,
          label: 'Corrective Action Taken',
          hintText: 'Enter action taken',
          minLines: 3,
          maxLines: 5,
          readOnly: !_canEditRespondFields,
          enabled: _canEditRespondFields,
        ),
        const SizedBox(height: 10),
        AppDateFormField(
          label: 'Compliance Date',
          value: _complianceDate,
          onTap: _pickComplianceDate,
          enabled: _canEditRespondFields,
        ),
      ],
    );
  }

  Widget _closureSection() {
    return _sectionCard(
      title: 'Closure',
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _canEditClosureFields ? _pickFinalAttachment : null,
                icon: const Icon(Icons.attach_file_rounded),
                label: Text(
                  _finalAttachmentName ?? 'Add Attachment / Photo',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AppDateFormField(
          label: 'Closed On',
          value: _closedOn,
          onTap: _pickClosedOn,
          enabled: _canEditClosureFields,
        ),
        const SizedBox(height: 10),
        AppTextFormField(
          controller: _commentsCtrl,
          label: 'Comments',
          hintText: 'Enter comments',
          minLines: 3,
          maxLines: 5,
          readOnly: !_canEditClosureFields,
          enabled: _canEditClosureFields,
        ),
      ],
    );
  }

  Widget _parametersSection() {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool canLoad = _item != null &&
        _selectedCategories.isNotEmpty &&
        _selectedSubCategories.isNotEmpty;

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

  List<String> get _parameterHeaders {
    final List<String> headers = <String>[
      'Parameters',
      'Acceptance Criteria',
      'UOM',
      'Frequency',
      'Result',
      'Pass / Fail',
    ];
    if (_showNcrColumn) {
      headers.add('Is NCR Required');
    }
    if (_showReinspectionColumns) {
      headers
        ..add('Revised Result')
        ..add('Revised Pass / Fail');
    }
    if (_canEditCreateFields) {
      headers.add('Attachment');
    }
    return headers;
  }

  Widget _parametersTable() {
    final List<String> headers = _parameterHeaders;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool canEditResults = _canEditCreateFields;
    final double tableWidth = headers.fold<double>(
      0,
      (double sum, String header) => sum + _paramColWidth(header),
    );

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
                                h == 'Result' ||
                                        h == 'Pass / Fail' ||
                                        h == 'Is NCR Required' ||
                                        h == 'Revised Result' ||
                                        h == 'Revised Pass / Fail'
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
                ..._parameterGroups.expand(
                  (
                    ({
                      String key,
                      String title,
                      List<_TestParameterRow> rows,
                    }) group,
                  ) {
                    final List<Widget> widgets = <Widget>[
                      SizedBox(
                        width: tableWidth,
                        child: Container(
                          color: cs.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Text(
                            group.title,
                            style: TextStyle(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ];
                    for (int index = 0; index < group.rows.length; index++) {
                      final _TestParameterRow row = group.rows[index];
                      final Color bg = index.isEven
                          ? cs.primary.withValues(alpha: 0.06)
                          : cs.surface;
                      widgets.add(
                        Container(
                          color: bg,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _paramCell(
                                row.parameter,
                                _paramColWidth('Parameters'),
                              ),
                              _paramCell(
                                row.acceptanceCriteria,
                                _paramColWidth('Acceptance Criteria'),
                              ),
                              _paramCell(row.uom, _paramColWidth('UOM')),
                              _paramCell(
                                row.frequency,
                                _paramColWidth('Frequency'),
                              ),
                              SizedBox(
                                width: _paramColWidth('Result'),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: AppCompactTextFormField(
                                    controller: row.resultCtrl,
                                    enabled: canEditResults,
                                  ),
                                ),
                              ),
                              _paramPassFailCell(row),
                              if (_showNcrColumn) _paramNcrCell(row),
                              if (_showReinspectionColumns) ...<Widget>[
                                SizedBox(
                                  width: _paramColWidth('Revised Result'),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: AppCompactTextFormField(
                                      controller: row.revisedResultCtrl,
                                      enabled: false,
                                    ),
                                  ),
                                ),
                                _paramRevisedPassFailCell(row),
                              ],
                              if (_canEditCreateFields)
                                SizedBox(
                                  width: _paramColWidth('Attachment'),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        IconButton.filled(
                                          tooltip: 'Attach file',
                                          onPressed: () => _pickAttachment(row),
                                          icon: const Icon(
                                            Icons.attach_file_rounded,
                                          ),
                                        ),
                                        if (row.attachmentName != null)
                                          Text(
                                            row.attachmentName!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                    return widgets;
                  },
                ),
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
    final bool editable = _canEditCreateFields;
    return SizedBox(
      width: _paramColWidth('Pass / Fail'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: AppCompactDropdownField<String>(
          value: row.passFail,
          items: _passFailOptions,
          itemLabelBuilder: (String v) => v,
          onChanged: editable
              ? (String? value) {
                  setState(() {
                    row.passFail = value;
                    if (_canEditNcrFields) {
                      if (value == 'Pass') {
                        row.ncrRequired = 'No';
                      } else if (value == 'Fail') {
                        row.ncrRequired = 'Yes';
                      } else {
                        row.ncrRequired = null;
                      }
                    }
                    _syncCorrectionRequiredFromParameters();
                  });
                }
              : null,
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
          onChanged: _canEditNcrFields
              ? (String? value) => setState(() {
                  row.ncrRequired = value;
                  _syncCorrectionRequiredFromParameters();
                })
              : null,
        ),
      ),
    );
  }

  Widget _paramRevisedPassFailCell(_TestParameterRow row) {
    return SizedBox(
      width: _paramColWidth('Revised Pass / Fail'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: AppCompactDropdownField<String>(
          value: row.revisedPassFail,
          items: _passFailOptions,
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
      case 'Revised Result':
        return 110;
      case 'Revised Pass / Fail':
        return 130;
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
