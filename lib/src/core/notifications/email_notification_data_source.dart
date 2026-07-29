import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/constants/api_constants.dart';
import 'package:wcr_pmis_mobile/src/core/network/dio_client.dart';

/// Email notification preference APIs on WCR (`wcrpmis`).
class EmailNotificationDataSource {
  const EmailNotificationDataSource(this._dio);

  final Dio _dio;

  Future<bool> getEnabled() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiConstants.emailNotificationStatusPath,
    );
    return _asBool(response.data);
  }

  /// Returns `true` when the server reports the update succeeded.
  Future<bool> updateEnabled(bool enabled) async {
    final Response<dynamic> response = await _dio.put<dynamic>(
      ApiConstants.emailNotificationUpdatePath,
      data: <String, dynamic>{'enabled': enabled},
    );
    return _asBool(response.data);
  }

  static bool _asBool(dynamic data) {
    if (data is bool) {
      return data;
    }
    if (data is num) {
      return data != 0;
    }
    if (data is String) {
      final String value = data.trim().toLowerCase();
      return value == 'true' || value == '1' || value == 'yes';
    }
    if (data is Map) {
      final dynamic nested =
          data['enabled'] ?? data['data'] ?? data['status'] ?? data['result'];
      return _asBool(nested);
    }
    return false;
  }
}

final emailNotificationDataSourceProvider =
    Provider<EmailNotificationDataSource>((ref) {
  return EmailNotificationDataSource(ref.watch(dioProvider));
});
