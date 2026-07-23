import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/device_token_payload.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/fcm_messaging_service.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/rfi_device_token_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/providers/auth_token_provider.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/data/datasources/rfi_handoff_data_source.dart';

/// Registers / deactivates FCM tokens against RFI after SSO is available.
class DeviceTokenSync {
  DeviceTokenSync(this._ref);

  final Ref _ref;
  bool _fcmInitialized = false;

  FcmMessagingService get _fcm => _ref.read(fcmMessagingServiceProvider);

  RfiDeviceTokenDataSource get _remote =>
      _ref.read(rfiDeviceTokenDataSourceProvider);

  Future<void> ensureFcmReady() async {
    if (_fcmInitialized) {
      return;
    }
    _fcmInitialized = true;
    await _fcm.initialize(
      onTokenRefresh: (DeviceTokenPayload payload) {
        final String? rfiToken = _ref.read(rfiAuthTokenProvider);
        if (rfiToken == null || rfiToken.isEmpty) {
          return;
        }
        unawaited(register(payloadOverride: payload));
      },
    );
  }

  /// Ensures RFI SSO session exists, then registers the device token.
  Future<void> ensureRfiSessionAndRegister() async {
    try {
      await ensureFcmReady();
      final String? existing = _ref.read(rfiAuthTokenProvider)?.trim();
      if (existing == null || existing.isEmpty) {
        final RfiHandoffResult result =
            await _ref.read(rfiHandoffDataSourceProvider).performRedirect();
        _ref.read(rfiAuthTokenProvider.notifier).state = result.token;
      }
      await register();
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('FCM RFI register sync failed: $error\n$stack');
      }
    }
  }

  Future<void> register({DeviceTokenPayload? payloadOverride}) async {
    try {
      await ensureFcmReady();
      final String? rfiToken = _ref.read(rfiAuthTokenProvider)?.trim();
      if (rfiToken == null || rfiToken.isEmpty) {
        if (kDebugMode) {
          debugPrint('FCM register skipped: RFI session not ready');
        }
        return;
      }
      final DeviceTokenPayload? payload =
          payloadOverride ?? await _fcm.buildPayload();
      if (payload == null) {
        if (kDebugMode) {
          debugPrint('FCM register skipped: no token/platform');
        }
        return;
      }
      await _remote.register(payload);
      if (kDebugMode) {
        debugPrint('FCM device registered on RFI (${payload.platform})');
      }
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('FCM register failed: $error\n$stack');
      }
    }
  }

  Future<void> deactivate() async {
    try {
      await ensureFcmReady();
      final DeviceTokenPayload? payload = await _fcm.buildPayload();
      if (payload == null) {
        return;
      }
      await _remote.deactivate(payload);
      if (kDebugMode) {
        debugPrint('FCM device deactivated on RFI');
      }
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('FCM deactivate failed: $error\n$stack');
      }
    }
  }
}

final deviceTokenSyncProvider = Provider<DeviceTokenSync>((ref) {
  return DeviceTokenSync(ref);
});
