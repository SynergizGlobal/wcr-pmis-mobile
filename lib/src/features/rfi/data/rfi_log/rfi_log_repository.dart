import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/dio_provider.dart';
import '../../domain/rfi_log/rfi_log_item.dart';
import '../../domain/rfi_log/rfi_report_details.dart';
import 'rfi_log_api.dart';

part 'rfi_log_repository.g.dart';

@riverpod
RfiLogRepository rfiLogRepository(RfiLogRepositoryRef ref) {
  final dio = ref.read(dioProvider);
  return RfiLogRepository(RfiLogApi(dio));
}

class RfiLogRepository {
  final RfiLogApi api;

  RfiLogRepository(this.api);

  Future<List<RfiLogItem>> getAllRfiLogDetails(Map<String, dynamic> body) async {
    final rawData = await api.getAllRfiLogDetails(body);

    if (rawData.isEmpty) {
      return [];
    }

    return rawData.map((json) {
      return RfiLogItem(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        rfiId: json['rfi_Id']?.toString() ?? json['rfiId']?.toString() ?? 'N/A',
        dateOfSubmission: json['dateOfSubmission']?.toString() ?? 'N/A',
        structure: (json['element']?.toString() ?? json['structure']?.toString()) ?? 'N/A',
        rfiDescription: json['activity']?.toString() ?? 
            json['rfiDescription']?.toString() ?? 
            'N/A',
        rfiRequestedBy: json['createdBy']?.toString() ?? 
            json['rfiRequestedBy']?.toString() ?? 
            'N/A',
        department: json['department']?.toString() ?? 'N/A',
        person: json['assignedPersonClient']?.toString() ?? 
            json['person']?.toString() ?? 
            'N/A',
        dateRaised: json['dateRaised']?.toString() ?? 'N/A',
        dateResponded: json['dateResponded']?.toString(),
        enggApproval: json['enggApproval']?.toString(),
        status: json['status']?.toString() ?? 'UNKNOWN',
        notes: json['notes']?.toString(),
        validationStatus: json['validationStatus']?.toString(),
        project: json['project']?.toString() ?? 'N/A',
        work: json['work']?.toString() ?? 'N/A',
        contract: json['contractId']?.toString() ?? 
            json['contract']?.toString() ?? 
            'N/A',
        nameOfRepresentative: json['nameOfRepresentative']?.toString() ?? 'N/A',
        txnId: json['txnId']?.toString(),
        estatus: json['estatus']?.toString(),
      );
    }).toList();
  }

  Future<RfiReportDetailsData> fetchRfiReportDetails(String id) async {
    final rawData = await api.getRfiReportDetails(id);
    return RfiReportDetailsData.fromJson(rawData);
  }

  Future<Map<String, dynamic>> getFilterList() async {
    return await api.getFilterList();
  }
}
