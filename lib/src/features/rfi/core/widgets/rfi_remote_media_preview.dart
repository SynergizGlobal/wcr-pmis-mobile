import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdfx/pdfx.dart';

import '../utils/rfi_media_utils.dart';
import '../utils/rfi_preview_fetch.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

class RfiRemoteMediaPreview extends StatefulWidget {
  const RfiRemoteMediaPreview({
    super.key,
    required this.source,
    required this.dio,
    this.height,
    this.fit = BoxFit.contain,
    this.compact = false,
  });

  final String source;
  final Dio dio;
  final double? height;
  final BoxFit fit;
  final bool compact;

  @override
  State<RfiRemoteMediaPreview> createState() => _RfiRemoteMediaPreviewState();
}

class _RfiRemoteMediaPreviewState extends State<RfiRemoteMediaPreview> {
  Uint8List? _bytes;
  RfiMediaKind? _kind;
  PdfControllerPinch? _pdfController;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant RfiRemoteMediaPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _pdfController?.dispose();
      _pdfController = null;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _bytes = null;
      _kind = null;
    });

    try {
      if (widget.compact && RfiPreviewFetch.looksLikePdfPath(widget.source)) {
        if (mounted) {
          setState(() {
            _kind = RfiMediaKind.pdf;
            _loading = false;
          });
        }
        return;
      }

      await Future<void>.delayed(
        Duration(milliseconds: 80 + (widget.source.hashCode % 300)),
      );

      final bytes = await RfiPreviewFetch.fetchBytes(widget.dio, widget.source);
      final kind = RfiMediaUtils.classify(widget.source, bytes);

      if (!mounted) return;

      if (kind == RfiMediaKind.pdf) {
        if (!RfiPreviewFetch.looksLikePdfBytes(bytes)) {
          throw Exception('Downloaded file is not a valid PDF');
        }
        if (!widget.compact) {
          _pdfController = PdfControllerPinch(
            document: PdfDocument.openData(bytes),
          );
        }
      }

      setState(() {
        _bytes = bytes;
        _kind = kind;
        _loading = false;
      });
    } catch (e) {
      debugPrint('RfiRemoteMediaPreview error for ${widget.source}: $e');
      if (mounted) {
        setState(() {
          _error = userFriendlyErrorMessage(e);
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? 400;

    if (_loading) {
      return SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: height,
        child: _UnavailableMedia(message: _error!),
      );
    }

    switch (_kind) {
      case RfiMediaKind.pdf:
        if (widget.compact) {
          return _compactOpenTile(
            context,
            height,
            icon: Icons.picture_as_pdf,
            label: 'PDF — tap to view',
          );
        }
        if (_pdfController == null) {
          return SizedBox(
            height: height,
            child: const _UnavailableMedia(message: 'PDF unavailable'),
          );
        }
        return SizedBox(
          height: height,
          width: double.infinity,
          child: PdfViewPinch(controller: _pdfController!),
        );
      case RfiMediaKind.svg:
        if (_bytes == null) {
          return SizedBox(
            height: height,
            child: const _UnavailableMedia(message: 'SVG unavailable'),
          );
        }
        return SizedBox(
          height: height,
          width: double.infinity,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5,
            child: Center(
              child: SvgPicture.memory(
                _bytes!,
                fit: widget.fit,
              ),
            ),
          ),
        );
      case RfiMediaKind.raster:
        if (_bytes == null) {
          return SizedBox(
            height: height,
            child: const _UnavailableMedia(message: 'Image unavailable'),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5,
            child: Image.memory(
              _bytes!,
              fit: widget.fit,
              errorBuilder: (_, __, ___) => const _UnavailableMedia(
                message: 'Could not display image',
              ),
            ),
          ),
        );
      case RfiMediaKind.unsupported:
      case null:
        return SizedBox(
          height: height,
          child: const _UnavailableMedia(
            message: 'Unsupported file format',
          ),
        );
    }
  }

  Widget _compactOpenTile(
    BuildContext context,
    double height, {
    required IconData icon,
    required String label,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => RfiMediaViewerDialog.show(
          context,
          source: widget.source,
          dio: widget.dio,
        ),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: scheme.primary),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RfiMediaViewerDialog extends StatelessWidget {
  const RfiMediaViewerDialog({
    super.key,
    required this.source,
    required this.dio,
    this.title,
  });

  final String source;
  final Dio dio;
  final String? title;

  static Future<void> show(
    BuildContext context, {
    required String source,
    required Dio dio,
    String? title,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => RfiMediaViewerDialog(
        source: source,
        dio: dio,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog.fullscreen(
      backgroundColor: scheme.surface,
      child: Column(
        children: [
          AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              title ?? source.split('/').last.split('?').first,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: RfiRemoteMediaPreview(
              source: source,
              dio: dio,
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}

/// In-app preview for files already on device (app-private or readable paths).
class RfiLocalMediaViewerDialog extends StatelessWidget {
  const RfiLocalMediaViewerDialog({
    super.key,
    required this.bytes,
    required this.sourceHint,
    this.title,
  });

  final Uint8List bytes;
  final String sourceHint;
  final String? title;

  static Future<void> show(
    BuildContext context, {
    required Uint8List bytes,
    required String sourceHint,
    String? title,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => RfiLocalMediaViewerDialog(
        bytes: bytes,
        sourceHint: sourceHint,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog.fullscreen(
      backgroundColor: scheme.surface,
      child: Column(
        children: [
          AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              title ?? sourceHint.split('/').last.split('?').first,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: RfiMemoryMediaPreview(
              bytes: bytes,
              sourceHint: sourceHint,
            ),
          ),
        ],
      ),
    );
  }
}

class RfiMemoryMediaPreview extends StatefulWidget {
  const RfiMemoryMediaPreview({
    super.key,
    required this.bytes,
    required this.sourceHint,
    this.height,
    this.fit = BoxFit.contain,
  });

  final Uint8List bytes;
  final String sourceHint;
  final double? height;
  final BoxFit fit;

  @override
  State<RfiMemoryMediaPreview> createState() => _RfiMemoryMediaPreviewState();
}

class _RfiMemoryMediaPreviewState extends State<RfiMemoryMediaPreview> {
  PdfControllerPinch? _pdfController;
  RfiMediaKind? _kind;

  @override
  void initState() {
    super.initState();
    _kind = RfiMediaUtils.classify(widget.sourceHint, widget.bytes);
    if (_kind == RfiMediaKind.pdf) {
      if (!RfiPreviewFetch.looksLikePdfBytes(widget.bytes)) {
        _kind = RfiMediaKind.unsupported;
        return;
      }
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openData(widget.bytes),
      );
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? 400;

    switch (_kind) {
      case RfiMediaKind.pdf:
        if (_pdfController == null) {
          return SizedBox(
            height: height,
            child: const _UnavailableMedia(message: 'PDF unavailable'),
          );
        }
        return SizedBox(
          height: height,
          width: double.infinity,
          child: PdfViewPinch(controller: _pdfController!),
        );
      case RfiMediaKind.svg:
        return SizedBox(
          height: height,
          width: double.infinity,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5,
            child: Center(
              child: SvgPicture.memory(
                widget.bytes,
                fit: widget.fit,
              ),
            ),
          ),
        );
      case RfiMediaKind.raster:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5,
            child: Image.memory(
              widget.bytes,
              fit: widget.fit,
              errorBuilder: (_, __, ___) => const _UnavailableMedia(
                message: 'Could not display image',
              ),
            ),
          ),
        );
      case RfiMediaKind.unsupported:
      case null:
        return SizedBox(
          height: height,
          child: const _UnavailableMedia(
            message: 'Unsupported file format',
          ),
        );
    }
  }
}

class _UnavailableMedia extends StatelessWidget {
  const _UnavailableMedia({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: scheme.onSurfaceVariant, size: 48),
            const SizedBox(height: 8),
            Text(
              message.length > 120 ? '${message.substring(0, 120)}...' : message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
