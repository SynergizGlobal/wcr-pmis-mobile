// Removed unnecessary import
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
      
      // Fetch details and inspections concurrently
      final responses = await Future.wait([
        api.getRfiDetails(id),
        api.getRfiInspections(id),
      ]);

      final detailsData = responses[0] as Map<String, dynamic>;
      final inspectionsFromDedicated = responses[1];
      
      // Get inspections from both possible sources
      final List<dynamic> rawInspections = (inspectionsFromDedicated is List) ? inspectionsFromDedicated : [];
      final List<dynamic> fromDetailsPayload = (detailsData['inspectionDetails'] is List) 
          ? detailsData['inspectionDetails'] as List<dynamic> 
          : [];
      
      // Combine and deduplicate by ID to ensure we have the best data
      final Map<int, dynamic> uniqueInspections = {};
      
      // First, take from the dedicated API (if any)
      for (var item in rawInspections) {
        if (item is Map) {
          final id = _sanitizeDeep(item['id']);
          if (id is int) uniqueInspections[id] = item;
        }
      }
      
      // Then, overwrite/supplement with data from rfi-details payload (often richer)
      for (var item in fromDetailsPayload) {
        if (item is Map) {
          final id = _sanitizeDeep(item['id']);
          if (id is int) {
            // If the item in details payload has a siteImage, prefer it
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

      // Perform deep sanitization
      final cleanDetails = _sanitizeDeep(detailsData) as Map<String, dynamic>;

      // Parse models
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
      
      // Sort models by inspection date/time if available
      inspectionModels.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

      state = state.copyWith(
        isLoading: false,
        detailModel: detailModel,
        inspections: inspectionModels,
        errorMessage: null,
      );

      // Trigger checklist fetching for enclosures
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
        // Mark as no checklist to avoid perpetual loading or retrying
        state = state.copyWith(
          enclosuresWithNoChecklist: {
            ...state.enclosuresWithNoChecklist,
            name,
          },
        );
      }
    }
  }


  // Deeply sanitize the JSON to fix QA vs LIVE disparities
  // Specifically: Converts empty strings to null. And fixes common boolean/int mismatches.
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
        // Default assignment for recursion
        dynamic sanitizedVal = _sanitizeDeep(val);

        // Special manual overrides for booleans stored as ints strings
        if (key == 'isDeleted' || key == 'contractorEsignDone' || key == 'engineerEsignDone') {
           if (val is int) {
             sanitized[key] = val == 1;
             return;
           } else if (val is String) {
             sanitized[key] = val.toLowerCase() == 'true' || val == '1';
             return;
           }
        }
        
        // Special manual override for id fields that should be integer but come as strings
        if (key == 'id' || key == 'inspectionId' || key == 'rfiId' || key == 'noOfItems' || key == 'no') {
           if (val is String && int.tryParse(val) != null) {
             sanitized[key] = int.parse(val);
             return;
           }
        }

        // If a field expects a String but the backend sends a Map/List, stringify it
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
