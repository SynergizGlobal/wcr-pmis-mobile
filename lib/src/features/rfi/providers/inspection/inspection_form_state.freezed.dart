// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MeasurementRow {
  String get type => throw _privateConstructorUsedError;
  String get units => throw _privateConstructorUsedError;
  String get l => throw _privateConstructorUsedError;
  String get b => throw _privateConstructorUsedError;
  String get h => throw _privateConstructorUsedError;
  String get weight => throw _privateConstructorUsedError;
  String get no => throw _privateConstructorUsedError;
  double get totalQty => throw _privateConstructorUsedError;

  /// Create a copy of MeasurementRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeasurementRowCopyWith<MeasurementRow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasurementRowCopyWith<$Res> {
  factory $MeasurementRowCopyWith(
    MeasurementRow value,
    $Res Function(MeasurementRow) then,
  ) = _$MeasurementRowCopyWithImpl<$Res, MeasurementRow>;
  @useResult
  $Res call({
    String type,
    String units,
    String l,
    String b,
    String h,
    String weight,
    String no,
    double totalQty,
  });
}

/// @nodoc
class _$MeasurementRowCopyWithImpl<$Res, $Val extends MeasurementRow>
    implements $MeasurementRowCopyWith<$Res> {
  _$MeasurementRowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeasurementRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? units = null,
    Object? l = null,
    Object? b = null,
    Object? h = null,
    Object? weight = null,
    Object? no = null,
    Object? totalQty = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            units: null == units
                ? _value.units
                : units // ignore: cast_nullable_to_non_nullable
                      as String,
            l: null == l
                ? _value.l
                : l // ignore: cast_nullable_to_non_nullable
                      as String,
            b: null == b
                ? _value.b
                : b // ignore: cast_nullable_to_non_nullable
                      as String,
            h: null == h
                ? _value.h
                : h // ignore: cast_nullable_to_non_nullable
                      as String,
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as String,
            no: null == no
                ? _value.no
                : no // ignore: cast_nullable_to_non_nullable
                      as String,
            totalQty: null == totalQty
                ? _value.totalQty
                : totalQty // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MeasurementRowImplCopyWith<$Res>
    implements $MeasurementRowCopyWith<$Res> {
  factory _$$MeasurementRowImplCopyWith(
    _$MeasurementRowImpl value,
    $Res Function(_$MeasurementRowImpl) then,
  ) = __$$MeasurementRowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    String units,
    String l,
    String b,
    String h,
    String weight,
    String no,
    double totalQty,
  });
}

/// @nodoc
class __$$MeasurementRowImplCopyWithImpl<$Res>
    extends _$MeasurementRowCopyWithImpl<$Res, _$MeasurementRowImpl>
    implements _$$MeasurementRowImplCopyWith<$Res> {
  __$$MeasurementRowImplCopyWithImpl(
    _$MeasurementRowImpl _value,
    $Res Function(_$MeasurementRowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MeasurementRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? units = null,
    Object? l = null,
    Object? b = null,
    Object? h = null,
    Object? weight = null,
    Object? no = null,
    Object? totalQty = null,
  }) {
    return _then(
      _$MeasurementRowImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        units: null == units
            ? _value.units
            : units // ignore: cast_nullable_to_non_nullable
                  as String,
        l: null == l
            ? _value.l
            : l // ignore: cast_nullable_to_non_nullable
                  as String,
        b: null == b
            ? _value.b
            : b // ignore: cast_nullable_to_non_nullable
                  as String,
        h: null == h
            ? _value.h
            : h // ignore: cast_nullable_to_non_nullable
                  as String,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as String,
        no: null == no
            ? _value.no
            : no // ignore: cast_nullable_to_non_nullable
                  as String,
        totalQty: null == totalQty
            ? _value.totalQty
            : totalQty // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$MeasurementRowImpl implements _MeasurementRow {
  const _$MeasurementRowImpl({
    this.type = 'Select',
    this.units = 'Select U',
    this.l = '',
    this.b = '',
    this.h = '',
    this.weight = '',
    this.no = '',
    this.totalQty = 0.0,
  });

  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final String units;
  @override
  @JsonKey()
  final String l;
  @override
  @JsonKey()
  final String b;
  @override
  @JsonKey()
  final String h;
  @override
  @JsonKey()
  final String weight;
  @override
  @JsonKey()
  final String no;
  @override
  @JsonKey()
  final double totalQty;

  @override
  String toString() {
    return 'MeasurementRow(type: $type, units: $units, l: $l, b: $b, h: $h, weight: $weight, no: $no, totalQty: $totalQty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasurementRowImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.units, units) || other.units == units) &&
            (identical(other.l, l) || other.l == l) &&
            (identical(other.b, b) || other.b == b) &&
            (identical(other.h, h) || other.h == h) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.no, no) || other.no == no) &&
            (identical(other.totalQty, totalQty) ||
                other.totalQty == totalQty));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, type, units, l, b, h, weight, no, totalQty);

  /// Create a copy of MeasurementRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasurementRowImplCopyWith<_$MeasurementRowImpl> get copyWith =>
      __$$MeasurementRowImplCopyWithImpl<_$MeasurementRowImpl>(
        this,
        _$identity,
      );
}

