import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import '../../data/inspection/inspection_repository.dart';
import '../../core/providers/dio_provider.dart';
import '../../core/providers/shared_prefs_provider.dart';
import '../../core/services/inspection_submit_pdf_builder.dart';
import '../../core/utils/final_submit_payload.dart';
import '../../core/utils/txn_id.dart';
import '../../core/utils/user_role.dart';
import '../auth/auth_provider.dart';
import '../../domain/inspection/inspection_item.dart';
import '../../domain/inspection/enclosure_checklist.dart';
import 'inspection_form_state.dart';

final inspectionFormProvider = StateNotifierProvider.family<
    InspectionFormNotifier, InspectionFormState, int>((ref, rfiId) {
  final repository = ref.watch(inspectionRepositoryProvider);
  return InspectionFormNotifier(ref, repository, rfiId);
});

class InspectionFormNotifier extends StateNotifier<InspectionFormState> {
  final Ref _ref;
  final InspectionRepository _repository;
  final int _rfiId;

  InspectionFormNotifier(this._ref, this._repository, this._rfiId)
      : super(const InspectionFormState()) {
    _init();
  }

  String get _draftKey =>
      "inspection_draft_${_rfiId}_${_ref.read(authNotifierProvider).value?['userId']}";

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final details = await _repository.getRfiDetails(_rfiId);
      
      String? initialChainage;
      String? initialContractorDesc;
      if (details.inspectionDetails != null && details.inspectionDetails!.isNotEmpty) {
        final lastDetail = details.inspectionDetails!.first;
        initialChainage = lastDetail.chainage;
        
        if (lastDetail.descriptionEnclosure != null && 
            lastDetail.descriptionEnclosure!.isNotEmpty &&
            lastDetail.descriptionEnclosure != lastDetail.location) {
          initialContractorDesc = lastDetail.descriptionEnclosure;
        }
      }

      if (initialContractorDesc == null || initialContractorDesc.isEmpty) {
        initialContractorDesc = details.description;
      }

      List<MeasurementRow> initialMeasurements = state.measurements;
      if (initialMeasurements.length == 1 && initialMeasurements.first.type == 'Select') {
        if (details.measurements != null) {
          final m = details.measurements!;
          initialMeasurements = [
            MeasurementRow(
              type: m.measurementType ?? 'Select',
              units: m.units ?? 'nos',
              l: m.length?.toString() ?? '',
              b: m.breadth?.toString() ?? '',
              h: m.height?.toString() ?? '',
              weight: m.weight?.toString() ?? '',
              no: m.noOfItems?.toString() ?? '',
              totalQty: m.totalQty ?? 0.0,
            )
          ];
        } else if (details.measurementType != null && details.measurementType!.isNotEmpty) {
          final type = details.measurementType!;
          final qty = details.totalQty ?? 0.0;
          
          initialMeasurements = [
            MeasurementRow(
              type: type,
              units: 'nos', // Default for Number, or could be improved later
              totalQty: qty,
              no: type == 'Number' ? qty.toString() : '1',
              l: type == 'Number' ? '' : qty.toString(), // Simplified fallback
            )
          ];
        }
      }

      state = state.copyWith(
        rfiDetails: details, 
        isLoading: false,
        chainage: state.chainage.isEmpty ? (initialChainage ?? "") : state.chainage,
        contractorDescription: state.contractorDescription.isEmpty ? (initialContractorDesc ?? "") : state.contractorDescription,
        measurements: initialMeasurements,
      );
      _loadDraft();
      _checkEnclosuresChecklistAvailability(details);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _checkEnclosuresChecklistAvailability(InspectionItem details) async {
    final enclosures = details.enclosuresList ?? [];
    if (enclosures.isEmpty) return;

    final Map<String, bool> statusMap = Map.from(state.enclosureHasChecklist);
    final Map<String, List<ChecklistItem>> checklistMap = Map.from(state.enclosureChecklists);
    final Map<String, String> gradeMap = Map.from(state.enclosureGrades);
    
    for (var enclosureName in enclosures) {
      try {
        final List<dynamic> rawItems = await _repository.getChecklistItems(enclosureName, _rfiId);
        final List<ChecklistItem> items = rawItems.map((json) => ChecklistItem.fromJson(json)).toList();
        
        statusMap[enclosureName] = items.isNotEmpty;
        if (items.isNotEmpty) {
          checklistMap[enclosureName] = items;
          final firstWithGrade = items.firstWhere((i) => i.gradeOfConcrete != null, orElse: () => const ChecklistItem());
          if (firstWithGrade.gradeOfConcrete != null) {
            gradeMap[enclosureName] = firstWithGrade.gradeOfConcrete!;
          }
        }
      } catch (_) {
        statusMap[enclosureName] = false;
      }
    }

    if (mounted) {
      state = state.copyWith(
        enclosureHasChecklist: statusMap,
        enclosureChecklists: checklistMap,
        enclosureGrades: gradeMap,
      );
    }
  }

