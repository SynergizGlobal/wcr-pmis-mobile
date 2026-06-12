import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_form_field_style.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

enum StructureFormMode { add, edit }

class StructureFormPage extends StatefulWidget {
  const StructureFormPage({
    super.key,
    required this.dataSource,
    required this.mode,
    this.initialProjectId,
  });

  static const String addRouteName = 'add-structure';
  static const String addRoutePath = '/structures/add';
  static const String editRouteName = 'update-structure';
  static const String editRoutePath = '/structures/edit';

  final DashboardRemoteDataSource dataSource;
  final StructureFormMode mode;
  final String? initialProjectId;

  @override
  State<StructureFormPage> createState() => _StructureFormPageState();
}

class _StructureFormPageState extends State<StructureFormPage> {
  static const List<String> _tableHeaders = <String>[
    'Structure',
    'Structure Name',
    'Structure Details',
    'From Chainage',
    'To Chainage',
    'Action',
  ];

  static const Map<String, double> _columnWidths = <String, double>{
    'Structure': 168,
    'Structure Name': 168,
    'Structure Details': 148,
    'From Chainage': 124,
    'To Chainage': 124,
    'Action': 52,
  };

  static const double _tableHeaderHeight = 44;
  static const double _tableRowHeight = 52;
  static const double _sectionTableMaxHeight = 280;

  bool _loading = false;
  bool _submitting = false;

  List<_ProjectOption> _projects = <_ProjectOption>[];
  List<String> _structureTypes = <String>[];
  String? _selectedProjectId;
  double? _fromChainage;
  double? _toChainage;

  final List<_StructureTypeSection> _sections = <_StructureTypeSection>[];

