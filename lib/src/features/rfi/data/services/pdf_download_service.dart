import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import '../../core/utils/rfi_file_actions.dart';
import '../../core/widgets/global_alert_dialog.dart';

class PdfDownloadService {
  static Future<void> downloadAndOpenPdf({
    required BuildContext context,
    required Dio dio,
    required String rfiId,
    required String txnId,
  }) async {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final dir = await _downloadsDirectory();
      final savePath = '${dir.path}/${rfiId}_report.pdf';

      await dio.download(
        '/api/rfiLog/pdf/download/$rfiId/$txnId',
        savePath,
        options: Options(extra: {'silentError': true}),
      );

      final file = File(savePath);
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
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (!context.mounted) return;
      await RfiFileActions.viewLocalFile(
        context,
        localPath: savePath,
        title: '${rfiId}_report.pdf',
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
    final downloadsDir = Directory('${appDir.path}/rfi_downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir;
  }
}
