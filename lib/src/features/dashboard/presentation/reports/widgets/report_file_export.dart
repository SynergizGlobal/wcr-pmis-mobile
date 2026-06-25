import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/core/utils/rfi_media_utils.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/core/widgets/rfi_remote_media_preview.dart';

class ReportFileExport {
  ReportFileExport._();

  static const MethodChannel _channel = MethodChannel(
    'wcr_pmis_mobile/file_export',
  );

  static Future<String> save({
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    if (Platform.isAndroid) {
      try {
        final String? relativePath = await _channel.invokeMethod<String>(
          'saveToDownloads',
          <String, dynamic>{
            'fileName': fileName,
            'mimeType': mimeType,
            'bytes': bytes,
            'subdirectory': 'WCR Documents',
          },
        );
        if (relativePath != null && relativePath.isNotEmpty) {
          return relativePath;
        }
      } on MissingPluginException {
      } on PlatformException {
      }
    }
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static Future<void> showGeneratedDialog({
    required BuildContext context,
    required String savedPath,
    required List<int> bytes,
    required String fileName,
  }) {
    return AppDialog.show(
      context: context,
      title: 'Report Generated',
      message: 'File saved to:\n$savedPath',
      type: AppDialogType.success,
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'OK'),
        AppDialogAction(
          label: 'Preview',
          isPrimary: true,
          onPressed: () {
            preview(
              context: context,
              bytes: bytes,
              fileName: fileName,
            );
          },
        ),
      ],
    );
  }

  static Future<void> preview({
    required BuildContext context,
    required List<int> bytes,
    required String fileName,
  }) async {
    if (bytes.isEmpty) {
      if (!context.mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Preview unavailable',
        message: 'The report file is empty.',
        type: AppDialogType.error,
      );
      return;
    }

    final Uint8List data = Uint8List.fromList(bytes);
    final RfiMediaKind kind = RfiMediaUtils.classify(fileName, data);
    if (kind == RfiMediaKind.pdf) {
      if (!context.mounted) {
        return;
      }
      await RfiLocalMediaViewerDialog.show(
        context,
        bytes: data,
        sourceHint: fileName,
        title: fileName,
      );
      return;
    }

    await _openWithExternalApp(
      context: context,
      bytes: data,
      fileName: fileName,
    );
  }

  static Future<void> _openWithExternalApp({
    required BuildContext context,
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final Directory dir = await getTemporaryDirectory();
      final String safeName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final String savePath =
          '${dir.path}/report_preview_${DateTime.now().millisecondsSinceEpoch}_$safeName';
      await File(savePath).writeAsBytes(bytes, flush: true);

      final OpenResult result = await OpenFile.open(savePath);
      if (!context.mounted) {
        return;
      }
      if (result.type != ResultType.done) {
        await AppDialog.show(
          context: context,
          title: 'Preview unavailable',
          message: result.message.trim().isNotEmpty
              ? result.message
              : 'No app found to open this file type. Install Excel, Word, or a compatible viewer and try again.',
          type: AppDialogType.info,
        );
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Preview failed',
        message: 'Unable to open this report on your device.',
        type: AppDialogType.error,
      );
    }
  }
}
