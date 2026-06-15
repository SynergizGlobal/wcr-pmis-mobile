import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/create_rfi/dropdown_item.dart';
import '../../domain/executives/executive.dart';
import '../../domain/assign_executive/assign_executive_log.dart';
import '../../providers/assign_executive/assign_executive_provider.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/table_pagination_footer.dart';
import '../../core/widgets/global_alert_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';

class AssignExecutiveScreen extends ConsumerStatefulWidget {
  const AssignExecutiveScreen({super.key});

  @override
  ConsumerState<AssignExecutiveScreen> createState() =>
      _AssignExecutiveScreenState();
}

class _AssignExecutiveScreenState extends ConsumerState<AssignExecutiveScreen> {
  int _rowsPerPage = 5;
  int _currentPage = 0;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(assignExecutiveFormProvider);
    final notifier = ref.read(assignExecutiveFormProvider.notifier);

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: RfiTheme.scaffoldBackground(context),
      appBar: AppBar(
        title: const Text('Assign Executive'),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => notifier.refresh(),
          child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          children: [
            _buildSectionHeader('ASSIGN EXECUTIVE PAGE'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  _buildDropdownRow(
                    left: AppDropdown<DropdownItem>(
                      label: 'Project',
                      hint: 'Select...',
                      items: formState.projects,
                      value: formState.selectedProject,
                      onChanged: notifier.selectProject,
                      itemLabel: (e) => e.name,
                    ),
                    right: AppDropdown<DropdownItem>(
                      label: 'Contract',
                      hint: 'Select...',
                      items: formState.contracts,
                      value: formState.selectedContract,
                      onChanged: notifier.selectContract,
                      itemLabel: (e) => e.name,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownRow(
                    left: AppDropdown<DropdownItem>(
                      label: 'Structure Type',
                      hint: 'Select...',
                      items: formState.structureTypes,
                      value: formState.selectedStructureType,
                      onChanged: notifier.selectStructureType,
                      itemLabel: (e) => e.name,
                    ),
                    right: AppDropdown<DropdownItem>(
                      label: 'Structure',
                      hint: 'Select...',
                      items: formState.structures,
                      value: formState.selectedStructure,
                      onChanged: notifier.selectStructure,
                      itemLabel: (e) => e.name,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownRow(
                    left: AppDropdown<Executive>(
                      label: 'Assign Executive',
                      hint: 'Select Executives',
                      items: formState.executives,
                      value: formState.selectedExecutive,
                      onChanged: notifier.selectExecutive,
                      itemLabel: (e) => e.userName,
                    ),
                    right: const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 140,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: formState.isSubmitting
                            ? null
                            : () async {
                                final ok = await notifier.submit();
                                if (!context.mounted) return;
                                GlobalAlertDialog.show(
                                  context,
                                  title: ok ? 'Success' : 'Action failed',
                                  message: ok
                                      ? 'Executive assigned successfully!'
                                      : 'Please fill all fields or try again.',
                                  type:
                                      ok ? DialogType.success : DialogType.error,
                                );
                              },
                        style: RfiTheme.destructiveElevated(
                          Theme.of(context).colorScheme,
                        ).copyWith(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        child: formState.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Submit',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildSectionHeader('ASSIGN EXECUTIVE LOG'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: _buildLogTable(
                  formState.logs, formState.isLoadingLogs, notifier),
            ),

          ],
        ),
      ),
    ),
  ),
);
}

  Widget _buildSectionHeader(String title) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
        ),
      ),
    );
  }

  Widget _buildDropdownRow({required Widget left, required Widget right}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 16),
              Expanded(child: right),
            ],
          );
        }
        return Column(
          children: [left, const SizedBox(height: 12), right],
        );
      },
    );
  }

  Widget _buildLogTable(
    List<AssignExecutiveLog> allLogs,
    bool isLoading,
    dynamic notifier,
  ) {
    final filteredLogs = _searchQuery.isEmpty
        ? allLogs
        : allLogs.where((log) {
            final q = _searchQuery.toLowerCase();
            return log.contract.toLowerCase().contains(q) ||
                log.structureType.toLowerCase().contains(q) ||
                log.structure.toLowerCase().contains(q) ||
                log.assignedExecutive.toLowerCase().contains(q);
          }).toList();

    final totalPages = (filteredLogs.length / _rowsPerPage).ceil();
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filteredLogs.length);
    final pageData = filteredLogs.isEmpty
        ? <AssignExecutiveLog>[]
        : filteredLogs.sublist(startIndex, endIndex);

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? cellStyle = RfiTheme.tableCellTextStyle(textTheme, scheme);
    final TextStyle? headerStyle = RfiTheme.tableHeaderTextStyle(textTheme, scheme);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: TextField(
            decoration: RfiTheme.searchFieldDecoration(
              context,
              hintText: 'Search...',
            ).copyWith(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            style: Theme.of(context).textTheme.bodySmall,
            onChanged: (v) => setState(() {
              _searchQuery = v;
              _currentPage = 0;
            }),
          ),
        ),
        const SizedBox(height: 8),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                RfiTheme.tableHeaderBackground(scheme),
              ),
              headingTextStyle: headerStyle,
              dataTextStyle: cellStyle,
              columnSpacing: 16,
              columns: <DataColumn>[
                DataColumn(label: Text('Contract', style: headerStyle)),
                DataColumn(label: Text('Structure Type', style: headerStyle)),
                DataColumn(label: Text('Structure', style: headerStyle)),
                DataColumn(
                    label: Text('Assigned Executive', style: headerStyle)),
                DataColumn(label: Text('Action', style: headerStyle)),
              ],
              rows: pageData.isEmpty
                  ? <DataRow>[
                      DataRow(cells: <DataCell>[
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                        DataCell(Center(
                          child: Text(
                            'No assignments found.',
                            style: cellStyle?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        )),
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                      ]),
                    ]
                  : pageData.map((log) {
                      return DataRow(cells: [
                        DataCell(SizedBox(
                            width: 200,
                            child: Text(log.contract, style: cellStyle))),
                        DataCell(Text(log.structureType, style: cellStyle)),
                        DataCell(Text(log.structure, style: cellStyle)),
                        DataCell(Text(log.assignedExecutive, style: cellStyle)),
                        DataCell(
                          ElevatedButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text(
                                      'Are you sure you want to delete this assignment?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final ok =
                                    await notifier.deleteAssignment(log.id);
                                 if (!mounted) return;
                                 GlobalAlertDialog.show(
                                   context,
                                   title: ok ? 'Success' : 'Action failed',
                                   message: ok
                                       ? 'Deleted successfully!'
                                       : 'Failed to delete.',
                                   type:
                                       ok ? DialogType.success : DialogType.error,
                                 );
                               }
                             },
                            style: RfiTheme.destructiveElevated(scheme).copyWith(
                              padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              minimumSize:
                                  const WidgetStatePropertyAll(Size(0, 30)),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            child: const Text('Delete',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                        ),
                      ]);
                    }).toList(),
            ),
          ),

        const SizedBox(height: 8),
        TablePaginationFooter(
          startIndex: startIndex,
          endIndex: endIndex,
          totalItems: filteredLogs.length,
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
}
