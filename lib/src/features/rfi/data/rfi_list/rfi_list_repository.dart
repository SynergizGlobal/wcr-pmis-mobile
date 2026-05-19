import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/environment.dart';
import '../../core/providers/dio_provider.dart';
import '../../domain/rfi_list/rfi_list_item.dart';
import 'rfi_list_api.dart';

part 'rfi_list_repository.g.dart';

@riverpod
RfiListRepository rfiListRepository(RfiListRepositoryRef ref) {
  final dio = ref.read(dioProvider);
  return RfiListRepository(RfiListApi(dio));
}

class RfiListRepository {
  final RfiListApi api;

  RfiListRepository(this.api);

  Future<List<RfiListItem>> getRfiDetails() async {
    final rawData = await api.getRfiDetails();
    return rawData.map((json) {
      if (json['approvalStatus']?.toString() == 'Rejected') {
        // Log rejected RFI if needed, but not using print
      }
      // Create a safely-mapped object, handling potential nulls
      return RfiListItem(
        rfiId: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        rfiNo: json['rfi_Id']?.toString() ?? json['rfiNo']?.toString() ?? 'N/A',
        project: json['project']?.toString() ?? 'Unknown',
        structure: json['structure']?.toString() ?? 'Unknown',
        activity: json['activity']?.toString() ?? 'Unknown',
        status: json['status']?.toString() ?? 'Unknown',
        dateOfSubmission: json['dateOfSubmission']?.toString() ?? 'Unknown',
        work: json['work']?.toString() ?? 'Unknown',
        element: json['element']?.toString() ?? 'N/A',
        assignedPersonClient: json['assignedPersonClient']?.toString() ?? 'N/A',
        nameOfRepresentative: json['nameOfRepresentative']?.toString() ?? 'N/A',
        createdBy: json['createdBy']?.toString() ?? 'N/A',
        approvalStatus: json['approvalStatus']?.toString() ?? 'N/A',
        totalQty: (json['measurements'] != null
                ? json['measurements']['totalQty']?.toString()
                : null) ??
            json['totalQty']?.toString() ??
            'N/A',
        contractorImages: _parseImagePaths(json['imgContractor']?.toString()),
        clientImages: _parseImagePaths(json['imgClient']?.toString()),
        contract: json['contractId']?.toString(),
        typeOfRFI: json['typeOfRFI']?.toString(),
        rfiDescription: json['rfiDescription']?.toString() ??
            json['description']?.toString() ??
            'N/A',
        measurementType: (json['measurements'] != null
                ? json['measurements']['measurementType']?.toString()
                : null) ??
            json['measurementType']?.toString() ??
            'N/A',
        validationStatus: json['validationStatus']?.toString(),
        inspectionStatus: json['inspectionStatus']?.toString(),
      );
    }).toList();
  }

  List<String> _parseImagePaths(String? imagePathsRaw) {
    if (imagePathsRaw == null || imagePathsRaw.isEmpty) return [];

    // Split by comma in case there are multiple paths concatenated
    return imagePathsRaw
        .split(',')
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .map((path) {
      if (path.startsWith('http')) return path;

      String cleanPath = path;
      if (path.startsWith('/home/ec2-user/')) {
        cleanPath = path.replaceFirst('/home/ec2-user/', '');
      }
      if (cleanPath.startsWith('/')) {
        cleanPath = cleanPath.substring(1);
      }
      return '${Environment.baseUrl}$cleanPath';
    }).toList();
  }
}
