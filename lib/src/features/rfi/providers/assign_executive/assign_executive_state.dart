import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/assign_executive/assign_executive_log.dart';
import '../../domain/create_rfi/dropdown_item.dart';
import '../../domain/executives/executive.dart';

part 'assign_executive_state.freezed.dart';

@freezed
class AssignExecutiveState with _$AssignExecutiveState {
  const factory AssignExecutiveState({
    @Default(false) bool isLoadingItems,
    @Default(false) bool isSubmitting,
    @Default(false) bool isLoadingLogs,

    @Default([]) List<DropdownItem> projects,
    @Default([]) List<DropdownItem> works,
    @Default([]) List<DropdownItem> contracts,
    @Default([]) List<DropdownItem> structureTypes,
    @Default([]) List<DropdownItem> structures,
    @Default([]) List<Executive> executives,

    DropdownItem? selectedProject,
    DropdownItem? selectedWork,
    DropdownItem? selectedContract,
    DropdownItem? selectedStructureType,
    DropdownItem? selectedStructure,
    Executive? selectedExecutive,

    @Default([]) List<AssignExecutiveLog> logs,
  }) = _AssignExecutiveState;
}
