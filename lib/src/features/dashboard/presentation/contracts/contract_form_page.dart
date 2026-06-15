import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_text_form_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

class ContractFormPage extends StatefulWidget {
  const ContractFormPage({
    super.key,
    required this.dataSource,
    this.contractId,
    this.initialRecord,
  });

  static const String routeName = 'contract-form';
  static const String routePath = '/contracts/form';

  final DashboardRemoteDataSource dataSource;
  final String? contractId;
  final Map<String, dynamic>? initialRecord;

  @override
  State<ContractFormPage> createState() => _ContractFormPageState();
}

class _ContractFormPageState extends State<ContractFormPage> {
  static const List<_ContractStepMeta> _steps = <_ContractStepMeta>[
    _ContractStepMeta(
      title: 'Contract Managers',
      subtitle: 'Project, HOD, department and bank funding',
      icon: Icons.groups_outlined,
    ),
    _ContractStepMeta(
      title: 'Executives',
      subtitle: 'Assign responsible people by department',
      icon: Icons.badge_outlined,
    ),
    _ContractStepMeta(
      title: 'Contract Details',
      subtitle: 'Names, costs, dates and tender revisions',
      icon: Icons.description_outlined,
    ),
    _ContractStepMeta(
      title: 'Documents',
      subtitle: 'Upload contract files and attachments',
      icon: Icons.folder_open_outlined,
    ),
  ];
  static const List<String> _typeOfReviewOptions = <String>['Prior', 'Post'];
  static const int _shortNameMaxLength = 100;
  static const int _contractNameMaxLength = 1000;
  static const int _ifasCodeMaxLength = 50;
  static const int _scopeMaxLength = 1000;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  final TextEditingController _shortNameCtrl = TextEditingController();
  final TextEditingController _contractNameCtrl = TextEditingController();
  final TextEditingController _ifasCodeCtrl = TextEditingController();
  final TextEditingController _scopeCtrl = TextEditingController();
  final TextEditingController _loaLetterCtrl = TextEditingController();
  final TextEditingController _estimatedCostCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _loadingWorkStatus = false;
  int _currentStep = 0;

  bool _contractAwarded = false;
  bool _bankFunded = false;

  _ContractOption? _project;
  _ContractOption? _hod;
  _ContractOption? _dyHod;
  _ContractOption? _contractDepartment;
  _ContractOption? _bankName;
  String? _typeOfReview;
  _ContractOption? _contractType;
  _ContractOption? _contractor;
  _ContractOption? _workStatus;
  _ContractOption? _costUnit;

  DateTime? _loaDate;
  DateTime? _plannedAwardDate;
  DateTime? _plannedCompletionDate;
  DateTime? _noticeInvitingTenderDate;
  DateTime? _tenderOpeningDate;
  DateTime? _technicalEvalDate;
  DateTime? _financialEvalDate;

  List<_ContractOption> _projects = <_ContractOption>[];
  List<_ContractOption> _hods = <_ContractOption>[];
  List<_ContractOption> _dyHods = <_ContractOption>[];
  List<_ContractOption> _departments = <_ContractOption>[];
  List<_ContractOption> _bankNames = <_ContractOption>[];
  List<_ContractOption> _contractTypes = <_ContractOption>[];
  List<_ContractOption> _contractors = <_ContractOption>[];
  List<_ContractOption> _workStatuses = <_ContractOption>[];
  List<_ContractOption> _units = <_ContractOption>[];
  List<_ContractOption> _fileTypes = <_ContractOption>[];

  final List<_ExecutiveRow> _executiveRows = <_ExecutiveRow>[_ExecutiveRow()];
  final List<_TenderRevisionRow> _revisionRows = <_TenderRevisionRow>[];
  final List<_DocumentRow> _documentRows = <_DocumentRow>[];
  Map<String, dynamic> _preservedEditValues = <String, dynamic>{};