  bool get _isEdit => widget.mode == StructureFormMode.edit;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.initialProjectId?.trim().isNotEmpty == true
        ? widget.initialProjectId!.trim()
        : null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    for (final _StructureTypeSection section in _sections) {
      section.dispose();
    }
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        widget.dataSource.fetchProjectsDropdown(),
        widget.dataSource.fetchStructureTypes(),
      ]);
      if (!mounted) {
        return;
      }
      final List<Map<String, dynamic>> projectRows =
          results[0] as List<Map<String, dynamic>>;
      final List<String> types = results[1] as List<String>;

      _projects = projectRows
          .map((Map<String, dynamic> row) {
            final String id = _string(row['project_id'] ?? row['projectId']);
            final String name =
                _string(row['project_name'] ?? row['projectName']);
            if (id.isEmpty) {
              return null;
            }
            return _ProjectOption(id: id, name: name);
          })
          .whereType<_ProjectOption>()
          .toList()
        ..sort(( _ProjectOption a, _ProjectOption b) => a.id.compareTo(b.id));
      _structureTypes = types;

      if (_selectedProjectId != null) {
        if (_isEdit) {
          await _loadEditProjectData(_selectedProjectId!);
        } else {
          await _loadProjectChainage(_selectedProjectId!);
        }
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load form',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onProjectSelected(String projectId) async {
    setState(() {
      _selectedProjectId = projectId;
      _fromChainage = null;
      _toChainage = null;
      for (final _StructureTypeSection section in _sections) {
        section.dispose();
      }
      _sections.clear();
    });

    setState(() => _loading = true);
    try {
      await _loadProjectChainage(projectId);
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load project data',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadEditProjectData(String projectId) async {
    setState(() => _loading = true);
    try {
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        widget.dataSource.fetchProjectStructureChainage(projectId),
        widget.dataSource.fetchStructuresForProject(projectId),
      ]);
      if (!mounted) {
        return;
      }
      final Map<String, dynamic> chainage =
          results[0] as Map<String, dynamic>;
      final Map<String, dynamic> structures =
          results[1] as Map<String, dynamic>;

      _applyChainage(chainage);
      _applyStructureSections(structures);
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load structure data',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadProjectChainage(String projectId) async {
    final Map<String, dynamic> chainage =
        await widget.dataSource.fetchProjectStructureChainage(projectId);
    if (!mounted) {
      return;
    }
    _applyChainage(chainage);
  }

  void _applyChainage(Map<String, dynamic> chainage) {
    setState(() {
      _fromChainage = _toDouble(chainage['fromChainage']);
      _toChainage = _toDouble(chainage['toChainage']);
    });
  }

  void _applyStructureSections(Map<String, dynamic> response) {
    final List<_StructureTypeSection> parsed =
        _parseStructureSections(response);
    for (final _StructureTypeSection section in _sections) {
      section.dispose();
    }
    setState(() {
      _sections
        ..clear()
        ..addAll(parsed);
    });
  }

  List<_StructureTypeSection> _parseStructureSections(
    Map<String, dynamic> response,
  ) {
    final List<_StructureTypeSection> sections = <_StructureTypeSection>[];
    dynamic rawTypes = response['structureTypes'];
    if (rawTypes is! List) {
      rawTypes = response['data'] is Map
          ? (response['data'] as Map)['structureTypes']
          : null;
    }
    if (rawTypes is! List) {
      return sections;
    }
    for (final dynamic group in rawTypes) {
      if (group is! Map) {
        continue;
      }
      final String type = _string(group['type'] ?? group['structureType']);
      if (type.isEmpty) {
        continue;
      }
      final List<dynamic> rows =
          group['rows'] as List<dynamic>? ?? <dynamic>[];
      final _StructureTypeSection section = _StructureTypeSection(type: type);
      for (final dynamic row in rows) {
        if (row is! Map) {
          continue;
        }
        section.rows.add(
          _StructureRowState.fromMap(
            row.map(
              (dynamic key, dynamic value) => MapEntry(key.toString(), value),
            ),
          ),
        );
      }
      if (section.rows.isEmpty) {
        section.addEmptyRow();
      }
      sections.add(section);
    }
    return sections;
  }

  void _addSection() {
    if (_structureTypes.isEmpty) {
      return;
    }
    final String type = _structureTypes.first;
    setState(() {
      final _StructureTypeSection section = _StructureTypeSection(type: type);
      section.addEmptyRow();
      _sections.add(section);
    });
  }

  Future<void> _removeSection(_StructureTypeSection section) async {
    if (!_isEdit) {
      setState(() {
        section.dispose();
        _sections.remove(section);
      });
      return;
    }
    if (_selectedProjectId == null) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'Remove structure type',
      message: 'Remove all "${section.type}" rows for this project?',
      type: AppDialogType.confirmation,
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Remove',
          isPrimary: true,
          onPressed: () => _confirmRemoveSection(section),
        ),
      ],
    );
  }

  Future<void> _confirmRemoveSection(_StructureTypeSection section) async {
    if (_selectedProjectId == null) {
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.dataSource.deleteStructureType(
        projectId: _selectedProjectId!,
        type: section.type,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        section.dispose();
        _sections.remove(section);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Delete failed',
        message:
            'Delete structure type is integrated but backend returned an error.\n\n$error',
        type: AppDialogType.error,
      );
      setState(() {
        section.dispose();
        _sections.remove(section);
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _removeRow(
    _StructureTypeSection section,
    _StructureRowState row,
  ) async {
    if (_isEdit && row.structureId.isNotEmpty) {
      setState(() => _loading = true);
      try {
        await widget.dataSource.deleteStructureRow(row.structureId);
      } catch (error) {
        if (!mounted) {
          return;
        }
        await AppDialog.show(
          context: context,
          title: 'Delete failed',
          message:
              'Delete structure row is integrated but backend returned an error.\n\n$error',
          type: AppDialogType.error,
        );
      } finally {
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    }
    setState(() {
      section.rows.remove(row);
      row.dispose();
      if (section.rows.isEmpty) {
        section.addEmptyRow();
      }
    });
  }

  Map<String, dynamic> _buildPayload() {
    return <String, dynamic>{
      'project': _selectedProjectId,
      'structureTypes': _sections
          .map(
            ( _StructureTypeSection section) => <String, dynamic>{
              'type': section.type,
              'rows': section.rows
                  .where(( _StructureRowState row) => row.hasContent)
                  .map(( _StructureRowState row) => row.toMap())
                  .toList(),
            },
          )
          .where(
            (Map<String, dynamic> group) =>
                (group['rows'] as List<dynamic>).isNotEmpty,
          )
          .toList(),
    };
  }

  Future<void> _submit() async {
    if (_selectedProjectId == null) {
      await AppDialog.show(
        context: context,
        title: 'Project required',
        message: 'Please select a project.',
        type: AppDialogType.info,
      );
      return;
    }
    final Map<String, dynamic> payload = _buildPayload();
    final List<dynamic> groups =
        payload['structureTypes'] as List<dynamic>? ?? <dynamic>[];
    if (groups.isEmpty) {
      await AppDialog.show(
        context: context,
        title: 'Structures required',
        message: 'Add at least one structure row before saving.',
        type: AppDialogType.info,
      );
      return;
    }
    final String? chainageError = _validateAllChainages();
    if (chainageError != null) {
      await AppDialog.show(
        context: context,
        title: 'Invalid chainage',
        message: chainageError,
        type: AppDialogType.info,
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.dataSource.saveOrUpdateStructures(payload);
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Success',
        message: _isEdit
            ? 'Structure updated successfully.'
            : 'Structure added successfully.',
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
        title: 'Save failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  double get _tableContentWidth => _tableHeaders.fold<double>(
        0,
        (double sum, String header) => sum + _columnWidth(header),
      );

  double _columnWidth(String header) =>
      _columnWidths[header] ?? 120;

  @override
  Widget build(BuildContext context) {
    final String title = _isEdit ? 'Update Structure' : 'Add Structure';
    final bool canEditSections =
        _selectedProjectId != null && !_loading && !_submitting;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: AppSelectSheetField<String>(
                    label: 'Project *',
                    title: 'Select Project',
                    items: _projects.map(( _ProjectOption p) => p.id).toList(),
                    value: _selectedProjectId,
                  enabled: !_loading && !_submitting && !_isEdit,
                  itemLabelBuilder: (String id) {
                      for (final _ProjectOption project in _projects) {
                        if (project.id == id) {
                          return project.label;
                        }
                      }
                      return id;
                    },
                    onChanged: _isEdit ? (_) {} : _onProjectSelected,
                  ),
                ),
                Expanded(
                  child: _selectedProjectId == null
                      ? _buildSelectProjectPlaceholder(context)
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          children: <Widget>[
                            if (_sections.isEmpty)
                              _buildEmptySectionsPlaceholder(context),
                            ..._sections.map(_buildSectionTable),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: canEditSections ? _addSection : null,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add Structure Type'),
                            ),
                            const SizedBox(height: 88),
                          ],
                        ),
                ),
              ],
            ),
          ),
          if (_loading || _submitting)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting ? null : () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _loading || _submitting ? null : _submit,
                  child: Text(_isEdit ? 'Update' : 'Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectProjectPlaceholder(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Select a project to add structure details.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySectionsPlaceholder(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.table_rows_rounded,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              'No structure type added yet',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap "Add Structure Type" to create a table and enter rows.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTable(_StructureTypeSection section) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double tableBodyHeight = (_tableRowHeight * section.rows.length)
        .clamp(_tableRowHeight, _sectionTableMaxHeight - _tableHeaderHeight);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: colorScheme.primaryContainer.withValues(alpha: 0.45),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildStructureTypeSelector(section),
                ),
                IconButton(
                  tooltip: 'Add row',
                  visualDensity: VisualDensity.compact,
                  onPressed: _loading || _submitting
                      ? null
                      : () => setState(section.addEmptyRow),
                  icon: const Icon(Icons.add_rounded),
                ),
                IconButton(
                  tooltip: 'Remove structure type',
                  visualDensity: VisualDensity.compact,
                  onPressed: _loading || _submitting
                      ? null
                      : () => _removeSection(section),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
            child: Scrollbar(
              thumbVisibility: section.rows.length > 4,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _tableContentWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildTableHeaderRow(context),
                      SizedBox(
                        height: tableBodyHeight,
                        child: Scrollbar(
                          thumbVisibility: section.rows.length > 4,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: section.rows.length,
                            itemBuilder: (
                              BuildContext context,
                              int index,
                            ) {
                              return _buildTableDataRow(
                                section,
                                section.rows[index],
                                index,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructureTypeSelector(_StructureTypeSection section) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: _loading || _submitting
          ? null
          : () async {
              final String? picked = await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                showDragHandle: true,
                builder: (BuildContext context) {
                  return ListView(
                    shrinkWrap: true,
                    children: _structureTypes
                        .map(
                          (String type) => ListTile(
                            title: Text(type),
                            trailing: type == section.type
                                ? const Icon(Icons.check_rounded)
                                : null,
                            onTap: () => Navigator.of(context).pop(type),
                          ),
                        )
                        .toList(),
                  );
                },
              );
              if (picked != null && mounted) {
                setState(() => section.type = picked);
              }
            },
      child: InputDecorator(
        decoration: AppFormFieldStyle.decoration(
          context,
          hintText: 'Structure Type',
          filled: section.type.isNotEmpty,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                section.type.isEmpty ? 'Select Structure Type' : section.type,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: section.type.isEmpty
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeaderRow(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color dividerColor =
        colorScheme.onPrimary.withValues(alpha: 0.35);

    return ColoredBox(
      color: colorScheme.primary,
      child: SizedBox(
        height: _tableHeaderHeight,
        width: _tableContentWidth,
        child: Row(
          children: <Widget>[
            for (int index = 0; index < _tableHeaders.length; index++)
              _tableHeaderCell(
                _tableHeaders[index],
                showRightBorder: index < _tableHeaders.length - 1,
                dividerColor: dividerColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeaderCell(
    String title, {
    required bool showRightBorder,
    required Color dividerColor,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: _columnWidth(title),
      alignment: Alignment.center,
      decoration: showRightBorder
          ? BoxDecoration(
              border: Border(
                right: BorderSide(color: dividerColor),
              ),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTableDataRow(
    _StructureTypeSection section,
    _StructureRowState row,
    int index,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color rowColor = index.isEven
        ? colorScheme.primary.withValues(alpha: 0.06)
        : colorScheme.surface;

    return ColoredBox(
      color: rowColor,
      child: SizedBox(
        height: _tableRowHeight,
        width: _tableContentWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _tableInputCell(row.structureCtrl, width: _columnWidth('Structure')),
            _tableInputCell(
              row.structureNameCtrl,
              width: _columnWidth('Structure Name'),
            ),
            _tableInputCell(
              row.structureDetailsCtrl,
              width: _columnWidth('Structure Details'),
            ),
            _tableChainageCell(
              row.fromChainageCtrl,
              width: _columnWidth('From Chainage'),
            ),
            _tableChainageCell(
              row.toChainageCtrl,
              width: _columnWidth('To Chainage'),
            ),
            SizedBox(
              width: _columnWidth('Action'),
              child: Center(
                child: IconButton(
                  tooltip: 'Remove row',
                  visualDensity: VisualDensity.compact,
                  onPressed: _loading || _submitting
                      ? null
                      : () => _removeRow(section, row),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colorScheme.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableInputCell(
    TextEditingController controller, {
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: TextField(
          controller: controller,
          enabled: !_loading && !_submitting,
          style: const TextStyle(fontSize: 13),
          maxLines: 1,
          decoration: _compactTableDecoration(controller),
        ),
      ),
    );
  }

  Widget _tableChainageCell(
    TextEditingController controller, {
    required double width,
  }) {
    final bool enabled = !_loading &&
        !_submitting &&
        _selectedProjectId != null &&
        _chainageRangeHint != null;

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(fontSize: 13),
          maxLines: 1,
          decoration: _compactTableDecoration(
            controller,
            hint: _chainageRangeHint,
          ),
        ),
      ),
    );
  }

  InputDecoration _compactTableDecoration(
    TextEditingController controller, {
    String? hint,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool filled = AppFormFieldStyle.hasText(controller: controller);
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: filled
          ? colorScheme.primary.withValues(alpha: 0.05)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 11,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
      ),
    );
  }

  String? get _chainageRangeHint {
    if (_fromChainage == null && _toChainage == null) {
      return null;
    }
    final String from = _formatChainage(_fromChainage);
    final String to = _formatChainage(_toChainage);
    if (from.isEmpty && to.isEmpty) {
      return null;
    }
    if (from.isEmpty) {
      return to;
    }
    if (to.isEmpty) {
      return from;
    }
    return '$from - $to';
  }

  String? _validateAllChainages() {
    if (_fromChainage == null && _toChainage == null) {
      return 'Project chainage is not available for the selected project.';
    }
    for (final _StructureTypeSection section in _sections) {
      for (final _StructureRowState row in section.rows) {
        if (!row.hasContent) {
          continue;
        }
        final String? fromError =
            _validateChainageValue(row.fromChainageCtrl.text, 'From chainage');
        if (fromError != null) {
          return '${section.type}: $fromError';
        }
        final String? toError =
            _validateChainageValue(row.toChainageCtrl.text, 'To chainage');
        if (toError != null) {
          return '${section.type}: $toError';
        }
        final double from = double.parse(row.fromChainageCtrl.text.trim());
        final double to = double.parse(row.toChainageCtrl.text.trim());
        if (from > to) {
          return '${section.type}: From chainage cannot be greater than to chainage.';
        }
      }
    }
    return null;
  }

  String? _validateChainageValue(String raw, String fieldLabel) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '$fieldLabel is required.';
    }
    final double? value = double.tryParse(trimmed);
    if (value == null) {
      return '$fieldLabel must be numeric.';
    }
    if (_fromChainage != null && value < _fromChainage!) {
      return '$fieldLabel must be at least ${_formatChainage(_fromChainage)}.';
    }
    if (_toChainage != null && value > _toChainage!) {
      return '$fieldLabel must be at most ${_formatChainage(_toChainage)}.';
    }
    return null;
  }

  static String _formatChainage(double? value) {
    if (value == null) {
      return '';
    }
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  static String _string(dynamic value) => value?.toString().trim() ?? '';

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString());
  }
}

class _ProjectOption {
  const _ProjectOption({required this.id, required this.name});

  final String id;
  final String name;

  String get label => name.isEmpty ? id : '$id - $name';
}

class _StructureTypeSection {
  _StructureTypeSection({required this.type});

  String type;
  final List<_StructureRowState> rows = <_StructureRowState>[];

  void addEmptyRow() {
    rows.add(_StructureRowState.empty());
  }

  void dispose() {
    for (final _StructureRowState row in rows) {
      row.dispose();
    }
    rows.clear();
  }
}

class _StructureRowState {
  _StructureRowState({
    required this.structureId,
    required this.structureCtrl,
    required this.structureNameCtrl,
    required this.structureDetailsCtrl,
    required this.fromChainageCtrl,
    required this.toChainageCtrl,
  });

  factory _StructureRowState.empty() {
    return _StructureRowState(
      structureId: '',
      structureCtrl: TextEditingController(),
      structureNameCtrl: TextEditingController(),
      structureDetailsCtrl: TextEditingController(),
      fromChainageCtrl: TextEditingController(),
      toChainageCtrl: TextEditingController(),
    );
  }

  static String _formatChainageFieldValue(dynamic value) {
    if (value == null) {
      return '';
    }
    final double? parsed = double.tryParse(value.toString());
    if (parsed == null) {
      return value.toString();
    }
    if (parsed == parsed.roundToDouble()) {
      return parsed.toInt().toString();
    }
    return parsed.toString();
  }

  factory _StructureRowState.fromMap(Map<String, dynamic> map) {
    return _StructureRowState(
      structureId: map['structureId']?.toString() ?? '',
      structureCtrl: TextEditingController(
        text: map['structure']?.toString() ?? '',
      ),
      structureNameCtrl: TextEditingController(
        text: map['structureName']?.toString() ?? '',
      ),
      structureDetailsCtrl: TextEditingController(
        text: map['structureDetails']?.toString() ?? '',
      ),
      fromChainageCtrl: TextEditingController(
        text: _formatChainageFieldValue(map['fromChainage']),
      ),
      toChainageCtrl: TextEditingController(
        text: _formatChainageFieldValue(map['toChainage']),
      ),
    );
  }

  final String structureId;
  final TextEditingController structureCtrl;
  final TextEditingController structureNameCtrl;
  final TextEditingController structureDetailsCtrl;
  final TextEditingController fromChainageCtrl;
  final TextEditingController toChainageCtrl;

  bool get hasContent =>
      structureCtrl.text.trim().isNotEmpty ||
      structureNameCtrl.text.trim().isNotEmpty ||
      structureDetailsCtrl.text.trim().isNotEmpty ||
      fromChainageCtrl.text.trim().isNotEmpty ||
      toChainageCtrl.text.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'structure': structureCtrl.text.trim(),
      'structureName': structureNameCtrl.text.trim(),
      'structureDetails': structureDetailsCtrl.text.trim(),
      'fromChainage': _chainageValue(fromChainageCtrl.text),
      'toChainage': _chainageValue(toChainageCtrl.text),
    };
    map['structureId'] = structureId;
    return map;
  }

  dynamic _chainageValue(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final int? asInt = int.tryParse(trimmed);
    if (asInt != null) {
      return asInt;
    }
    return double.tryParse(trimmed) ?? trimmed;
  }

  void dispose() {
    structureCtrl.dispose();
    structureNameCtrl.dispose();
    structureDetailsCtrl.dispose();
    fromChainageCtrl.dispose();
    toChainageCtrl.dispose();
  }
}
