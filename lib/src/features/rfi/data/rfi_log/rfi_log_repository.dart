import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/dio_provider.dart';
import '../../core/utils/rfi_file_paths.dart';
import '../../core/utils/rfi_log_pdf_paths.dart';
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
        rfiId: RfiLogPdfPaths.readRfiIdFromJson(json),
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
    final normalized = _normalizeReportPayload(rawData);
    var data = RfiReportDetailsData.fromJson(normalized);

    final needsMoreEnclosures = data.enclosures.isEmpty ||
        data.enclosures.every(
          (e) => extractFilePaths(e.file).isEmpty,
        );
    if (needsMoreEnclosures) {
      final fromDetails = await _enclosuresFromRfiDetails(id);
      if (fromDetails.isNotEmpty) {
        data = data.copyWith(enclosures: fromDetails);
      }
    }

    return data;
  }

  Map<String, dynamic> _normalizeReportPayload(Map<String, dynamic> raw) {
    final copy = Map<String, dynamic>.from(raw);
    final enclosuresRaw = copy['enclosures'];
    if (enclosuresRaw is List) {
      copy['enclosures'] = enclosuresRaw.map((item) {
        if (item is! Map) return item;
        final map = Map<String, dynamic>.from(item);
        final paths = extractFilePaths(map);
        if (paths.isEmpty) return map;

        final id = map['id'];
        if (id != null &&
            paths.length == 1 &&
            paths.first.contains('view-enclosure')) {
          map['file'] = paths.first;
        } else {
          map['file'] = paths.join(',');
        }
        return map;
      }).toList();
    }
    return copy;
  }

  Future<List<EnclosureInfo>> _enclosuresFromRfiDetails(String id) async {
    try {
      final response = await api.dio.get('/rfi/rfi-details/$id');
      final body = response.data;
      if (body is! Map<String, dynamic>) return [];

      final items = <EnclosureInfo>[];
      final enclosureList = body['enclosure'];
      if (enclosureList is List) {
        for (final entry in enclosureList) {
          if (entry is! Map) continue;
          final map = Map<String, dynamic>.from(entry);
          final name = map['enclosureName']?.toString();
          final paths = extractFilePaths(map);
          if (paths.isEmpty) continue;

          for (final path in paths) {
            items.add(
              EnclosureInfo(
                enclosureName: name,
                file: path,
              ),
            );
          }
        }
      }

      final names = body['enclosuresList'];
      if (items.isEmpty && names is List) {
        for (final name in names) {
          final label = name?.toString().trim();
          if (label != null && label.isNotEmpty) {
            items.add(EnclosureInfo(enclosureName: label, file: null));
          }
        }
      }

      return items;
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getFilterList() async {
    return await api.getFilterList();
  }
}
