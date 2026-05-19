import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/inspection/inspection_item.dart';
import '../../domain/inspection/enclosure_checklist.dart';

part 'inspection_form_state.freezed.dart';

@freezed
class MeasurementRow with _$MeasurementRow {
  const factory MeasurementRow({
    @Default('Select') String type,
    @Default('Select U') String units,
    @Default('') String l,
    @Default('') String b,
    @Default('') String h,
    @Default('') String weight,
    @Default('') String no,
    @Default(0.0) double totalQty,
  }) = _MeasurementRow;
}

@freezed
class InspectionFormState with _$InspectionFormState {
  const factory InspectionFormState({
    InspectionItem? rfiDetails,
    @Default(1) int currentStep,
    @Default(false) bool isLoading,
    String? error,

    // Step 1
    String? selfiePath,
    @Default('') String chainage,

    // Step 2
    @Default('') String location,
    String? dateOfInspection,
    String? timeOfInspection,
    @Default('') String contractorRepresentative,
    @Default([]) List<String> siteImagePaths,
    @Default([]) List<String> enclosurePaths, // PDFs
    @Default([]) List<String> supportingDocPaths,
    @Default('') String contractorDescription,
    @Default('') String clientDescription,
    @Default('') String engineerRemarks,
    @Default('Select') String inspectionStatus,
    @Default([MeasurementRow()]) List<MeasurementRow> measurements,
    @Default('Select') String testInSiteLab,
    @Default(false) bool hasSigned,
    @Default(false) bool isSubmitting,
    @Default(false) bool isUploadingFile,
    @Default(false) bool isDraftSaving,
    @Default(false) bool isLocationLoading,
    @Default(false) bool locationPermissionDenied,
    @Default({}) Map<String, bool> enclosureHasChecklist,
    @Default({}) Map<String, List<ChecklistItem>> enclosureChecklists,
    @Default({}) Map<String, String> enclosureGrades,
    @Default(false) bool isSavingChecklist,
    String? draftSavedAt,
  }) = _InspectionFormState;
}
