import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdf/widgets.dart' as pw;

import 'rfi_preview_fetch.dart';

enum RfiMediaKind { pdf, svg, raster, unsupported }

abstract final class RfiMediaUtils {
  static RfiMediaKind classify(String path, Uint8List bytes) {
    if (RfiPreviewFetch.looksLikePdfBytes(bytes)) {
      return RfiMediaKind.pdf;
    }
    if (looksLikeSvg(path, bytes)) {
      return RfiMediaKind.svg;
    }
    if (isRasterImageBytes(bytes)) {
      return RfiMediaKind.raster;
    }
    return RfiMediaKind.unsupported;
  }

  static bool looksLikeSvg(String path, [Uint8List? bytes]) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.svg') || lower.contains('.svg?')) {
      return true;
    }
    if (bytes == null || bytes.isEmpty) return false;
    final sample = bytes.length > 800 ? bytes.sublist(0, 800) : bytes;
    final sniff = String.fromCharCodes(sample).trimLeft().toLowerCase();
    return sniff.contains('<svg');
  }

  static bool isRasterImageBytes(Uint8List bytes) {
    if (bytes.length > 4 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return true; // JPEG
    }
    if (bytes.length > 8 && bytes[0] == 0x89 && bytes[1] == 0x50) {
      return true; // PNG
    }
    if (bytes.length > 3 && bytes[0] == 0x47 && bytes[1] == 0x49) {
      return true; // GIF
    }
    return false;
  }

  static Future<Uint8List?> toDisplayRasterBytes(
    String path,
    Uint8List rawBytes,
  ) async {
    final kind = classify(path, rawBytes);
    switch (kind) {
      case RfiMediaKind.raster:
        return isRasterImageBytes(rawBytes) ? rawBytes : null;
      case RfiMediaKind.svg:
        return rasterizeSvgToPng(rawBytes);
      case RfiMediaKind.pdf:
      case RfiMediaKind.unsupported:
        return null;
    }
  }

  static Future<pw.MemoryImage?> toPdfMemoryImage(
    String path,
    Uint8List rawBytes,
  ) async {
    if (path.toLowerCase().endsWith('.webp')) {
      debugPrint('Skipping WebP for PDF: $path');
      return null;
    }
    final raster = await toDisplayRasterBytes(path, rawBytes);
    if (raster == null || raster.isEmpty) return null;
    try {
      return pw.MemoryImage(raster);
    } catch (e) {
      debugPrint('PDF image decode failed for $path: $e');
      return null;
    }
  }

  static Future<Uint8List?> rasterizeSvgToPng(
    Uint8List svgBytes, {
    double targetWidth = 1024,
  }) async {
    try {
      final pictureInfo = await vg.loadPicture(
        SvgBytesLoader(svgBytes),
        null,
      );
      final size = pictureInfo.size;
      if (size.width <= 0 || size.height <= 0) {
        pictureInfo.picture.dispose();
        return null;
      }

      final scale = targetWidth / size.width;
      final height = (size.height * scale).ceil().clamp(1, 4096).toDouble();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.scale(scale);
      canvas.drawPicture(pictureInfo.picture);
      pictureInfo.picture.dispose();

      final picture = recorder.endRecording();
      final image = await picture.toImage(
        targetWidth.toInt(),
        height.toInt(),
      );
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return data?.buffer.asUint8List();
    } catch (e, st) {
      debugPrint('SVG rasterize error: $e\n$st');
      return null;
    }
  }
}