  void _loadDraft() {
    final prefs = _ref.read(sharedPrefsProvider);
    final draftStr = prefs.getString(_draftKey);
    if (draftStr != null) {
      try {
        final data = jsonDecode(draftStr);
        
        final List<MeasurementRow> measurements = [];
        if (data['measurements'] != null) {
          for (var m in (data['measurements'] as List)) {
            measurements.add(MeasurementRow(
              type: m['type'] ?? 'Select',
              units: m['units'] ?? 'Select U',
              l: m['l'] ?? '',
              b: m['b'] ?? '',
              h: m['h'] ?? '',
              weight: m['weight'] ?? '',
              no: m['no'] ?? '',
              totalQty: (m['totalQty'] as num?)?.toDouble() ?? 0.0,
            ));
          }
        }

        state = state.copyWith(
          currentStep: data['currentStep'] ?? 1,
          chainage: data['chainage'] ?? '',
          location: data['location'] ?? '',
          contractorDescription: data['contractorDescription'] ?? '',
          clientDescription: data['clientDescription'] ?? '',
          engineerRemarks: data['engineerRemarks'] ?? '',
          inspectionStatus: data['inspectionStatus'] ?? 'Select',
          testInSiteLab: data['testInSiteLab'] ?? 'Select',
          measurements: measurements.isNotEmpty ? measurements : [const MeasurementRow()],
        );
      } catch (_) {}
    }
  }

  Future<void> saveDraft() async {
    state = state.copyWith(isDraftSaving: true);
    try {
      final data = {
        'currentStep': state.currentStep,
        'chainage': state.chainage,
        'location': state.location,
        'contractorDescription': state.contractorDescription,
        'clientDescription': state.clientDescription,
        'engineerRemarks': state.engineerRemarks,
        'inspectionStatus': state.inspectionStatus,
        'testInSiteLab': state.testInSiteLab,
        'measurements': state.measurements.map((m) => {
          'type': m.type,
          'units': m.units,
          'l': m.l,
          'b': m.b,
          'h': m.h,
          'weight': m.weight,
          'no': m.no,
          'totalQty': m.totalQty,
        }).toList(),
      };
      final prefs = _ref.read(sharedPrefsProvider);
      await prefs.setString(_draftKey, jsonEncode(data));
      state = state.copyWith(
          isDraftSaving: false, draftSavedAt: DateTime.now().toIso8601String());
    } catch (_) {
      state = state.copyWith(isDraftSaving: false);
    }
  }

  void updateStep(int step) {
    state = state.copyWith(currentStep: step);
    if (step == 2 && state.location.isEmpty) {
      fetchLocation();
    }
  }

  void updateChainage(String val) => state = state.copyWith(chainage: val);
  void updateLocation(String val) => state = state.copyWith(location: val);
  void updateContractorDescription(String val) =>
      state = state.copyWith(contractorDescription: val);
  void updateClientDescription(String val) =>
      state = state.copyWith(clientDescription: val);
  void updateInspectionStatus(String val) =>
      state = state.copyWith(inspectionStatus: val);

