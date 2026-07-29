import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/constants/api_constants.dart';
import 'package:wcr_pmis_mobile/src/core/network/dio_client.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/device_token_payload.dart';

/// Device token APIs on WCR (`wcrpmis`).
class WcrDeviceTokenDataSource {
  const WcrDeviceTokenDataSource(this._dio);

  final Dio _dio;

  Future<void> register(DeviceTokenPayload payload) async {
    await _dio.post<dynamic>(
      ApiConstants.wcrDeviceTokenRegisterPath,
      data: payload.toJson(),
    );
  }

  Future<void> deactivate(DeviceTokenPayload payload) async {
    await _dio.post<dynamic>(
      ApiConstants.wcrDeviceTokenDeactivatePath,
      data: payload.toJson(),
    );
  }
}

final wcrDeviceTokenDataSourceProvider =
    Provider<WcrDeviceTokenDataSource>((ref) {
  return WcrDeviceTokenDataSource(ref.watch(dioProvider));
});
