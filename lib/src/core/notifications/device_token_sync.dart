import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/device_token_payload.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/fcm_messaging_service.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/rfi_device_token_data_source.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/wcr_device_token_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/providers/auth_token_provider.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/data/datasources/rfi_handoff_data_source.dart';

/// Registers / deactivates FCM tokens on WCR and RFI when sessions are ready.
///
/// Must not read [authControllerProvider] — that provider depends on this one
/// (circular dependency would silently break WCR register).
class DeviceTokenSync {
  DeviceTokenSync(this._ref);

  final Ref _ref;
  Future<void>? _fcmReadyFuture;

  FcmMessagingService get _fcm => _ref.read(fcmMessagingServiceProvider);

  WcrDeviceTokenDataSource get _wcrRemote =>
      _ref.read(wcrDeviceTokenDataSourceProvider);

  RfiDeviceTokenDataSource get _rfiRemote =>
      _ref.read(rfiDeviceTokenDataSourceProvider);

  /// All callers share one in-flight init so nobody skips ahead of WCR register.
  Future<void> ensureFcmReady() async {
    final Future<void>? inFlight = _fcmReadyFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final Completer<void> completer = Completer<void>();
    _fcmReadyFuture = completer.future;
    try {
      await _fcm.initialize(
        onTokenRefresh: (DeviceTokenPayload payload) {
          unawaited(registerWhereverReady(payloadOverride: payload));
        },
      );
      completer.complete();
    } catch (error, stack) {
      _fcmReadyFuture = null;
      completer.completeError(error, stack);
      rethrow;
    }
  }

  /// After WCR login: register on WCR, then ensure RFI SSO + register there.
  Future<void> ensureSessionsAndRegister() async {
    if (kDebugMode) {
      debugPrint('FCM ensureSessionsAndRegister start');
    }
    try {
      await ensureFcmReady();
      // Login already set [wcrSessionActiveProvider]; force avoids races.
      await registerOnWcr(force: true);
      await ensureRfiSessionAndRegister();
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('FCM device register sync failed: $error\n$stack');
      }
    }
  }

  /// Ensures RFI SSO session exists, then registers the device token on RFI.
  Future<void> ensureRfiSessionAndRegister() async {
    try {
      await ensureFcmReady();
      final String? existing = _ref.read(rfiAuthTokenProvider)?.trim();
      if (existing == null || existing.isEmpty) {
        final RfiHandoffResult result =
            await _ref.read(rfiHandoffDataSourceProvider).performRedirect();
        _ref.read(rfiAuthTokenProvider.notifier).state = result.token;
      }
      await registerOnRfi();
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('FCM RFI register sync failed: $error\n$stack');
      }
    }
  }

  Future<void> registerWhereverReady({
    DeviceTokenPayload? payloadOverride,
  }) async {
    await registerOnWcr(payloadOverride: payloadOverride);
    await registerOnRfi(payloadOverride: payloadOverride);
  }

  Future<void> registerOnWcr({
    DeviceTokenPayload? payloadOverride,
    bool force = false,
  }) async {
    try {
      await ensureFcmReady();
      final bool sessionActive = _ref.read(wcrSessionActiveProvider);
      if (!force && !sessionActive) {
        if (kDebugMode) {
          debugPrint('FCM WCR register skipped: WCR session inactive');
        }
        return;
      }
      final DeviceTokenPayload? payload =
          payloadOverride ?? await _fcm.buildPayload();
      if (payload == null) {
        if (kDebugMode) {
          debugPrint('FCM WCR register skipped: no token/platform');
        }
        return;
      }
      if (kDebugMode) {
        debugPrint(
          'FCM WCR register calling API → '
          '${payload.platform} deviceId=${payload.deviceId}',
        );
      }
      await _wcrRemote.register(payload);
      if (kDebugMode) {
        debugPrint('FCM device registered on WCR (${payload.platform})');
      }
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('FCM WCR register failed: $error\n$stack');
      }
    }
  }

  Future<void> registerOnRfi({DeviceTokenPayload? payloadOverride}) async {
    try {
      await ensureFcmReady();
      final String? rfiToken = _ref.read(rfiAuthTokenProvider)?.trim();
      if (rfiToken == null || rfiToken.isEmpty) {
        if (kDebugMode) {
          debugPrint('FCM RFI register skipped: RFI session not ready');
        }
        return;
      }
      final DeviceTokenPayload? payload =
          payloadOverride ?? await _fcm.buildPayload();
      if (payload == null) {
        if (kDebugMode) {
          debugPrint('FCM RFI register skipped: no token/platform');
        }
        return;
      }
      if (kDebugMode) {
        debugPrint(
          'FCM RFI register calling API → '
          '${payload.platform} deviceId=${payload.deviceId}',
        );
      }
      await _rfiRemote.register(payload);
      if (kDebugMode) {
        debugPrint('FCM device registered on RFI (${payload.platform})');
      }
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('FCM RFI register failed: $error\n$stack');
      }
    }
  }

  /// Prefer [ensureSessionsAndRegister] after login; kept for RFI-only callers.
  Future<void> register({DeviceTokenPayload? payloadOverride}) async {
    await registerOnRfi(payloadOverride: payloadOverride);
  }

  Future<void> deactivate() async {
    await ensureFcmReady();
    final DeviceTokenPayload? payload = await _fcm.buildPayload();
    if (payload == null) {
      return;
    }
    await Future.wait(<Future<void>>[
      _deactivateWcr(payload),
      _deactivateRfi(payload),
    ]);
  }

  Future<void> _deactivateWcr(DeviceTokenPayload payload) async {
    try {
      await _wcrRemote.deactivate(payload);
      if (kDebugMode) {
        debugPrint('FCM device deactivated on WCR');
      }
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('FCM WCR deactivate failed: $error\n$stack');
      }
    }
  }

  Future<void> _deactivateRfi(DeviceTokenPayload payload) async {
    try {
      await _rfiRemote.deactivate(payload);
      if (kDebugMode) {
        debugPrint('FCM device deactivated on RFI');
      }
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('FCM RFI deactivate failed: $error\n$stack');
      }
    }
  }
}

final deviceTokenSyncProvider = Provider<DeviceTokenSync>((ref) {
  return DeviceTokenSync(ref);
});
