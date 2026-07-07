import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/report_generate_error.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/report_file_export.dart';

typedef DirectReportDownload =
    Future<({Uint8List bytes, String? fileName})> Function();

Future<void> runDirectReportDownload({
  required BuildContext context,
  required DirectReportDownload download,
  required String defaultFileName,
  String? reportTitle,
}) async {
  if (!context.mounted) {
    return;
  }

  final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: <Widget>[
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  reportTitle == null || reportTitle.trim().isEmpty
                      ? 'Downloading report...'
                      : 'Downloading $reportTitle...',
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  try {
    final ({Uint8List bytes, String? fileName}) result = await download();
    if (navigator.mounted) {
      navigator.pop();
    }
    if (!context.mounted) {
      return;
    }

    ensureReportHasData(result.bytes);
    final String fileName = result.fileName?.trim().isNotEmpty == true
        ? result.fileName!.trim()
        : '${defaultFileName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final String path = await ReportFileExport.save(
      fileName: fileName,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      bytes: result.bytes,
    );
    if (!context.mounted) {
      return;
    }
    await ReportFileExport.showGeneratedDialog(
      context: context,
      savedPath: path,
      bytes: result.bytes,
      fileName: fileName,
    );
  } catch (error) {
    if (navigator.mounted) {
      navigator.pop();
    }
    if (context.mounted) {
      await AppDialog.show(
        context: context,
        title: reportErrorTitle(error, isDownload: true),
        message: reportErrorMessage(error, isDownload: true),
        type: AppDialogType.error,
      );
    }
  }
}

class DirectDownloadReportScreen extends StatefulWidget {
  const DirectDownloadReportScreen({
    super.key,
    required this.args,
    required this.download,
    required this.defaultFileName,
    this.fallbackTitle,
  });

  final ReportFormArgs args;
  final DirectReportDownload download;
  final String defaultFileName;
  final String? fallbackTitle;

  @override
  State<DirectDownloadReportScreen> createState() =>
      _DirectDownloadReportScreenState();
}

class _DirectDownloadReportScreenState extends State<DirectDownloadReportScreen> {
  bool _downloading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _downloadReport());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String title = widget.args.formName.trim().isNotEmpty
        ? widget.args.formName.trim()
        : widget.fallbackTitle ?? 'Report';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (_downloading)
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(),
                    )
                  else
                    Icon(
                      _errorMessage == null
                          ? Icons.downloading_outlined
                          : Icons.error_outline,
                      size: 56,
                      color: _errorMessage == null
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _downloading
                        ? 'Downloading report...'
                        : _errorMessage ??
                            'Report download will start automatically.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_errorMessage != null && !_downloading) ...<Widget>[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _downloadReport,
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadReport() async {
    setState(() {
      _downloading = true;
      _errorMessage = null;
    });
    try {
      final ({Uint8List bytes, String? fileName}) result =
          await widget.download();
      ensureReportHasData(result.bytes);
      final String fileName = result.fileName?.trim().isNotEmpty == true
          ? result.fileName!.trim()
          : '${widget.defaultFileName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final String path = await ReportFileExport.save(
        fileName: fileName,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        bytes: result.bytes,
      );
      if (!mounted) {
        return;
      }
      await ReportFileExport.showGeneratedDialog(
        context: context,
        savedPath: path,
        bytes: result.bytes,
        fileName: fileName,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = reportErrorMessage(error, isDownload: true);
      });
      await AppDialog.show(
        context: context,
        title: reportErrorTitle(error, isDownload: true),
        message: reportErrorMessage(error, isDownload: true),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _downloading = false);
      }
    }
  }
}
