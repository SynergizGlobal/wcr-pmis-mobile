import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/report_file_export.dart';

class _LandReportOption {
  const _LandReportOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  bool operator ==(Object other) {
    return other is _LandReportOption && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class LandAcquisitionReportScreen extends StatefulWidget {
  const LandAcquisitionReportScreen({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  State<LandAcquisitionReportScreen> createState() =>
      _LandAcquisitionReportScreenState();
}

class _LandAcquisitionReportScreenState extends State<LandAcquisitionReportScreen> {
  bool _loading = false;
  bool _generating = false;

  List<_LandReportOption> _projectOptions = <_LandReportOption>[];
  List<_LandReportOption> _typeOptions = <_LandReportOption>[];
  List<_LandReportOption> _subCategoryOptions = <_LandReportOption>[];

  _LandReportOption? _selectedProject;
  _LandReportOption? _selectedType;
  _LandReportOption? _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProjects());
  }

  @override
  Widget build(BuildContext context) {
    final bool canGenerate = _selectedProject != null &&
        _selectedType != null &&
        _selectedSubCategory != null &&
        !_loading &&
        !_generating;
    final bool hasFilters = _selectedProject != null ||
        _selectedType != null ||
        _selectedSubCategory != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.formName.trim().isEmpty
              ? 'Land Acquisition Report'
              : widget.args.formName,
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppSelectSheetField<_LandReportOption>(
                      label: 'Project',
                      title: 'Select Project',
                      placeholderText: 'Select Project',
                      items: _projectOptions,
                      value: _selectedProject,
                      enabled: !_loading && !_generating,
                      itemLabelBuilder: (_LandReportOption option) => option.label,
                      onChanged: _onProjectChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<_LandReportOption>(
                      label: 'Type Of Land',
                      title: 'Select Type Of Land',
                      placeholderText: 'Select Type Of Land',
                      items: _typeOptions,
                      value: _selectedType,
                      enabled:
                          !_loading && !_generating && _selectedProject != null,
                      itemLabelBuilder: (_LandReportOption option) => option.label,
                      onChanged: _onTypeChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<_LandReportOption>(
                      label: 'Sub Category',
                      title: 'Select Sub Category',
                      placeholderText: 'Select Sub Category',
                      items: _subCategoryOptions,
                      value: _selectedSubCategory,
                      enabled:
                          !_loading && !_generating && _selectedType != null,
                      itemLabelBuilder: (_LandReportOption option) => option.label,
                      onChanged: (_LandReportOption value) {
                        setState(() => _selectedSubCategory = value);
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: hasFilters && !_loading && !_generating
                                ? _clearFilters
                                : null,
                            child: const Text('Clear Filter'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: canGenerate ? _generateReport : null,
                            child: _generating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Generate Report'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadProjects({String? categoryFk}) async {
    setState(() => _loading = true);
    try {
      final List<Map<String, dynamic>> rows =
          await widget.dataSource.fetchLandReportProjectList(
        categoryFk: categoryFk,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _projectOptions = _dedupeOptions(rows.map(_projectOption));
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load projects',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onProjectChanged(_LandReportOption project) async {
    setState(() {
      _selectedProject = project;
      _selectedType = null;
      _selectedSubCategory = null;
      _typeOptions = <_LandReportOption>[];
      _subCategoryOptions = <_LandReportOption>[];
    });
    await _loadTypes(project.value);
  }

  Future<void> _loadTypes(String projectIdFk) async {
    setState(() => _loading = true);
    try {
      final List<Map<String, dynamic>> rows =
          await widget.dataSource.fetchLandReportTypeList(
        projectIdFk: projectIdFk,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _typeOptions = _dedupeOptions(rows.map(_typeOption));
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load land types',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onTypeChanged(_LandReportOption type) async {
    setState(() {
      _selectedType = type;
      _selectedSubCategory = null;
      _subCategoryOptions = <_LandReportOption>[];
    });
    final String? projectId = _selectedProject?.value;
    if (projectId == null) {
      return;
    }
    await _loadSubCategories(projectIdFk: projectId, categoryFk: type.value);
    await _loadProjects(categoryFk: type.value);
  }

  Future<void> _loadSubCategories({
    required String projectIdFk,
    required String categoryFk,
  }) async {
    setState(() => _loading = true);
    try {
      final List<Map<String, dynamic>> rows =
          await widget.dataSource.fetchLandReportSubCategoryList(
        projectIdFk: projectIdFk,
        categoryFk: categoryFk,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _subCategoryOptions = _dedupeOptions(rows.map(_subCategoryOption));
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load sub categories',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _clearFilters() async {
    setState(() {
      _selectedProject = null;
      _selectedType = null;
      _selectedSubCategory = null;
      _typeOptions = <_LandReportOption>[];
      _subCategoryOptions = <_LandReportOption>[];
    });
    await _loadProjects();
  }

  Future<void> _generateReport() async {
    final _LandReportOption? project = _selectedProject;
    final _LandReportOption? type = _selectedType;
    final _LandReportOption? subCategory = _selectedSubCategory;
    if (project == null || type == null || subCategory == null) {
      return;
    }

    setState(() => _generating = true);
    try {
      final ({Uint8List bytes, String? fileName}) result =
          await widget.dataSource.generateLandAcquisitionReport(
        projectIdFk: project.value,
        categoryFk: type.value,
        laSubCategoryFk: subCategory.value,
      );
      if (result.bytes.isEmpty) {
        throw Exception('Empty report received from server.');
      }
      final String fileName = result.fileName?.trim().isNotEmpty == true
          ? result.fileName!.trim()
          : 'land_acquisition_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final String path = await ReportFileExport.save(
        fileName: fileName,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        bytes: result.bytes,
      );
      if (!mounted) {
        return;
      }
      await ReportFileExport.showGeneratedDialog(
        context: context,
        savedPath: path,
        bytes: result.bytes,
        fileName: fileName,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Generate Failed',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _generating = false);
      }
    }
  }

  List<_LandReportOption> _dedupeOptions(
    Iterable<_LandReportOption?> options,
  ) {
    final Map<String, _LandReportOption> unique = <String, _LandReportOption>{};
    for (final _LandReportOption? option in options) {
      if (option == null || option.value.isEmpty) {
        continue;
      }
      unique.putIfAbsent(option.value, () => option);
    }
    final List<_LandReportOption> sorted = unique.values.toList()
      ..sort(
        (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
      );
    return sorted;
  }

  _LandReportOption? _projectOption(Map<String, dynamic> row) {
    final String id = _string(row['project_id']).isNotEmpty
        ? _string(row['project_id'])
        : _string(row['project_id_fk']);
    if (id.isEmpty) {
      return null;
    }
    final String label = _string(row['project_name']).isEmpty ? id : _string(row['project_name']);
    return _LandReportOption(value: id, label: label);
  }

  _LandReportOption? _typeOption(Map<String, dynamic> row) {
    final String value = _string(row['category_fk']);
    if (value.isEmpty) {
      return null;
    }
    return _LandReportOption(value: value, label: value);
  }

  _LandReportOption? _subCategoryOption(Map<String, dynamic> row) {
    final String value = _string(row['la_sub_category_fk']);
    if (value.isEmpty) {
      return null;
    }
    final String label = _string(row['la_sub_category']).isEmpty
        ? value
        : _string(row['la_sub_category']);
    return _LandReportOption(value: value, label: label);
  }

  String _string(dynamic value) => value?.toString().trim() ?? '';
}