  bool get _isEdit =>
      widget.contractId != null && widget.contractId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadForm());
  }

  @override
  void dispose() {
    _shortNameCtrl.dispose();
    _contractNameCtrl.dispose();
    _ifasCodeCtrl.dispose();
    _scopeCtrl.dispose();
    _loaLetterCtrl.dispose();
    _estimatedCostCtrl.dispose();
    _remarksCtrl.dispose();
    for (final _ExecutiveRow row in _executiveRows) {
      row.dispose();
    }
    for (final _TenderRevisionRow row in _revisionRows) {
      row.dispose();
    }
    for (final _DocumentRow row in _documentRows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Update Contract' : 'Add Contract'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (!_loading)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: _ContractFormStepper(
                  steps: _steps,
                  currentStep: _currentStep,
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.03, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: ListView(
                          key: ValueKey<int>(_currentStep),
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                          children: <Widget>[
                            if (_currentStep == 0) _stepManagers(),
                            if (_currentStep == 1) _stepExecutives(),
                            if (_currentStep == 2) _stepDetails(),
                            if (_currentStep == 3) _stepDocuments(),
                          ],
                        ),
                      ),
                    ),
            ),
            if (!_loading)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: BoxDecoration(
                  color: cs.surface,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  border: Border(
                    top: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.55),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Step ${_currentStep + 1} of ${_steps.length} · ${_steps[_currentStep].title}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildFooterActions(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterActions() {
    if (_currentStep == 3) {
      if (_isEdit) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: _saving
                  ? null
                  : () => setState(() => _currentStep -= 1),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back'),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _saving ? null : () => _submit(),
              icon: const Icon(Icons.save_rounded),
              label: Text(_saving ? 'Updating...' : 'Update'),
            ),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          OutlinedButton.icon(
            onPressed: _saving
                ? null
                : () => setState(() => _currentStep -= 1),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back'),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => _submit(addAnother: true),
                  child: Text(_saving ? 'Saving...' : 'Add'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saving ? null : () => _submit(),
                  icon: const Icon(Icons.save_rounded),
                  label: Text(_saving ? 'Saving...' : 'Save'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: <Widget>[
        if (_currentStep > 0) ...<Widget>[
          OutlinedButton.icon(
            onPressed: _saving
                ? null
                : () => setState(() => _currentStep -= 1),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back'),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: FilledButton.icon(
            onPressed: _saving ? null : _nextStep,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Continue'),
          ),
        ),
      ],
    );
  }

  Widget _stepManagers() {
    return Column(
      children: <Widget>[
        _sectionCard(
          children: <Widget>[
            AppSelectSheetField<_ContractOption>(
              label: 'Project *',
              title: 'Select Project',
              items: _projects,
              value: _project,
              itemLabelBuilder: (_ContractOption o) => o.label,
              placeholderText: 'Select project',
              onChanged: ( _ContractOption value) =>
                  setState(() => _project = value),
            ),
            const SizedBox(height: 10),
            _yesNoField(
              label: 'Contract Awarded *',
              value: _contractAwarded,
              onChanged: _onContractAwardedChanged,
            ),
            const SizedBox(height: 10),
            AppSelectSheetField<_ContractOption>(
              label: 'HOD *',
              title: 'Select HOD',
              items: _hods,
              value: _hod,
              itemLabelBuilder: (_ContractOption o) => o.label,
              placeholderText: 'Select HOD',
              onChanged: (_ContractOption value) => setState(() => _hod = value),
            ),
            const SizedBox(height: 10),
            AppSelectSheetField<_ContractOption>(
              label: 'Dy HOD *',
              title: 'Select Dy HOD',
              items: _dyHods,
              value: _dyHod,
              itemLabelBuilder: (_ContractOption o) => o.label,
              placeholderText: 'Select Dy HOD',
              onChanged: (_ContractOption value) =>
                  setState(() => _dyHod = value),
            ),
            const SizedBox(height: 10),
            AppSelectSheetField<_ContractOption>(
              label: 'Contract Department *',
              title: 'Select Department',
              items: _departments,
              value: _contractDepartment,
              itemLabelBuilder: (_ContractOption o) => o.label,
              placeholderText: 'Select department',
              onChanged: (_ContractOption value) =>
                  setState(() => _contractDepartment = value),
            ),
            const SizedBox(height: 10),
            _yesNoField(
              label: 'Bank Funded',
              value: _bankFunded,
              onChanged: (bool value) => setState(() {
                _bankFunded = value;
                if (!value) {
                  _bankName = null;
                  _typeOfReview = null;
                }
              }),
            ),
            if (_bankFunded) ...<Widget>[
              const SizedBox(height: 10),
              AppSelectSheetField<_ContractOption>(
                label: 'Bank Name',
                title: 'Select Bank',
                items: _bankNames,
                value: _bankName,
                itemLabelBuilder: (_ContractOption o) => o.label,
                placeholderText: 'Select bank',
                onChanged: (_ContractOption value) =>
                    setState(() => _bankName = value),
              ),
              const SizedBox(height: 10),
              AppSelectSheetField<String>(
                label: 'Type of Review',
                title: 'Select Type of Review',
                items: _typeOfReviewOptions,
                value: _typeOfReview,
                itemLabelBuilder: (String value) => value,
                placeholderText: 'Select type',
                onChanged: (String value) =>
                    setState(() => _typeOfReview = value),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _stepExecutives() {
    return Column(
      children: <Widget>[
        _sectionCard(
          children: <Widget>[
            ...List<Widget>.generate(_executiveRows.length, (int index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _executiveRows.length - 1 ? 0 : 12,
                ),
                child: _executiveCard(index),
              );
            }),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: FilledButton.tonalIcon(
                onPressed: _saving
                    ? null
                    : () => setState(() => _executiveRows.add(_ExecutiveRow())),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Executive Row'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _executiveCard(int index) {
    final _ExecutiveRow row = _executiveRows[index];
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        color: cs.surfaceContainerLowest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Executive assignment',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_executiveRows.length > 1)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: _saving ? null : () => _removeExecutiveRow(index),
                  icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AppSelectSheetField<_ContractOption>(
            label: 'Department *',
            title: 'Select Department',
            items: _departments,
            value: row.department,
            itemLabelBuilder: (_ContractOption o) => o.label,
            placeholderText: 'Select department',
            enabled: !_saving,
            onChanged: ( _ContractOption value) =>
                _onExecutiveDepartmentChanged(row, value),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _saving || row.department == null || row.loadingExecutives
                ? null
                : () => _pickExecutives(row),
            child: row.loadingExecutives
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    row.selected.isEmpty
                        ? 'Select Executives *'
                        : '${row.selected.length} executive(s) selected',
                  ),
          ),
          if (row.selected.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: row.selected
                  .map(
                    ( _ContractOption executive) => InputChip(
                      label: Text(
                        executive.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onDeleted: _saving
                          ? null
                          : () => setState(() => row.selected.remove(executive)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stepDetails() {
    return Column(
      children: <Widget>[
        _sectionCard(
          title: 'Contract Details',
          children: <Widget>[
            AppTextFormField(
              label: 'Contract Short Name *',
              controller: _shortNameCtrl,
              hintText: 'Enter short name',
              maxLength: _shortNameMaxLength,
              readOnly: _saving,
            ),
            const SizedBox(height: 10),
            AppTextFormField(
              label: 'Contract Name *',
              controller: _contractNameCtrl,
              hintText: 'Enter contract name',
              maxLength: _contractNameMaxLength,
              maxLines: 3,
              readOnly: _saving,
            ),
            const SizedBox(height: 10),
            AppSelectSheetField<_ContractOption>(
              label: 'Contract Type *',
              title: 'Select Contract Type',
              items: _contractTypes,
              value: _contractType,
              itemLabelBuilder: (_ContractOption o) => o.label,
              placeholderText: 'Select contract type',
              onChanged: (_ContractOption value) =>
                  setState(() => _contractType = value),
            ),
            const SizedBox(height: 10),
            AppSelectSheetField<_ContractOption>(
              label: 'Contractor Name',
              title: 'Select Contractor',
              items: _contractors,
              value: _contractor,
              itemLabelBuilder: (_ContractOption o) => o.label,
              placeholderText: 'Select contractor',
              onChanged: (_ContractOption value) =>
                  setState(() => _contractor = value),
            ),
            const SizedBox(height: 10),
            AppTextFormField(
              label: 'Contract (IFAS Code)',
              controller: _ifasCodeCtrl,
              hintText: 'Enter IFAS code',
              maxLength: _ifasCodeMaxLength,
              readOnly: _saving,
            ),
            const SizedBox(height: 10),
            AppTextFormField(
              label: 'Scope of Contract',
              controller: _scopeCtrl,
              hintText: 'Enter scope',
              maxLength: _scopeMaxLength,
              maxLines: 3,
              readOnly: _saving,
            ),
            const SizedBox(height: 10),
            AppTextFormField(
              label: 'LOA Letter No',
              controller: _loaLetterCtrl,
              hintText: 'Enter LOA letter number',
              readOnly: _saving,
            ),
            const SizedBox(height: 10),
            _dateField(
              label: 'LOA Date',
              value: _loaDate,
              onPick: (DateTime? date) => setState(() => _loaDate = date),
            ),
            const SizedBox(height: 10),
            if (_loadingWorkStatus)
              const LinearProgressIndicator(minHeight: 2),
            if (_loadingWorkStatus) const SizedBox(height: 10),
            AppSelectSheetField<_ContractOption>(
              label: 'Status of Work *',
              title: 'Select Status',
              items: _workStatuses,
              value: _workStatus,
              enabled: !_loadingWorkStatus,
              itemLabelBuilder: (_ContractOption o) => o.label,
              placeholderText: 'Select status',
              onChanged: (_ContractOption value) =>
                  setState(() => _workStatus = value),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: AppTextFormField(
                    label: 'Detailed Estimated Cost',
                    controller: _estimatedCostCtrl,
                    hintText: 'Enter value',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    readOnly: _saving,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppSelectSheetField<_ContractOption>(
                    label: 'Unit',
                    title: 'Select Unit',
                    items: _units,
                    value: _costUnit,
                    itemLabelBuilder: (_ContractOption o) => o.label,
                    placeholderText: 'Unit',
                    onChanged: (_ContractOption value) =>
                        setState(() => _costUnit = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _dateField(
              label: 'Planned Date of Award',
              value: _plannedAwardDate,
              onPick: (DateTime? date) =>
                  setState(() => _plannedAwardDate = date),
            ),
            const SizedBox(height: 10),
            _dateField(
              label: 'Planned Date of Completion',
              value: _plannedCompletionDate,
              onPick: (DateTime? date) =>
                  setState(() => _plannedCompletionDate = date),
            ),
            const SizedBox(height: 10),
            _dateField(
              label: 'Notice Inviting Tender',
              value: _noticeInvitingTenderDate,
              onPick: (DateTime? date) =>
                  setState(() => _noticeInvitingTenderDate = date),
            ),
            const SizedBox(height: 10),
            _dateField(
              label: 'Tender Opening Date',
              value: _tenderOpeningDate,
              onPick: (DateTime? date) =>
                  setState(() => _tenderOpeningDate = date),
            ),
            const SizedBox(height: 10),
            _dateField(
              label: 'Technical Eval. Submission',
              value: _technicalEvalDate,
              onPick: (DateTime? date) =>
                  setState(() => _technicalEvalDate = date),
            ),
            const SizedBox(height: 10),
            _dateField(
              label: 'Financial Eval. Submission',
              value: _financialEvalDate,
              onPick: (DateTime? date) =>
                  setState(() => _financialEvalDate = date),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Tender Bid Revisions',
          children: <Widget>[
            if (_revisionRows.isEmpty)
              _emptyStateHint(
                icon: Icons.history_edu_outlined,
                message: 'Optional tender bid revisions can be added below.',
              ),
            ...List<Widget>.generate(_revisionRows.length, (int index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _revisionRows.length - 1 ? 0 : 12,
                ),
                child: _revisionCard(index),
              );
            }),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: FilledButton.tonalIcon(
                onPressed: _saving
                    ? null
                    : () => setState(
                        () => _revisionRows.add(_TenderRevisionRow()),
                      ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Revision'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Remarks',
          children: <Widget>[
            AppTextFormField(
              label: 'Remarks',
              controller: _remarksCtrl,
              hintText: 'Enter remarks',
              maxLines: 4,
              readOnly: _saving,
            ),
          ],
        ),
      ],
    );
  }

  Widget _revisionCard(int index) {
    final _TenderRevisionRow row = _revisionRows[index];
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        color: cs.surfaceContainerLowest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: cs.secondaryContainer.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'R${index + 1}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSecondaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tender revision',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: _saving ? null : () => _removeRevisionRow(index),
                icon: Icon(Icons.delete_outline_rounded, color: cs.error),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextFormField(
            label: 'Revision No',
            controller: row.revisionNoCtrl,
            hintText: 'e.g. R1',
            readOnly: _saving,
          ),
          const SizedBox(height: 8),
          AppTextFormField(
            label: 'Detailed Estimated Cost',
            controller: row.estimatedCostCtrl,
            hintText: 'Enter value',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            readOnly: _saving,
          ),
          const SizedBox(height: 8),
          _dateField(
            label: 'Planned Date of Award',
            value: row.plannedAwardDate,
            onPick: (DateTime? date) =>
                setState(() => row.plannedAwardDate = date),
          ),
          const SizedBox(height: 8),
          _dateField(
            label: 'Planned Date of Completion',
            value: row.plannedCompletionDate,
            onPick: (DateTime? date) =>
                setState(() => row.plannedCompletionDate = date),
          ),
          const SizedBox(height: 8),
          AppTextFormField(
            label: 'Notice Inviting Tender',
            controller: row.noticeCtrl,
            readOnly: _saving,
          ),
          const SizedBox(height: 8),
          _dateField(
            label: 'Tender Opening Date',
            value: row.tenderOpeningDate,
            onPick: (DateTime? date) =>
                setState(() => row.tenderOpeningDate = date),
          ),
          const SizedBox(height: 8),
          AppTextFormField(
            label: 'Tech. Eval. Approval',
            controller: row.techEvalCtrl,
            readOnly: _saving,
          ),
          const SizedBox(height: 8),
          AppTextFormField(
            label: 'Fin. Eval. Approval',
            controller: row.finEvalCtrl,
            readOnly: _saving,
          ),
          const SizedBox(height: 8),
          AppTextFormField(
            label: 'Remarks',
            controller: row.remarksCtrl,
            maxLines: 2,
            readOnly: _saving,
          ),
        ],
      ),
    );
  }

  Widget _stepDocuments() {
    return Column(
      children: <Widget>[
        _sectionCard(
          children: <Widget>[
            if (_documentRows.isEmpty)
              _emptyStateHint(
                icon: Icons.upload_file_outlined,
                message: 'No documents added yet. Tap below to attach files.',
              ),
            ...List<Widget>.generate(_documentRows.length, (int index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _documentRows.length - 1 ? 0 : 12,
                ),
                child: _documentCard(index),
              );
            }),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: FilledButton.tonalIcon(
                onPressed: _saving
                    ? null
                    : () => setState(() => _documentRows.add(_DocumentRow())),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Document'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _documentCard(int index) {
    final _DocumentRow row = _documentRows[index];
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        color: cs.surfaceContainerLowest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  size: 16,
                  color: cs.onTertiaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Document ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: _saving ? null : () => _removeDocumentRow(index),
                icon: Icon(Icons.delete_outline_rounded, color: cs.error),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppSelectSheetField<_ContractOption>(
            label: 'File Type',
            title: 'Select File Type',
            items: _fileTypes,
            value: row.fileType,
            itemLabelBuilder: (_ContractOption o) => o.label,
            placeholderText: 'Select file type',
            onChanged: (_ContractOption value) =>
                setState(() => row.fileType = value),
          ),
          const SizedBox(height: 8),
          AppTextFormField(
            label: 'Name',
            controller: row.nameCtrl,
            hintText: 'File name',
            readOnly: _saving,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _saving ? null : () => _pickDocument(row),
            icon: const Icon(Icons.attach_file_rounded),
            label: Text(row.pickedFileName ?? 'Upload File'),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    String? title,
    required List<Widget> children,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (title != null && title.trim().isNotEmpty) ...<Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _emptyStateHint({
    required IconData icon,
    required String message,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _yesNoField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        SegmentedButton<bool>(
          segments: const <ButtonSegment<bool>>[
            ButtonSegment<bool>(value: true, label: Text('Yes')),
            ButtonSegment<bool>(value: false, label: Text('No')),
          ],
          selected: <bool>{value},
          onSelectionChanged: _saving
              ? null
              : (Set<bool> selection) => onChanged(selection.first),
        ),
      ],
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPick,
  }) {
    final String display = value == null
        ? 'Select date'
        : _displayDateFormat.format(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        OutlinedButton(
          onPressed: _saving ? null : () => _pickDate(value, onPick),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(display),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(
    DateTime? current,
    ValueChanged<DateTime?> onPick,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) {
      onPick(picked);
    }
  }

  Future<void> _loadForm() async {
    setState(() => _loading = true);
    try {
      final Map<String, dynamic> data = _isEdit
          ? await widget.dataSource.fetchEditContractFormData(
              contractId: widget.contractId!.trim(),
            )
          : await widget.dataSource.fetchAddContractFormData();
      List<Map<String, dynamic>> projectRows =
          _listFrom(data, const <String>['worksList', 'workList']);
      if (projectRows.isEmpty) {
        projectRows = await widget.dataSource.fetchProjectsDropdown();
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _projects = _projectOptions(projectRows);
        _hods = _personOptions(
          _listFrom(data, const <String>['hodList']),
          idKeys: const <String>['user_id', 'hod_user_id_fk'],
          designationKeys: const <String>['designation'],
          nameKeys: const <String>['user_name', 'hod_name'],
        );
        _dyHods = _personOptions(
          _listFrom(data, const <String>['dyHodList']),
          idKeys: const <String>['dy_hod_user_id_fk', 'user_id'],
          designationKeys: const <String>['designation', 'dy_hod_designation'],
          nameKeys: const <String>['user_name', 'dy_hod_name'],
        );
        _departments = _simpleOptions(
          _listFrom(data, const <String>['departmentList']),
          idKeys: const <String>['department_fk', 'department_id_fk'],
          labelKeys: const <String>['department_name', 'department'],
        );
        _bankNames = _simpleOptions(
          _listFrom(data, const <String>['bankNameList']),
          idKeys: const <String>['bank_name', 'issuing_bank'],
          labelKeys: const <String>['bank_name', 'issuing_bank'],
        );
        _contractTypes = _simpleOptions(
          _listFrom(data, const <String>['contract_type']),
          idKeys: const <String>['contract_type_fk'],
          labelKeys: const <String>['contract_type_fk'],
        );
        _contractors = _simpleOptions(
          _listFrom(data, const <String>['contractors', 'contractList']),
          idKeys: const <String>['contractor_id_fk', 'contractor_id'],
          labelKeys: const <String>['contractor_name'],
        );
        _units = _simpleOptions(
          _listFrom(data, const <String>['unitsList']),
          idKeys: const <String>['unit', 'estimated_cost_unit'],
          labelKeys: const <String>['unit', 'estimated_cost_unit'],
        );
        _fileTypes = _simpleOptions(
          _listFrom(data, const <String>['contractFileTypeList']),
          idKeys: const <String>[
            'contract_file_type_fk',
            'contract_file_type',
          ],
          labelKeys: const <String>['contract_file_type'],
        );
      });

      if (_isEdit) {
        Map<String, dynamic>? record = _extractContractRecord(data);
        if (record == null &&
            widget.initialRecord != null &&
            _recordHasContractFields(widget.initialRecord!)) {
          record = Map<String, dynamic>.from(widget.initialRecord!);
        }
        if (record != null) {
          await _applyEditPrefill(record, data);
        }
      } else {
        await _reloadWorkStatus();
      }

      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      await AppDialog.show(
        context: context,
        type: AppDialogType.error,
        title: 'Unable to Load Form',
        message: _isEdit
            ? 'Could not load this contract for edit. Please try again.'
            : 'Could not fetch contract form data. Please try again.',
      );
    }
  }

  Future<void> _onContractAwardedChanged(bool value) async {
    setState(() {
      _contractAwarded = value;
      _workStatus = null;
    });
    await _reloadWorkStatus();
  }

  Future<void> _reloadWorkStatus() async {
    setState(() => _loadingWorkStatus = true);
    try {
      final List<Map<String, dynamic>> rows =
          await widget.dataSource.fetchContractWorkStatusForForm(
        contractAwarded: _contractAwarded ? 'Yes' : 'No',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _workStatuses = _simpleOptions(
          rows,
          idKeys: const <String>['contract_status_fk', 'status'],
          labelKeys: const <String>['contract_status_fk', 'status'],
        );
        if (_workStatuses.length == 1) {
          _workStatus = _workStatuses.first;
        }
        _loadingWorkStatus = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loadingWorkStatus = false);
    }
  }

  Future<void> _onExecutiveDepartmentChanged(
    _ExecutiveRow row,
    _ContractOption department,
  ) async {
    setState(() {
      row.department = department;
      row.selected.clear();
      row.executives = <_ContractOption>[];
      row.loadingExecutives = true;
    });
    try {
      await _loadExecutivesForRow(row);
      if (!mounted) {
        return;
      }
      setState(() => row.loadingExecutives = false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => row.loadingExecutives = false);
      await AppDialog.show(
        context: context,
        type: AppDialogType.error,
        title: 'Executives Unavailable',
        message: 'Could not load executives for the selected department.',
      );
    }
  }

  Future<void> _pickExecutives(_ExecutiveRow row) async {
    if (row.executives.isEmpty) {
      return;
    }
    final Set<String> selectedIds = row.selected.map(( _ContractOption e) => e.id).toSet();
    final List<_ContractOption>? picked = await showModalBottomSheet<List<_ContractOption>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        final Set<String> temp = Set<String>.from(selectedIds);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Select Executives',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: row.executives.map((_ContractOption option) {
                        final bool checked = temp.contains(option.id);
                        return CheckboxListTile(
                          value: checked,
                          title: Text(option.label),
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                temp.add(option.id);
                              } else {
                                temp.remove(option.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      final List<_ContractOption> selected = row.executives
                          .where(( _ContractOption e) => temp.contains(e.id))
                          .toList();
                      Navigator.of(context).pop(selected);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (picked != null) {
      setState(() => row.selected
        ..clear()
        ..addAll(picked));
    }
  }

  void _removeExecutiveRow(int index) {
    setState(() {
      _executiveRows[index].dispose();
      _executiveRows.removeAt(index);
    });
  }

  void _removeRevisionRow(int index) {
    setState(() {
      _revisionRows[index].dispose();
      _revisionRows.removeAt(index);
    });
  }

  void _removeDocumentRow(int index) {
    setState(() {
      _documentRows[index].dispose();
      _documentRows.removeAt(index);
    });
  }

  Future<void> _pickDocument(_DocumentRow row) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final PlatformFile file = result.files.first;
      if (file.bytes == null || file.bytes!.isEmpty) {
        return;
      }
      setState(() {
        row.bytes = file.bytes;
        row.pickedFileName = file.name;
        if (row.nameCtrl.text.trim().isEmpty) {
          row.nameCtrl.text = file.name;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        type: AppDialogType.error,
        title: 'Upload Failed',
        message: 'Unable to pick this file.',
      );
    }
  }

  void _nextStep() {
    if (!_validateStep(_currentStep)) {
      return;
    }
    setState(() => _currentStep += 1);
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        if (_project == null ||
            _hod == null ||
            _dyHod == null ||
            _contractDepartment == null) {
          _showRequired('Please complete all required manager fields.');
          return false;
        }
        if (_bankFunded && (_bankName == null || _typeOfReview == null)) {
          _showRequired('Bank Name and Type of Review are required when bank funded.');
          return false;
        }
        return true;
      case 1:
        if (_executiveRows.isEmpty) {
          _showRequired('Add at least one executive row.');
          return false;
        }
        for (int i = 0; i < _executiveRows.length; i++) {
          final _ExecutiveRow row = _executiveRows[i];
          if (row.department == null || row.selected.isEmpty) {
            _showRequired(
              'Executive row ${i + 1} requires department and at least one executive.',
            );
            return false;
          }
        }
        return true;
      case 2:
        if (_shortNameCtrl.text.trim().isEmpty ||
            _contractNameCtrl.text.trim().isEmpty ||
            _contractType == null) {
          _showRequired('Contract short name, name and type are required.');
          return false;
        }
        if (_workStatus == null) {
          _showRequired('Status of Work is required.');
          return false;
        }
        return true;
      case 3:
        for (int i = 0; i < _documentRows.length; i++) {
          final _DocumentRow row = _documentRows[i];
          final bool hasAny = row.fileType != null ||
              row.nameCtrl.text.trim().isNotEmpty ||
              row.bytes != null;
          if (!hasAny) {
            continue;
          }
          if (row.fileType == null || row.nameCtrl.text.trim().isEmpty) {
            _showRequired(
              'Document row ${i + 1} needs file type and name.',
            );
            return false;
          }
        }
        return true;
      default:
        return true;
    }
  }

  void _showRequired(String message) {
    AppDialog.show(
      context: context,
      type: AppDialogType.error,
      title: 'Missing Required Fields',
      message: message,
    );
  }

  Future<void> _submit({bool addAnother = false}) async {
    for (int step = 0; step <= 3; step++) {
      if (!_validateStep(step)) {
        setState(() => _currentStep = step);
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final Map<String, dynamic> response = _isEdit
          ? await widget.dataSource.submitUpdateContract(_buildPayload())
          : await widget.dataSource.submitAddContract(_buildPayload());
      if (!mounted) {
        return;
      }
      final String message = _string(response['success']).isNotEmpty
          ? _string(response['success'])
          : (_isEdit
                ? 'Contract updated successfully.'
                : 'Contract saved successfully.');
      await AppDialog.show(
        context: context,
        type: AppDialogType.success,
        title: _isEdit ? 'Updated' : 'Saved',
        message: message,
      );
      if (!mounted) {
        return;
      }
      if (addAnother) {
        _resetFormForAnother();
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
        message: _isEdit
            ? 'Unable to update contract. Please verify the data and retry.'
            : 'Unable to save contract. Please verify the data and retry.',
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _resetFormForAnother() {
    _preservedEditValues = <String, dynamic>{};
    _shortNameCtrl.clear();
    _contractNameCtrl.clear();
    _ifasCodeCtrl.clear();
    _scopeCtrl.clear();
    _loaLetterCtrl.clear();
    _estimatedCostCtrl.clear();
    _remarksCtrl.clear();
    setState(() {
      _currentStep = 0;
      _contractType = null;
      _contractor = null;
      _workStatus = null;
      _costUnit = null;
      _loaDate = null;
      _plannedAwardDate = null;
      _plannedCompletionDate = null;
      _noticeInvitingTenderDate = null;
      _tenderOpeningDate = null;
      _technicalEvalDate = null;
      _financialEvalDate = null;
      for (final _TenderRevisionRow row in _revisionRows) {
        row.dispose();
      }
      _revisionRows.clear();
      for (final _DocumentRow row in _documentRows) {
        row.dispose();
      }
      _documentRows.clear();
    });
  }

  dynamic _nullableNumber(String value, {dynamic fallback}) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return fallback;
    }
    final int? asInt = int.tryParse(trimmed);
    if (asInt != null) {
      return asInt;
    }
    return double.tryParse(trimmed) ?? fallback ?? trimmed;
  }

  dynamic _preservedValue(String key, {dynamic fallback = ''}) {
    if (!_isEdit) {
      return fallback;
    }
    final dynamic raw = _preservedEditValues[key];
    if (raw == null) {
      return fallback;
    }
    if (raw is String && (raw.isEmpty || raw.toLowerCase() == 'null')) {
      return fallback;
    }
    return raw;
  }

  List<String> _preservedStringList(String key) {
    final dynamic raw = _preservedEditValues[key];
    return _stringList(raw);
  }

  List<dynamic> _preservedDynamicList(String key) {
    final dynamic raw = _preservedEditValues[key];
    if (raw is List) {
      return List<dynamic>.from(raw);
    }
    return const <dynamic>[];
  }

  Map<String, dynamic> _collectPreservedEditValues(
    Map<String, dynamic> record,
    Map<String, dynamic> root,
  ) {
    List<String> listFromRecord(String key) => _stringList(record[key]);

    List<String> milestoneIds = listFromRecord('milestone_ids');
    List<String> milestoneNames = listFromRecord('milestone_names');
    List<String> milestoneDates = listFromRecord('milestone_dates');
    List<String> actualDates = listFromRecord('actual_dates');
    List<String> revisions = listFromRecord('revisions');
    List<String> mileRemarks = listFromRecord('mile_remarks');

    final dynamic milestones = record['milestones'];
    if (milestones is List && milestones.isNotEmpty) {
      milestoneIds = <String>[];
      milestoneNames = <String>[];
      milestoneDates = <String>[];
      actualDates = <String>[];
      revisions = <String>[];
      mileRemarks = <String>[];
      for (final dynamic item in milestones) {
        if (item is! Map) {
          continue;
        }
        final Map<String, dynamic> row = Map<String, dynamic>.from(item);
        milestoneIds.add(_pick(row, const <String>[
          'milestone_id',
          'milestone_ids',
        ]));
        milestoneNames.add(_pick(row, const <String>['milestone_name']));
        milestoneDates.add(_pick(row, const <String>['milestone_date']));
        actualDates.add(_pick(row, const <String>['actual_date']));
        revisions.add(_pick(row, const <String>['revision']));
        mileRemarks.add(_pick(row, const <String>[
          'mile_remark',
          'mile_remarks',
        ]));
      }
    }

    String flagOrDefault(String key) {
      final String value = _pick(record, <String>[key]);
      return value.isEmpty ? 'no' : value;
    }

    return <String, dynamic>{
      'contract_status': _pick(record, const <String>['contract_status']),
      'ca_no': _pick(record, const <String>['ca_no']),
      'ca_date': _pick(record, const <String>['ca_date']),
      'date_of_start': _pick(record, const <String>['date_of_start']),
      'doc': _pick(record, const <String>['doc']),
      'target_doc': _pick(record, const <String>['target_doc']),
      'awarded_cost': record['awarded_cost'],
      'awarded_cost_units': record['awarded_cost_units'],
      'milestone_ids': milestoneIds,
      'milestone_names': milestoneNames,
      'milestone_dates': milestoneDates,
      'actual_dates': actualDates,
      'revisions': revisions,
      'mile_remarks': mileRemarks,
      'revision_numbers': listFromRecord('revision_numbers'),
      'revised_amounts': record['revised_amounts'] is List
          ? List<dynamic>.from(record['revised_amounts'] as List)
          : const <dynamic>[],
      'revised_docs': record['revised_docs'] is List
          ? List<dynamic>.from(record['revised_docs'] as List)
          : const <dynamic>[],
      'revision_statuss': listFromRecord('revision_statuss'),
      'revised_amount_unitss': record['revised_amount_unitss'] is List
          ? List<dynamic>.from(record['revised_amount_unitss'] as List)
          : const <dynamic>[],
      'revision_amounts_statuss': listFromRecord('revision_amounts_statuss'),
      'approval_by_bank': listFromRecord('approval_by_bank'),
      'bg_required': flagOrDefault('bg_required'),
      'insurance_required': flagOrDefault('insurance_required'),
      'milestone_requried': flagOrDefault('milestone_requried'),
      'revision_requried': flagOrDefault('revision_requried'),
      'contractors_key_requried': flagOrDefault('contractors_key_requried'),
    };
  }

  Map<String, dynamic> _buildPayload() {
    String formatDate(DateTime? date) {
      if (date == null) {
        return '';
      }
      return _apiDateFormat.format(date);
    }

    final List<String> departmentFks = <String>[];
    final List<String> responsiblePeopleIds = <String>[];
    final List<String> filecounts = <String>[];
    for (final _ExecutiveRow row in _executiveRows) {
      if (row.department == null || row.selected.isEmpty) {
        continue;
      }
      departmentFks.add(row.department!.id);
      filecounts.add('${row.selected.length}');
      for (final _ContractOption executive in row.selected) {
        responsiblePeopleIds.add(executive.id);
      }
    }

    final List<_DocumentRow> filledDocuments = _documentRows
        .where(
          (_DocumentRow row) =>
              row.fileType != null && row.nameCtrl.text.trim().isNotEmpty,
        )
        .toList();

    final Map<String, dynamic> payload = <String, dynamic>{
      'project_id_fk': _project?.id ?? '',
      'hod_user_id_fk': _hod?.id ?? '',
      'dy_hod_user_id_fk': _dyHod?.id ?? '',
      'contract_type_fk': _contractType?.id ?? '',
      'contractor_id_fk': _contractor?.id ?? '',
      'contract_status_fk': _workStatus?.id ?? '',
      'contract_ifas_code': _ifasCodeCtrl.text.trim(),
      'contract_status': _preservedValue('contract_status', fallback: ''),
      'is_contract_awarded': _contractAwarded ? 'Yes' : 'No',
      'contract_department': _contractDepartment?.id ?? '',
      'contract_short_name': _shortNameCtrl.text.trim(),
      'contract_name': _contractNameCtrl.text.trim(),
      'bank_funded': _bankFunded ? 'yes' : 'no',
      'bank_name': _bankName?.id ?? '',
      'type_of_review': _typeOfReview ?? '',
      'scope_of_contract': _scopeCtrl.text.trim(),
      'loa_letter_number': _loaLetterCtrl.text.trim(),
      'loa_date': formatDate(_loaDate),
      'ca_no': _preservedValue('ca_no', fallback: ''),
      'ca_date': _preservedValue('ca_date', fallback: ''),
      'date_of_start': _preservedValue('date_of_start', fallback: ''),
      'doc': _preservedValue('doc', fallback: ''),
      'awarded_cost': _isEdit
          ? _preservedValue('awarded_cost', fallback: null)
          : null,
      'awarded_cost_units': _isEdit
          ? _preservedValue('awarded_cost_units', fallback: null)
          : null,
      'target_doc': _preservedValue('target_doc', fallback: ''),
      'estimated_cost': _nullableNumber(_estimatedCostCtrl.text),
      'estimated_cost_units': _costUnit?.id,
      'planned_date_of_award': formatDate(_plannedAwardDate),
      'planned_date_of_completion': formatDate(_plannedCompletionDate),
      'contract_notice_inviting_tender': formatDate(_noticeInvitingTenderDate),
      'tender_opening_date': formatDate(_tenderOpeningDate),
      'technical_eval_submission': formatDate(_technicalEvalDate),
      'financial_eval_submission': formatDate(_financialEvalDate),
      'remarks': _remarksCtrl.text.trim(),
      'status': 'Active',
      'is_contract_closure_initiated': 'No',
      'department_fks': departmentFks,
      'responsible_people_id_fks': responsiblePeopleIds,
      'filecounts': filecounts,
      'revisionno': _revisionRows
          .map((_TenderRevisionRow r) => r.revisionNoCtrl.text.trim())
          .toList(),
      'revision_estimated_cost': _revisionRows
          .map((_TenderRevisionRow r) => r.estimatedCostCtrl.text.trim())
          .toList(),
      'revision_planned_date_of_award': _revisionRows
          .map((_TenderRevisionRow r) => formatDate(r.plannedAwardDate))
          .toList(),
      'revision_planned_date_of_completion': _revisionRows
          .map((_TenderRevisionRow r) => formatDate(r.plannedCompletionDate))
          .toList(),
      'notice_inviting_tender': _revisionRows
          .map((_TenderRevisionRow r) => r.noticeCtrl.text.trim())
          .toList(),
      'tender_bid_opening_date': _revisionRows
          .map((_TenderRevisionRow r) => formatDate(r.tenderOpeningDate))
          .toList(),
      'technical_eval_approval': _revisionRows
          .map((_TenderRevisionRow r) => r.techEvalCtrl.text.trim())
          .toList(),
      'financial_eval_approval': _revisionRows
          .map((_TenderRevisionRow r) => r.finEvalCtrl.text.trim())
          .toList(),
      'tender_bid_remarks': _revisionRows
          .map((_TenderRevisionRow r) => r.remarksCtrl.text.trim())
          .toList(),
      'bg_type_fks': <String>[],
      'issuing_banks': <String>[],
      'bg_numbers': <String>[],
      'bg_values': <String>[],
      'bg_valid_uptos': <String>[],
      'bg_dates': <String>[],
      'release_dates': <String>[],
      'bg_value_unitss': <String>[],
      'insurance_type_fks': <String>[],
      'issuing_agencys': <String>[],
      'agency_addresss': <String>[],
      'insurance_numbers': <String>[],
      'insurance_values': <String>[],
      'insurence_valid_uptos': <String>[],
      'insuranceStatus': <String>[],
      'insurance_value_unitss': <String>[],
      'milestone_ids': _isEdit
          ? _preservedStringList('milestone_ids')
          : <String>[],
      'milestone_names': _isEdit
          ? _preservedStringList('milestone_names')
          : <String>[],
      'milestone_dates': _isEdit
          ? _preservedStringList('milestone_dates')
          : <String>[],
      'actual_dates': _isEdit
          ? _preservedStringList('actual_dates')
          : <String>[],
      'revisions': _isEdit ? _preservedStringList('revisions') : <String>[],
      'mile_remarks': _isEdit
          ? _preservedStringList('mile_remarks')
          : <String>[],
      'revision_numbers': _isEdit
          ? _preservedStringList('revision_numbers')
          : <String>[],
      'revised_amounts': _isEdit
          ? _preservedDynamicList('revised_amounts')
          : <dynamic>[],
      'revised_docs': _isEdit
          ? _preservedDynamicList('revised_docs')
          : <dynamic>[],
      'revision_statuss': _isEdit
          ? _preservedStringList('revision_statuss')
          : <String>[],
      'revised_amount_unitss': _isEdit
          ? _preservedDynamicList('revised_amount_unitss')
          : <dynamic>[],
      'revision_amounts_statuss': _isEdit
          ? _preservedStringList('revision_amounts_statuss')
          : <String>[],
      'approval_by_bank': _isEdit
          ? _preservedStringList('approval_by_bank')
          : <String>[],
      'contractKeyPersonnelNames': <String>[],
      'contractKeyPersonnelDesignations': <String>[],
      'contractKeyPersonnelMobileNos': <String>[],
      'contractKeyPersonnelEmailIds': <String>[],
      'contractDocumentNames': filledDocuments
          .map((_DocumentRow r) => r.nameCtrl.text.trim())
          .toList(),
      'contractDocumentFileNames': filledDocuments
          .map((_DocumentRow r) => r.pickedFileName ?? '')
          .toList(),
      'contract_file_types': filledDocuments
          .map((_DocumentRow r) => r.fileType?.label ?? '')
          .toList(),
      'contract_file_ids': filledDocuments
          .map((_DocumentRow r) => r.existingFileId ?? '')
          .toList(),
      if (_isEdit) 'contract_id': widget.contractId!.trim(),
      'bg_required': _preservedValue('bg_required', fallback: 'no'),
      'insurance_required': _preservedValue('insurance_required', fallback: 'no'),
      'milestone_requried': _preservedValue('milestone_requried', fallback: 'no'),
      'revision_requried': _preservedValue('revision_requried', fallback: 'no'),
      'contractors_key_requried':
          _preservedValue('contractors_key_requried', fallback: 'no'),
    };
    return payload;
  }

  Map<String, dynamic>? _extractContractRecord(Map<String, dynamic> data) {
    final String targetId = widget.contractId?.trim() ?? '';

    for (final String key in const <String>['contract_Status', 'contractStatus']) {
      final dynamic statusRaw = data[key];
      if (statusRaw is! List) {
        continue;
      }

      Map<String, dynamic>? matched;
      Map<String, dynamic>? firstWithData;
      for (final dynamic item in statusRaw) {
        if (item is! Map) {
          continue;
        }
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        if (!_recordHasContractFields(map)) {
          continue;
        }
        firstWithData ??= map;
        if (targetId.isEmpty) {
          continue;
        }
        final String id = _pick(map, const <String>[
          'contract_id',
          'contract_id_fk',
        ]);
        if (id == targetId) {
          matched = map;
          break;
        }
      }

      final Map<String, dynamic>? record = matched ?? firstWithData;
      if (record != null) {
        return _expandContractRecord(record);
      }
    }

    for (final String key in const <String>[
      'contract',
      'contractDetails',
      'contractData',
    ]) {
      final dynamic raw = data[key];
      if (raw is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
        if (_recordHasContractFields(map)) {
          return _expandContractRecord(map);
        }
      }
    }

    if (_recordHasContractFields(data)) {
      return _expandContractRecord(data);
    }

    return null;
  }

  bool _recordHasContractFields(Map<String, dynamic> map) {
    return _pick(map, const <String>[
      'contract_id',
      'contract_name',
      'contract_short_name',
      'project_id_fk',
      'contractor_id_fk',
    ]).isNotEmpty;
  }

  Map<String, dynamic> _expandContractRecord(Map<String, dynamic> record) {
    final Map<String, dynamic> expanded = Map<String, dynamic>.from(record);
    final dynamic revisions =
        record['contract_revisions'] ?? record['contract_revision'];
    if (revisions is List &&
        revisions.isNotEmpty &&
        revisions.first is Map &&
        _stringList(expanded['revisionno']).isEmpty) {
      expanded['revisionno'] = revisions
          .map(
            (dynamic item) => item is Map
                ? _pick(Map<String, dynamic>.from(item), const <String>[
                    'revisionno',
                    'revision_number',
                    'revision',
                  ])
                : item?.toString().trim() ?? '',
          )
          .where((String value) => value.isNotEmpty)
          .toList();
      expanded['revision_estimated_cost'] = revisions
          .map(
            (dynamic item) => item is Map
                ? _pick(Map<String, dynamic>.from(item), const <String>[
                    'revision_estimated_cost',
                    'estimated_cost',
                    'revised_amount',
                  ])
                : '',
          )
          .toList();
      expanded['revision_planned_date_of_award'] = revisions
          .map(
            (dynamic item) => item is Map
                ? _pick(Map<String, dynamic>.from(item), const <String>[
                    'revision_planned_date_of_award',
                    'planned_date_of_award',
                    'revision_date',
                  ])
                : '',
          )
          .toList();
      expanded['revision_planned_date_of_completion'] = revisions
          .map(
            (dynamic item) => item is Map
                ? _pick(Map<String, dynamic>.from(item), const <String>[
                    'revision_planned_date_of_completion',
                    'planned_date_of_completion',
                  ])
                : '',
          )
          .toList();
      expanded['notice_inviting_tender'] = revisions
          .map(
            (dynamic item) => item is Map
                ? _pick(Map<String, dynamic>.from(item), const <String>[
                    'notice_inviting_tender',
                    'contract_notice_inviting_tender',
                  ])
                : '',
          )
          .toList();
      expanded['tender_bid_opening_date'] = revisions
          .map(
            (dynamic item) => item is Map
                ? _pick(Map<String, dynamic>.from(item), const <String>[
                    'tender_bid_opening_date',
                    'tender_opening_date',
                  ])
                : '',
          )
          .toList();
      expanded['technical_eval_approval'] = revisions
          .map(
            (dynamic item) => item is Map
                ? _pick(Map<String, dynamic>.from(item), const <String>[
                    'technical_eval_approval',
                    'technical_eval_submission',
                  ])
                : '',
          )
          .toList();
      expanded['financial_eval_approval'] = revisions
          .map(
            (dynamic item) => item is Map
                ? _pick(Map<String, dynamic>.from(item), const <String>[
                    'financial_eval_approval',
                    'financial_eval_submission',
                  ])
                : '',
          )
          .toList();
      expanded['tender_bid_remarks'] = revisions
          .map(
            (dynamic item) => item is Map
                ? _pick(Map<String, dynamic>.from(item), const <String>[
                    'tender_bid_remarks',
                    'revision_remark',
                    'remarks',
                  ])
                : '',
          )
          .toList();
    }
    return expanded;
  }

  Future<void> _applyEditPrefill(
    Map<String, dynamic> record,
    Map<String, dynamic> root,
  ) async {
    _shortNameCtrl.text = _pick(record, const <String>['contract_short_name']);
    _contractNameCtrl.text = _pick(record, const <String>['contract_name']);
    _ifasCodeCtrl.text = _pick(record, const <String>['contract_ifas_code']);
    _scopeCtrl.text = _pick(record, const <String>['scope_of_contract']);
    _loaLetterCtrl.text = _pick(record, const <String>['loa_letter_number']);
    _estimatedCostCtrl.text = _pick(record, const <String>[
      'estimated_cost',
    ]);
    _remarksCtrl.text = _pick(record, const <String>['remarks']);

    _contractAwarded = _isTruthyYes(
      _pick(record, const <String>['is_contract_awarded', 'contract_awarded']),
    );
    _bankFunded = _isBankFunded(
      _pick(record, const <String>['bank_funded', 'bank_status']),
    );
    _typeOfReview = _pick(record, const <String>['type_of_review']).isEmpty
        ? null
        : _pick(record, const <String>['type_of_review']);

    _loaDate = _parseDateString(_pick(record, const <String>['loa_date']));
    _plannedAwardDate = _parseDateString(
      _pick(record, const <String>['planned_date_of_award']),
    );
    _plannedCompletionDate = _parseDateString(
      _pick(record, const <String>['planned_date_of_completion']),
    );
    _noticeInvitingTenderDate = _parseDateString(
      _pick(record, const <String>[
        'contract_notice_inviting_tender',
        'notice_inviting_tender',
      ]),
    );
    _tenderOpeningDate = _parseDateString(
      _pick(record, const <String>['tender_opening_date']),
    );
    _technicalEvalDate = _parseDateString(
      _pick(record, const <String>['technical_eval_submission']),
    );
    _financialEvalDate = _parseDateString(
      _pick(record, const <String>['financial_eval_submission']),
    );

    _project = _optionFromRecord(
      _projects,
      record,
      const <String>['project_id_fk', 'project_id', 'work_id_fk'],
      labelKeys: const <String>['project_name', 'work_name'],
    );
    _hod = _optionFromRecord(
      _hods,
      record,
      const <String>['hod_user_id_fk'],
      labelKeys: const <String>['hod_name', 'user_name'],
    ) ??
        _optionFromRecord(
          _hods,
          record,
          const <String>['designation'],
          labelKeys: const <String>['hod_name', 'user_name'],
        );
    _dyHod = _optionFromRecord(
      _dyHods,
      record,
      const <String>['dy_hod_user_id_fk'],
      labelKeys: const <String>['dy_hod_name', 'user_name'],
    );
    _contractDepartment = _optionFromRecord(
      _departments,
      record,
      const <String>['contract_department', 'department_fk'],
      labelKeys: const <String>['department_name', 'contract_department'],
    );
    _bankName = _optionFromRecord(
      _bankNames,
      record,
      const <String>['bank_name', 'issuing_bank'],
      labelKeys: const <String>['bank_name', 'issuing_bank'],
    );
    _contractType = _optionFromRecord(
      _contractTypes,
      record,
      const <String>['contract_type_fk'],
      labelKeys: const <String>['contract_type_fk'],
    );
    _contractor = _optionFromRecord(
      _contractors,
      record,
      const <String>['contractor_id_fk', 'contractor_id'],
      labelKeys: const <String>['contractor_name'],
    );
    _costUnit = _optionFromRecord(
      _units,
      record,
      const <String>['estimated_cost_units', 'estimated_cost_unit'],
      labelKeys: const <String>['estimated_cost_units', 'estimated_cost_unit'],
    );

    await _reloadWorkStatus();
    _workStatus = _optionFromRecord(
      _workStatuses,
      record,
      const <String>['contract_status_fk'],
      labelKeys: const <String>['contract_status_fk'],
    );

    await _prefillExecutives(record, root);
    _prefillRevisions(record);
    _prefillDocuments(record, root);
    _preservedEditValues = _collectPreservedEditValues(record, root);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _prefillExecutives(
    Map<String, dynamic> record,
    Map<String, dynamic> root,
  ) async {
    for (final _ExecutiveRow row in _executiveRows) {
      row.dispose();
    }
    _executiveRows.clear();

    final List<Map<String, dynamic>> people = _listFrom(root, const <String>[
      'responsiblePeopleList',
      'executivesList',
      'responsiblePersonsList',
    ]);

    if (people.isNotEmpty) {
      final Map<String, List<Map<String, dynamic>>> grouped =
          <String, List<Map<String, dynamic>>>{};
      for (final Map<String, dynamic> person in people) {
        final String departmentId = _pick(person, const <String>[
          'department_fk',
          'department_id_fk',
        ]);
        if (departmentId.isEmpty) {
          continue;
        }
        grouped.putIfAbsent(departmentId, () => <Map<String, dynamic>>[]).add(
          person,
        );
      }

      for (final MapEntry<String, List<Map<String, dynamic>>> entry
          in grouped.entries) {
        final _ExecutiveRow row = _ExecutiveRow();
        row.department =
            _optionById(_departments, entry.key) ??
            _ContractOption(
              id: entry.key,
              label: _pick(entry.value.first, const <String>[
                'department_name',
              ]),
            );
        await _loadExecutivesForRow(row);
        for (final Map<String, dynamic> person in entry.value) {
          final String executiveId = _pick(person, const <String>[
            'responsible_people_id_fk',
            'user_id',
            'hod_user_id_fk',
            'executive_user_id_fk',
          ]);
          if (executiveId.isEmpty) {
            continue;
          }
          final _ContractOption? matched = _optionById(row.executives, executiveId);
          row.selected.add(
            matched ??
                _ContractOption(
                  id: executiveId,
                  label: _combinedLabel(
                    _pick(person, const <String>['designation']),
                    _pick(person, const <String>['user_name']),
                    fallback: executiveId,
                  ),
                ),
          );
        }
        _executiveRows.add(row);
      }
    } else {
      final List<String> departmentIds = _stringList(record['department_fks']);
      final List<String> executiveIds =
          _stringList(record['responsible_people_id_fks']);
      if (departmentIds.isNotEmpty && executiveIds.isNotEmpty) {
        final _ExecutiveRow row = _ExecutiveRow();
        row.department =
            _optionById(_departments, departmentIds.first) ??
            _ContractOption(id: departmentIds.first, label: departmentIds.first);
        await _loadExecutivesForRow(row);
        for (final String executiveId in executiveIds) {
          final _ContractOption? matched =
              _optionById(row.executives, executiveId);
          row.selected.add(
            matched ?? _ContractOption(id: executiveId, label: executiveId),
          );
        }
        _executiveRows.add(row);
      }
    }

    if (_executiveRows.isEmpty) {
      _executiveRows.add(_ExecutiveRow());
    }
  }

  Future<void> _loadExecutivesForRow(_ExecutiveRow row) async {
    if (row.department == null) {
      return;
    }
    row.loadingExecutives = true;
    try {
      final List<Map<String, dynamic>> rows =
          await widget.dataSource.fetchContractExecutivesForDepartment(
        departmentFk: row.department!.id,
      );
      row.executives = _personOptions(
        rows,
        idKeys: const <String>[
          'responsible_people_id_fk',
          'user_id',
          'hod_user_id_fk',
          'executive_user_id_fk',
        ],
        designationKeys: const <String>['designation'],
        nameKeys: const <String>['user_name'],
      );
    } finally {
      row.loadingExecutives = false;
    }
  }

  void _prefillRevisions(Map<String, dynamic> record) {
    final List<String> revisionNumbers = _stringList(record['revisionno']);
    if (revisionNumbers.isEmpty) {
      return;
    }
    for (final _TenderRevisionRow row in _revisionRows) {
      row.dispose();
    }
    _revisionRows.clear();

    final List<String> costs = _stringList(record['revision_estimated_cost']);
    final List<String> awardDates =
        _stringList(record['revision_planned_date_of_award']);
    final List<String> completionDates =
        _stringList(record['revision_planned_date_of_completion']);
    final List<String> notices = _stringList(record['notice_inviting_tender']);
    final List<String> openingDates =
        _stringList(record['tender_bid_opening_date']);
    final List<String> techApprovals =
        _stringList(record['technical_eval_approval']);
    final List<String> finApprovals =
        _stringList(record['financial_eval_approval']);
    final List<String> remarks = _stringList(record['tender_bid_remarks']);

    for (int i = 0; i < revisionNumbers.length; i++) {
      final _TenderRevisionRow row = _TenderRevisionRow();
      row.revisionNoCtrl.text = revisionNumbers[i];
      if (i < costs.length) {
        row.estimatedCostCtrl.text = costs[i];
      }
      row.plannedAwardDate = _parseDateString(
        i < awardDates.length ? awardDates[i] : '',
      );
      row.plannedCompletionDate = _parseDateString(
        i < completionDates.length ? completionDates[i] : '',
      );
      if (i < notices.length) {
        row.noticeCtrl.text = notices[i];
      }
      row.tenderOpeningDate = _parseDateString(
        i < openingDates.length ? openingDates[i] : '',
      );
      if (i < techApprovals.length) {
        row.techEvalCtrl.text = techApprovals[i];
      }
      if (i < finApprovals.length) {
        row.finEvalCtrl.text = finApprovals[i];
      }
      if (i < remarks.length) {
        row.remarksCtrl.text = remarks[i];
      }
      _revisionRows.add(row);
    }
  }

  void _prefillDocuments(Map<String, dynamic> record, Map<String, dynamic> root) {
    for (final _DocumentRow row in _documentRows) {
      row.dispose();
    }
    _documentRows.clear();

    List<Map<String, dynamic>> docs = _listFrom(root, const <String>[
      'contractDocuments',
      'contractDocumentList',
    ]);
    if (docs.isEmpty) {
      docs = _listFrom(record, const <String>[
        'contractDocuments',
        'contractDocumentList',
      ]);
    }

    if (docs.isNotEmpty) {
      for (final Map<String, dynamic> doc in docs) {
        final _DocumentRow row = _DocumentRow();
        final String fileType = _pick(doc, const <String>[
          'contract_file_type',
          'contract_file_type_fk',
        ]);
        row.fileType =
            _optionById(_fileTypes, fileType) ??
            (fileType.isEmpty
                ? null
                : _ContractOption(id: fileType, label: fileType));
        row.nameCtrl.text = _pick(doc, const <String>[
          'name',
          'contractDocumentNames',
        ]);
        row.existingFileId = _pick(doc, const <String>[
          'contract_file_id',
          'contract_file_ids',
        ]);
        row.pickedFileName = _pick(doc, const <String>[
          'attachment',
          'contractDocumentFileNames',
        ]);
        _documentRows.add(row);
      }
      return;
    }

    final List<String> names = _stringList(record['contractDocumentNames']);
    if (names.isEmpty) {
      return;
    }
    final List<String> fileNames =
        _stringList(record['contractDocumentFileNames']);
    final List<String> fileTypes = _stringList(record['contract_file_types']);
    final List<String> fileIds = _stringList(record['contract_file_ids']);

    for (int i = 0; i < names.length; i++) {
      final _DocumentRow row = _DocumentRow();
      row.nameCtrl.text = names[i];
      if (i < fileNames.length) {
        row.pickedFileName = fileNames[i];
      }
      if (i < fileIds.length) {
        row.existingFileId = fileIds[i];
      }
      if (i < fileTypes.length && fileTypes[i].isNotEmpty) {
        row.fileType =
            _optionById(_fileTypes, fileTypes[i]) ??
            _ContractOption(id: fileTypes[i], label: fileTypes[i]);
      }
      _documentRows.add(row);
    }
  }

  _ContractOption? _optionById(List<_ContractOption> options, String id) {
    if (id.trim().isEmpty) {
      return null;
    }
    for (final _ContractOption option in options) {
      if (option.id == id) {
        return option;
      }
    }
    return null;
  }

  _ContractOption? _optionFromRecord(
    List<_ContractOption> options,
    Map<String, dynamic> record,
    List<String> idKeys, {
    List<String> labelKeys = const <String>[],
  }) {
    final String id = _pick(record, idKeys);
    final _ContractOption? existing = _optionById(options, id);
    if (existing != null) {
      return existing;
    }
    if (id.isEmpty) {
      return null;
    }
    final String label = labelKeys.isNotEmpty
        ? _pick(record, labelKeys)
        : id;
    return _ContractOption(id: id, label: label.isEmpty ? id : label);
  }

  List<String> _stringList(dynamic raw) {
    if (raw is! List) {
      return const <String>[];
    }
    return raw
        .map((dynamic item) => item?.toString().trim() ?? '')
        .where((String value) => value.isNotEmpty && value.toLowerCase() != 'null')
        .toList();
  }

  bool _isTruthyYes(String value) {
    final String normalized = value.trim().toLowerCase();
    return normalized == 'yes' || normalized == 'y' || normalized == 'true';
  }

  bool _isBankFunded(String value) {
    final String normalized = value.trim().toLowerCase();
    return normalized == 'yes' || normalized == 'y' || normalized == 'true';
  }

  DateTime? _parseDateString(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') {
      return null;
    }
    for (final DateFormat format in <DateFormat>[
      _apiDateFormat,
      _displayDateFormat,
      DateFormat('dd-MM-yyyy'),
    ]) {
      try {
        return format.parse(trimmed);
      } catch (_) {}
    }
    return null;
  }

  String _string(dynamic raw) {
    if (raw == null) {
      return '';
    }
    final String value = raw.toString().trim();
    if (value.isEmpty || value.toLowerCase() == 'null') {
      return '';
    }
    return value;
  }

  List<Map<String, dynamic>> _listFrom(
    Map<String, dynamic> root,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final dynamic raw = root[key];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return const <Map<String, dynamic>>[];
  }

  List<_ContractOption> _projectOptions(List<Map<String, dynamic>> rows) {
    final List<_ContractOption> options = <_ContractOption>[];
    final Set<String> seen = <String>{};
    for (final Map<String, dynamic> row in rows) {
      final String projectId = _pick(
        row,
        const <String>[
          'project_id',
          'project_id_fk',
          'projectId',
          'work_id_fk',
          'work_id',
        ],
      );
      if (projectId.isEmpty || seen.contains(projectId)) {
        continue;
      }
      seen.add(projectId);
      final String projectName = _pick(
        row,
        const <String>['project_name', 'work_name', 'projectName'],
      );
      options.add(
        _ContractOption(
          id: projectId,
          label: _combinedLabel(projectId, projectName, fallback: projectId),
        ),
      );
    }
    return options;
  }

  List<_ContractOption> _personOptions(
    List<Map<String, dynamic>> rows, {
    required List<String> idKeys,
    required List<String> designationKeys,
    required List<String> nameKeys,
  }) {
    final List<_ContractOption> options = <_ContractOption>[];
    final Set<String> seen = <String>{};
    for (final Map<String, dynamic> row in rows) {
      final String id = _pick(row, idKeys);
      if (id.isEmpty || seen.contains(id)) {
        continue;
      }
      seen.add(id);
      final String designation = _pick(row, designationKeys);
      final String name = _pick(row, nameKeys);
      options.add(
        _ContractOption(
          id: id,
          label: _combinedLabel(designation, name, fallback: id),
        ),
      );
    }
    return options;
  }

  List<_ContractOption> _simpleOptions(
    List<Map<String, dynamic>> rows, {
    required List<String> idKeys,
    required List<String> labelKeys,
  }) {
    final List<_ContractOption> options = <_ContractOption>[];
    final Set<String> seen = <String>{};
    for (final Map<String, dynamic> row in rows) {
      final String id = _pick(row, idKeys);
      if (id.isEmpty || seen.contains(id)) {
        continue;
      }
      seen.add(id);
      final String label = _pick(row, labelKeys);
      options.add(_ContractOption(id: id, label: label.isEmpty ? id : label));
    }
    return options;
  }

  String _pick(Map<String, dynamic> row, List<String> keys) {
    for (final String key in keys) {
      final dynamic raw = row[key];
      if (raw == null) {
        continue;
      }
      final String value = raw.toString().trim();
      if (value.isNotEmpty && value.toLowerCase() != 'null') {
        return value;
      }
    }
    return '';
  }

  String _combinedLabel(String first, String second, {String fallback = ''}) {
    final String part1 = first.trim();
    final String part2 = second.trim();
    if (part1.isNotEmpty && part2.isNotEmpty) {
      return '$part1 - $part2';
    }
    if (part1.isNotEmpty) {
      return part1;
    }
    if (part2.isNotEmpty) {
      return part2;
    }
    return fallback;
  }
}

class _ContractStepMeta {
  const _ContractStepMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _ContractFormStepper extends StatelessWidget {
  const _ContractFormStepper({
    required this.steps,
    required this.currentStep,
  });

  final List<_ContractStepMeta> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final int safeStep = currentStep.clamp(0, steps.length - 1);
    final _ContractStepMeta meta = steps[safeStep];
    final double progress = (safeStep + 1) / steps.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: cs.surfaceContainerHighest,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 42,
          child: Row(
            children: List<Widget>.generate(steps.length * 2 - 1, (int i) {
              if (i.isOdd) {
                final int leftIndex = i ~/ 2;
                final bool filled = safeStep > leftIndex;
                return Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 2,
                      color: filled
                          ? cs.primary
                          : cs.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
                );
              }

              final int index = i ~/ 2;
              final bool done = safeStep > index;
              final bool active = safeStep == index;
              final Color fillColor = done || active
                  ? cs.primary
                  : cs.surfaceContainerHighest;
              final Color contentColor =
                  done || active ? cs.onPrimary : cs.onSurfaceVariant;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fillColor,
                  border: Border.all(
                    color: active
                        ? cs.primary
                        : cs.outlineVariant.withValues(alpha: 0.55),
                    width: active ? 2 : 1,
                  ),
                  boxShadow: active
                      ? <BoxShadow>[
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: done
                      ? Icon(Icons.check_rounded, size: 18, color: contentColor)
                      : Icon(
                          steps[index].icon,
                          size: 18,
                          color: contentColor,
                        ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Container(
            key: ValueKey<int>(safeStep),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  cs.primaryContainer.withValues(alpha: 0.72),
                  cs.primaryContainer.withValues(alpha: 0.28),
                ],
              ),
              border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(meta.icon, color: cs.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Step ${safeStep + 1} of ${steps.length}',
                        style: tt.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta.title,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta.subtitle,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContractOption {
  const _ContractOption({required this.id, required this.label});

  final String id;
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ContractOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class _ExecutiveRow {
  _ContractOption? department;
  List<_ContractOption> executives = <_ContractOption>[];
  List<_ContractOption> selected = <_ContractOption>[];
  bool loadingExecutives = false;

  void dispose() {}
}

class _TenderRevisionRow {
  final TextEditingController revisionNoCtrl = TextEditingController();
  final TextEditingController estimatedCostCtrl = TextEditingController();
  final TextEditingController noticeCtrl = TextEditingController();
  final TextEditingController techEvalCtrl = TextEditingController();
  final TextEditingController finEvalCtrl = TextEditingController();
  final TextEditingController remarksCtrl = TextEditingController();
  DateTime? plannedAwardDate;
  DateTime? plannedCompletionDate;
  DateTime? tenderOpeningDate;

  void dispose() {
    revisionNoCtrl.dispose();
    estimatedCostCtrl.dispose();
    noticeCtrl.dispose();
    techEvalCtrl.dispose();
    finEvalCtrl.dispose();
    remarksCtrl.dispose();
  }
}

class _DocumentRow {
  _ContractOption? fileType;
  final TextEditingController nameCtrl = TextEditingController();
  Uint8List? bytes;
  String? pickedFileName;
  String? existingFileId;

  void dispose() {
    nameCtrl.dispose();
  }
}
