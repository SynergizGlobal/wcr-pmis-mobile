import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_step_header.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

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

Map<String, dynamic> _mergedIssueRoot(Map<String, dynamic> root) {
  Map<String, dynamic> merged = Map<String, dynamic>.from(root);
  void pullFrom(dynamic node) {
    if (node is! Map) {
      return;
    }
    final Map<String, dynamic> inner = _asStringKeyedMap(node);
    inner.forEach((String k, dynamic v) {
      merged.putIfAbsent(k, () => v);
    });
  }

  for (final String key in <String>['data', 'model', 'result', 'body']) {
    pullFrom(merged[key]);
  }
  return merged;
}

List<dynamic> _responseLists(Map<String, dynamic> map) {
  final dynamic direct = map['data'];
  if (direct is List<dynamic>) {
    return direct;
  }
  for (final MapEntry<String, dynamic> e in map.entries) {
    if (e.value is List<dynamic>) {
      return e.value as List<dynamic>;
    }
  }
  return const <dynamic>[];
}

List<dynamic> _listFromMerged(Map<String, dynamic> merged, List<String> keys) {
  for (final String k in keys) {
    final dynamic v = merged[k];
    if (v is List<dynamic> && v.isNotEmpty) {
      return v;
    }
  }
  for (final MapEntry<String, dynamic> e in merged.entries) {
    final dynamic raw = e.value;
    if (raw is! List<dynamic>) {
      continue;
    }
    final List<dynamic> list = raw;
    if (list.isEmpty) {
      continue;
    }
    final String ekLower = e.key.toLowerCase();
    for (final String k in keys) {
      if (ekLower == k.toLowerCase()) {
        return list;
      }
    }
  }
  return const <dynamic>[];
}

String _pick(Map<String, dynamic> map, List<String> keys) {
  for (final String key in keys) {
    final dynamic value = map[key];
    final String parsed = value?.toString().trim() ?? '';
    if (parsed.isNotEmpty && parsed.toLowerCase() != 'null') {
      return parsed;
    }
  }
  return '';
}

class _IssueOption {
  const _IssueOption({required this.id, required this.label, this.raw});

  final String id;
  final String label;
  final Map<String, dynamic>? raw;
}

class _IssueAttachmentRow {
  _IssueAttachmentRow()
      : id =
            '${DateTime.now().microsecondsSinceEpoch}_${identityHashCode(Object())}',
        nameCtrl = TextEditingController();

  final String id;
  final TextEditingController nameCtrl;
  _IssueOption? fileType;
  Uint8List? bytes;
  String? pickedFileName;

  void dispose() {
    nameCtrl.dispose();
  }
}

class AddIssueFormPage extends StatefulWidget {
  const AddIssueFormPage({
    super.key,
    required this.dataSource,
    this.session,
  });

  static const String routeName = 'add-issue-form';
  static const String routePath = '/add-issue-form';

  final DashboardRemoteDataSource dataSource;

  final AuthSession? session;

  @override
  State<AddIssueFormPage> createState() => _AddIssueFormPageState();
}

