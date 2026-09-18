import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/dio_provider.dart';
import '../../core/utils/rfi_file_paths.dart';
import '../../core/utils/rfi_log_pdf_paths.dart';
import '../../domain/common/filter_option.dart';
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
      final String? projectId = _cleanText(
        json['projectId'] ?? json['project_id'],
      );
      final String? contractId = _cleanText(
        json['contractId'] ?? json['contract_id'],
      );
      final String? projectName = _cleanText(
        json['projectName'] ?? json['project'],
      );
      final String? contractName = _cleanText(
        json['contractName'] ?? json['contract'],
      );

      // Web "RFI Raised Date" — try common log/list field names.
      final String raisedDate = _cleanText(
            json['dateRaised'] ??
                json['rfiRaisedDate'] ??
                json['dateOfRaised'] ??
                json['raisedDate'] ??
                json['dateOfSubmission'] ??
                json['dateOfCreation'],
          ) ??
          '-';

      final String? respondedContractor = _cleanText(
        json['dateRespondedContractor'] ??
            json['contractorSubmittedOn'] ??
            json['contractorDateResponded'] ??
            json['dateRespondedCon'] ??
            json['conDateResponded'],
      );
      final String? respondedEngineer = _cleanText(
        json['dateRespondedEngineer'] ??
            json['engineerSubmittedOn'] ??
            json['engineerDateResponded'] ??
            json['dateRespondedEng'] ??
            json['enggDateResponded'] ??
            json['dateResponded'],
      );

      return RfiLogItem(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        rfiId: RfiLogPdfPaths.readRfiIdFromJson(json),
        dateOfSubmission: raisedDate,
        // Web "ID Of Structure" uses structure (e.g. 129/4 (PSC Girder)).
        structure: _cleanText(json['structure']) ??
            _cleanText(json['element']) ??
            '-',
        // Web description cells are usually activity labels.
        rfiDescription: _cleanText(json['activity']) ??
            _cleanText(json['rfiDescription']) ??
            '-',
        rfiRequestedBy: _cleanText(json['createdBy']) ??
            _cleanText(json['rfiRequestedBy']) ??
            '-',
        department: _cleanText(json['department']) ?? '-',
        person: _cleanText(json['assignedPersonClient']) ??
            _cleanText(json['person']) ??
            '-',
        dateRaised: raisedDate,
        dateResponded: respondedEngineer ?? respondedContractor,
        dateRespondedContractor: respondedContractor,
        dateRespondedEngineer: respondedEngineer,
        enggApproval: _cleanText(json['enggApproval']),
        status: json['status']?.toString() ?? 'UNKNOWN',
        notes: _cleanText(json['notes']),
        validationStatus: _cleanText(json['validationStatus']),
        project: projectName ?? projectId ?? '',
        projectId: projectId,
        work: _cleanText(json['work']) ?? '',
        contract: contractName ?? contractId ?? '',
        contractId: contractId,
        nameOfRepresentative:
            _cleanText(json['nameOfRepresentative']) ?? '-',
        txnId: _cleanText(json['txnId']),
        estatus: _cleanText(json['estatus']),
      );
    }).toList();
  }

  /// Treats empty / placeholder API values as missing.
  static String? _cleanText(dynamic value) {
    if (value == null) return null;
    final String text = value.toString().trim();
    if (text.isEmpty) return null;
    final String lower = text.toLowerCase();
    if (lower == 'n/a' ||
        lower == 'na' ||
        lower == 'null' ||
        lower == 'undefined' ||
        lower == '-') {
      return null;
    }
    return text;
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

  Future<List<FilterOption>> getFilterProjects({
    String project = '',
    String contract = '',
  }) async {
    final raw = await api.filterListProjects(
      project: project,
      contract: contract,
    );
    return FilterOption.parseList(raw, isProject: true);
  }

  Future<List<FilterOption>> getFilterContracts({
    String project = '',
    String contract = '',
  }) async {
    final raw = await api.filterListContracts(
      project: project,
      contract: contract,
    );
    return FilterOption.parseList(raw, isProject: false);
  }

  Future<Map<String, dynamic>> getFilterList() async {
    return await api.getFilterList();
  }
}
