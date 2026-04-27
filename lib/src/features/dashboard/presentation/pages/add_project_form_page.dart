import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

class AddProjectFormPage extends ConsumerStatefulWidget {
  const AddProjectFormPage({super.key, this.initialData});

  static const String routeName = 'add-project-form';
  static const String routePath = '/add-project/form';
  final Map<String, dynamic>? initialData;

  @override
  ConsumerState<AddProjectFormPage> createState() => _AddProjectFormPageState();
}

class _AddProjectFormPageState extends ConsumerState<AddProjectFormPage> {
  static const MethodChannel _fileExportChannel = MethodChannel(
    'wcr_pmis_mobile/file_export',
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  bool _prefilledFromInitialData = false;
  String? _initialFormSignature;

  final TextEditingController _projectNameCtrl = TextEditingController();
  final TextEditingController _planHeadCtrl = TextEditingController();
  final TextEditingController _pbItemCtrl = TextEditingController();
  final TextEditingController _sanctionedAmountCtrl = TextEditingController();
  final TextEditingController _actualCompletionCostCtrl = TextEditingController();
  final TextEditingController _benefitsCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  final TextEditingController _proposedLengthCtrl = TextEditingController();
  final TextEditingController _structureDetailsCtrl = TextEditingController();
  final TextEditingController _fromChainageCtrl = TextEditingController();
  final TextEditingController _toChainageCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  int _currentStep = 0;

  String _projectStatus = 'Open';
  _OptionItem? _projectType;
  _OptionItem? _railwayZone;
  _OptionItem? _sanctionedYear;
  _OptionItem? _division;
  _OptionItem? _section;
  DateTime? _sanctionedCommissionDate;
  DateTime? _actualCompletionDate;

  List<_OptionItem> _projectTypes = <_OptionItem>[];
  List<_OptionItem> _railwayZones = <_OptionItem>[];
  List<_OptionItem> _years = <_OptionItem>[];
  List<_OptionItem> _divisions = <_OptionItem>[];
  List<_OptionItem> _sections = <_OptionItem>[];

  final List<_CompletionCostRow> _completionRows = <_CompletionCostRow>[
    _CompletionCostRow(),
  ];

  @override
  void initState() {
    super.initState();
    _attachControllerListeners();
    _loadLookups();
  }

  @override
  void dispose() {
    _projectNameCtrl.dispose();
    _planHeadCtrl.dispose();
    _pbItemCtrl.dispose();
    _sanctionedAmountCtrl.dispose();
    _actualCompletionCostCtrl.dispose();
    _benefitsCtrl.dispose();
    _remarksCtrl.dispose();
    _proposedLengthCtrl.dispose();
    _structureDetailsCtrl.dispose();
    _fromChainageCtrl.dispose();
    _toChainageCtrl.dispose();
    for (final _CompletionCostRow row in _completionRows) {
      row.estimatedCostCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _loadLookups() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final DashboardRemoteDataSource ds = ref.read(
        dashboardRemoteDataSourceProvider,
      );
      final List<Map<String, dynamic>> responses = await Future.wait<
        Map<String, dynamic>
      >(<Future<Map<String, dynamic>>>[
        ds.fetchProjectTypes(),
        ds.fetchRailwayZones(),
        ds.fetchYearList(),
        ds.fetchDivisions(),
        ds.fetchSections(),
      ]);

      _projectTypes = _parseOptions(
        responses[0]['data'],
        idKeys: <String>['project_type_id', 'project_type_id_fk', 'id'],
        labelKeys: <String>['project_type_name', 'projectTypeName', 'name'],
      );
      _railwayZones = _parseOptions(
        responses[1]['data'],
        idKeys: <String>['railway_zone', 'railway_id', 'id'],
        labelKeys: <String>['railway_zone', 'railway_id', 'railway_name'],
      );
      _years = _parseOptions(
        responses[2]['data'],
        idKeys: <String>['financial_year', 'year', 'id'],
        labelKeys: <String>['financial_year', 'year'],
      );
      _divisions = _parseOptions(
        responses[3]['data'],
        idKeys: <String>['division_id', 'id'],
        labelKeys: <String>['division_name', 'divisionName', 'name'],
      );
      _sections = _parseOptions(
        responses[4]['data'],
        idKeys: <String>['section_id', 'id'],
        labelKeys: <String>['section_name', 'sectionName', 'name'],
      );
      _applyInitialValuesIfNeeded();
      _initialFormSignature ??= _formSignature();

      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
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

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.initialData != null;
    final bool isLastStep = _currentStep == 2;
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Project' : 'Add Project')),
      bottomNavigationBar: (_loading || _loadError != null)
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : (_currentStep == 0
                                  ? () => Navigator.of(context).maybePop()
                                  : () => setState(() => _currentStep--)),
                        child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving
                            ? null
                            : (isLastStep
                                  ? (!_canSubmit ? null : _submit)
                                  : (!_canProceedCurrentStep
                                        ? null
                                        : _goToNextStep)),
                        child: Text(
                          !isLastStep
                              ? 'Next'
                              : (_saving
                                    ? (isEditMode ? 'Updating...' : 'Saving...')
                                    : (isEditMode ? 'Update' : 'Save')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(_loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _loadLookups,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: <Widget>[
                  _buildStepHeader(),
                  const SizedBox(height: 14),
                  if (_currentStep == 0) ..._buildStepBasicDetails(),
                  if (_currentStep == 1) ..._buildStepAdditionalDetails(),
                  if (_currentStep == 2) ..._buildStepStructureAndCosts(),
                  const SizedBox(height: 14),
                ],
              ),
            ),
    );
  }

  Widget _buildStepHeader() {
    final List<String> labels = <String>[
      'Basic',
      'Additional',
      'Structure & Costs',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Step ${_currentStep + 1} of ${labels.length}: ${labels[_currentStep]}',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          children: List<Widget>.generate(labels.length, (int index) {
            final bool active = index <= _currentStep;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 6),
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  List<Widget> _buildStepBasicDetails() {
    return <Widget>[
      _sectionTitle('Project Details'),
      _textField(_projectNameCtrl, 'Project Name *', required: true),
      const SizedBox(height: 10),
      AppSelectSheetField<String>(
        label: 'Project Status *',
        title: 'Select Project Status',
        items: const <String>['Open', 'Closed'],
        value: _projectStatus,
        itemLabelBuilder: (String value) => value,
        onChanged: (String value) => setState(() => _projectStatus = value),
      ),
      const SizedBox(height: 10),
      _optionSelect(
        label: 'Project Type *',
        items: _projectTypes,
        value: _projectType,
        onChanged: (_OptionItem v) => setState(() => _projectType = v),
      ),
      const SizedBox(height: 10),
      _optionSelect(
        label: 'Railway Zone *',
        items: _railwayZones,
        value: _railwayZone,
        onChanged: (_OptionItem v) => setState(() => _railwayZone = v),
      ),
      const SizedBox(height: 10),
      _textField(_planHeadCtrl, 'Plan Head Number *', required: true),
      const SizedBox(height: 10),
      _optionSelect(
        label: 'Sanctioned Year *',
        items: _years,
        value: _sanctionedYear,
        onChanged: (_OptionItem v) => setState(() => _sanctionedYear = v),
      ),
      const SizedBox(height: 10),
      _textField(
        _sanctionedAmountCtrl,
        'Sanctioned Amount *',
        required: true,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 10),
      _dateField(
        label: 'Sanctioned Commissioning Date *',
        value: _sanctionedCommissionDate,
        onChanged: (DateTime value) =>
            setState(() => _sanctionedCommissionDate = value),
      ),
      const SizedBox(height: 10),
      _optionSelect(
        label: 'Division *',
        items: _divisions,
        value: _division,
        onChanged: (_OptionItem v) => setState(() => _division = v),
      ),
      const SizedBox(height: 10),
      _optionSelect(
        label: 'Section *',
        items: _sections,
        value: _section,
        onChanged: (_OptionItem v) => setState(() => _section = v),
      ),
    ];
  }

  List<Widget> _buildStepAdditionalDetails() {
    return <Widget>[
      _sectionTitle('Additional Details'),
      _textField(_pbItemCtrl, 'PB Item No'),
      const SizedBox(height: 10),
      _textField(
        _actualCompletionCostCtrl,
        'Actual Completion Cost',
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 10),
      _dateField(
        label: 'Actual Completion Date',
        value: _actualCompletionDate,
        onChanged: (DateTime value) => setState(() => _actualCompletionDate = value),
      ),
      const SizedBox(height: 10),
      _textField(_proposedLengthCtrl, 'Proposed Length (km)'),
      const SizedBox(height: 10),
      _textField(_benefitsCtrl, 'Benefits', maxLines: 3),
      const SizedBox(height: 10),
      _textField(_remarksCtrl, 'Remarks', maxLines: 3),
    ];
  }

  List<Widget> _buildStepStructureAndCosts() {
    return <Widget>[
      _sectionCard(
        title: 'Structure Details',
        children: <Widget>[
          _textField(
            _structureDetailsCtrl,
            'Structure Details',
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _textField(
                  _fromChainageCtrl,
                  'From Chainage',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _textField(
                  _toChainageCtrl,
                  'To Chainage',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 16),
      _sectionCard(
        title: 'Completion Costs',
        children: <Widget>[
          ..._completionRows.asMap().entries.map(
            (MapEntry<int, _CompletionCostRow> entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _completionRow(entry.key, entry.value),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => setState(
                () => _completionRows.add(_CompletionCostRow()),
              ),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Add Completion Cost'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _sectionTitle('KMZ / Chainage Template'),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: _downloadTemplate,
          icon: const Icon(Icons.download_rounded),
          label: const Text('Download Template (.xlsx)'),
        ),
      ),
    ];
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
  );

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.20,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: const InputDecoration(hintText: 'Enter value'),
          onChanged: (_) => setState(() {}),
          validator: required
              ? (String? value) => (value == null || value.trim().isEmpty)
                    ? '$label is required'
                    : null
              : null,
        ),
      ],
    );
  }

  Widget _optionSelect({
    required String label,
    required List<_OptionItem> items,
    required _OptionItem? value,
    required ValueChanged<_OptionItem> onChanged,
  }) {
    return AppSelectSheetField<_OptionItem>(
      label: label,
      title: 'Select $label',
      items: items,
      value: value,
      itemLabelBuilder: (_OptionItem v) => v.label,
      onChanged: onChanged,
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
          ),
          child: InkWell(
            onTap: () async {
              final DateTime now = DateTime.now();
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: value ?? now,
                firstDate: DateTime(1990),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                onChanged(picked);
                setState(() {});
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                value == null ? 'Select...' : _apiDateFormat.format(value),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _completionRow(int index, _CompletionCostRow row) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Row ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (_completionRows.length > 1)
                IconButton(
                  onPressed: () => setState(() {
                    row.estimatedCostCtrl.dispose();
                    _completionRows.removeAt(index);
                  }),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ],
          ),
          _dateField(
            label: 'Completion Date',
            value: row.completionDate,
            onChanged: (DateTime value) => setState(() => row.completionDate = value),
          ),
          const SizedBox(height: 8),
          _textField(
            row.estimatedCostCtrl,
            'Estimated Completion Cost',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          _dateField(
            label: 'Revised Completion Date',
            value: row.revisedCompletionDate,
            onChanged: (DateTime value) =>
                setState(() => row.revisedCompletionDate = value),
          ),
        ],
      ),
    );
  }

  List<_OptionItem> _parseOptions(
    dynamic data, {
    required List<String> idKeys,
    required List<String> labelKeys,
  }) {
    final List<dynamic> rows = data is List<dynamic> ? data : <dynamic>[];
    final List<_OptionItem> options = <_OptionItem>[];
    for (final dynamic row in rows) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = row.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      );
      final String id = _firstValue(map, idKeys);
      final String label = _firstValue(map, labelKeys);
      if (id.isEmpty || label.isEmpty) {
        continue;
      }
      options.add(_OptionItem(id: id, label: label));
    }
    return options;
  }

  String _firstValue(Map<String, dynamic> map, List<String> keys) {
    for (final String key in keys) {
      final String value = map[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  Future<void> _downloadTemplate() async {
    final Excel workbook = Excel.createExcel();
    final String sheetName = workbook.getDefaultSheet() ?? 'Template';
    final Sheet sheet = workbook[sheetName];
    sheet.appendRow(<CellValue>[
      TextCellValue('S.No'),
      TextCellValue('Project Id'),
      TextCellValue('Chainages(m)'),
      TextCellValue('Latitude'),
      TextCellValue('Longitude'),
    ]);
    for (int i = 1; i <= 10; i++) {
      sheet.appendRow(<CellValue>[
        TextCellValue('$i'),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
      ]);
    }
    final List<int>? bytes = workbook.encode();
    if (bytes == null || bytes.isEmpty) {
      return;
    }
    final String savedPath = await _saveExportFile(
      fileName: 'project_chainage_template.xlsx',
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      bytes: Uint8List.fromList(bytes),
    );
    if (!mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'Template Downloaded',
      message: 'File saved to:\n$savedPath',
      type: AppDialogType.success,
    );
  }

  Future<void> _submit() async {
    final bool isEditMode = widget.initialData != null;
    if (!_formKey.currentState!.validate() || !_hasRequiredSelections) {
      return;
    }
    if (!_hasRequiredSelections) {
      await AppDialog.show(
        context: context,
        title: 'Missing Required Fields',
        message:
            'Please select Project Type, Railway Zone, Sanctioned Year, Division and Section.',
        type: AppDialogType.error,
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final List<_CompletionCostRow> validRows = _completionRows
          .where(
            (_CompletionCostRow row) =>
                row.completionDate != null ||
                row.revisedCompletionDate != null ||
                row.estimatedCostCtrl.text.trim().isNotEmpty,
          )
          .toList();

      final String? projectId = _safeString(widget.initialData?['project_id']);
      final Map<String, dynamic> payload = <String, dynamic>{
        if (projectId case final String id) 'project_id': id,
        'project_name': _projectNameCtrl.text.trim(),
        'plan_head_number': _planHeadCtrl.text.trim(),
        'project_status': _projectStatus,
        'project_type_id': _projectType!.id,
        'railway_zone': _railwayZone!.id,
        'pb_item_number': _pbItemCtrl.text.trim(),
        'sanctioned_year': _sanctionedYear!.id,
        'sanctioned_amount': _toNum(_sanctionedAmountCtrl.text),
        'sanctioned_commissioning_date': _toApiDate(_sanctionedCommissionDate),
        'actual_completion_cost': _toNum(_actualCompletionCostCtrl.text),
        'actual_completion_date': _toApiDate(_actualCompletionDate),
        'benefits': _benefitsCtrl.text.trim(),
        'remarks': _remarksCtrl.text.trim(),
        'division_id': _division!.id,
        'section_id': _section!.id,
        'proposed_length': _proposedLengthCtrl.text.trim(),
        'structure_details': _structureDetailsCtrl.text.trim(),
        'from_chainage': _toNum(_fromChainageCtrl.text),
        'to_chainage': _toNum(_toChainageCtrl.text),
        'completion_dates': validRows.map((r) => _toApiDate(r.completionDate)).toList(),
        'estimated_completion_costs': validRows
            .map((r) => _toNum(r.estimatedCostCtrl.text))
            .toList(),
        'revised_completion_dates': validRows
            .map((r) => _toApiDate(r.revisedCompletionDate))
            .toList(),
        'financial_years': <dynamic>[null],
        'railways': <dynamic>[null],
        'pink_book_item_numbers': <dynamic>[null],
      };

      final DashboardRemoteDataSource ds = ref.read(
        dashboardRemoteDataSourceProvider,
      );
      if (isEditMode && (projectId == null || projectId.isEmpty)) {
        throw Exception('Project id is missing for update.');
      }
      final Map<String, dynamic> response = isEditMode
          ? await ds.updateProject(projectId: projectId!, payload: payload)
          : await ds.addProject(payload);

      final bool success = response['success'] == true;
      final String message =
          response['message']?.toString() ??
          (success
              ? (isEditMode
                    ? 'Project updated successfully'
                    : 'Project added successfully')
              : (isEditMode
                    ? 'Unable to update project.'
                    : 'Unable to add project.'));
      if (!mounted) {
        return;
      }
      if (!success) {
        await AppDialog.show(
          context: context,
          title: 'Save Failed',
          message: message,
          type: AppDialogType.error,
        );
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Success',
        message: message,
        type: AppDialogType.success,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Save Failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  bool get _hasRequiredSelections =>
      _projectType != null &&
      _railwayZone != null &&
      _sanctionedYear != null &&
      _division != null &&
      _section != null &&
      _sanctionedCommissionDate != null;

  bool get _hasRequiredTextFields {
    return _projectNameCtrl.text.trim().isNotEmpty &&
        _planHeadCtrl.text.trim().isNotEmpty &&
        _sanctionedAmountCtrl.text.trim().isNotEmpty;
  }

  bool get _hasChanges {
    if (widget.initialData == null) {
      return true;
    }
    if (_initialFormSignature == null) {
      return false;
    }
    return _formSignature() != _initialFormSignature!;
  }

  bool get _canSubmit => _hasRequiredTextFields && _hasRequiredSelections && _hasChanges;

  bool get _canProceedCurrentStep {
    if (_currentStep == 0) {
      return _hasRequiredTextFields && _hasRequiredSelections;
    }
    return true;
  }

  void _goToNextStep() {
    if (!_canProceedCurrentStep) {
      AppDialog.show(
        context: context,
        title: 'Missing Required Fields',
        message:
            'Please complete all mandatory fields in this step before proceeding.',
        type: AppDialogType.error,
      );
      return;
    }
    setState(() => _currentStep++);
  }

  String _formSignature() {
    final List<Map<String, String?>> completionSignature = _completionRows
        .map(
          (_CompletionCostRow row) => <String, String?>{
            'completion': _toApiDate(row.completionDate),
            'estimated': row.estimatedCostCtrl.text.trim().isEmpty
                ? null
                : row.estimatedCostCtrl.text.trim(),
            'revised': _toApiDate(row.revisedCompletionDate),
          },
        )
        .toList();
    final Map<String, dynamic> signature = <String, dynamic>{
      'project_name': _projectNameCtrl.text.trim(),
      'plan_head_number': _planHeadCtrl.text.trim(),
      'project_status': _projectStatus,
      'project_type_id': _projectType?.id,
      'railway_zone': _railwayZone?.id,
      'pb_item_number': _pbItemCtrl.text.trim().isEmpty ? null : _pbItemCtrl.text.trim(),
      'sanctioned_year': _sanctionedYear?.id,
      'sanctioned_amount': _sanctionedAmountCtrl.text.trim(),
      'sanctioned_commissioning_date': _toApiDate(_sanctionedCommissionDate),
      'actual_completion_cost': _actualCompletionCostCtrl.text.trim(),
      'actual_completion_date': _toApiDate(_actualCompletionDate),
      'benefits': _benefitsCtrl.text.trim(),
      'remarks': _remarksCtrl.text.trim(),
      'division_id': _division?.id,
      'section_id': _section?.id,
      'proposed_length': _proposedLengthCtrl.text.trim(),
      'structure_details': _structureDetailsCtrl.text.trim(),
      'from_chainage': _fromChainageCtrl.text.trim(),
      'to_chainage': _toChainageCtrl.text.trim(),
      'completion_rows': completionSignature,
    };
    return jsonEncode(signature);
  }

  void _attachControllerListeners() {
    final List<TextEditingController> controllers = <TextEditingController>[
      _projectNameCtrl,
      _planHeadCtrl,
      _pbItemCtrl,
      _sanctionedAmountCtrl,
      _actualCompletionCostCtrl,
      _benefitsCtrl,
      _remarksCtrl,
      _proposedLengthCtrl,
      _structureDetailsCtrl,
      _fromChainageCtrl,
      _toChainageCtrl,
    ];
    for (final TextEditingController controller in controllers) {
      controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _applyInitialValuesIfNeeded() {
    if (_prefilledFromInitialData || widget.initialData == null) {
      return;
    }
    final Map<String, dynamic> row = widget.initialData!;
    _projectNameCtrl.text = _safeString(row['project_name']) ?? '';
    _planHeadCtrl.text = _safeString(row['plan_head_number']) ?? '';
    _projectStatus = _safeString(row['project_status']) ?? _projectStatus;
    _pbItemCtrl.text = _safeString(row['pb_item_number']) ?? '';
    _sanctionedAmountCtrl.text = _safeString(row['sanctioned_amount']) ?? '';
    _actualCompletionCostCtrl.text = _safeString(row['actual_completion_cost']) ?? '';
    _benefitsCtrl.text = _safeString(row['benefits']) ?? '';
    _remarksCtrl.text = _safeString(row['remarks']) ?? '';
    _proposedLengthCtrl.text = _safeString(row['proposed_length']) ?? '';
    _structureDetailsCtrl.text = _safeString(row['structure_details']) ?? '';
    _fromChainageCtrl.text = _safeString(row['from_chainage']) ?? '';
    _toChainageCtrl.text = _safeString(row['to_chainage']) ?? '';

    _sanctionedCommissionDate = _parseDate(row['sanctioned_commissioning_date']);
    _actualCompletionDate = _parseDate(row['actual_completion_date']);

    _projectType = _findOption(
      _projectTypes,
      idCandidates: <String?>[
        _safeString(row['project_type_id']),
        _safeString(row['project_type_id_fk']),
      ],
      labelCandidates: <String?>[_safeString(row['project_type_name'])],
    );
    _railwayZone = _findOption(
      _railwayZones,
      idCandidates: <String?>[
        _safeString(row['railway_zone']),
        _safeString(row['railway_id']),
      ],
      labelCandidates: <String?>[_safeString(row['railway_zone'])],
    );
    _sanctionedYear = _findOption(
      _years,
      idCandidates: <String?>[_safeString(row['sanctioned_year'])],
      labelCandidates: <String?>[_safeString(row['sanctioned_year'])],
    );
    _division = _findOption(
      _divisions,
      idCandidates: <String?>[_safeString(row['division_id'])],
      labelCandidates: <String?>[_safeString(row['division'])],
    );
    _section = _findOption(
      _sections,
      idCandidates: <String?>[_safeString(row['section_id'])],
      labelCandidates: <String?>[_safeString(row['sections'])],
    );

    final List<_CompletionCostRow> rows = _parseCompletionRows(row['completionCosts']);
    if (rows.isNotEmpty) {
      for (final _CompletionCostRow row in _completionRows) {
        row.estimatedCostCtrl.dispose();
      }
      _completionRows
        ..clear()
        ..addAll(rows);
    }
    _prefilledFromInitialData = true;
  }

  _OptionItem? _findOption(
    List<_OptionItem> options, {
    required List<String?> idCandidates,
    required List<String?> labelCandidates,
  }) {
    for (final String? id in idCandidates) {
      if (id == null || id.isEmpty) {
        continue;
      }
      _OptionItem? found;
      for (final _OptionItem option in options) {
        if (option.id == id) {
          found = option;
          break;
        }
      }
      if (found != null) {
        return found;
      }
    }
    for (final String? label in labelCandidates) {
      if (label == null || label.isEmpty) {
        continue;
      }
      final String normalized = label.toLowerCase();
      _OptionItem? found;
      for (final _OptionItem option in options) {
        if (option.label.toLowerCase() == normalized) {
          found = option;
          break;
        }
      }
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  List<_CompletionCostRow> _parseCompletionRows(dynamic raw) {
    final List<dynamic> list = raw is List<dynamic> ? raw : <dynamic>[];
    final List<_CompletionCostRow> rows = <_CompletionCostRow>[];
    for (final dynamic item in list) {
      if (item is! Map) {
        continue;
      }
      final Map<String, dynamic> map = item.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      );
      final _CompletionCostRow row = _CompletionCostRow();
      row.completionDate = _parseDate(map['completion_date']);
      row.revisedCompletionDate = _parseDate(map['revised_completion_date']);
      row.estimatedCostCtrl.text = _safeString(map['estimated_completion_cost']) ?? '';
      rows.add(row);
    }
    return rows;
  }

  DateTime? _parseDate(dynamic raw) {
    final String? value = _safeString(raw);
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value);
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

  num? _toNum(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return num.tryParse(trimmed);
  }

  String? _toApiDate(DateTime? date) {
    if (date == null) {
      return null;
    }
    return _apiDateFormat.format(date);
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
        // fallback
      } on PlatformException {
        // fallback
      }
    }
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}

class _OptionItem {
  const _OptionItem({required this.id, required this.label});
  final String id;
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _OptionItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label;

  @override
  int get hashCode => Object.hash(id, label);
}

class _CompletionCostRow {
  _CompletionCostRow();
  DateTime? completionDate;
  final TextEditingController estimatedCostCtrl = TextEditingController();
  DateTime? revisedCompletionDate;
}