abstract class _MeasurementRow implements MeasurementRow {
  const factory _MeasurementRow({
    final String type,
    final String units,
    final String l,
    final String b,
    final String h,
    final String weight,
    final String no,
    final double totalQty,
  }) = _$MeasurementRowImpl;

  @override
  String get type;
  @override
  String get units;
  @override
  String get l;
  @override
  String get b;
  @override
  String get h;
  @override
  String get weight;
  @override
  String get no;
  @override
  double get totalQty;

  /// Create a copy of MeasurementRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeasurementRowImplCopyWith<_$MeasurementRowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$InspectionFormState {
  InspectionItem? get rfiDetails => throw _privateConstructorUsedError;
  int get currentStep => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError; // Step 1
  String? get selfiePath => throw _privateConstructorUsedError;
  String get chainage => throw _privateConstructorUsedError; // Step 2
  String get location => throw _privateConstructorUsedError;
  String? get dateOfInspection => throw _privateConstructorUsedError;
  String? get timeOfInspection => throw _privateConstructorUsedError;
  String get contractorRepresentative => throw _privateConstructorUsedError;
  List<String> get siteImagePaths => throw _privateConstructorUsedError;
  List<String> get enclosurePaths => throw _privateConstructorUsedError; // PDFs
  List<SupportingDocument> get supportingDocuments =>
      throw _privateConstructorUsedError;
  String get contractorDescription => throw _privateConstructorUsedError;
  String get clientDescription => throw _privateConstructorUsedError;
  String get engineerRemarks => throw _privateConstructorUsedError;
  String get inspectionStatus => throw _privateConstructorUsedError;
  List<MeasurementRow> get measurements => throw _privateConstructorUsedError;
  String get testInSiteLab => throw _privateConstructorUsedError;
  bool get hasSigned => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  bool get isUploadingFile => throw _privateConstructorUsedError;
  bool get isDraftSaving => throw _privateConstructorUsedError;
  bool get isLocationLoading => throw _privateConstructorUsedError;
  bool get locationPermissionDenied => throw _privateConstructorUsedError;
  Map<String, bool> get enclosureHasChecklist =>
      throw _privateConstructorUsedError;
  Map<String, List<ChecklistItem>> get enclosureChecklists =>
      throw _privateConstructorUsedError;
  Map<String, String> get enclosureGrades => throw _privateConstructorUsedError;
  bool get isSavingChecklist => throw _privateConstructorUsedError;
  String? get draftSavedAt => throw _privateConstructorUsedError;

  /// Create a copy of InspectionFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InspectionFormStateCopyWith<InspectionFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InspectionFormStateCopyWith<$Res> {
  factory $InspectionFormStateCopyWith(
    InspectionFormState value,
    $Res Function(InspectionFormState) then,
  ) = _$InspectionFormStateCopyWithImpl<$Res, InspectionFormState>;
  @useResult
  $Res call({
    InspectionItem? rfiDetails,
    int currentStep,
    bool isLoading,
    String? error,
    String? selfiePath,
    String chainage,
    String location,
    String? dateOfInspection,
    String? timeOfInspection,
    String contractorRepresentative,
    List<String> siteImagePaths,
    List<String> enclosurePaths,
    List<SupportingDocument> supportingDocuments,
    String contractorDescription,
    String clientDescription,
    String engineerRemarks,
    String inspectionStatus,
    List<MeasurementRow> measurements,
    String testInSiteLab,
    bool hasSigned,
    bool isSubmitting,
    bool isUploadingFile,
    bool isDraftSaving,
    bool isLocationLoading,
    bool locationPermissionDenied,
    Map<String, bool> enclosureHasChecklist,
    Map<String, List<ChecklistItem>> enclosureChecklists,
    Map<String, String> enclosureGrades,
    bool isSavingChecklist,
    String? draftSavedAt,
  });

