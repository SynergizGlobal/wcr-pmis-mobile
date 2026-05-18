import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_dropdown_item.dart';

class CreateRfiState {
  const CreateRfiState({
    this.isLoadingItems = false,
    this.projects = const <RfiDropdownItem>[],
    this.contracts = const <RfiDropdownItem>[],
    this.structureTypes = const <RfiDropdownItem>[],
    this.structures = const <RfiDropdownItem>[],
    this.components = const <RfiDropdownItem>[],
    this.elements = const <RfiDropdownItem>[],
    this.activities = const <RfiDropdownItem>[],
    this.rfiDescriptions = const <RfiDropdownItem>[],
    this.representatives = const <RfiDropdownItem>[],
    this.selectedProject,
    this.selectedContract,
    this.selectedStructureType,
    this.selectedStructure,
    this.selectedComponent,
    this.selectedElement,
    this.selectedActivity,
    this.selectedRfiDescription,
    this.currentStep = 0,
    this.action,
    this.typeOfRfi,
    this.contractorRepresentative,
    this.dateOfSubmission,
    this.timeOfInspection,
    this.dateOfInspection,
    this.selectedEnclosures = const <String>[],
    this.rfiDescriptionText,
    this.isDraftSaving = false,
    this.isSubmitting = false,
    this.initialLoadError,
    this.errorMessage,
  });

  final bool isLoadingItems;
  final List<RfiDropdownItem> projects;
  final List<RfiDropdownItem> contracts;
  final List<RfiDropdownItem> structureTypes;
  final List<RfiDropdownItem> structures;
  final List<RfiDropdownItem> components;
  final List<RfiDropdownItem> elements;
  final List<RfiDropdownItem> activities;
  final List<RfiDropdownItem> rfiDescriptions;
  final List<RfiDropdownItem> representatives;

  final RfiDropdownItem? selectedProject;
  final RfiDropdownItem? selectedContract;
  final RfiDropdownItem? selectedStructureType;
  final RfiDropdownItem? selectedStructure;
  final RfiDropdownItem? selectedComponent;
  final RfiDropdownItem? selectedElement;
  final RfiDropdownItem? selectedActivity;
  final RfiDropdownItem? selectedRfiDescription;

  final int currentStep;
  final String? action;
  final String? typeOfRfi;
  final String? contractorRepresentative;
  final String? dateOfSubmission;
  final String? timeOfInspection;
  final String? dateOfInspection;
  final List<String> selectedEnclosures;
  final String? rfiDescriptionText;

  final bool isDraftSaving;
  final bool isSubmitting;
  final String? initialLoadError;
  final String? errorMessage;

  CreateRfiState copyWith({
    bool? isLoadingItems,
    List<RfiDropdownItem>? projects,
    List<RfiDropdownItem>? contracts,
    List<RfiDropdownItem>? structureTypes,
    List<RfiDropdownItem>? structures,
    List<RfiDropdownItem>? components,
    List<RfiDropdownItem>? elements,
    List<RfiDropdownItem>? activities,
    List<RfiDropdownItem>? rfiDescriptions,
    List<RfiDropdownItem>? representatives,
    RfiDropdownItem? selectedProject,
    bool clearSelectedProject = false,
    RfiDropdownItem? selectedContract,
    bool clearSelectedContract = false,
    RfiDropdownItem? selectedStructureType,
    bool clearSelectedStructureType = false,
    RfiDropdownItem? selectedStructure,
    bool clearSelectedStructure = false,
    RfiDropdownItem? selectedComponent,
    bool clearSelectedComponent = false,
    RfiDropdownItem? selectedElement,
    bool clearSelectedElement = false,
    RfiDropdownItem? selectedActivity,
    bool clearSelectedActivity = false,
    RfiDropdownItem? selectedRfiDescription,
    bool clearSelectedRfiDescription = false,
    int? currentStep,
    String? action,
    String? typeOfRfi,
    String? contractorRepresentative,
    String? dateOfSubmission,
    String? timeOfInspection,
    String? dateOfInspection,
    List<String>? selectedEnclosures,
    String? rfiDescriptionText,
    bool? isDraftSaving,
    bool? isSubmitting,
    String? initialLoadError,
    bool clearInitialLoadError = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CreateRfiState(
      isLoadingItems: isLoadingItems ?? this.isLoadingItems,
      projects: projects ?? this.projects,
      contracts: contracts ?? this.contracts,
      structureTypes: structureTypes ?? this.structureTypes,
      structures: structures ?? this.structures,
      components: components ?? this.components,
      elements: elements ?? this.elements,
      activities: activities ?? this.activities,
      rfiDescriptions: rfiDescriptions ?? this.rfiDescriptions,
      representatives: representatives ?? this.representatives,
      selectedProject: clearSelectedProject
          ? null
          : (selectedProject ?? this.selectedProject),
      selectedContract: clearSelectedContract
          ? null
          : (selectedContract ?? this.selectedContract),
      selectedStructureType: clearSelectedStructureType
          ? null
          : (selectedStructureType ?? this.selectedStructureType),
      selectedStructure: clearSelectedStructure
          ? null
          : (selectedStructure ?? this.selectedStructure),
      selectedComponent: clearSelectedComponent
          ? null
          : (selectedComponent ?? this.selectedComponent),
      selectedElement: clearSelectedElement
          ? null
          : (selectedElement ?? this.selectedElement),
      selectedActivity: clearSelectedActivity
          ? null
          : (selectedActivity ?? this.selectedActivity),
      selectedRfiDescription: clearSelectedRfiDescription
          ? null
          : (selectedRfiDescription ?? this.selectedRfiDescription),
      currentStep: currentStep ?? this.currentStep,
      action: action ?? this.action,
      typeOfRfi: typeOfRfi ?? this.typeOfRfi,
      contractorRepresentative:
          contractorRepresentative ?? this.contractorRepresentative,
      dateOfSubmission: dateOfSubmission ?? this.dateOfSubmission,
      timeOfInspection: timeOfInspection ?? this.timeOfInspection,
      dateOfInspection: dateOfInspection ?? this.dateOfInspection,
      selectedEnclosures: selectedEnclosures ?? this.selectedEnclosures,
      rfiDescriptionText: rfiDescriptionText ?? this.rfiDescriptionText,
      isDraftSaving: isDraftSaving ?? this.isDraftSaving,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      initialLoadError: clearInitialLoadError
          ? null
          : (initialLoadError ?? this.initialLoadError),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
