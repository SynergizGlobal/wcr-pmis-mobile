import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/constants/api_constants.dart';
import 'package:wcr_pmis_mobile/src/core/network/rfi_dio_client.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/device_token_payload.dart';

/// Device token APIs live on RFI (`rfiSystem`), not WCR.
class RfiDeviceTokenDataSource {
  const RfiDeviceTokenDataSource(this._dio);

  final Dio _dio;

  Future<void> register(DeviceTokenPayload payload) async {
    await _dio.post<dynamic>(
      ApiConstants.deviceTokenRegisterPath,
      data: payload.toJson(),
    );
  }

  Future<void> deactivate(DeviceTokenPayload payload) async {
    await _dio.post<dynamic>(
      ApiConstants.deviceTokenDeactivatePath,
      data: payload.toJson(),
    );
  }
}

final rfiDeviceTokenDataSourceProvider =
    Provider<RfiDeviceTokenDataSource>((ref) {
  return RfiDeviceTokenDataSource(ref.watch(rfiDioProvider));
});
