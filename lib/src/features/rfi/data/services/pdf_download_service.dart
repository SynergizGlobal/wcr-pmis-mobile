import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/utils/rfi_file_actions.dart';
import '../../core/utils/rfi_log_pdf_paths.dart';
import '../../core/widgets/global_alert_dialog.dart';

class PdfDownloadService {
  static Future<void> downloadAndOpenPdf({
    required BuildContext context,
    required Dio dio,
    required String rfiId,
    required String txnId,
  }) async {
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final dir = await _downloadsDirectory();
      final String normalizedRfiId = RfiLogPdfPaths.downloadRfiId(rfiId);
      final safeRfiId = normalizedRfiId.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final fileName = '${safeRfiId}_report.pdf';
      final savePath = p.join(dir.path, fileName);

      await _downloadPdfWithFallback(
        dio: dio,
        rfiId: rfiId,
        txnId: txnId,
        savePath: savePath,
      );

      await _validatePdfFile(File(savePath));

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (!context.mounted) return;

      await RfiFileActions.openDownloadedWithSystemViewer(
        context,
        savePath: savePath,
        fileName: fileName,
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        final msg = e is DioException
            ? _downloadErrorMessage(e)
            : 'Download failed. Please try again.';
        GlobalAlertDialog.show(
          context,
          title: 'Download failed',
          message: msg,
          type: DialogType.error,
        );
      }
    }
  }

  /// Tries web-style id (`/` → `_`) first, then raw API id if the server 404s.
  static Future<void> _downloadPdfWithFallback({
    required Dio dio,
    required String rfiId,
    required String txnId,
    required String savePath,
  }) async {
    final List<String> paths = RfiLogPdfPaths.downloadPathCandidates(
      rfiId: rfiId,
      txnId: txnId,
    );

    DioException? lastDioError;
    for (var i = 0; i < paths.length; i++) {
      final String path = paths[i];
      try {
        await dio.download(
          path,
          savePath,
          options: Options(extra: {'silentError': true}),
        );
        return;
      } on DioException catch (e) {
        final bool isNotFound = e.response?.statusCode == 404;
        final bool hasAnotherCandidate = i < paths.length - 1;
        if (isNotFound && hasAnotherCandidate) {
          if (kDebugMode) {
            debugPrint(
              'RFI PDF download 404 for $path — retrying with alternate rfiId format',
            );
          }
          lastDioError = e;
          continue;
        }
        rethrow;
      }
    }

    if (lastDioError != null) {
      throw lastDioError;
    }
  }

  static Future<void> _validatePdfFile(File file) async {
    if (!await file.exists() || await file.length() == 0) {
      throw Exception('Downloaded file is empty or missing');
    }

    final bytes = await file.readAsBytes();
    if (bytes.length > 15) {
      final header = String.fromCharCodes(bytes.sublist(0, 15)).toLowerCase();
      if (header.contains('<!doctype') || header.contains('<html')) {
        await file.delete();
        throw Exception('Server returned an error page instead of a PDF');
      }
    }
  }

  static String _downloadErrorMessage(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map && responseData['error'] != null) {
      return responseData['error'].toString();
    }
    if (responseData is Map && responseData['message'] != null) {
      return responseData['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Download timed out. Please check your connection and retry.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network and retry.';
    }
    return 'Unable to download report right now. Please try again.';
  }

  static Future<Directory> _downloadsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory(p.join(appDir.path, 'rfi_downloads'));
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir;
  }
}