  $InspectionItemCopyWith<$Res>? get rfiDetails;
}

/// @nodoc
class _$InspectionFormStateCopyWithImpl<$Res, $Val extends InspectionFormState>
    implements $InspectionFormStateCopyWith<$Res> {
  _$InspectionFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InspectionFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rfiDetails = freezed,
    Object? currentStep = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? selfiePath = freezed,
    Object? chainage = null,
    Object? location = null,
    Object? dateOfInspection = freezed,
    Object? timeOfInspection = freezed,
    Object? contractorRepresentative = null,
    Object? siteImagePaths = null,
    Object? enclosurePaths = null,
    Object? supportingDocuments = null,
    Object? contractorDescription = null,
    Object? clientDescription = null,
    Object? engineerRemarks = null,
    Object? inspectionStatus = null,
    Object? measurements = null,
    Object? testInSiteLab = null,
    Object? hasSigned = null,
    Object? isSubmitting = null,
    Object? isUploadingFile = null,
    Object? isDraftSaving = null,
    Object? isLocationLoading = null,
    Object? locationPermissionDenied = null,
    Object? enclosureHasChecklist = null,
    Object? enclosureChecklists = null,
    Object? enclosureGrades = null,
    Object? isSavingChecklist = null,
    Object? draftSavedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            rfiDetails: freezed == rfiDetails
                ? _value.rfiDetails
                : rfiDetails // ignore: cast_nullable_to_non_nullable
                      as InspectionItem?,
            currentStep: null == currentStep
                ? _value.currentStep
                : currentStep // ignore: cast_nullable_to_non_nullable
                      as int,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            selfiePath: freezed == selfiePath
                ? _value.selfiePath
                : selfiePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            chainage: null == chainage
                ? _value.chainage
                : chainage // ignore: cast_nullable_to_non_nullable
                      as String,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String,
            dateOfInspection: freezed == dateOfInspection
                ? _value.dateOfInspection
                : dateOfInspection // ignore: cast_nullable_to_non_nullable
                      as String?,
            timeOfInspection: freezed == timeOfInspection
                ? _value.timeOfInspection
                : timeOfInspection // ignore: cast_nullable_to_non_nullable
                      as String?,
            contractorRepresentative: null == contractorRepresentative
                ? _value.contractorRepresentative
                : contractorRepresentative // ignore: cast_nullable_to_non_nullable
                      as String,
            siteImagePaths: null == siteImagePaths
                ? _value.siteImagePaths
                : siteImagePaths // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            enclosurePaths: null == enclosurePaths
                ? _value.enclosurePaths
                : enclosurePaths // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            supportingDocuments: null == supportingDocuments
                ? _value.supportingDocuments
                : supportingDocuments // ignore: cast_nullable_to_non_nullable
                      as List<SupportingDocument>,
            contractorDescription: null == contractorDescription
                ? _value.contractorDescription
                : contractorDescription // ignore: cast_nullable_to_non_nullable
                      as String,
            clientDescription: null == clientDescription
                ? _value.clientDescription
                : clientDescription // ignore: cast_nullable_to_non_nullable
                      as String,
            engineerRemarks: null == engineerRemarks
                ? _value.engineerRemarks
                : engineerRemarks // ignore: cast_nullable_to_non_nullable
                      as String,
            inspectionStatus: null == inspectionStatus
                ? _value.inspectionStatus
                : inspectionStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            measurements: null == measurements
                ? _value.measurements
                : measurements // ignore: cast_nullable_to_non_nullable
                      as List<MeasurementRow>,
            testInSiteLab: null == testInSiteLab
                ? _value.testInSiteLab
                : testInSiteLab // ignore: cast_nullable_to_non_nullable
                      as String,
            hasSigned: null == hasSigned
                ? _value.hasSigned
                : hasSigned // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSubmitting: null == isSubmitting
                ? _value.isSubmitting
                : isSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            isUploadingFile: null == isUploadingFile
                ? _value.isUploadingFile
                : isUploadingFile // ignore: cast_nullable_to_non_nullable
                      as bool,
            isDraftSaving: null == isDraftSaving
                ? _value.isDraftSaving
                : isDraftSaving // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLocationLoading: null == isLocationLoading
                ? _value.isLocationLoading
                : isLocationLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            locationPermissionDenied: null == locationPermissionDenied
                ? _value.locationPermissionDenied
                : locationPermissionDenied // ignore: cast_nullable_to_non_nullable
                      as bool,
            enclosureHasChecklist: null == enclosureHasChecklist
                ? _value.enclosureHasChecklist
                : enclosureHasChecklist // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
            enclosureChecklists: null == enclosureChecklists
                ? _value.enclosureChecklists
                : enclosureChecklists // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<ChecklistItem>>,
            enclosureGrades: null == enclosureGrades
                ? _value.enclosureGrades
                : enclosureGrades // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            isSavingChecklist: null == isSavingChecklist
                ? _value.isSavingChecklist
                : isSavingChecklist // ignore: cast_nullable_to_non_nullable
                      as bool,
            draftSavedAt: freezed == draftSavedAt
                ? _value.draftSavedAt
                : draftSavedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of InspectionFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InspectionItemCopyWith<$Res>? get rfiDetails {
    if (_value.rfiDetails == null) {
      return null;
    }

    return $InspectionItemCopyWith<$Res>(_value.rfiDetails!, (value) {
      return _then(_value.copyWith(rfiDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InspectionFormStateImplCopyWith<$Res>
    implements $InspectionFormStateCopyWith<$Res> {
  factory _$$InspectionFormStateImplCopyWith(
    _$InspectionFormStateImpl value,
    $Res Function(_$InspectionFormStateImpl) then,
  ) = __$$InspectionFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    InspectionItem? rfiDetails,
    int currentStep,
    bool isLoading,
    String? error,
    String? selfiePath,
    String chainage,
    String location,
    String? dateOfInspection,
    String? timeOfInspection,
    String contractorRepresentative,
    List<String> siteImagePaths,
    List<String> enclosurePaths,
    List<SupportingDocument> supportingDocuments,
    String contractorDescription,
    String clientDescription,
    String engineerRemarks,
    String inspectionStatus,
    List<MeasurementRow> measurements,
    String testInSiteLab,
    bool hasSigned,
    bool isSubmitting,
    bool isUploadingFile,
    bool isDraftSaving,
    bool isLocationLoading,
    bool locationPermissionDenied,
    Map<String, bool> enclosureHasChecklist,
    Map<String, List<ChecklistItem>> enclosureChecklists,
    Map<String, String> enclosureGrades,
    bool isSavingChecklist,
    String? draftSavedAt,
  });

  @override
  $InspectionItemCopyWith<$Res>? get rfiDetails;
}

/// @nodoc
class __$$InspectionFormStateImplCopyWithImpl<$Res>
    extends _$InspectionFormStateCopyWithImpl<$Res, _$InspectionFormStateImpl>
    implements _$$InspectionFormStateImplCopyWith<$Res> {
  __$$InspectionFormStateImplCopyWithImpl(
    _$InspectionFormStateImpl _value,
    $Res Function(_$InspectionFormStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InspectionFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rfiDetails = freezed,
    Object? currentStep = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? selfiePath = freezed,
    Object? chainage = null,
    Object? location = null,
    Object? dateOfInspection = freezed,
    Object? timeOfInspection = freezed,
    Object? contractorRepresentative = null,
    Object? siteImagePaths = null,
    Object? enclosurePaths = null,
    Object? supportingDocuments = null,
    Object? contractorDescription = null,
    Object? clientDescription = null,
    Object? engineerRemarks = null,
    Object? inspectionStatus = null,
    Object? measurements = null,
    Object? testInSiteLab = null,
    Object? hasSigned = null,
    Object? isSubmitting = null,
    Object? isUploadingFile = null,
    Object? isDraftSaving = null,
    Object? isLocationLoading = null,
    Object? locationPermissionDenied = null,
    Object? enclosureHasChecklist = null,
    Object? enclosureChecklists = null,
    Object? enclosureGrades = null,
    Object? isSavingChecklist = null,
    Object? draftSavedAt = freezed,
  }) {
    return _then(
      _$InspectionFormStateImpl(
        rfiDetails: freezed == rfiDetails
            ? _value.rfiDetails
            : rfiDetails // ignore: cast_nullable_to_non_nullable
                  as InspectionItem?,
        currentStep: null == currentStep
            ? _value.currentStep
            : currentStep // ignore: cast_nullable_to_non_nullable
                  as int,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        selfiePath: freezed == selfiePath
            ? _value.selfiePath
            : selfiePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        chainage: null == chainage
            ? _value.chainage
            : chainage // ignore: cast_nullable_to_non_nullable
                  as String,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String,
        dateOfInspection: freezed == dateOfInspection
            ? _value.dateOfInspection
            : dateOfInspection // ignore: cast_nullable_to_non_nullable
                  as String?,
        timeOfInspection: freezed == timeOfInspection
            ? _value.timeOfInspection
            : timeOfInspection // ignore: cast_nullable_to_non_nullable
                  as String?,
        contractorRepresentative: null == contractorRepresentative
            ? _value.contractorRepresentative
            : contractorRepresentative // ignore: cast_nullable_to_non_nullable
                  as String,
        siteImagePaths: null == siteImagePaths
            ? _value._siteImagePaths
            : siteImagePaths // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        enclosurePaths: null == enclosurePaths
            ? _value._enclosurePaths
            : enclosurePaths // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        supportingDocuments: null == supportingDocuments
            ? _value._supportingDocuments
            : supportingDocuments // ignore: cast_nullable_to_non_nullable
                  as List<SupportingDocument>,
        contractorDescription: null == contractorDescription
            ? _value.contractorDescription
            : contractorDescription // ignore: cast_nullable_to_non_nullable
                  as String,
        clientDescription: null == clientDescription
            ? _value.clientDescription
            : clientDescription // ignore: cast_nullable_to_non_nullable
                  as String,
        engineerRemarks: null == engineerRemarks
            ? _value.engineerRemarks
            : engineerRemarks // ignore: cast_nullable_to_non_nullable
                  as String,
        inspectionStatus: null == inspectionStatus
            ? _value.inspectionStatus
            : inspectionStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        measurements: null == measurements
            ? _value._measurements
            : measurements // ignore: cast_nullable_to_non_nullable
                  as List<MeasurementRow>,
        testInSiteLab: null == testInSiteLab
            ? _value.testInSiteLab
            : testInSiteLab // ignore: cast_nullable_to_non_nullable
                  as String,
        hasSigned: null == hasSigned
            ? _value.hasSigned
            : hasSigned // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSubmitting: null == isSubmitting
            ? _value.isSubmitting
            : isSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        isUploadingFile: null == isUploadingFile
            ? _value.isUploadingFile
            : isUploadingFile // ignore: cast_nullable_to_non_nullable
                  as bool,
        isDraftSaving: null == isDraftSaving
            ? _value.isDraftSaving
            : isDraftSaving // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLocationLoading: null == isLocationLoading
            ? _value.isLocationLoading
            : isLocationLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        locationPermissionDenied: null == locationPermissionDenied
            ? _value.locationPermissionDenied
            : locationPermissionDenied // ignore: cast_nullable_to_non_nullable
                  as bool,
        enclosureHasChecklist: null == enclosureHasChecklist
            ? _value._enclosureHasChecklist
            : enclosureHasChecklist // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
        enclosureChecklists: null == enclosureChecklists
            ? _value._enclosureChecklists
            : enclosureChecklists // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<ChecklistItem>>,
        enclosureGrades: null == enclosureGrades
            ? _value._enclosureGrades
            : enclosureGrades // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        isSavingChecklist: null == isSavingChecklist
            ? _value.isSavingChecklist
            : isSavingChecklist // ignore: cast_nullable_to_non_nullable
                  as bool,
        draftSavedAt: freezed == draftSavedAt
            ? _value.draftSavedAt
            : draftSavedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$InspectionFormStateImpl implements _InspectionFormState {
  const _$InspectionFormStateImpl({
    this.rfiDetails,
    this.currentStep = 1,
    this.isLoading = false,
    this.error,
    this.selfiePath,
    this.chainage = '',
    this.location = '',
    this.dateOfInspection,
    this.timeOfInspection,
    this.contractorRepresentative = '',
    final List<String> siteImagePaths = const [],
    final List<String> enclosurePaths = const [],
    final List<SupportingDocument> supportingDocuments = const [],
    this.contractorDescription = '',
    this.clientDescription = '',
    this.engineerRemarks = '',
    this.inspectionStatus = 'Select',
    final List<MeasurementRow> measurements = const [MeasurementRow()],
    this.testInSiteLab = 'Select',
    this.hasSigned = false,
    this.isSubmitting = false,
    this.isUploadingFile = false,
    this.isDraftSaving = false,
    this.isLocationLoading = false,
    this.locationPermissionDenied = false,
    final Map<String, bool> enclosureHasChecklist = const {},
    final Map<String, List<ChecklistItem>> enclosureChecklists = const {},
    final Map<String, String> enclosureGrades = const {},
    this.isSavingChecklist = false,
    this.draftSavedAt,
  }) : _siteImagePaths = siteImagePaths,
       _enclosurePaths = enclosurePaths,
       _supportingDocuments = supportingDocuments,
       _measurements = measurements,
       _enclosureHasChecklist = enclosureHasChecklist,
       _enclosureChecklists = enclosureChecklists,
       _enclosureGrades = enclosureGrades;

  @override
  final InspectionItem? rfiDetails;
  @override
  @JsonKey()
  final int currentStep;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  // Step 1
  @override
  final String? selfiePath;
  @override
  @JsonKey()
  final String chainage;
  // Step 2
  @override
  @JsonKey()
  final String location;
  @override
  final String? dateOfInspection;
  @override
  final String? timeOfInspection;
  @override
  @JsonKey()
  final String contractorRepresentative;
  final List<String> _siteImagePaths;
  @override
  @JsonKey()
  List<String> get siteImagePaths {
    if (_siteImagePaths is EqualUnmodifiableListView) return _siteImagePaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_siteImagePaths);
  }

  final List<String> _enclosurePaths;
  @override
  @JsonKey()
  List<String> get enclosurePaths {
    if (_enclosurePaths is EqualUnmodifiableListView) return _enclosurePaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_enclosurePaths);
  }

  // PDFs
  final List<SupportingDocument> _supportingDocuments;
  // PDFs
  @override
  @JsonKey()
  List<SupportingDocument> get supportingDocuments {
    if (_supportingDocuments is EqualUnmodifiableListView)
      return _supportingDocuments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_supportingDocuments);
  }

  @override
  @JsonKey()
  final String contractorDescription;
  @override
  @JsonKey()
  final String clientDescription;
  @override
  @JsonKey()
  final String engineerRemarks;
  @override
  @JsonKey()
  final String inspectionStatus;
  final List<MeasurementRow> _measurements;
  @override
  @JsonKey()
  List<MeasurementRow> get measurements {
    if (_measurements is EqualUnmodifiableListView) return _measurements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_measurements);
  }

  @override
  @JsonKey()
  final String testInSiteLab;
  @override
  @JsonKey()
  final bool hasSigned;
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  @JsonKey()
  final bool isUploadingFile;
  @override
  @JsonKey()
  final bool isDraftSaving;
  @override
  @JsonKey()
  final bool isLocationLoading;
  @override
  @JsonKey()
  final bool locationPermissionDenied;
  final Map<String, bool> _enclosureHasChecklist;
  @override
  @JsonKey()
  Map<String, bool> get enclosureHasChecklist {
    if (_enclosureHasChecklist is EqualUnmodifiableMapView)
      return _enclosureHasChecklist;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_enclosureHasChecklist);
  }

  final Map<String, List<ChecklistItem>> _enclosureChecklists;
  @override
  @JsonKey()
  Map<String, List<ChecklistItem>> get enclosureChecklists {
    if (_enclosureChecklists is EqualUnmodifiableMapView)
      return _enclosureChecklists;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_enclosureChecklists);
  }

  final Map<String, String> _enclosureGrades;
  @override
  @JsonKey()
  Map<String, String> get enclosureGrades {
    if (_enclosureGrades is EqualUnmodifiableMapView) return _enclosureGrades;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_enclosureGrades);
  }

  @override
  @JsonKey()
  final bool isSavingChecklist;
  @override
  final String? draftSavedAt;

  @override
  String toString() {
    return 'InspectionFormState(rfiDetails: $rfiDetails, currentStep: $currentStep, isLoading: $isLoading, error: $error, selfiePath: $selfiePath, chainage: $chainage, location: $location, dateOfInspection: $dateOfInspection, timeOfInspection: $timeOfInspection, contractorRepresentative: $contractorRepresentative, siteImagePaths: $siteImagePaths, enclosurePaths: $enclosurePaths, supportingDocuments: $supportingDocuments, contractorDescription: $contractorDescription, clientDescription: $clientDescription, engineerRemarks: $engineerRemarks, inspectionStatus: $inspectionStatus, measurements: $measurements, testInSiteLab: $testInSiteLab, hasSigned: $hasSigned, isSubmitting: $isSubmitting, isUploadingFile: $isUploadingFile, isDraftSaving: $isDraftSaving, isLocationLoading: $isLocationLoading, locationPermissionDenied: $locationPermissionDenied, enclosureHasChecklist: $enclosureHasChecklist, enclosureChecklists: $enclosureChecklists, enclosureGrades: $enclosureGrades, isSavingChecklist: $isSavingChecklist, draftSavedAt: $draftSavedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InspectionFormStateImpl &&
            (identical(other.rfiDetails, rfiDetails) ||
                other.rfiDetails == rfiDetails) &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.selfiePath, selfiePath) ||
                other.selfiePath == selfiePath) &&
            (identical(other.chainage, chainage) ||
                other.chainage == chainage) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.dateOfInspection, dateOfInspection) ||
                other.dateOfInspection == dateOfInspection) &&
            (identical(other.timeOfInspection, timeOfInspection) ||
                other.timeOfInspection == timeOfInspection) &&
            (identical(
                  other.contractorRepresentative,
                  contractorRepresentative,
                ) ||
                other.contractorRepresentative == contractorRepresentative) &&
            const DeepCollectionEquality().equals(
              other._siteImagePaths,
              _siteImagePaths,
            ) &&
            const DeepCollectionEquality().equals(
              other._enclosurePaths,
              _enclosurePaths,
            ) &&
            const DeepCollectionEquality().equals(
              other._supportingDocuments,
              _supportingDocuments,
            ) &&
            (identical(other.contractorDescription, contractorDescription) ||
                other.contractorDescription == contractorDescription) &&
            (identical(other.clientDescription, clientDescription) ||
                other.clientDescription == clientDescription) &&
            (identical(other.engineerRemarks, engineerRemarks) ||
                other.engineerRemarks == engineerRemarks) &&
            (identical(other.inspectionStatus, inspectionStatus) ||
                other.inspectionStatus == inspectionStatus) &&
            const DeepCollectionEquality().equals(
              other._measurements,
              _measurements,
            ) &&
            (identical(other.testInSiteLab, testInSiteLab) ||
                other.testInSiteLab == testInSiteLab) &&
            (identical(other.hasSigned, hasSigned) ||
                other.hasSigned == hasSigned) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.isUploadingFile, isUploadingFile) ||
                other.isUploadingFile == isUploadingFile) &&
            (identical(other.isDraftSaving, isDraftSaving) ||
                other.isDraftSaving == isDraftSaving) &&
            (identical(other.isLocationLoading, isLocationLoading) ||
                other.isLocationLoading == isLocationLoading) &&
            (identical(
                  other.locationPermissionDenied,
                  locationPermissionDenied,
                ) ||
                other.locationPermissionDenied == locationPermissionDenied) &&
            const DeepCollectionEquality().equals(
              other._enclosureHasChecklist,
              _enclosureHasChecklist,
            ) &&
            const DeepCollectionEquality().equals(
              other._enclosureChecklists,
              _enclosureChecklists,
            ) &&
            const DeepCollectionEquality().equals(
              other._enclosureGrades,
              _enclosureGrades,
            ) &&
            (identical(other.isSavingChecklist, isSavingChecklist) ||
                other.isSavingChecklist == isSavingChecklist) &&
            (identical(other.draftSavedAt, draftSavedAt) ||
                other.draftSavedAt == draftSavedAt));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    rfiDetails,
    currentStep,
    isLoading,
    error,
    selfiePath,
    chainage,
    location,
    dateOfInspection,
    timeOfInspection,
    contractorRepresentative,
    const DeepCollectionEquality().hash(_siteImagePaths),
    const DeepCollectionEquality().hash(_enclosurePaths),
    const DeepCollectionEquality().hash(_supportingDocuments),
    contractorDescription,
    clientDescription,
    engineerRemarks,
    inspectionStatus,
    const DeepCollectionEquality().hash(_measurements),
    testInSiteLab,
    hasSigned,
    isSubmitting,
    isUploadingFile,
    isDraftSaving,
    isLocationLoading,
    locationPermissionDenied,
    const DeepCollectionEquality().hash(_enclosureHasChecklist),
    const DeepCollectionEquality().hash(_enclosureChecklists),
    const DeepCollectionEquality().hash(_enclosureGrades),
    isSavingChecklist,
    draftSavedAt,
  ]);

  /// Create a copy of InspectionFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InspectionFormStateImplCopyWith<_$InspectionFormStateImpl> get copyWith =>
      __$$InspectionFormStateImplCopyWithImpl<_$InspectionFormStateImpl>(
        this,
        _$identity,
      );
}

