import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../providers/inspection/inspection_form_state.dart';

class FinalSubmitPayload {
  static Map<String, dynamic> buildDataJson({
    required int rfiId,
    required InspectionFormState state,
    required String? userId,
    required String? Function(String?) mapInspectionStatus,
    required String? Function(String?) mapTestType,
  }) {
    final firstM = state.measurements.isNotEmpty
        ? state.measurements.first
        : const MeasurementRow();

    final supportingDescriptions = <String>[];
    for (final doc in state.supportingDocuments) {
      final path = doc.path.trim();
      if (path.isEmpty || path.startsWith('http')) continue;
      if (!File(path).existsSync()) continue;
      supportingDescriptions.add(doc.description.trim());
    }

    return {
      'inspectionId': null,
      'rfiId': rfiId,
      'location': state.location,
      'chainage': state.chainage,
      'nameOfRepresentative': _resolveNameOfRepresentative(state, userId),
      'measurementType': firstM.type == 'Select' ? null : firstM.type,
      'length': _parseNullableDouble(firstM.l),
      'breadth': _parseNullableDouble(firstM.b),
      'height': _parseNullableDouble(firstM.h),
      'weight': _parseNullableDouble(firstM.weight),
      'units': firstM.units == 'Select U' ? null : firstM.units,
      'noOfItems': int.tryParse(firstM.no),
      'totalQty': firstM.totalQty,
      'inspectionStatus': mapInspectionStatus(state.testInSiteLab),
      'testInsiteLab': mapTestType(state.inspectionStatus),
      'engineerRemarks':
          state.engineerRemarks.isEmpty ? null : state.engineerRemarks,
      'descriptionEnclosure': _resolveDescriptionEnclosure(state),
      'supportingDescriptions': supportingDescriptions,
    };
  }

  static Future<FormData> buildFormData({
    required Map<String, dynamic> dataJson,
    required InspectionFormState state,
  }) async {
    final formData = FormData();

    for (final doc in state.supportingDocuments) {
      final path = doc.path.trim();
      if (path.isEmpty || path.startsWith('http')) continue;
      if (!File(path).existsSync()) continue;
      formData.files.add(
        MapEntry(
          'supportingFiles',
          await MultipartFile.fromFile(path, filename: p.basename(path)),
        ),
      );
    }

    formData.fields.add(MapEntry('data', jsonEncode(dataJson)));

    final selfie = state.selfiePath;
    if (selfie != null && selfie.isNotEmpty && File(selfie).existsSync()) {
      formData.files.add(
        MapEntry('selfie', await MultipartFile.fromFile(selfie)),
      );
    }

    return formData;
  }

  static String _resolveNameOfRepresentative(
    InspectionFormState state,
    String? userId,
  ) {
    final fromRfi = state.rfiDetails?.nameOfRepresentative?.trim();
    if (fromRfi != null && fromRfi.isNotEmpty) return fromRfi;

    final fromState = state.contractorRepresentative.trim();
    if (fromState.isNotEmpty) return fromState;

    return userId?.trim() ?? '';
  }

  static String? _resolveDescriptionEnclosure(InspectionFormState state) {
    final contractor = state.contractorDescription.trim();
    if (contractor.isNotEmpty) return contractor;

    final rfiDesc = state.rfiDetails?.description?.trim();
    if (rfiDesc != null && rfiDesc.isNotEmpty) return rfiDesc;

    return null;
  }

  static double? _parseNullableDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value);
  }
}
