import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_date_form_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_form_field_style.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_text_form_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/structures/widgets/structure_document_preview_dialog.dart';

class _OptionItem {
  const _OptionItem({required this.id, required this.label});

  final String id;
  final String label;
}

class _ExecutiveRow {
  _ExecutiveRow()
      : id =
            '${DateTime.now().microsecondsSinceEpoch}_${identityHashCode(Object())}',
        selectedExecutives = <_OptionItem>[];

  final String id;
  _OptionItem? contract;
  final List<_OptionItem> selectedExecutives;
}

class _StructureDetailRow {
  _StructureDetailRow()
      : id =
            '${DateTime.now().microsecondsSinceEpoch}_${identityHashCode(Object())}',
        detailCtrl = TextEditingController(),
        valueCtrl = TextEditingController();

  final String id;
  final TextEditingController detailCtrl;
  final TextEditingController valueCtrl;

  void dispose() {
    detailCtrl.dispose();
    valueCtrl.dispose();
  }
}

class _DocumentRow {
  _DocumentRow()
      : id =
            '${DateTime.now().microsecondsSinceEpoch}_${identityHashCode(Object())}',
        nameCtrl = TextEditingController();

  final String id;
  final TextEditingController nameCtrl;
  _OptionItem? fileType;
  String? existingFileId;
  String? existingFileName;
  Uint8List? pickedBytes;
  String? pickedFileName;

  void dispose() {
    nameCtrl.dispose();
  }
}

class UpdateStructureWorkFormPage extends StatefulWidget {
  const UpdateStructureWorkFormPage({
    super.key,
    required this.dataSource,
    required this.structureId,
  });

  static const String routeName = 'update-structure-work-form';
  static const String routePath = '/structure-form/edit';

  final DashboardRemoteDataSource dataSource;
  final String structureId;

  @override
  State<UpdateStructureWorkFormPage> createState() =>
      _UpdateStructureWorkFormPageState();
}

