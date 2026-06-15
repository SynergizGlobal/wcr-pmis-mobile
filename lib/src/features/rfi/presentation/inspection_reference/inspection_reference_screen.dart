import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/inspection_reference/enclosure_name.dart';
import '../../domain/inspection_reference/reference_form_item.dart';
import '../../providers/inspection_reference/inspection_reference_provider.dart';
import '../../providers/inspection_reference/inspection_reference_state.dart';
import '../../core/widgets/app_dropdown.dart';
import 'widgets/enclosure_form_dialog.dart';
import 'widgets/checklist_description_form_dialog.dart';
import 'widgets/reference_form_dialog.dart';
import '../../core/widgets/table_pagination_footer.dart';
import '../../core/widgets/global_alert_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';

class InspectionReferenceScreen extends ConsumerStatefulWidget {
  const InspectionReferenceScreen({super.key});

  @override
  ConsumerState<InspectionReferenceScreen> createState() =>
      _InspectionReferenceScreenState();
}

class _InspectionReferenceScreenState
    extends ConsumerState<InspectionReferenceScreen> {
  int _rowsPerPage = 10;
  int _currentPage = 0;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(inspectionReferenceNotifierProvider);
    final notifier = ref.read(inspectionReferenceNotifierProvider.notifier);

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: RfiTheme.scaffoldBackground(context),
      appBar: AppBar(
        title: const Text('Inspection Reference Form'),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => notifier.refresh(),
          child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormSelectionRow(formState, notifier),
                  const SizedBox(height: 16),
                  _buildDataSection(formState, notifier),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  ),
);
}

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildFormSelectionRow(
    InspectionReferenceState formState,
    InspectionReferenceNotifier notifier,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        AppDropdown<FormType>(
          label: 'Select Form:',
          hint: '-- Select --',
          value: formState.selectedFormType,
          items: FormType.values,
          itemLabel: _formTypeLabel,
          width: 220,
          onChanged: (val) {
            setState(() {
              _currentPage = 0;
              _searchQuery = '';
            });
            notifier.selectFormType(val);
          },
        ),

        if (formState.selectedFormType == FormType.checklistDescription)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppDropdown<EnclosureName>(
                  label: 'Sub Option *',
                  hint: 'Select Sub Option',
                  value: formState.selectedSubOption,
                  items: formState.subOptions,
                  itemLabel: (EnclosureName option) => option.encloserName,
                  onChanged: (EnclosureName? newValue) {
                    setState(() {
                      _currentPage = 0;
                      _searchQuery = '';
                    });
                    ref
                        .read(inspectionReferenceNotifierProvider.notifier)
                        .selectSubOption(newValue);
                  },
                ),
              ),
              const SizedBox(width: 16),
              if (formState.selectedSubOption != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        ChecklistDescriptionFormDialog.show(context, ref),
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text('Add New',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildDataSection(
    InspectionReferenceState formState,
    InspectionReferenceNotifier notifier,
  ) {
    if (formState.isLoadingInitial || formState.isLoadingList) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (formState.selectedFormType == null) {
      return _buildInitialOpenTable(formState.initialEnclosureNames);
    }

    switch (formState.selectedFormType!) {
      case FormType.rfiEnclosureList:
        return _buildEnclosureListTable(formState.enclosureList);
      case FormType.checklistDescription:
        return _buildChecklistDescriptionTable(formState);
      case FormType.referenceForm:
        return _buildReferenceFormTable(formState.referenceFormItems);
    }
  }

  Widget _buildInitialOpenTable(List<EnclosureName> allItems) {
    final filtered = _applySearch(
      allItems,
      (item) =>
          item.encloserName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (item.action ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()),
    );

    return _buildPaginatedTable(
      filteredLength: filtered.length,
      columns: const [
        DataColumn(
            label: Text('Sr No',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        DataColumn(
            label: Text('Enclosure Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        DataColumn(
            label: Text('Action Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
      ],
      rowBuilder: (pageData) {
        final startIdx = _currentPage * _rowsPerPage;
        return pageData.asMap().entries.map((entry) {
          final item = entry.value;
          return DataRow(cells: [
            DataCell(Text('${startIdx + entry.key + 1}',
                style: const TextStyle(fontSize: 12))),
            DataCell(
                Text(item.encloserName, style: const TextStyle(fontSize: 12))),
            DataCell(
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.action == 'OPEN'
                      ? const Color(0xFF28A745)
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.action ?? '-',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ]);
        }).toList();
      },
      filtered: filtered,
      emptyMessage: 'No enclosure names found.',
    );
  }

  Widget _buildEnclosureListTable(List<EnclosureName> allItems) {
    final filtered = _applySearch(
      allItems,
      (item) =>
          item.encloserName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (item.action ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()),
    );

    return _buildPaginatedTable(
      filteredLength: filtered.length,
      customAction: ElevatedButton.icon(
        onPressed: () => EnclosureFormDialog.show(context, ref),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add New'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF009688),
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 34),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      columns: const [
        DataColumn(
            label: Text('Sr No',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        DataColumn(
            label: Text('Enclosure Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        DataColumn(
            label: Text('Action Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        DataColumn(
            label: Text('Action',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
      ],
      rowBuilder: (pageData) {
        final startIdx = _currentPage * _rowsPerPage;
        return pageData.asMap().entries.map((entry) {
          final item = entry.value;
          return DataRow(cells: [
            DataCell(Text('${startIdx + entry.key + 1}',
                style: const TextStyle(fontSize: 12))),
            DataCell(
                Text(item.encloserName, style: const TextStyle(fontSize: 12))),
            DataCell(
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.action == 'OPEN'
                      ? const Color(0xFF28A745)
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.action ?? '-',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            DataCell(_buildEditDeleteActions(
              item.id,
              item.encloserName,
              onEdit: () => EnclosureFormDialog.show(context, ref, item),
              onDelete: () => ref
                  .read(inspectionReferenceNotifierProvider.notifier)
                  .deleteEnclosure(item.id),
            )),
          ]);
        }).toList();
      },
      filtered: filtered,
      emptyMessage: 'No enclosure items found.',
    );
  }

  Widget _buildChecklistDescriptionTable(InspectionReferenceState formState) {
    if (formState.selectedSubOption == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Please select a Sub Option to view checklist descriptions.',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    final subTitle =
        'Checklist for: ${formState.selectedSubOption!.encloserName}';
    final allItems = formState.checklistDetails;
    final filtered = _applySearch(
      allItems,
      (item) => item.checklistDescription
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()),
    );

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: const BoxDecoration(
            border:
                Border(left: BorderSide(color: Color(0xFF00897B), width: 4)),
          ),
          child: Text(
            subTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00897B),
            ),
          ),
        ),

        _buildPaginatedTable(
          filteredLength: filtered.length,
          columns: const [
            DataColumn(
                label: Text('S. No',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            DataColumn(
                label: Text('Reference Description',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            DataColumn(
                label: Text('Actions',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          ],
          rowBuilder: (pageData) {
            final startIdx = _currentPage * _rowsPerPage;
            return pageData.asMap().entries.map((entry) {
              final item = entry.value;
              return DataRow(cells: [
                DataCell(Text('${startIdx + entry.key + 1}',
                    style: const TextStyle(fontSize: 12))),
                DataCell(SizedBox(
                  width: 350,
                  child: Text(item.checklistDescription,
                      style: const TextStyle(fontSize: 12)),
                )),
                DataCell(_buildEditDeleteActions(
                  item.id,
                  item.checklistDescription,
                  onEdit: () =>
                      ChecklistDescriptionFormDialog.show(context, ref, item),
                  onDelete: () => ref
                      .read(inspectionReferenceNotifierProvider.notifier)
                      .deleteChecklistDescription(item.id),
                )),
              ]);
            }).toList();
          },
          filtered: filtered,
          emptyMessage: 'No checklist descriptions found.',
        ),
      ],
    );
  }

  Widget _buildReferenceFormTable(List<ReferenceFormItem> allItems) {
    final filtered = _applySearch(
      allItems,
      (item) =>
          item.activity.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.rfiDescription
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          item.enclosures.toLowerCase().contains(_searchQuery.toLowerCase()),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () => ReferenceFormDialog.show(context, ref),
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text('Add New',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPaginatedTable(
          filteredLength: filtered.length,
          columns: const [
            DataColumn(
                label: Text('Id',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            DataColumn(
                label: Text('Activity',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            DataColumn(
                label: Text('RFI Description',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            DataColumn(
                label: Text('Enclosures',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            DataColumn(
                label: Text('Action',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          ],
          rowBuilder: (pageData) {
            return pageData.asMap().entries.map((entry) {
              final item = entry.value;
              return DataRow(cells: [
                DataCell(
                    Text('${item.id}', style: const TextStyle(fontSize: 12))),
                DataCell(
                    Text(item.activity, style: const TextStyle(fontSize: 12))),
                DataCell(SizedBox(
                  width: 200,
                  child: Text(item.rfiDescription,
                      style: const TextStyle(fontSize: 12)),
                )),
                DataCell(SizedBox(
                  width: 200,
                  child: Text(item.enclosures,
                      style: const TextStyle(fontSize: 12)),
                )),
                DataCell(_buildEditDeleteActions(
                  item.id,
                  item.rfiDescription,
                  onEdit: () => ReferenceFormDialog.show(context, ref, item),
                  hideDelete:
                      true, // Only Edit is required per the provided info
                )),
              ]);
            }).toList();
          },
          filtered: filtered,
          emptyMessage: 'No reference form items found.',
        ),
      ],
    );
  }


  Widget _buildEditDeleteActions(int id, String name,
      {VoidCallback? onEdit,
      Future<void> Function()? onDelete,
      bool hideDelete = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          child: ElevatedButton(
            onPressed: () {
              if (onEdit != null) {
                onEdit();
              } else {
                GlobalAlertDialog.show(
                  context,
                  title: 'Edit',
                  message: 'Edit: $name (id: $id)',
                  type: DialogType.info,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: const Size(0, 28),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('Edit',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
        if (!hideDelete) ...[
          const SizedBox(width: 6),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: Text('Are you sure you want to delete "$name"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  if (onDelete != null) {
                    await onDelete();
                    if (!mounted) return;
                    GlobalAlertDialog.show(
                      context,
                      title: 'Success',
                      message: 'Delete successful',
                      type: DialogType.success,
                    );
                  } else {
                    if (!mounted) return;
                    GlobalAlertDialog.show(
                      context,
                      title: 'Delete',
                      message: 'Delete: $name (id: $id)',
                      type: DialogType.info,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: const Size(0, 28),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaginatedTable<T>({
    required int filteredLength,
    required List<DataColumn> columns,
    required List<DataRow> Function(List<T> pageData) rowBuilder,
    required List<T> filtered,
    required String emptyMessage,
    Widget? customAction,
  }) {
    final totalPages = (filteredLength / _rowsPerPage).ceil();
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filteredLength);
    final pageData =
        filtered.isEmpty ? <T>[] : filtered.sublist(startIndex, endIndex);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            spacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 140,
                    height: 34,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: const TextStyle(fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4)),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: (v) => setState(() {
                        _searchQuery = v;
                        _currentPage = 0;
                      }),
                    ),
                  ),
                  if (customAction != null) ...<Widget>[
                    const SizedBox(width: 8),
                    customAction,
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFE8E8E8)),
            columnSpacing: 16,
            columns: columns,
            rows: pageData.isEmpty
                ? [
                    DataRow(
                      cells: List.generate(
                        columns.length,
                        (i) => DataCell(
                          i == columns.length ~/ 2
                              ? Center(
                                  child: Text(
                                    emptyMessage,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : const Text(''),
                        ),
                      ),
                    ),
                  ]
                : rowBuilder(pageData),
          ),
        ),

        const SizedBox(height: 8),
        TablePaginationFooter(
          startIndex: startIndex,
          endIndex: endIndex,
          totalItems: filtered.length,
          currentPage: _currentPage + 1,
          totalPages: totalPages == 0 ? 1 : totalPages,
          pageSize: _rowsPerPage,
          onPageSizeChanged: (int value) => setState(() {
            _rowsPerPage = value;
            _currentPage = 0;
          }),
          onPageChanged: (page) => setState(() => _currentPage = page - 1),
        ),
      ],
    );
  }

  String _formTypeLabel(FormType type) {
    switch (type) {
      case FormType.rfiEnclosureList:
        return 'RFI Enclosure List';
      case FormType.checklistDescription:
        return 'Checklist Description';
      case FormType.referenceForm:
        return 'Reference Form';
    }
  }

  List<T> _applySearch<T>(List<T> items, bool Function(T) predicate) {
    if (_searchQuery.isEmpty) return items;
    return items.where(predicate).toList();
  }
}
