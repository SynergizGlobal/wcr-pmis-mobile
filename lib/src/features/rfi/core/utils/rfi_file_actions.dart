import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../widgets/global_alert_dialog.dart';
import '../widgets/rfi_remote_media_preview.dart';
import 'rfi_preview_fetch.dart';

/// Play Store–safe file view/download for RFI attachments.
///
/// Uses in-app preview and app-private storage only — never requests
/// [MANAGE_EXTERNAL_STORAGE] or broad storage permissions.
abstract final class RfiFileActions {
  static Future<void> view(
    BuildContext context, {
    required String path,
    required Dio dio,
    String? title,
  }) async {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return;

    if (RfiPreviewFetch.isRemoteInspectablePath(trimmed)) {
      if (!context.mounted) return;
      await RfiMediaViewerDialog.show(
        context,
        source: trimmed,
        dio: dio,
        title: title ?? _fileLabel(trimmed),
      );
      return;
    }

    final file = File(trimmed);
    if (await file.exists()) {
      try {
        final bytes = await file.readAsBytes();
        if (!context.mounted) return;
        await RfiLocalMediaViewerDialog.show(
          context,
          bytes: bytes,
          sourceHint: trimmed,
          title: title ?? _fileLabel(trimmed),
        );
        return;
      } catch (_) {
        // Fall through to API fetch when the path is not readable locally.
      }
    }

    if (!context.mounted) return;
    await RfiMediaViewerDialog.show(
      context,
      source: trimmed,
      dio: dio,
      title: title ?? _fileLabel(trimmed),
    );
  }

  static Future<void> viewLocalFile(
    BuildContext context, {
    required String localPath,
    String? title,
  }) async {
    final file = File(localPath);
    if (!await file.exists()) {
      if (!context.mounted) return;
      GlobalAlertDialog.show(
        context,
        title: 'File not found',
        message: 'The downloaded file is no longer available.',
        type: DialogType.error,
      );
      return;
    }

    final bytes = await file.readAsBytes();
    if (!context.mounted) return;
    await RfiLocalMediaViewerDialog.show(
      context,
      bytes: bytes,
      sourceHint: localPath,
      title: title ?? _fileLabel(localPath),
    );
  }

  /// Downloads to app-private storage and opens in the in-app viewer.
  static Future<void> download(
    BuildContext context, {
    required String path,
    required Dio dio,
    String? title,
  }) async {
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final savePath = await _downloadToAppStorage(
        dio: dio,
        path: path,
        preferredFileName: title,
      );

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      await viewLocalFile(
        context,
        localPath: savePath,
        title: title ?? _fileLabel(savePath),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      GlobalAlertDialog.show(
        context,
        title: 'Download failed',
        message: e.toString(),
        type: DialogType.error,
      );
    }
  }

  static Future<String> _downloadToAppStorage({
    required Dio dio,
    required String path,
    String? preferredFileName,
  }) async {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      throw Exception('Empty file path');
    }

    final dir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory(p.join(dir.path, 'rfi_downloads'));
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    var fileName = preferredFileName?.trim().isNotEmpty == true
        ? preferredFileName!.trim()
        : trimmed.split('/').last.split('?').first;
    if (fileName.isEmpty || fileName.contains('=')) {
      fileName = 'rfi_file_${DateTime.now().millisecondsSinceEpoch}.pdf';
    }
    fileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final savePath = p.join(downloadsDir.path, fileName);

    if (trimmed.contains('view-enclosure')) {
      final idMatch = RegExp(r'id=(\d+)').firstMatch(trimmed)?.group(1);
      if (idMatch != null) {
        await dio.download(
          'api/rfi/view-enclosure',
          savePath,
          queryParameters: <String, String>{'id': idMatch},
          options: Options(extra: <String, dynamic>{'silentError': true}),
        );
      } else {
        await dio.download(
          trimmed,
          savePath,
          options: Options(extra: <String, dynamic>{'silentError': true}),
        );
      }
    } else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      await dio.download(
        trimmed,
        savePath,
        options: Options(extra: <String, dynamic>{'silentError': true}),
      );
    } else if (RfiPreviewFetch.isRemoteInspectablePath(trimmed)) {
      final bytes = await RfiPreviewFetch.fetchBytes(dio, trimmed);
      await File(savePath).writeAsBytes(bytes);
    } else {
      try {
        final bytes = await RfiPreviewFetch.fetchBytes(dio, trimmed);
        await File(savePath).writeAsBytes(bytes);
      } catch (_) {
        final source = File(trimmed);
        if (!await source.exists()) {
          throw Exception('File does not exist');
        }
        await source.copy(savePath);
      }
    }

    final saved = File(savePath);
    if (!await saved.exists() || await saved.length() == 0) {
      throw Exception('Downloaded file is empty or missing');
    }

    final bytes = await saved.readAsBytes();
    if (bytes.length > 15) {
      final header = String.fromCharCodes(bytes.sublist(0, 15)).toLowerCase();
      if (header.contains('<!doctype') || header.contains('<html')) {
        await saved.delete();
        throw Exception('Server returned an error page instead of the file');
      }
    }

    return savePath;
  }

  static String _fileLabel(String path) {
    final label = path.split('/').last.split('?').first;
    return label.isEmpty ? 'Document' : label;
  }
}