class _AddIssueFormPageState extends State<AddIssueFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _saving = false;
  bool _cascadeBusy = false;
  int _currentStep = 0;

  List<_IssueOption> _projects = <_IssueOption>[];
  List<_IssueOption> _contracts = <_IssueOption>[];
  List<_IssueOption> _categories = <_IssueOption>[];
  List<_IssueOption> _titles = <_IssueOption>[];
  List<_IssueOption> _structures = <_IssueOption>[];
  List<_IssueOption> _components = <_IssueOption>[];
  List<_IssueOption> _priorityItems = <_IssueOption>[];
  List<_IssueOption> _responsibleItems = <_IssueOption>[];
  List<_IssueOption> _otherOrgItems = <_IssueOption>[];
  List<_IssueOption> _fileTypeItems = <_IssueOption>[];

  _IssueOption? _project;
  _IssueOption? _contract;
  _IssueOption? _category;
  _IssueOption? _title;
  _IssueOption? _structure;
  _IssueOption? _component;
  _IssueOption? _priority;
  _IssueOption? _responsible;
  _IssueOption? _otherOrg;

  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _actionTakenCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _otherOrgResponsibleNameCtrl =
      TextEditingController();
  final TextEditingController _otherOrgResponsibleDesignationCtrl =
      TextEditingController();

  DateTime? _deadlineResolutionDate;
  final List<_IssueAttachmentRow> _attachments = <_IssueAttachmentRow>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _actionTakenCtrl.dispose();
    _locationCtrl.dispose();
    _otherOrgResponsibleNameCtrl.dispose();
    _otherOrgResponsibleDesignationCtrl.dispose();
    for (final _IssueAttachmentRow r in _attachments) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    try {
      final Map<String, dynamic> data =
          await widget.dataSource.fetchAddIssueFormData();
      if (!mounted) {
        return;
      }
      final Map<String, dynamic> merged = _mergedIssueRoot(data);
      setState(() {
        _projects = _optionsFromMaps(
          _listFromMerged(merged, const <String>['projectsList', 'projectList']),
          idKeys: const <String>['project_id_fk', 'project_id', 'projectId'],
          labelKeys: const <String>['project_name', 'projectName', 'name'],
        );
        _priorityItems = _optionsFromMaps(
          _listFromMerged(merged, const <String>['issuesPriorityList', 'priorityList']),
          idKeys: const <String>['priority_fk', 'priority', 'id'],
          labelKeys: const <String>['priority', 'priority_name', 'name'],
        );
        _responsibleItems = _optionsFromRailwayRows(
          _listFromMerged(merged, const <String>[
            'railwayList',
            'railway_list',
            'railways',
            'railway_name',
          ]),
        );
        _otherOrgItems = _optionsFromOtherOrgRows(
          _listFromMerged(merged, const <String>[
            'other_organization',
            'other_organizations',
            'otherOrganizations',
            'otherOrganizationList',
            'other_organization_list',
          ]),
        );
        _fileTypeItems = _optionsFromMaps(
          _listFromMerged(merged, const <String>['issueFileTypes', 'issue_file_typesList']),
          idKeys: const <String>['issue_file_type_fk', 'issue_file_type', 'id'],
          labelKeys: const <String>['issue_file_type', 'file_type_name', 'name'],
        );
        _structures = _issueOptionsFromField(
          _listFromMerged(merged, const <String>[
            'structure',
            'structures',
            'structureList',
            'structure_list',
          ]),
          rowFieldKey: 'structure',
        );
        _components = _issueOptionsFromField(
          _listFromMerged(merged, const <String>[
            'component',
            'components',
            'componentList',
            'component_list',
          ]),
          rowFieldKey: 'component',
        );
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        type: AppDialogType.error,
        title: 'Load Failed',
        message: 'Could not load add-issue form data. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _reportedByUserId() => widget.session?.userId.trim() ?? '';

  List<_IssueOption> _optionsFromMaps(
    List<dynamic> rows, {
    required List<String> idKeys,
    required List<String> labelKeys,
    String labelSeparator = ' — ',
  }) {
    final List<_IssueOption> out = <_IssueOption>[];
    final Set<String> seen = <String>{};
    for (final dynamic row in rows) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> m = _asStringKeyedMap(row);
      final String id = _pick(m, idKeys);
      if (id.isEmpty) {
        continue;
      }
      final StringBuffer buf = StringBuffer();
      for (final String lk in labelKeys) {
        final String bit = _pick(m, <String>[lk]);
        if (bit.isEmpty) {
          continue;
        }
        if (buf.isEmpty) {
          buf.write(bit);
        } else if (!buf.toString().contains(bit)) {
          buf.write(labelSeparator);
          buf.write(bit);
        }
      }
      String label = buf.toString();
      if (label.isEmpty) {
        label = id;
      }
      if (!seen.add(id)) {
        continue;
      }
      out.add(_IssueOption(id: id, label: label, raw: m));
    }
    return out;
  }

  List<_IssueOption> _contractOptionsFrom(List<dynamic> rows) {
    final List<_IssueOption> out = <_IssueOption>[];
    final Set<String> seen = <String>{};
    for (final dynamic row in rows) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> m = _asStringKeyedMap(row);
      final String id = _pick(m, const <String>['contract_id_fk', 'contract_id']);
      if (id.isEmpty || !seen.add(id)) {
        continue;
      }
      final String label = _pick(
            m,
            const <String>['contract_short_name', 'contract_name', 'contract_code'],
          ).isEmpty
          ? id
          : _pick(
              m,
              const <String>['contract_short_name', 'contract_name', 'contract_code'],
            );
      out.add(_IssueOption(id: id, label: label, raw: m));
    }
    return out;
  }

  List<_IssueOption> _categoryOptionsFrom(List<dynamic> rows) {
    final List<_IssueOption> out = <_IssueOption>[];
    final Set<String> seen = <String>{};
    for (final dynamic row in rows) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> m = _asStringKeyedMap(row);
      String id = _pick(m, const <String>['category_fk', 'category_id', 'id']);
      if (id.isEmpty) {
        final String cat = _pick(m, const <String>['category']);
        final String rel = _pick(m, const <String>['issues_related_to']);
        id = rel.isNotEmpty ? '$cat|$rel' : cat;
      }
      if (id.isEmpty || !seen.add(id)) {
        continue;
      }
      final String cat = _pick(m, const <String>['category']);
      final String rel = _pick(m, const <String>['issues_related_to']);
      final String label = rel.isNotEmpty ? '$cat — $rel' : cat;
      out.add(_IssueOption(id: id, label: label.isEmpty ? id : label, raw: m));
    }
    return out;
  }

  List<_IssueOption> _titleOptionsFrom(List<dynamic> rows) {
    final List<_IssueOption> out = <_IssueOption>[];
    final Set<String> seen = <String>{};
    for (final dynamic row in rows) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> m = _asStringKeyedMap(row);
      String id = _pick(m, const <String>[
        'issue_title_fk',
        'title_fk',
        'short_description_fk',
        'id',
      ]);
      if (id.isEmpty) {
        id = _pick(m, const <String>['short_description', 'title', 'description']);
      }
      if (id.isEmpty || !seen.add(id)) {
        continue;
      }
      final String label = _pick(
        m,
        const <String>['short_description', 'title', 'description'],
      );
      out.add(
        _IssueOption(
          id: id,
          label: label.isEmpty ? id : label,
          raw: m,
        ),
      );
    }
    return out;
  }

  List<_IssueOption> _issueOptionsFromField(
    List<dynamic> rows, {
    required String rowFieldKey,
  }) {
    final List<_IssueOption> out = <_IssueOption>[];
    final Set<String> seen = <String>{};
    for (final dynamic row in rows) {
      if (row is String) {
        final String s = row.trim();
        if (s.isEmpty || !seen.add(s)) {
          continue;
        }
        out.add(_IssueOption(id: s, label: s));
        continue;
      }
      if (row is Map) {
        final Map<String, dynamic> m = _asStringKeyedMap(row);
        final String v = _pick(
          m,
          <String>[rowFieldKey, '${rowFieldKey}_name'],
        );
        if (v.isEmpty || !seen.add(v)) {
          continue;
        }
        out.add(_IssueOption(id: v, label: v, raw: m));
      }
    }
    return out;
  }

  List<_IssueOption> _optionsFromRailwayRows(List<dynamic> rows) {
    final List<_IssueOption> out = <_IssueOption>[];
    final Set<String> seen = <String>{};
    for (final dynamic row in rows) {
      if (row is String) {
        final String s = row.trim();
        if (s.isEmpty || !seen.add(s)) {
          continue;
        }
        out.add(_IssueOption(id: s, label: s));
        continue;
      }
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> m = _asStringKeyedMap(row);
      final String label = _pick(
        m,
        const <String>['railway_name', 'railway', 'name', 'railway_full_name'],
      );
      String id = _pick(
        m,
        const <String>[
          'railway_id',
          'railway_id_fk',
          'railway_fk',
          'zonal_railway_fk',
          'zonal_railway',
          'id',
        ],
      );
      if (id.isEmpty) {
        id = label;
      }
      if (id.isEmpty || !seen.add(id)) {
        continue;
      }
      out.add(
        _IssueOption(
          id: id,
          label: label.isEmpty ? id : label,
          raw: m,
        ),
      );
    }
    return out;
  }

  List<_IssueOption> _optionsFromOtherOrgRows(List<dynamic> rows) {
    final List<_IssueOption> out = <_IssueOption>[];
    final Set<String> seen = <String>{};
    for (final dynamic row in rows) {
      if (row is String) {
        final String s = row.trim();
        if (s.isEmpty || !seen.add(s)) {
          continue;
        }
        out.add(_IssueOption(id: s, label: s));
        continue;
      }
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> m = _asStringKeyedMap(row);
      final String label = _pick(
        m,
        const <String>[
          'other_organization',
          'other_org_name',
          'organization_name',
          'name',
        ],
      );
      String id = _pick(
        m,
        const <String>[
          'other_organization_fk',
          'organization_fk',
          'other_org_fk',
          'id',
        ],
      );
      if (id.isEmpty) {
        id = label;
      }
      if (id.isEmpty || !seen.add(id)) {
        continue;
      }
      out.add(
        _IssueOption(
          id: id,
          label: label.isEmpty ? id : label,
          raw: m,
        ),
      );
    }
    return out;
  }

  Future<void> _onProjectChanged(_IssueOption? p) async {
    setState(() {
      _project = p;
      _contract = null;
      _category = null;
      _title = null;
      _structure = null;
      _component = null;
      _priority = null;
      _contracts = <_IssueOption>[];
      _categories = <_IssueOption>[];
      _titles = <_IssueOption>[];
    });
    if (p == null || p.id.isEmpty) {
      return;
    }
    setState(() => _cascadeBusy = true);
    try {
      final Map<String, dynamic> res = await widget.dataSource
          .fetchIssueFormContracts(projectIdFk: p.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _contracts = _contractOptionsFrom(_responseLists(res));
      });
    } finally {
      if (mounted) {
        setState(() => _cascadeBusy = false);
      }
    }
  }

  Future<void> _onContractChanged(_IssueOption? c) async {
    setState(() {
      _contract = c;
      _category = null;
      _title = null;
      _structure = null;
      _component = null;
      _priority = null;
      _categories = <_IssueOption>[];
      _titles = <_IssueOption>[];
    });
    if (c == null || c.id.isEmpty) {
      return;
    }
    setState(() => _cascadeBusy = true);
    try {
      final String contractTypeFk =
          _pick(c.raw ?? <String, dynamic>{}, const <String>['contract_type_fk']);
      final Map<String, dynamic> catRes = await widget.dataSource
          .fetchIssueFormCategories(contractTypeFk: contractTypeFk);
      if (!mounted) {
        return;
      }
      setState(() {
        _categories = _categoryOptionsFrom(_responseLists(catRes));
      });
    } finally {
      if (mounted) {
        setState(() => _cascadeBusy = false);
      }
    }
  }

  Future<void> _onCategoryChanged(_IssueOption? c) async {
    setState(() {
      _category = c;
      _title = null;
      _titles = <_IssueOption>[];
    });
    if (c == null || c.id.isEmpty) {
      return;
    }
    setState(() => _cascadeBusy = true);
    try {
      final Map<String, dynamic> res =
          await widget.dataSource.fetchIssueFormTitles(categoryFk: c.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _titles = _titleOptionsFrom(_responseLists(res));
      });
    } finally {
      if (mounted) {
        setState(() => _cascadeBusy = false);
      }
    }
  }

  void _onStructureChanged(_IssueOption? s) {
    setState(() {
      _structure = s;
      _component = null;
    });
  }

  void _addAttachment() {
    setState(() {
      _attachments.add(_IssueAttachmentRow());
    });
  }

  void _removeAttachment(String id) {
    setState(() {
      _attachments.removeWhere((_IssueAttachmentRow r) {
        if (r.id == id) {
          r.dispose();
          return true;
        }
        return false;
      });
    });
  }

  Future<void> _pickFile(_IssueAttachmentRow row) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final PlatformFile file = result.files.first;
    if (file.bytes == null) {
      return;
    }
    setState(() {
      row.bytes = file.bytes;
      row.pickedFileName = file.name;
      if (row.nameCtrl.text.trim().isEmpty) {
        row.nameCtrl.text = file.name;
      }
    });
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        if (_project == null) {
          _showRequired('Please select a project.');
          return false;
        }
        if (_contract == null) {
          _showRequired('Please select a contract.');
          return false;
        }
        if (_category == null) {
          _showRequired('Please select a category.');
          return false;
        }
        if (_title == null) {
          _showRequired('Please select an issue title / short description.');
          return false;
        }
        if (_priority == null) {
          _showRequired('Please select issue priority.');
          return false;
        }
        return true;
      case 1:
        if (_reportedByUserId().isEmpty) {
          _showRequired(
            'Reported by requires a signed-in user. Please log in again.',
          );
          return false;
        }
        if (_descriptionCtrl.text.trim().isEmpty) {
          _showRequired('Please enter description of issue.');
          return false;
        }
        if (_responsible == null) {
          _showRequired(
            'Please select responsible organization (pending with).',
          );
          return false;
        }
        if (_otherOrg == null) {
          _showRequired(
            'Please select other responsible organization (pending with).',
          );
          return false;
        }
        if (_otherOrgResponsibleNameCtrl.text.trim().isEmpty) {
          _showRequired('Please enter responsible person name.');
          return false;
        }
        if (_otherOrgResponsibleDesignationCtrl.text.trim().isEmpty) {
          _showRequired('Please enter responsible person designation.');
          return false;
        }
        return true;
      case 2:
        for (final _IssueAttachmentRow r in _attachments) {
          final bool hasFile = r.bytes != null && r.bytes!.isNotEmpty;
          if (hasFile && r.fileType == null) {
            _showRequired('Select a file type for each attachment with a file.');
            return false;
          }
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _showRequired(String message) async {
    await AppDialog.show(
      context: context,
      type: AppDialogType.info,
      title: 'Required',
      message: message,
    );
  }

  Future<void> _next() async {
    if (!_validateStep(_currentStep)) {
      return;
    }
    setState(() => _currentStep = (_currentStep + 1).clamp(0, 2));
  }

  String _formatDate(DateTime? d) {
    if (d == null) {
      return '';
    }
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  String _reportedByDisplayName() {
    final String n = widget.session?.userName.trim() ?? '';
    if (n.isNotEmpty) {
      return n;
    }
    return _reportedByUserId();
  }

  String _zonalRailwayFk() {
    if (_responsible == null) {
      return '';
    }
    final Map<String, dynamic> m =
        _responsible!.raw ?? <String, dynamic>{};
    final String z = _pick(
      m,
      const <String>[
        'zonal_railway_fk',
        'railway_id',
        'railway_fk',
        'railway_id_fk',
      ],
    );
    if (z.isNotEmpty) {
      return z;
    }
    return _responsible!.id;
  }

  Map<String, String> _buildAddIssueFields() {
    final String titleText = _title?.label ?? _title?.id ?? '';
    final String priorityText = _priority?.label ?? _priority?.id ?? '';
    final String otherOrgText = _otherOrg?.label ?? _otherOrg?.id ?? '';

    final List<String> typeLabels = <String>[];
    final List<String> fileNames = <String>[];
    for (final _IssueAttachmentRow r in _attachments) {
      if (r.bytes == null || r.bytes!.isEmpty) {
        continue;
      }
      typeLabels.add(
        (r.fileType?.label ?? r.fileType?.id ?? '').trim(),
      );
      final String fn = r.pickedFileName?.trim().isNotEmpty == true
          ? r.pickedFileName!.trim()
          : (r.nameCtrl.text.trim().isNotEmpty
                ? r.nameCtrl.text.trim()
                : 'file');
      fileNames.add(fn);
    }

    return <String, String>{
      'project_id_fk': _project?.id ?? '',
      'contract_id_fk': _contract?.id ?? '',
      'structure': _structure?.id ?? '',
      'component': _component?.id ?? '',
      'category_fk': _category?.id ?? '',
      'title': titleText,
      'priority_fk': priorityText,
      'description': _descriptionCtrl.text.trim(),
      'corrective_measure': _actionTakenCtrl.text.trim(),
      'date': _deadlineResolutionDate != null
          ? _formatDate(_deadlineResolutionDate)
          : '',
      'location': _locationCtrl.text.trim(),
      'other_organization': otherOrgText,
      'zonal_railway_fk': _zonalRailwayFk(),
      'other_org_resposible_person_name':
          _otherOrgResponsibleNameCtrl.text.trim(),
      'other_org_resposible_person_designation':
          _otherOrgResponsibleDesignationCtrl.text.trim(),
      'reported_by': _reportedByDisplayName(),
      'assigned_date': '',
      'resolved_date': '',
      'issue_file_types': typeLabels.join(','),
      'issueFileNames': fileNames.join(','),
      'issue_file_ids': '',
    };
  }

  List<({Uint8List bytes, String fileName})> _buildIssueFileParts() {
    final List<({Uint8List bytes, String fileName})> out =
        <({Uint8List bytes, String fileName})>[];
    for (final _IssueAttachmentRow r in _attachments) {
      final Uint8List? b = r.bytes;
      if (b == null || b.isEmpty) {
        continue;
      }
      final String fn = r.pickedFileName?.trim().isNotEmpty == true
          ? r.pickedFileName!.trim()
          : (r.nameCtrl.text.trim().isNotEmpty
                ? r.nameCtrl.text.trim()
                : 'file');
      out.add((bytes: b, fileName: fn));
    }
    return out;
  }

  Future<void> _submit() async {
    if (!_validateStep(0) ||
        !_validateStep(1) ||
        !_validateStep(2)) {
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.dataSource.submitAddIssue(
        fields: _buildAddIssueFields(),
        files: _buildIssueFileParts(),
      );
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        type: AppDialogType.success,
        title: 'Saved',
        message: 'Issue submitted successfully.',
      );
      if (!mounted) {
        return;
      }
      context.pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        type: AppDialogType.error,
        title: 'Save Failed',
        message: 'Unable to submit issue. Check required fields and try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Issue')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppStepHeader(
                    title: 'Report an issue',
                    currentStep: _currentStep,
                    stepTitles: const <String>[
                      'Step 1 — Basics',
                      'Step 2 — Issue details',
                      'Step 3 — Attachments',
                    ],
                    chipLabels: const <String>['1 Basics', '2 Details', '3 Files'],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : Form(
                          key: _formKey,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                            children: <Widget>[
                              if (_currentStep == 0) _stepClassification(),
                              if (_currentStep == 1) _stepIssueDetails(),
                              if (_currentStep == 2) _stepAttachments(),
                            ],
                          ),
                        ),
                  if (_cascadeBusy)
                    Positioned.fill(
                      child: AbsorbPointer(
                        child: ColoredBox(
                          color: Colors.black.withValues(alpha: 0.06),
                          child: const Center(
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                  top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
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
                          : (_currentStep == 2 ? _submit : _next),
                      icon: Icon(
                        _currentStep == 2
                            ? Icons.send_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(_currentStep == 2 ? 'Submit issue' : 'Continue'),
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

  Widget _reportedByBanner(BuildContext context) {
    final String name =
        widget.session?.userName.trim().isNotEmpty == true
            ? widget.session!.userName.trim()
            : _reportedByUserId();
    final ThemeData theme = Theme.of(context);
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Reported by',
        border: OutlineInputBorder(),
      ),
      child: Text(
        name.isEmpty ? '—' : name,
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  Widget _stepClassification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _grid(<Widget>[
          AppSelectSheetField<_IssueOption>(
            label: 'Project *',
            title: 'Select project',
            items: _projects,
            value: _project,
            onChanged: _onProjectChanged,
            itemLabelBuilder: (_IssueOption o) => o.label,
            placeholderText: 'Select project',
          ),
          AppSelectSheetField<_IssueOption>(
            label: 'Contract *',
            title: 'Select contract',
            items: _contracts,
            value: _contract,
            enabled: _project != null && !_cascadeBusy,
            onChanged: _onContractChanged,
            itemLabelBuilder: (_IssueOption o) => o.label,
            placeholderText: 'Select contract',
          ),
          AppSelectSheetField<_IssueOption>(
            label: 'Structure',
            title: 'Select structure',
            items: _structures,
            value: _structure,
            enabled:
                !_cascadeBusy && _structures.isNotEmpty,
            onChanged: _onStructureChanged,
            itemLabelBuilder: (_IssueOption o) => o.label,
            placeholderText: 'Optional',
          ),
          AppSelectSheetField<_IssueOption>(
            label: 'Component',
            title: 'Select component',
            items: _components,
            value: _component,
            enabled:
                !_cascadeBusy && _components.isNotEmpty,
            onChanged: (_IssueOption v) => setState(() => _component = v),
            itemLabelBuilder: (_IssueOption o) => o.label,
            placeholderText: 'Optional',
          ),
          AppSelectSheetField<_IssueOption>(
            label: 'Issue Category *',
            title: 'Select category',
            items: _categories,
            value: _category,
            enabled: _contract != null && !_cascadeBusy,
            onChanged: _onCategoryChanged,
            itemLabelBuilder: (_IssueOption o) => o.label,
            placeholderText: 'Select category',
          ),
          AppSelectSheetField<_IssueOption>(
            label: 'Short Description *',
            title: 'Select Description',
            items: _titles,
            value: _title,
            enabled: _category != null && !_cascadeBusy,
            onChanged: (_IssueOption v) => setState(() => _title = v),
            itemLabelBuilder: (_IssueOption o) => o.label,
            placeholderText: 'Select Description',
          ),
          AppSelectSheetField<_IssueOption>(
            label: 'Issue Priority *',
            title: 'Select priority',
            items: _priorityItems,
            value: _priority,
            enabled: !_cascadeBusy && _priorityItems.isNotEmpty,
            onChanged: (_IssueOption v) => setState(() => _priority = v),
            itemLabelBuilder: (_IssueOption o) => o.label,
            placeholderText: 'Select priority',
          ),
        ]),
      ],
    );
  }

  static const int _detailMaxChars = 1000;

  Widget _stepIssueDetails() {
    const double gapV = 12;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          controller: _descriptionCtrl,
          maxLines: 5,
          maxLength: _detailMaxChars,
          decoration: const InputDecoration(
            labelText: 'Description of issue *',
            hintText: 'Describe the issue',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: gapV),
        TextFormField(
          controller: _actionTakenCtrl,
          maxLines: 5,
          maxLength: _detailMaxChars,
          decoration: const InputDecoration(
            labelText: 'Action taken',
            hintText: 'What has been done so far',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: gapV),
        _dateTile(
          label: 'Deadline for issue resolution',
          value: _deadlineResolutionDate,
          placeholder: 'dd/mm/yyyy',
          onPick: (DateTime d) =>
              setState(() => _deadlineResolutionDate = d),
        ),
        const SizedBox(height: gapV),
        TextFormField(
          controller: _locationCtrl,
          decoration: const InputDecoration(
            labelText: 'Location / station / KM',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: gapV),
        AppSelectSheetField<_IssueOption>(
          label: 'Responsible Organization (Pending with) *',
          title: 'Select organization',
          items: _responsibleItems,
          value: _responsible,
          enabled: !_cascadeBusy && _responsibleItems.isNotEmpty,
          onChanged: (_IssueOption v) => setState(() => _responsible = v),
          itemLabelBuilder: (_IssueOption o) => o.label,
          placeholderText: 'Select value',
        ),
        const SizedBox(height: gapV),
        AppSelectSheetField<_IssueOption>(
          label: 'Other Responsible Organization (Pending with) *',
          title: 'Select organization',
          items: _otherOrgItems,
          value: _otherOrg,
          enabled: !_cascadeBusy && _otherOrgItems.isNotEmpty,
          onChanged: (_IssueOption v) {
            setState(() {
              _otherOrg = v;
              _otherOrgResponsibleNameCtrl.clear();
              _otherOrgResponsibleDesignationCtrl.clear();
            });
          },
          itemLabelBuilder: (_IssueOption o) => o.label,
          placeholderText: 'Select value',
        ),
        if (_otherOrg != null) ...<Widget>[
          const SizedBox(height: gapV),
          TextFormField(
            controller: _otherOrgResponsibleNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Responsible Person Name *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: gapV),
          TextFormField(
            controller: _otherOrgResponsibleDesignationCtrl,
            decoration: const InputDecoration(
              labelText: 'Responsible Person Designation *',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        const SizedBox(height: gapV),
        _reportedByBanner(context),
      ],
    );
  }

  Widget _stepAttachments() {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'File type & attachment',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Attachments',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _saving ? null : _addAttachment,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Add row'),
                  ),
                ],
              ),
              if (_attachments.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Optional: add file type + attachment rows.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                )
              else
                ..._attachments.map(_attachmentCard),
            ],
          ),
        ),
      ],
    );
  }

  Widget _attachmentCard(_IssueAttachmentRow row) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Attachment',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  onPressed: _saving ? null : () => _removeAttachment(row.id),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            AppSelectSheetField<_IssueOption>(
              label: 'File type',
              title: 'Select file type',
              items: _fileTypeItems,
              value: row.fileType,
              enabled: _fileTypeItems.isNotEmpty,
              onChanged: (_IssueOption v) => setState(() => row.fileType = v),
              itemLabelBuilder: (_IssueOption o) => o.label,
              placeholderText: 'Select type',
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: row.nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Display name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _saving ? null : () => _pickFile(row),
              icon: const Icon(Icons.attach_file_rounded),
              label: Text(row.pickedFileName ?? 'Choose file'),
            ),
            if (row.bytes != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${row.bytes!.length} bytes selected',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.primary,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onPick,
    String placeholder = 'Tap to select',
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final DateTime now = DateTime.now();
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 5),
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
              ? placeholder
              : '${value.day.toString().padLeft(2, '0')}/'
                  '${value.month.toString().padLeft(2, '0')}/'
                  '${value.year}',
        ),
      ),
    );
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
}
