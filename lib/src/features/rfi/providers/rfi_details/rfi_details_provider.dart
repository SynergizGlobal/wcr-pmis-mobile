import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/providers/dio_provider.dart';
import '../../domain/rfi_details/rfi_detail_model.dart';
import '../../domain/rfi_details/rfi_inspection_model.dart';
import '../../domain/rfi_details/enclosure_checklist_item.dart';
import '../../data/rfi_details/rfi_details_api.dart';


part 'rfi_details_state.dart';
part 'rfi_details_provider.freezed.dart';
part 'rfi_details_provider.g.dart';

final rfiDetailsApiProvider = Provider<RfiDetailsApi>((ref) {
  return RfiDetailsApi(ref.read(dioProvider));
});

@riverpod
class RfiDetailsNotifier extends _$RfiDetailsNotifier {
  @override
  RfiDetailsState build() {
    return const RfiDetailsState();
  }

  Future<void> fetchRfiDetails(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final api = ref.read(rfiDetailsApiProvider);
      
      final responses = await Future.wait([
        api.getRfiDetails(id),
        api.getRfiInspections(id),
      ]);

      final detailsData = responses[0] as Map<String, dynamic>;
      final inspectionsFromDedicated = responses[1];
      
      final List<dynamic> rawInspections = (inspectionsFromDedicated is List) ? inspectionsFromDedicated : [];
      final List<dynamic> fromDetailsPayload = (detailsData['inspectionDetails'] is List) 
          ? detailsData['inspectionDetails'] as List<dynamic> 
          : [];
      
      final Map<int, dynamic> uniqueInspections = {};
      
      for (var item in rawInspections) {
        if (item is Map) {
          final id = _sanitizeDeep(item['id']);
          if (id is int) uniqueInspections[id] = item;
        }
      }
      
      for (var item in fromDetailsPayload) {
        if (item is Map) {
          final id = _sanitizeDeep(item['id']);
          if (id is int) {
            if (uniqueInspections.containsKey(id)) {
              final existing = uniqueInspections[id];
              if ((item['siteImage'] != null && item['siteImage'].toString().isNotEmpty) || 
                  (existing['siteImage'] == null || existing['siteImage'].toString().isEmpty)) {
                uniqueInspections[id] = item;
              }
            } else {
              uniqueInspections[id] = item;
            }
          }
        }
      }

      final cleanDetails = _sanitizeDeep(detailsData) as Map<String, dynamic>;

      final RfiDetailModel detailModel = RfiDetailModel.fromJson(cleanDetails);
      final List<RfiInspectionModel> inspectionModels = uniqueInspections.values
          .map((e) {
            final cleanE = _sanitizeDeep(e);
            if (cleanE is Map<String, dynamic>) {
              return RfiInspectionModel.fromJson(cleanE);
            }
            return const RfiInspectionModel();
          })
          .toList();
      
      inspectionModels.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

      state = state.copyWith(
        isLoading: false,
        detailModel: detailModel,
        inspections: inspectionModels,
        errorMessage: null,
      );

      _fetchChecklistsForEnclosures(id, detailModel);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _fetchChecklistsForEnclosures(int rfiId, RfiDetailModel detail) async {
    if (detail.enclosuresList == null || detail.enclosuresList!.isEmpty) return;

    final api = ref.read(rfiDetailsApiProvider);

    for (var name in detail.enclosuresList!) {
      try {
        final checklist = await api.getEnclosureChecklistItems(name, rfiId);
        final List<EnclosureChecklistItem> items = checklist
            .map((e) => EnclosureChecklistItem.fromJson(_sanitizeDeep(e)))
            .toList();

        if (items.isNotEmpty) {
          state = state.copyWith(
            enclosureChecklists: {
              ...state.enclosureChecklists,
              name: items,
            },
          );
        }
      } catch (e) {
        state = state.copyWith(
          enclosuresWithNoChecklist: {
            ...state.enclosuresWithNoChecklist,
            name,
          },
        );
      }
    }
  }


  dynamic _sanitizeDeep(dynamic value) {
    if (value == null) return null;
    
    if (value is String) {
      if (value.trim().isEmpty || value.toLowerCase() == 'null') {
        return null;
      }
      return value;
    } else if (value is Map<String, dynamic>) {
      final sanitized = <String, dynamic>{};
      value.forEach((key, val) {
        dynamic sanitizedVal = _sanitizeDeep(val);

        if (key == 'isDeleted' || key == 'contractorEsignDone' || key == 'engineerEsignDone') {
           if (val is int) {
             sanitized[key] = val == 1;
             return;
           } else if (val is String) {
             sanitized[key] = val.toLowerCase() == 'true' || val == '1';
             return;
           }
        }
        
        if (key == 'id' || key == 'inspectionId' || key == 'rfiId' || key == 'noOfItems' || key == 'no') {
           if (val is String && int.tryParse(val) != null) {
             sanitized[key] = int.parse(val);
             return;
           }
        }

        final strictStringFields = <String>[
          'rfiValidation', 'action', 'typeOfRFI', 'enclosures', 'location', 'description',
          'timeOfInspection', 'dateOfSubmission', 'dateOfInspection', 'createdAt', 'updatedAt',
          'createdBy', 'emailUser', 'status', 'assignedPersonClient', 'clientDepartment',
          'txn_id', 'assignedPersonContractor', 'assignedPersonUserId', 'contractId',
          'dyHodUserId', 'contractor_submitted_date', 'engineer_submitted_date',
          'closedDate', 'deletedAt', 'estatus', 'project', 'work', 'contract', 'structureType',
          'structure', 'component', 'element', 'activity', 'p6ActivityId', 'pmisCalcFk',
          'reasonForDelete', 'rfiDescription', 'nameOfRepresentative', 'rfi_Id'
        ];
        
        if (strictStringFields.contains(key)) {
           if (val is Map || val is List) {
             sanitized[key] = jsonEncode(val);
             return;
           }
        }

        sanitized[key] = sanitizedVal;
      });
      return sanitized;
    } else if (value is List) {
      return value.map((e) => _sanitizeDeep(e)).toList();
    }
    return value;
  }
}