  void updateSelfie(String path) {
    var trimmed = path.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(selfiePath: null);
      return;
    }
    if (trimmed.startsWith('file:')) {
      try {
        trimmed = Uri.parse(trimmed).toFilePath();
      } catch (_) {
        /* keep trimmed as-is */
      }
    }
    state = state.copyWith(
      selfiePath: trimmed.isEmpty ? null : trimmed,
    );
  }
  void clearSelfie() => state = state.copyWith(selfiePath: null);

  void addSiteImage(String path) {
    state = state.copyWith(siteImagePaths: [...state.siteImagePaths, path]);
  }

  void removeSiteImage(int index) {
    final list = List<String>.from(state.siteImagePaths);
    list.removeAt(index);
    state = state.copyWith(siteImagePaths: list);
  }

  void addEnclosure(String path) {
    state = state.copyWith(enclosurePaths: [...state.enclosurePaths, path]);
  }

  void removeEnclosure(int index) {
    final list = List<String>.from(state.enclosurePaths);
    list.removeAt(index);
    state = state.copyWith(enclosurePaths: list);
  }

  void addSupportingDoc(String path, {String description = ''}) {
    state = state.copyWith(
      supportingDocuments: [
        ...state.supportingDocuments,
        SupportingDocument(path: path, description: description.trim()),
      ],
    );
  }

  void removeSupportingDoc(int index) {
    final list = List<SupportingDocument>.from(state.supportingDocuments);
    list.removeAt(index);
    state = state.copyWith(supportingDocuments: list);
  }

  void updateSupportingDocDescription(int index, String description) {
    final list = List<SupportingDocument>.from(state.supportingDocuments);
    if (index < 0 || index >= list.length) return;
    list[index] = SupportingDocument(
      path: list[index].path,
      description: description.trim(),
    );
    state = state.copyWith(supportingDocuments: list);
  }

  Future<void> uploadEnclosureRealtime(
      String path, String enclosureName) async {
    state = state.copyWith(isUploadingFile: true, error: null);
    try {
      final data = FormData.fromMap({
        'rfiId': _rfiId,
        'enclosureName': enclosureName,
        'file': await MultipartFile.fromFile(
          path,
          filename: p.basename(path),
        ),
      });

      await _repository.uploadEnclosure(data);
      await _init();
      state = state.copyWith(isUploadingFile: false);
    } catch (e) {
      state = state.copyWith(isUploadingFile: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteRemoteEnclosure(int enclosureId) async {
    state = state.copyWith(isUploadingFile: true, error: null);
    try {
      await _repository.deleteEnclosure(enclosureId);
      await _init(); // Refresh list after deletion
      state = state.copyWith(isUploadingFile: false);
    } catch (e) {
      state = state.copyWith(isUploadingFile: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> uploadSiteImageRealtime(String path) async {
    state = state.copyWith(isUploadingFile: true, error: null);
    try {
      final data = FormData.fromMap({
        'RfiId': _rfiId,
        'siteImage': await MultipartFile.fromFile(
          path,
          filename: p.basename(path),
        ),
      });

      await _repository.uploadSiteImage(data);
      await _init();
      state = state.copyWith(isUploadingFile: false);
    } catch (e) {
      state = state.copyWith(isUploadingFile: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteRemoteSiteImage(String imgPath, String uploadedBy) async {
    state = state.copyWith(isUploadingFile: true, error: null);
    try {
      await _repository.deleteSiteImage(
        rfiId: _rfiId,
        imgPath: imgPath,
        uploadedBy: uploadedBy,
      );
      await _init();
      state = state.copyWith(isUploadingFile: false);
    } catch (e) {
      state = state.copyWith(isUploadingFile: false, error: e.toString());
      rethrow;
    }
  }

  void addMeasurementRow() {
    state = state.copyWith(
        measurements: [...state.measurements, const MeasurementRow()]);
  }

  void updateMeasurement(int index, MeasurementRow row) {
    final list = List<MeasurementRow>.from(state.measurements);

    MeasurementRow updatedRow = row;
    if (index < state.measurements.length &&
        state.measurements[index].type != row.type) {
      String defaultUnit = 'Select U';
      switch (row.type) {
        case 'Area':
          defaultUnit = 'sqm';
          break;
        case 'Length':
          defaultUnit = 'm';
          break;
        case 'Volume':
          defaultUnit = 'cum';
          break;
        case 'Number':
          defaultUnit = "nos";
          break;
        case 'Weight':
          defaultUnit = 'kg';
          break;
      }
      updatedRow = row.copyWith(
        units: defaultUnit,
        l: '',
        b: '',
        h: '',
        weight: '',
        no: '',
      );
    }

    double total = 0.0;
    double l = double.tryParse(updatedRow.l) ?? 0.0;
    double b = double.tryParse(updatedRow.b) ?? 0.0;
    double h = double.tryParse(updatedRow.h) ?? 0.0;
    double w = double.tryParse(updatedRow.weight) ?? 0.0;
    double n = double.tryParse(updatedRow.no) ?? 1.0; // Default to 1 for multiplier

    switch (updatedRow.type) {
      case 'Area':
        total = l * b * n;
        break;
      case 'Length':
        total = l * n;
        break;
      case 'Volume':
        total = l * b * h * n;
        break;
      case 'Number':
        total = double.tryParse(updatedRow.no) ?? 0.0;
        break;
      case 'Weight':
        total = w * n;
        break;
    }

    list[index] = updatedRow.copyWith(totalQty: total);
    state = state.copyWith(measurements: list);
  }

  Future<void> fetchLocation() async {
    state = state.copyWith(
      isLocationLoading: true,
      locationPermissionDenied: false,
      error: null,
    );

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLocationLoading: false,
          error: 'Location services are disabled.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLocationLoading: false,
            locationPermissionDenied: true,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLocationLoading: false,
          locationPermissionDenied: true,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address =
            "${p.name}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}, ${p.postalCode}, ${p.country}";
        state = state.copyWith(
          location: address,
          isLocationLoading: false,
        );
      } else {
        state = state.copyWith(
          isLocationLoading: false,
          error: 'Could not resolve address.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLocationLoading: false,
        error: 'Error getting location: $e',
      );
    }
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }

  void updateEngineerRemarks(String val) {
    state = state.copyWith(engineerRemarks: val);
  }

  void updateTestInSiteLab(String val) {
    state = state.copyWith(testInSiteLab: val);
  }

  void updateHasSigned(bool val) {
    state = state.copyWith(hasSigned: val);
  }


  Future<void> refreshChecklist(String enclosureName) async {
    try {
      final List<dynamic> rawItems = await _repository.getChecklistItems(enclosureName, _rfiId);
      final List<ChecklistItem> items = rawItems.map((json) => ChecklistItem.fromJson(json)).toList();
      
      final checklistMap = Map<String, List<ChecklistItem>>.from(state.enclosureChecklists);
      final gradeMap = Map<String, String>.from(state.enclosureGrades);
      
      checklistMap[enclosureName] = items;
      if (items.isNotEmpty) {
        final firstWithGrade = items.firstWhere((i) => i.gradeOfConcrete != null, orElse: () => const ChecklistItem());
        if (firstWithGrade.gradeOfConcrete != null) {
          gradeMap[enclosureName] = firstWithGrade.gradeOfConcrete!;
        }
      }

      state = state.copyWith(
        enclosureChecklists: checklistMap,
        enclosureGrades: gradeMap,
      );
    } catch (e) {
      debugPrint('Error refreshing checklist: $e');
    }
  }

  void updateChecklistItemStatus(String enclosureName, int index, String? status, bool isContractor) {
    final checklists = Map<String, List<ChecklistItem>>.from(state.enclosureChecklists);
    final items = List<ChecklistItem>.from(checklists[enclosureName] ?? []);
    
    if (index < items.length) {
      items[index] = isContractor 
        ? items[index].copyWith(contractorStatus: status)
        : items[index].copyWith(engineerStatus: status);
      
      checklists[enclosureName] = items;
      state = state.copyWith(enclosureChecklists: checklists);
    }
  }

  void updateChecklistItemRemark(String enclosureName, int index, String remark, bool isContractor) {
    final checklists = Map<String, List<ChecklistItem>>.from(state.enclosureChecklists);
    final items = List<ChecklistItem>.from(checklists[enclosureName] ?? []);
    
    if (index < items.length) {
      items[index] = isContractor 
        ? items[index].copyWith(contractorRemarks: remark)
        : items[index].copyWith(engineerRemark: remark);
      
      checklists[enclosureName] = items;
      state = state.copyWith(enclosureChecklists: checklists);
    }
  }

  void updateEnclosureGrade(String enclosureName, String grade) {
    final grades = Map<String, String>.from(state.enclosureGrades);
    grades[enclosureName] = grade;
    state = state.copyWith(enclosureGrades: grades);
  }

  void selectAllStatus(String enclosureName, String? status, bool isContractor) {
    final checklists = Map<String, List<ChecklistItem>>.from(state.enclosureChecklists);
    final items = List<ChecklistItem>.from(checklists[enclosureName] ?? []);
    
    final finalStatus = status == 'CLEAR' ? null : status;

    for (int i = 0; i < items.length; i++) {
      items[i] = isContractor 
        ? items[i].copyWith(contractorStatus: finalStatus)
        : items[i].copyWith(engineerStatus: finalStatus);
    }
    
    checklists[enclosureName] = items;
    state = state.copyWith(enclosureChecklists: checklists);
  }

  Future<void> saveEnclosureChecklist(String enclosureName) async {
    state = state.copyWith(isSavingChecklist: true, error: null);
    try {
      final items = state.enclosureChecklists[enclosureName] ?? [];
      final grade = state.enclosureGrades[enclosureName] ?? "";
      final userData = _ref.read(authNotifierProvider).value;
      final role = UserRole.fromLoginResponse(userData ?? {});
      final isContractor = role == UserRole.contractor || role == UserRole.contractorRep;

      final payload = {
        "rfiId": _rfiId,
        "enclosureName": enclosureName,
        "gradeOfConcrete": grade,
        "uploadedBy": isContractor ? "CON" : "engg",
        "checklistRows": items.map((item) => {
          "checklistDescriptionId": item.checklistDescId,
          "description": item.checklistDescription,
          "contractorStatus": item.contractorStatus,
          "engineerStatus": item.engineerStatus,
          "contractorRemark": item.contractorRemarks ?? "",
          "aeRemark": item.engineerRemark ?? "",
        }).toList(),
      };

      debugPrint("Checklist Save Payload: ${jsonEncode(payload)}");
      
      final formData = FormData.fromMap({
        "data": jsonEncode(payload),
      });
      
      await _repository.saveEnclosureChecklist(formData);
      
      await refreshChecklist(enclosureName);
      
      state = state.copyWith(isSavingChecklist: false);
    } catch (e) {
      state = state.copyWith(isSavingChecklist: false, error: e.toString());
      rethrow;
    }
  }

  bool isChecklistCompleted(String enclosureName) {
    final items = state.enclosureChecklists[enclosureName] ?? [];
    if (items.isEmpty) return false;
    
    final userData = _ref.read(authNotifierProvider).value;
    final role = UserRole.fromLoginResponse(userData ?? {});

    if (role == UserRole.contractor || role == UserRole.contractorRep) {
      return items.every((item) => 
        item.contractorStatus != null && item.contractorStatus!.isNotEmpty
      );
    } else if (role == UserRole.engineer || role == UserRole.dyHodEngineer || role == UserRole.hod || role == UserRole.dyHod) {
      return items.every((item) => 
        item.engineerStatus != null && item.engineerStatus!.isNotEmpty
      );
    }

    return items.every((item) => 
      (item.contractorStatus != null && item.contractorStatus!.isNotEmpty) ||
      (item.engineerStatus != null && item.engineerStatus!.isNotEmpty)
    );
  }

  bool isChecklistStarted(String enclosureName) {
    final items = state.enclosureChecklists[enclosureName] ?? [];
    return items.any((item) => 
      (item.contractorStatus != null && item.contractorStatus!.isNotEmpty) ||
      (item.engineerStatus != null && item.engineerStatus!.isNotEmpty)
    );
  }

  bool checkIsStep2Valid(bool isOffline) {
    if (state.location.isEmpty) return false;

    final hasRemoteEnclosures =
        state.rfiDetails?.enclosure?.isNotEmpty ?? false;
    if (isOffline) {
      if (state.enclosurePaths.isEmpty && !hasRemoteEnclosures) return false;
    } else {
      final requiredEnclosureNames = (state.rfiDetails?.enclosuresList ?? [])
          .where((name) => !(state.enclosureHasChecklist[name] ?? false))
          .toList();

      if (requiredEnclosureNames.isNotEmpty) {
        final uploadedEnclosureNames = (state.rfiDetails?.enclosure ?? [])
            .map((e) => e.enclosureName?.trim())
            .whereType<String>()
            .where((name) => name.isNotEmpty)
            .toSet();

        final missingRequiredDocument = requiredEnclosureNames.any(
          (name) => !uploadedEnclosureNames.contains(name.trim()),
        );

        if (missingRequiredDocument) return false;
      }
    }

    final hasValidMeasurement = state.measurements.any((m) =>
        m.type != 'Select' && m.units != 'Select U' && m.totalQty > 0);
    if (!hasValidMeasurement) return false;

    final userData = _ref.read(authNotifierProvider).value;
    final role = UserRole.fromLoginResponse(userData ?? {});

    if (role == UserRole.contractor || role == UserRole.contractorRep) {
      if (state.testInSiteLab == 'Select') return false;
    } else if (role == UserRole.engineer || role == UserRole.dyHodEngineer || role == UserRole.hod || role == UserRole.dyHod) {
      if (state.inspectionStatus == 'Select') return false;
      if ((state.inspectionStatus == 'Rejected' ||
              state.inspectionStatus == 'Rectification') &&
          state.engineerRemarks.trim().isEmpty) {
        return false;
      }
      
      if (!isOffline) {
        for (var entry in state.enclosureChecklists.entries) {
          final items = entry.value;
          if (items.isNotEmpty) {
            final enggNotFilled = items.any((item) => 
              item.engineerStatus == null || item.engineerStatus!.isEmpty);
            if (enggNotFilled) return false;
          }
        }
      }
    }

    return true;
  }

  Future<void> submit({bool isOffline = false}) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final userData = _ref.read(authNotifierProvider).value;
      final role = UserRole.fromLoginResponse(userData ?? {});
      final userId = userData?['userId'] ?? '';
      final dio = _ref.read(dioProvider);

      final pdfFile = await InspectionSubmitPdfBuilder.build(
        state: state,
        role: role,
        isOffline: isOffline,
        rfiId: _rfiId,
        dio: dio,
      );

      final isEngineerRole = role == UserRole.engineer ||
          role == UserRole.dyHodEngineer ||
          role == UserRole.hod ||
          role == UserRole.dyHod;
      final isEngineerRectification =
          isEngineerRole && state.inspectionStatus == 'Rectification';

      if (role == UserRole.contractor || role == UserRole.contractorRep) {
        final uploadData = FormData.fromMap({
          "rfiId": _rfiId,
          "pdf": await MultipartFile.fromFile(
            pdfFile.path,
            filename: "$_rfiId.pdf",
          ),
        });
        await _repository.uploadPdfContractor(uploadData);

        final txnId = generateUniqueTxnId();
        await _repository.stampPdf(FormData.fromMap({
          "rfiId": _rfiId,
          "txnId": txnId,
        }));
      } else if (isEngineerRole && !isEngineerRectification) {
        final uploadData = FormData.fromMap({
          "inspectionStatus": _mapTestType(state.inspectionStatus) ?? '',
          "engineerRemarks": state.engineerRemarks,
          "rfiId": _rfiId,
          "pdf": await MultipartFile.fromFile(
            pdfFile.path,
            filename: "$_rfiId.pdf",
          ),
        });
        await _repository.uploadPdfEngg(uploadData);

        await _repository.stampEnggPdf(FormData.fromMap({
          "rfiId": _rfiId,
        }));
      }

      final dataMap = FinalSubmitPayload.buildDataJson(
        rfiId: _rfiId,
        state: state,
        userId: userId,
        mapInspectionStatus: _mapInspectionStatus,
        mapTestType: _mapTestType,
      );

      final finalFormData = await FinalSubmitPayload.buildFormData(
        dataJson: dataMap,
        state: state,
      );

      await _repository.finalSubmit(finalFormData);

      final prefs = _ref.read(sharedPrefsProvider);
      await prefs.remove(_draftKey);
      state = state.copyWith(isSubmitting: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: _userMessageFromDioException(e),
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: _userMessageFromException(e),
      );
      rethrow;
    }
  }

  String _userMessageFromException(Object e) {
    final text = e.toString();
    const prefix = 'Exception: ';
    if (text.startsWith(prefix)) {
      return text.substring(prefix.length);
    }
    return text;
  }

  String _userMessageFromDioException(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map && responseData['error'] != null) {
      return responseData['error'].toString();
    }
    if (responseData is Map && responseData['message'] != null) {
      return responseData['message'].toString();
    }
    if (responseData is Map && responseData['status'] != null) {
      return responseData['status'].toString();
    }
    if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }
    if (e.message != null && e.message!.isNotEmpty) {
      return e.message!;
    }
    return 'Failed to submit inspection. Please try again.';
  }
  
  String? _mapInspectionStatus(String? value) {
    if (value == null || value == 'Select' || value.isEmpty) return null;

    switch (value) {
      case 'Visual':
        return 'VISUAL';
      case 'Lab test':
      case 'Lab Test':
        return 'LAB_TEST';
      case 'Site test':
      case 'Site Test':
        return 'SITE_TEST';
      default:
        return value;
    }
  }

  String? _mapTestType(String? value) {
    if (value == null || value == 'Select' || value.isEmpty) return null;

    switch (value) {
      case 'Accepted':
        return 'Accepted';
      case 'Rejected':
        return 'Rejected';
      case 'Rectification':
        return 'Returned_For_Rectification';
      default:
        return value;
    }
  }

}