class _UpdateStructureWorkFormPageState
    extends State<UpdateStructureWorkFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _saving = false;
  bool _contractsLoading = false;
  String? _loadError;

  List<_OptionItem> _projects = <_OptionItem>[];
  List<_OptionItem> _structureTypes = <_OptionItem>[];
  List<_OptionItem> _workStatuses = <_OptionItem>[];
  List<_OptionItem> _units = <_OptionItem>[];
  List<_OptionItem> _contracts = <_OptionItem>[];
  List<_OptionItem> _responsiblePeople = <_OptionItem>[];
  List<_OptionItem> _fileTypes = <_OptionItem>[];

  final List<_ExecutiveRow> _executiveRows = <_ExecutiveRow>[];
  final List<_StructureDetailRow> _detailRows = <_StructureDetailRow>[];
  final List<_DocumentRow> _documentRows = <_DocumentRow>[];

  _OptionItem? _project;
  _OptionItem? _structureType;
  _OptionItem? _workStatus;
  _OptionItem? _estimatedCostUnit;

  final TextEditingController _structureNameCtrl = TextEditingController();
  final TextEditingController _structureIdCtrl = TextEditingController();
  final TextEditingController _estimatedCostCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  final TextEditingController _latitudeCtrl = TextEditingController();
  final TextEditingController _longitudeCtrl = TextEditingController();

  DateTime? _originalTargetDate;
  DateTime? _constructionStartDate;
  DateTime? _targetCompletionDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadForm());
  }

  @override
  void dispose() {
    _structureNameCtrl.dispose();
    _structureIdCtrl.dispose();
    _estimatedCostCtrl.dispose();
    _remarksCtrl.dispose();
    _latitudeCtrl.dispose();
    _longitudeCtrl.dispose();
    for (final _StructureDetailRow row in _detailRows) {
      row.dispose();
    }
    for (final _DocumentRow row in _documentRows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Update Structure Form')),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Column(
              children: <Widget>[
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
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: _loadForm,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Form(
                          key: _formKey,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                            children: <Widget>[
                              _sectionCard(
                                title: 'Basic Information',
                                children: <Widget>[
                                  _selectField(
                                    label: 'Project *',
                                    title: 'Select Project',
                                    value: _project,
                                    items: _projects,
                                    onChanged: _onProjectChanged,
                                  ),
                                  const SizedBox(height: 10),
                                  _selectField(
                                    label: 'Structure Type *',
                                    title: 'Select Structure Type',
                                    value: _structureType,
                                    items: _structureTypes,
                                    onChanged: ( _OptionItem value) =>
                                        setState(() => _structureType = value),
                                  ),
                                  const SizedBox(height: 10),
                                  AppTextFormField(
                                    label: 'Structure Name *',
                                    controller: _structureNameCtrl,
                                    hintText: 'Enter structure name',
                                  ),
                                  const SizedBox(height: 10),
                                  AppTextFormField(
                                    label: 'Structure ID *',
                                    controller: _structureIdCtrl,
                                    hintText: 'Enter structure ID',
                                  ),
                                  const SizedBox(height: 10),
                                  _selectField(
                                    label: 'Work Status *',
                                    title: 'Select Work Status',
                                    value: _workStatus,
                                    items: _workStatuses,
                                    onChanged: ( _OptionItem value) =>
                                        setState(() => _workStatus = value),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _sectionCard(
                                title: 'Contract - Execution Executives',
                                children: <Widget>[
                                  if (_contractsLoading)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: LinearProgressIndicator(),
                                    ),
                                  ..._executiveRows.map(_buildExecutiveCard),
                                  const SizedBox(height: 8),
                                  Align(
                                    child: FilledButton.tonalIcon(
                                      onPressed: _addExecutiveRow,
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text('Add Contract Row'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _sectionCard(
                                title: 'Additional Details',
                                children: <Widget>[
                                  AppDateFormField(
                                    label: 'Original Target Date',
                                    value: _originalTargetDate,
                                    onTap: () => _pickDate(
                                      current: _originalTargetDate,
                                      onPicked: (DateTime value) => setState(
                                        () => _originalTargetDate = value,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: AppTextFormField(
                                          label: 'Estimated Cost',
                                          controller: _estimatedCostCtrl,
                                          hintText: 'Enter value',
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: _selectField(
                                          label: 'Unit',
                                          title: 'Select Unit',
                                          value: _estimatedCostUnit,
                                          items: _units,
                                          onChanged: ( _OptionItem value) =>
                                              setState(
                                            () => _estimatedCostUnit = value,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  AppTextFormField(
                                    label: 'Remarks',
                                    controller: _remarksCtrl,
                                    hintText: 'Enter remarks...',
                                    minLines: 3,
                                    maxLines: 5,
                                    maxLength: 1000,
                                  ),
                                  const SizedBox(height: 10),
                                  AppTextFormField(
                                    label: 'Latitude',
                                    controller: _latitudeCtrl,
                                    hintText: 'Enter Latitude',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                    maxLength: 15,
                                  ),
                                  const SizedBox(height: 10),
                                  AppTextFormField(
                                    label: 'Longitude',
                                    controller: _longitudeCtrl,
                                    hintText: 'Enter Longitude',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                    maxLength: 15,
                                  ),
                                  const SizedBox(height: 10),
                                  AppDateFormField(
                                    label: 'Construction Start Date',
                                    value: _constructionStartDate,
                                    onTap: () => _pickDate(
                                      current: _constructionStartDate,
                                      onPicked: (DateTime value) => setState(
                                        () => _constructionStartDate = value,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  AppDateFormField(
                                    label: 'Target Completion Date',
                                    value: _targetCompletionDate,
                                    onTap: () => _pickDate(
                                      current: _targetCompletionDate,
                                      onPicked: (DateTime value) => setState(
                                        () => _targetCompletionDate = value,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _sectionCard(
                                title: 'Structure Details',
                                children: <Widget>[
                                  ..._detailRows.map(_buildDetailCard),
                                  const SizedBox(height: 8),
                                  Align(
                                    child: FilledButton.tonalIcon(
                                      onPressed: _addDetailRow,
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text('Add Detail'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _sectionCard(
                                title: 'Documents',
                                children: <Widget>[
                                  if (_documentRows.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        'No documents added yet. Tap below to attach files.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    )
                                  else
                                    ...List<Widget>.generate(
                                      _documentRows.length,
                                      (int index) => _buildDocumentCard(
                                        index,
                                        _documentRows[index],
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Align(
                                    child: FilledButton.tonalIcon(
                                      onPressed: _addDocumentRow,
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text('Add Document'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
                if (!_loading && _loadError == null)
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : () => context.pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: _saving ? null : _submit,
                            child: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Update'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
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
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _selectField({
    required String label,
    required String title,
    required _OptionItem? value,
    required List<_OptionItem> items,
    required ValueChanged<_OptionItem> onChanged,
    String placeholder = 'Select',
    bool enabled = true,
  }) {
    return AppSelectSheetField<_OptionItem>(
      label: label,
      title: title,
      value: value,
      items: items,
      itemLabelBuilder: ( _OptionItem item) => item.label,
      onChanged: onChanged,
      placeholderText: placeholder,
      enabled: enabled,
    );
  }

  Widget _buildExecutiveCard(_ExecutiveRow row) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _selectField(
                  label: 'Contract *',
                  title: 'Select Contract',
                  value: row.contract,
                  items: _contracts,
                  onChanged: ( _OptionItem value) =>
                      setState(() => row.contract = value),
                ),
              ),
              IconButton(
                tooltip: 'Remove row',
                onPressed: () => setState(() => _executiveRows.remove(row)),
                icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _multiSelectField(
            label: 'Responsible Executives *',
            items: _responsiblePeople,
            selected: row.selectedExecutives,
            onChanged: (List<_OptionItem> picked) => setState(() {
              row.selectedExecutives
                ..clear()
                ..addAll(picked);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(_StructureDetailRow row) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: AppTextFormField(
              label: 'Structure Detail',
              controller: row.detailCtrl,
              hintText: 'Enter detail description',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppTextFormField(
              label: 'Value',
              controller: row.valueCtrl,
              hintText: 'Enter value',
            ),
          ),
          IconButton(
            tooltip: 'Remove row',
            onPressed: () {
              setState(() {
                _detailRows.remove(row);
                row.dispose();
              });
            },
            icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(int index, _DocumentRow row) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? displayFileName = _documentDisplayFileName(row);
    final bool hasNewFile = row.pickedBytes != null;
    final bool hasExisting =
        !hasNewFile && (row.existingFileName?.trim().isNotEmpty ?? false);
    final IconData fileIcon = _fileIconForName(displayFileName);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Document ${index + 1}',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Remove document',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer,
                    foregroundColor: colorScheme.onErrorContainer,
                  ),
                  onPressed: _saving ? null : () => _removeDocumentRow(index),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _selectField(
              label: 'File Type',
              title: 'Select File Type',
              value: row.fileType,
              items: _fileTypes,
              onChanged: ( _OptionItem value) =>
                  setState(() => row.fileType = value),
              enabled: !_saving,
            ),
            const SizedBox(height: 10),
            AppTextFormField(
              label: 'Name',
              controller: row.nameCtrl,
              hintText: 'Enter document name',
              readOnly: _saving,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.55),
                ),
                color: colorScheme.surface.withValues(alpha: 0.65),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          displayFileName == null
                              ? Icons.insert_drive_file_outlined
                              : fileIcon,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _documentFileStatusChip(
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                              hasNewFile: hasNewFile,
                              hasExisting: hasExisting,
                            ),
                            if (displayFileName != null &&
                                displayFileName.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 6),
                              Text(
                                displayFileName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ] else ...<Widget>[
                              const SizedBox(height: 6),
                              Text(
                                'No file attached yet',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'PDF, images, Excel and other supported files',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (displayFileName != null && displayFileName.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _saving
                                ? null
                                : () => _previewDocument(row),
                            icon: const Icon(Icons.visibility_outlined, size: 18),
                            label: const Text('View'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: _saving
                                ? null
                                : () => _pickDocumentFile(row),
                            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                            label: Text(hasExisting ? 'Replace' : 'Change'),
                          ),
                        ),
                      ],
                    ),
                    if (hasNewFile && hasExisting) ...<Widget>[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer.withValues(
                            alpha: 0.55,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: colorScheme.onTertiaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Will replace: ${row.existingFileName}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ] else ...<Widget>[
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: _saving ? null : () => _pickDocumentFile(row),
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Upload file'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _documentFileStatusChip({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool hasNewFile,
    required bool hasExisting,
  }) {
    final String label;
    final Color background;
    final Color foreground;
    final IconData icon;

    if (hasNewFile) {
      label = 'New file selected';
      background = colorScheme.primaryContainer;
      foreground = colorScheme.onPrimaryContainer;
      icon = Icons.file_upload_outlined;
    } else if (hasExisting) {
      label = 'Saved attachment';
      background = colorScheme.secondaryContainer;
      foreground = colorScheme.onSecondaryContainer;
      icon = Icons.cloud_done_outlined;
    } else {
      label = 'No file';
      background = colorScheme.surfaceContainerHighest;
      foreground = colorScheme.onSurfaceVariant;
      icon = Icons.attach_file_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String? _documentDisplayFileName(_DocumentRow row) {
    if (row.pickedFileName != null && row.pickedFileName!.trim().isNotEmpty) {
      return row.pickedFileName!.trim();
    }
    final String existing = row.existingFileName?.trim() ?? '';
    if (existing.isNotEmpty) {
      return existing;
    }
    return null;
  }

  IconData _fileIconForName(String? fileName) {
    final String lower = (fileName ?? '').toLowerCase();
    if (lower.endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    }
    if (lower.endsWith('.xlsx') ||
        lower.endsWith('.xls') ||
        lower.endsWith('.csv')) {
      return Icons.table_chart_outlined;
    }
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif')) {
      return Icons.image_outlined;
    }
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Icons.article_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  void _removeDocumentRow(int index) {
    setState(() {
      _documentRows[index].dispose();
      _documentRows.removeAt(index);
    });
  }

  Future<void> _previewDocument(_DocumentRow row) async {
    final String? displayName = _documentDisplayFileName(row);
    if (row.pickedBytes != null && row.pickedBytes!.isNotEmpty) {
      await showStructureDocumentPreview(
        context: context,
        dataSource: widget.dataSource,
        localBytes: row.pickedBytes,
        localFileName: row.pickedFileName,
        title: row.nameCtrl.text.trim().isNotEmpty
            ? row.nameCtrl.text.trim()
            : displayName,
      );
      return;
    }

    final String existing = row.existingFileName?.trim() ?? '';
    if (existing.isEmpty) {
      return;
    }

    await showStructureDocumentPreview(
      context: context,
      dataSource: widget.dataSource,
      remoteFileName: existing,
      title: row.nameCtrl.text.trim().isNotEmpty
          ? row.nameCtrl.text.trim()
          : existing,
    );
  }

  Widget _multiSelectField({
    required String label,
    required List<_OptionItem> items,
    required List<_OptionItem> selected,
    required ValueChanged<List<_OptionItem>> onChanged,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String summary = selected.isEmpty
        ? 'Select executives'
        : selected.map(( _OptionItem o) => o.label).join(', ');

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
          onTap: () async {
            final Set<String> tempSelected =
                selected.map(( _OptionItem o) => o.id).toSet();
            final List<_OptionItem>? picked =
                await showModalBottomSheet<List<_OptionItem>>(
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
                              label,
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
                              itemBuilder: (BuildContext context, int index) {
                                final _OptionItem item = items[index];
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
                                    final List<_OptionItem> result =
                                        items
                                            .where(
                                              ( _OptionItem item) =>
                                                  tempSelected.contains(
                                                    item.id,
                                                  ),
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
              onChanged(picked);
            }
          },
          child: InputDecorator(
            decoration: AppFormFieldStyle.decoration(
              context,
              filled: selected.isNotEmpty,
              suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
            child: Text(
              summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppFormFieldStyle.valueStyle(
                context,
                filled: selected.isNotEmpty,
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
                  ( _OptionItem option) => Chip(
                    label: Text(option.label),
                    deleteIcon: const Icon(Icons.close_rounded, size: 16),
                    onDeleted: () {
                      final List<_OptionItem> next =
                          List<_OptionItem>.from(selected)
                            ..removeWhere(
                              ( _OptionItem o) => o.id == option.id,
                            );
                      onChanged(next);
                    },
                  ),
                )
                .toList(),
          ),
        ] else ...<Widget>[
          const SizedBox(height: 4),
          Text(
            'Tap to select one or more executives',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _loadForm() async {
    if (widget.structureId.trim().isEmpty) {
      setState(() => _loadError = 'Structure id is required.');
      return;
    }
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final Map<String, dynamic> response =
          await widget.dataSource.fetchStructureWorkForm(
        structureId: widget.structureId.trim(),
      );
      _applyBootstrap(response);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loadError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _applyBootstrap(Map<String, dynamic> response) {
    final Map<String, dynamic> details = _asMap(
      response['structuresListDetails'],
    );

    _projects = _projectOptions(_list(response['projectsList']));
    _structureTypes = _structureTypeOptions(_list(response['structuresList']));
    _workStatuses = _stringOptions(_stringList(response['executionStatusList']));
    _units = _unitOptions(_list(response['unitsList']));
    _contracts = _contractOptions(_list(response['contractsList']));
    _responsiblePeople = _peopleOptions(_list(response['responsiblePeopleList']));
    _fileTypes = _fileTypeOptions(_list(response['fileType']));

    final String projectId = _string(
      details['project_id_fk'] ?? details['project_id'],
    );
    final String structureType = _string(
      details['structure_type_fk'] ?? details['structure_type'],
    );
    final String workStatus = _string(details['work_status_fk']);
    final String unit = _string(details['estimated_cost_units']);

    _project = _findOption(_projects, projectId);
    _structureType = _findOption(_structureTypes, structureType);
    _workStatus = _findOption(_workStatuses, workStatus);
    _estimatedCostUnit = _findOption(_units, unit);

    _structureNameCtrl.text = _string(
      details['structure_name'] ?? details['structure'],
    );
    _structureIdCtrl.text = _string(details['structure'] ?? details['structure_name']);
    _estimatedCostCtrl.text = _string(details['estimated_cost']);
    _remarksCtrl.text = _string(details['remarks']);
    _latitudeCtrl.text = _sanitizeCoord(_string(details['latitude']));
    _longitudeCtrl.text = _sanitizeCoord(_string(details['longitude']));

    _originalTargetDate = _parseDate(details['target_date']);
    _constructionStartDate = _parseDate(details['construction_start_date']);
    _targetCompletionDate = _parseDate(details['revised_completion']);

    for (final _ExecutiveRow row in _executiveRows) {
      row.selectedExecutives.clear();
    }
    _executiveRows.clear();
    for (final Map<String, dynamic> executive in _list(details['executivesList'])) {
      final _ExecutiveRow row = _ExecutiveRow();
      final String contractId = _string(executive['contract_id_fk']);
      row.contract = _findOption(_contracts, contractId);
      for (final Map<String, dynamic> person
          in _list(executive['responsiblePeopleLists'])) {
        final String personId = _string(
          person['responsible_people_id_fk'] ?? person['user_id'],
        );
        final _OptionItem? option = _findOption(_responsiblePeople, personId);
        if (option != null &&
            !row.selectedExecutives.any(
              ( _OptionItem o) => o.id == option.id,
            )) {
          row.selectedExecutives.add(option);
        }
      }
      _executiveRows.add(row);
    }

    for (final _StructureDetailRow row in _detailRows) {
      row.dispose();
    }
    _detailRows.clear();
    for (final Map<String, String> detail in _structureDetailPrefillRows(
      response,
      details,
    )) {
      final _StructureDetailRow row = _StructureDetailRow();
      row.detailCtrl.text = detail['detail'] ?? '';
      row.valueCtrl.text = detail['value'] ?? '';
      _detailRows.add(row);
    }

    for (final _DocumentRow row in _documentRows) {
      row.dispose();
    }
    _documentRows.clear();
    for (final Map<String, dynamic> doc in _list(details['documentsList'])) {
      final _DocumentRow row = _DocumentRow();
      final String fileType = _string(doc['structure_file_type_fk']);
      row.fileType = _findOption(_fileTypes, fileType);
      row.nameCtrl.text = _string(doc['name']);
      row.existingFileId = _string(doc['structure_file_id']);
      row.existingFileName = _string(doc['attachment']);
      _documentRows.add(row);
    }
  }

  Future<void> _onProjectChanged(_OptionItem value) async {
    setState(() {
      _project = value;
      _contractsLoading = true;
      for (final _ExecutiveRow row in _executiveRows) {
        row.contract = null;
      }
    });
    try {
      final List<Map<String, dynamic>> rows =
          await widget.dataSource.fetchContractsListForStructureFormProject(
        projectIdFk: value.id,
      );
      if (!mounted) {
        return;
      }
      setState(() => _contracts = _contractOptions(rows));
    } catch (_) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Contracts',
        message: 'Unable to load contracts for the selected project.',
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _contractsLoading = false);
      }
    }
  }

  void _addExecutiveRow() => setState(() => _executiveRows.add(_ExecutiveRow()));

  void _addDetailRow() => setState(() => _detailRows.add(_StructureDetailRow()));

  void _addDocumentRow() => setState(() => _documentRows.add(_DocumentRow()));

  Future<void> _pickDocumentFile(_DocumentRow row) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final PlatformFile file = result.files.first;
    final Uint8List? bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      return;
    }
    setState(() {
      row.pickedBytes = bytes;
      row.pickedFileName = file.name;
    });
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  Future<void> _submit() async {
    if (_project == null ||
        _structureType == null ||
        _workStatus == null ||
        _structureNameCtrl.text.trim().isEmpty ||
        _structureIdCtrl.text.trim().isEmpty) {
      await AppDialog.show(
        context: context,
        title: 'Required Details',
        message:
            'Please fill Project, Structure Type, Structure Name, Structure ID and Work Status.',
        type: AppDialogType.info,
      );
      return;
    }

    for (final _ExecutiveRow row in _executiveRows) {
      final bool hasPartialData = row.contract != null ||
          row.selectedExecutives.isNotEmpty;
      if (hasPartialData &&
          (row.contract == null || row.selectedExecutives.isEmpty)) {
        await AppDialog.show(
          context: context,
          title: 'Required Details',
          message:
              'Each contract row needs a contract and at least one responsible executive.',
          type: AppDialogType.info,
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final List<MapEntry<String, String>> fields = _buildUpdateFields();
      final List<({Uint8List bytes, String fileName})> files =
          <({Uint8List bytes, String fileName})>[];
      for (final _DocumentRow row in _documentRows) {
        if (row.pickedBytes != null &&
            row.pickedFileName != null &&
            row.pickedFileName!.isNotEmpty) {
          files.add((bytes: row.pickedBytes!, fileName: row.pickedFileName!));
        }
      }
      await widget.dataSource.submitUpdateStructureWorkForm(
        fields: fields,
        structureFiles: files,
      );
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Updated',
        message: 'Structure details updated successfully.',
        type: AppDialogType.success,
      );
      if (!mounted) {
        return;
      }
      context.pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Update Failed',
        message:
            'Unable to update structure details. Please verify the data and retry.',
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  List<MapEntry<String, String>> _buildUpdateFields() {
    String formatDate(DateTime? date) {
      if (date == null) {
        return '';
      }
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    final String unitValue = _estimatedCostUnit?.id ?? '';

    final List<MapEntry<String, String>> fields = <MapEntry<String, String>>[
      MapEntry<String, String>('structure_id', widget.structureId.trim()),
      MapEntry<String, String>('project_id_fk', _project?.id ?? ''),
      MapEntry<String, String>('structure_type_fk', _structureType?.id ?? ''),
      MapEntry<String, String>(
        'structure_name',
        _structureNameCtrl.text.trim(),
      ),
      MapEntry<String, String>('structure', _structureIdCtrl.text.trim()),
      MapEntry<String, String>('work_status_fk', _workStatus?.id ?? ''),
      MapEntry<String, String>(
        'target_date',
        formatDate(_originalTargetDate),
      ),
      MapEntry<String, String>(
        'estimated_cost',
        _estimatedCostCtrl.text.trim(),
      ),
      if (unitValue.isNotEmpty) ...<MapEntry<String, String>>[
        MapEntry<String, String>('estimated_cost_unit', unitValue),
        MapEntry<String, String>('estimated_cost_units', unitValue),
      ],
      MapEntry<String, String>('remarks', _remarksCtrl.text.trim()),
      MapEntry<String, String>('latitude', _latitudeCtrl.text.trim()),
      MapEntry<String, String>('longitude', _longitudeCtrl.text.trim()),
      MapEntry<String, String>(
        'construction_start_date',
        formatDate(_constructionStartDate),
      ),
      MapEntry<String, String>(
        'revised_completion',
        formatDate(_targetCompletionDate),
      ),
    ];

    for (final _ExecutiveRow row in _executiveRows) {
      if (row.contract == null && row.selectedExecutives.isEmpty) {
        continue;
      }
      final String contractId = row.contract?.id ?? '';
      fields.add(MapEntry<String, String>('contracts_id_fk', contractId));
      fields.add(MapEntry<String, String>('contract_id_fk', contractId));
      for (final _OptionItem person in row.selectedExecutives) {
        fields.add(
          MapEntry<String, String>(
            'responsible_people_id_fks',
            person.id,
          ),
        );
      }
    }

    final List<({String detail, String value})> structureDetailPairs =
        <({String detail, String value})>[];
    for (final _StructureDetailRow row in _detailRows) {
      final String detail = row.detailCtrl.text.trim();
      final String value = row.valueCtrl.text.trim();
      if (detail.isEmpty && value.isEmpty) {
        continue;
      }
      structureDetailPairs.add((detail: detail, value: value));
    }
    // Web sends all structure_details first, then all structure_values.
    for (final ({String detail, String value}) pair in structureDetailPairs) {
      fields.add(MapEntry<String, String>('structure_details', pair.detail));
    }
    for (final ({String detail, String value}) pair in structureDetailPairs) {
      fields.add(MapEntry<String, String>('structure_values', pair.value));
    }

    for (final _DocumentRow row in _documentRows) {
      fields.add(
        MapEntry<String, String>(
          'structure_file_types',
          row.fileType?.label ?? row.fileType?.id ?? '',
        ),
      );
      fields.add(
        MapEntry<String, String>(
          'structureDocumentNames',
          row.nameCtrl.text.trim(),
        ),
      );
      final String pickedName = row.pickedFileName?.trim() ?? '';
      final String attachmentName = pickedName.isNotEmpty
          ? pickedName
          : row.existingFileName?.trim() ?? '';
      fields.add(
        MapEntry<String, String>('structureFileNames', attachmentName),
      );
    }

    return fields;
  }

  List<Map<String, dynamic>> _list(dynamic raw) {
    if (raw is! List) {
      return const <Map<String, dynamic>>[];
    }
    return raw
        .whereType<Map>()
        .map((Map<dynamic, dynamic> row) => _asMap(row))
        .toList();
  }

  List<Map<String, String>> _structureDetailPrefillRows(
    Map<String, dynamic> response,
    Map<String, dynamic> details,
  ) {
    for (final String key in <String>[
      'structureDetailsList1',
      'structureDetailsList',
    ]) {
      final List<Map<String, String>> fromList = _structureDetailRowsFromList(
        details[key] ?? response[key],
      );
      if (fromList.isNotEmpty) {
        return fromList;
      }
    }

    final List<String> detailValues = _stringValues(
      details['structure_details'] ?? details['structure_detailss'],
    );
    final List<String> valueValues = _stringValues(details['structure_values']);
    if (detailValues.isNotEmpty || valueValues.isNotEmpty) {
      final int count = detailValues.length > valueValues.length
          ? detailValues.length
          : valueValues.length;
      return List<Map<String, String>>.generate(count, (int index) {
        return <String, String>{
          'detail': index < detailValues.length ? detailValues[index] : '',
          'value': index < valueValues.length ? valueValues[index] : '',
        };
      }).where((Map<String, String> row) {
        return row['detail']!.isNotEmpty || row['value']!.isNotEmpty;
      }).toList();
    }

    return const <Map<String, String>>[];
  }

  List<Map<String, String>> _structureDetailRowsFromList(dynamic raw) {
    final List<Map<String, String>> rows = <Map<String, String>>[];
    for (final Map<String, dynamic> detail in _list(raw)) {
      final String detailText = _string(
        detail['structure_detail'] ??
            detail['structure_details'] ??
            detail['detail'],
      );
      final String valueText = _string(
        detail['structure_value'] ?? detail['structure_values'] ?? detail['value'],
      );
      if (detailText.isEmpty && valueText.isEmpty) {
        continue;
      }
      rows.add(<String, String>{
        'detail': detailText,
        'value': valueText,
      });
    }
    return rows;
  }

  List<String> _stringValues(dynamic raw) {
    if (raw is List) {
      return raw.map((dynamic item) => _string(item)).toList();
    }
    final String single = _string(raw);
    if (single.isEmpty) {
      return const <String>[];
    }
    return <String>[single];
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map(
        (dynamic key, dynamic value) => MapEntry<String, dynamic>(
          key.toString(),
          value,
        ),
      );
    }
    return <String, dynamic>{};
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

  String _sanitizeCoord(String raw) {
    if (raw.isEmpty || raw.toLowerCase() == 'null') {
      return '';
    }
    return raw;
  }

  DateTime? _parseDate(dynamic raw) {
    final String value = _string(raw);
    if (value.isEmpty) {
      return null;
    }
    final String normalized = value.split(' ').first;
    try {
      final List<String> parts = normalized.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
      final List<String> slashParts = normalized.split('/');
      if (slashParts.length == 3) {
        return DateTime(
          int.parse(slashParts[2]),
          int.parse(slashParts[1]),
          int.parse(slashParts[0]),
        );
      }
    } catch (_) {
      return null;
    }
    return DateTime.tryParse(normalized);
  }

  _OptionItem? _findOption(List<_OptionItem> items, String id) {
    if (id.isEmpty) {
      return null;
    }
    for (final _OptionItem item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  List<_OptionItem> _projectOptions(List<Map<String, dynamic>> rows) {
    return rows
        .map((Map<String, dynamic> row) {
          final String id = _string(row['project_id_fk'] ?? row['project_id']);
          final String name = _string(row['project_name']);
          if (id.isEmpty) {
            return null;
          }
          final String label =
              name.isNotEmpty ? '$id - $name' : id;
          return _OptionItem(id: id, label: label);
        })
        .whereType<_OptionItem>()
        .toList();
  }

  List<_OptionItem> _structureTypeOptions(List<Map<String, dynamic>> rows) {
    return rows
        .map((Map<String, dynamic> row) {
          final String type = _string(row['structure_type']);
          if (type.isEmpty) {
            return null;
          }
          return _OptionItem(id: type, label: type);
        })
        .whereType<_OptionItem>()
        .toList();
  }

  List<_OptionItem> _stringOptions(List<String> values) {
    return values
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .map((String value) => _OptionItem(id: value, label: value))
        .toList();
  }

  List<String> _stringList(dynamic raw) {
    if (raw is! List) {
      return const <String>[];
    }
    return raw.map((dynamic item) => item.toString()).toList();
  }

  List<_OptionItem> _unitOptions(List<Map<String, dynamic>> rows) {
    return rows
        .map((Map<String, dynamic> row) {
          final String unit = _string(row['unit']);
          final String value = _string(row['value']);
          final String id = _string(row['id']);
          if (unit.isEmpty) {
            return null;
          }
          final String apiValue = value.isNotEmpty ? value : id;
          return _OptionItem(
            id: apiValue.isNotEmpty ? apiValue : unit,
            label: unit,
          );
        })
        .whereType<_OptionItem>()
        .toList();
  }

  List<_OptionItem> _contractOptions(List<Map<String, dynamic>> rows) {
    return rows
        .map((Map<String, dynamic> row) {
          final String id = _string(row['contract_id_fk'] ?? row['contract_id']);
          final String shortName = _string(row['contract_short_name']);
          final String name = _string(row['contract_name']);
          final String label = shortName.isNotEmpty
              ? shortName
              : name.isNotEmpty
              ? name
              : id;
          if (id.isEmpty && label.isEmpty) {
            return null;
          }
          return _OptionItem(id: id.isNotEmpty ? id : label, label: label);
        })
        .whereType<_OptionItem>()
        .toList();
  }

  List<_OptionItem> _peopleOptions(List<Map<String, dynamic>> rows) {
    return rows
        .map((Map<String, dynamic> row) {
          final String id = _string(row['user_id'] ?? row['responsible_people_id_fk']);
          final String name = _string(row['user_name']);
          final String designation = _string(row['designation']);
          if (id.isEmpty) {
            return null;
          }
          final String label = designation.isNotEmpty && name.isNotEmpty
              ? '$designation - $name'
              : name.isNotEmpty
              ? name
              : id;
          return _OptionItem(id: id, label: label);
        })
        .whereType<_OptionItem>()
        .toList();
  }

  List<_OptionItem> _fileTypeOptions(List<Map<String, dynamic>> rows) {
    return rows
        .map((Map<String, dynamic> row) {
          final String type = _string(row['structure_file_type']);
          if (type.isEmpty) {
            return null;
          }
          return _OptionItem(id: type, label: type);
        })
        .whereType<_OptionItem>()
        .toList();
  }
}