abstract class _InspectionFormState implements InspectionFormState {
  const factory _InspectionFormState({
    final InspectionItem? rfiDetails,
    final int currentStep,
    final bool isLoading,
    final String? error,
    final String? selfiePath,
    final String chainage,
    final String location,
    final String? dateOfInspection,
    final String? timeOfInspection,
    final String contractorRepresentative,
    final List<String> siteImagePaths,
    final List<String> enclosurePaths,
    final List<SupportingDocument> supportingDocuments,
    final String contractorDescription,
    final String clientDescription,
    final String engineerRemarks,
    final String inspectionStatus,
    final List<MeasurementRow> measurements,
    final String testInSiteLab,
    final bool hasSigned,
    final bool isSubmitting,
    final bool isUploadingFile,
    final bool isDraftSaving,
    final bool isLocationLoading,
    final bool locationPermissionDenied,
    final Map<String, bool> enclosureHasChecklist,
    final Map<String, List<ChecklistItem>> enclosureChecklists,
    final Map<String, String> enclosureGrades,
    final bool isSavingChecklist,
    final String? draftSavedAt,
  }) = _$InspectionFormStateImpl;

  @override
  InspectionItem? get rfiDetails;
  @override
  int get currentStep;
  @override
  bool get isLoading;
  @override
  String? get error; // Step 1
  @override
  String? get selfiePath;
  @override
  String get chainage; // Step 2
  @override
  String get location;
  @override
  String? get dateOfInspection;
  @override
  String? get timeOfInspection;
  @override
  String get contractorRepresentative;
  @override
  List<String> get siteImagePaths;
  @override
  List<String> get enclosurePaths; // PDFs
  @override
  List<SupportingDocument> get supportingDocuments;
  @override
  String get contractorDescription;
  @override
  String get clientDescription;
  @override
  String get engineerRemarks;
  @override
  String get inspectionStatus;
  @override
  List<MeasurementRow> get measurements;
  @override
  String get testInSiteLab;
  @override
  bool get hasSigned;
  @override
  bool get isSubmitting;
  @override
  bool get isUploadingFile;
  @override
  bool get isDraftSaving;
  @override
  bool get isLocationLoading;
  @override
  bool get locationPermissionDenied;
  @override
  Map<String, bool> get enclosureHasChecklist;
  @override
  Map<String, List<ChecklistItem>> get enclosureChecklists;
  @override
  Map<String, String> get enclosureGrades;
  @override
  bool get isSavingChecklist;
  @override
  String? get draftSavedAt;

  /// Create a copy of InspectionFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InspectionFormStateImplCopyWith<_$InspectionFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
