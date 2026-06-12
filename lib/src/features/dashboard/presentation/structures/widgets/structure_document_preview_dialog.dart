import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/core/utils/rfi_media_utils.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/core/widgets/rfi_remote_media_preview.dart';

Future<void> showStructureDocumentPreview({
  required BuildContext context,
  required DashboardRemoteDataSource dataSource,
  String? remoteFileName,
  Uint8List? localBytes,
  String? localFileName,
  String? title,
}) async {
  final String fileLabel = _displayTitle(
    title: title,
    remoteFileName: remoteFileName,
    localFileName: localFileName,
  );
  final String sourceHint =
      localFileName?.trim().isNotEmpty == true
          ? localFileName!.trim()
          : remoteFileName?.trim() ?? fileLabel;

  if (localBytes != null && localBytes.isNotEmpty) {
    await _previewBytes(
      context,
      bytes: localBytes,
      sourceHint: sourceHint,
      title: fileLabel,
    );
    return;
  }

  final String remote = remoteFileName?.trim() ?? '';
  if (remote.isEmpty) {
    await AppDialog.show(
      context: context,
      title: 'Preview unavailable',
      message: 'No file is attached to preview.',
      type: AppDialogType.info,
    );
    return;
  }

  if (!context.mounted) {
    return;
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      );
    },
  );

  try {
    final Uint8List bytes = await dataSource.fetchStructurePhotoBytes(remote);
    if (!context.mounted) {
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();

    final RfiMediaKind kind = RfiMediaUtils.classify(remote, bytes);
    if (kind == RfiMediaKind.unsupported) {
      await _openBytesWithExternalApp(
        context,
        bytes: bytes,
        fileName: remote,
      );
      return;
    }

    if (!context.mounted) {
      return;
    }
    await _previewBytes(
      context,
      bytes: bytes,
      sourceHint: remote,
      title: fileLabel,
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
    await AppDialog.show(
      context: context,
      title: 'Preview failed',
      message: 'Unable to load this document. Please try again later.',
      type: AppDialogType.error,
    );
  }
}

Future<void> _previewBytes(
  BuildContext context, {
  required Uint8List bytes,
  required String sourceHint,
  required String title,
}) {
  return RfiLocalMediaViewerDialog.show(
    context,
    bytes: bytes,
    sourceHint: sourceHint,
    title: title,
  );
}

Future<void> _openBytesWithExternalApp(
  BuildContext context, {
  required Uint8List bytes,
  required String fileName,
}) async {
  try {
    final Directory dir = await getTemporaryDirectory();
    final String safeName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final String savePath = p.join(
      dir.path,
      'structure_preview_${DateTime.now().millisecondsSinceEpoch}_$safeName',
    );
    await File(savePath).writeAsBytes(bytes, flush: true);

    final OpenResult result = await OpenFile.open(savePath);
    if (!context.mounted) {
      return;
    }
    if (result.type != ResultType.done) {
      await AppDialog.show(
        context: context,
        title: 'Open file',
        message: result.message.trim().isNotEmpty
            ? result.message
            : 'No app found to open this file type. Install a compatible viewer and try again.',
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
      message: 'Unable to open this file on your device.',
      type: AppDialogType.error,
    );
  }
}

String _displayTitle({
  String? title,
  String? remoteFileName,
  String? localFileName,
}) {
  if (title != null && title.trim().isNotEmpty) {
    return title.trim();
  }
  if (localFileName != null && localFileName.trim().isNotEmpty) {
    return localFileName.trim();
  }
  if (remoteFileName != null && remoteFileName.trim().isNotEmpty) {
    return remoteFileName.trim();
  }
  return 'Document';
}
