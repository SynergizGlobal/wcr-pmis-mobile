import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/dio_provider.dart';
import '../../domain/inspection/inspection_item.dart';
import 'inspection_api.dart';

final inspectionApiProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return InspectionApi(dio);
});

final inspectionRepositoryProvider = Provider((ref) {
  final api = ref.watch(inspectionApiProvider);
  return InspectionRepository(api);
});

class InspectionRepository {
  final InspectionApi _api;

  InspectionRepository(this._api);

  String _messageFromResponse(Response response, String fallback) {
    final data = response.data;
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    return fallback;
  }

  void _ensureStampSuccess(Response response, String fallback) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_messageFromResponse(response, fallback));
    }
    final data = response.data;
    if (data is Map && data['status'] == 'error') {
      throw Exception(
        data['message']?.toString() ?? fallback,
      );
    }
  }

  Future<List<InspectionItem>> getInspectionList() async {
    try {
      final response = await _api.getInspectionDetails();

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> dataList = response.data;
        return dataList.map((json) => InspectionItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load inspection list');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error occurred');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<InspectionItem> getRfiDetails(int id) async {
    try {
      final response = await _api.getRfiDetails(id);
      if (response.statusCode == 200 && response.data != null) {
        return InspectionItem.fromJson(response.data);
      }
      throw Exception('Failed to load RFI details');
    } catch (e) {
      throw Exception('Error fetching RFI details: $e');
    }
  }

  Future<List<dynamic>> getChecklistItems(
      String enclosureName, int rfiId) async {
    try {
      final response = await _api.getChecklistItems(enclosureName, rfiId);
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<String?> getEnclosureDescription(String enclosureName) async {
    try {
      final response = await _api.getEnclosureDescription(enclosureName);
      if (response.statusCode == 200 && response.data != null) {
        return response.data['description']?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> uploadPdfContractor(FormData data) async {
    final response = await _api.uploadPdfContractor(data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _messageFromResponse(response, 'Failed to upload Contractor PDF'),
      );
    }
  }

  Future<void> uploadPdfEngg(FormData data) async {
    final response = await _api.uploadPdfEngg(data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _messageFromResponse(response, 'Failed to upload Engineer PDF'),
      );
    }
  }

  Future<void> stampPdf(FormData data) async {
    final response = await _api.stampPdf(data);
    _ensureStampSuccess(response, 'Failed to stamp Contractor PDF');
  }

  Future<void> stampEnggPdf(FormData data) async {
    final response = await _api.stampEnggPdf(data);
    _ensureStampSuccess(response, 'Failed to stamp Engineer PDF');
  }

  Future<void> uploadEnclosure(FormData data) async {
    final response = await _api.uploadEnclosure(data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload enclosure');
    }
  }

  Future<void> uploadSiteImage(FormData data) async {
    final response = await _api.uploadSiteImage(data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload site image');
    }
  }

  Future<void> finalSubmit(FormData data) async {
    final response = await _api.finalSubmit(data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Final submission failed');
    }
  }

  Future<void> saveAsDraft(Map<String, dynamic> data) async {
    await _api.saveAsDraft(data);
  }

  Future<void> deleteEnclosure(int id) async {
    final response = await _api.deleteEnclosure(id);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete enclosure');
    }
  }

  Future<void> deleteSiteImage({
    required int rfiId,
    required String imgPath,
    required String uploadedBy,
  }) async {
    final response = await _api.deleteSiteImage(
      rfiId: rfiId,
      img: imgPath,
      uploadedBy: uploadedBy,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete site image');
    }
  }

  Future<String> sendForValidation(int rfiId) async {
    try {
      final response = await _api.sendForValidation(rfiId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data?.toString() ?? 'RFI sent for validation successfully.';
      } else {
        throw Exception(response.data?.toString() ?? 'Failed to send for validation');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? e.message ?? 'Network error occurred');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> saveEnclosureChecklist(FormData data) async {
    final response = await _api.saveEnclosureChecklist(data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save enclosure checklist');
    }
  }

  Future<String> uploadAttachment(FormData data) async {
    try {
      final response = await _api.uploadAttachment(data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data?.toString() ?? 'Attachment uploaded successfully.';
      } else {
        throw Exception(response.data?.toString() ?? 'Failed to upload attachment');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? e.message ?? 'Network error occurred');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> uploadTestReport(FormData data) async {
    try {
      final response = await _api.uploadTestReport(data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data?.toString() ?? 'Test report uploaded successfully.';
      } else {
        throw Exception(response.data?.toString() ?? 'Failed to upload test report');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? e.message ?? 'Network error occurred');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
