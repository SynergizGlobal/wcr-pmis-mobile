import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

enum RfiPermissionOutcome {
  granted,
  denied,
  permanentlyDenied,
}

/// Runtime permissions for RFI upload / capture flows.
///
/// Google Play aligned:
/// - **Camera** — runtime prompt (selfie, site photos).
/// - **Gallery (Android)** — system Photo Picker / GET_CONTENT; no broad storage access.
/// - **Documents (PDF etc.)** — [FilePicker] SAF; no storage permission.
/// - **View / download** — in-app viewer + app-private folder only.
abstract final class RfiMediaPermissions {
  static Future<RfiPermissionOutcome> prepareCamera() =>
      _prepare(Permission.camera);

  /// iOS may prompt for photo library. Android does not need storage permission.
  static Future<RfiPermissionOutcome> prepareGalleryPick() {
    if (!Platform.isIOS) {
      return Future.value(RfiPermissionOutcome.granted);
    }
    return _prepare(Permission.photos);
  }

  static Future<RfiPermissionOutcome> _prepare(Permission permission) async {
    var status = await permission.status;
    if (status.isGranted || status.isLimited) {
      return RfiPermissionOutcome.granted;
    }
    if (status.isDenied) {
      status = await permission.request();
      if (status.isGranted || status.isLimited) {
        return RfiPermissionOutcome.granted;
      }
      return RfiPermissionOutcome.denied;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return RfiPermissionOutcome.permanentlyDenied;
    }
    return RfiPermissionOutcome.denied;
  }
}
