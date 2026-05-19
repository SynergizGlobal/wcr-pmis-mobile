part of 'rfi_details_provider.dart';

@freezed

class RfiDetailsState with _$RfiDetailsState {
  const factory RfiDetailsState({
    @Default(true) bool isLoading,
    String? errorMessage,
    RfiDetailModel? detailModel,
    @Default([]) List<RfiInspectionModel> inspections,
    @Default({}) Map<String, List<EnclosureChecklistItem>> enclosureChecklists,
    @Default({}) Set<String> enclosuresWithNoChecklist,
  }) = _RfiDetailsState;
}
