import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/core/network/environment.dart';

/// Loads RFI enclosure / preview media through the authenticated RFI [Dio] client.
abstract final class RfiPreviewFetch {
  static Options get _byteOptions => Options(
        responseType: ResponseType.bytes,
        extra: const <String, dynamic>{'silentError': true},
        receiveTimeout: const Duration(seconds: 90),
      );

  static final RegExp _viewEnclosureIdPattern = RegExp(
    r'view-enclosure\?id=(\d+)',
    caseSensitive: false,
  );

  static final RegExp _windowsOrDrivePathPattern = RegExp(r'^[A-Za-z]:[/\\]');

  /// Resolves a server path or URL to a public URL (for display / sharing).
  static String resolvePublicUrl(String urlOrPath) {
    final String trimmed = urlOrPath.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final String? enclosureId = _extractViewEnclosureId(trimmed);
    if (enclosureId != null) {
      return '${Environment.baseUrl}api/rfi/view-enclosure?id=$enclosureId';
    }

    final String baseUrl = Environment.baseUrl;

    if (_needsPreviewFilesEndpoint(trimmed)) {
      return '${baseUrl}api/validation/previewFiles?'
          'filepath=${Uri.encodeComponent(trimmed)}';
    }

    var path = trimmed;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return '$baseUrl$path';
  }

  /// Downloads file bytes using RFI auth (Bearer + cookies on [dio]).
  static Future<Uint8List> fetchBytes(Dio dio, String urlOrPath) async {
    final String trimmed = urlOrPath.trim();
    if (trimmed.isEmpty) {
      throw Exception('Empty file path');
    }

    // Already a previewFiles URL — re-fetch via relative API route.
    if (trimmed.contains('previewFiles')) {
      final Uri uri = Uri.parse(
        trimmed.startsWith('http') ? trimmed : resolvePublicUrl(trimmed),
      );
      final String? filepath = uri.queryParameters['filepath'];
      if (filepath != null && filepath.isNotEmpty) {
        return fetchBytes(dio, filepath);
      }
    }

    // Enclosure by DB id — same endpoint as download (must use relative path on [dio]).
    final String? enclosureId = _extractViewEnclosureId(trimmed);
    if (enclosureId != null) {
      final Response<List<int>> response = await dio.get<List<int>>(
        'api/rfi/view-enclosure',
        queryParameters: <String, String>{'id': enclosureId},
        options: _byteOptions,
      );
      return _validatePdfOrImageBytes(
        response.data,
        'enclosure_$enclosureId.pdf',
      );
    }

    if (_needsPreviewFilesEndpoint(trimmed)) {
      final Response<List<int>> response = await dio.get<List<int>>(
        'api/validation/previewFiles',
        queryParameters: <String, String>{'filepath': trimmed},
        options: _byteOptions,
      );
      return _validatePdfOrImageBytes(response.data, trimmed);
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final Response<List<int>> response = await dio.get<List<int>>(
        trimmed,
        options: _byteOptions,
      );
      return _validatePdfOrImageBytes(response.data, trimmed);
    }

    var relativePath = trimmed;
    if (relativePath.startsWith('/')) {
      relativePath = relativePath.substring(1);
    }

    final Response<List<int>> response = await dio.get<List<int>>(
      relativePath,
      options: _byteOptions,
    );
    return _validatePdfOrImageBytes(response.data, trimmed);
  }

  static String? _extractViewEnclosureId(String urlOrPath) {
    return _viewEnclosureIdPattern.firstMatch(urlOrPath)?.group(1);
  }

  static bool _needsPreviewFilesEndpoint(String path) {
    if (_isServerFilesystemPath(path)) {
      return true;
    }
    return path.startsWith('/home/ec2-user/') ||
        (path.startsWith('/') && !path.startsWith('/api/'));
  }

  /// Absolute server paths (Linux or Windows) that must go through previewFiles.
  static bool _isServerFilesystemPath(String path) {
    if (path.contains(r'\')) {
      return true;
    }
    return _windowsOrDrivePathPattern.hasMatch(path);
  }

  static Uint8List _validatePdfOrImageBytes(List<int>? data, String source) {
    if (data == null || data.isEmpty) {
      throw Exception('Empty response from server');
    }

    final Uint8List bytes = Uint8List.fromList(data);

    if (bytes.length > 15) {
      final String header =
          String.fromCharCodes(bytes.sublist(0, 15)).toLowerCase();
      if (header.contains('<!doctype') || header.contains('<html')) {
        throw Exception(
          'Server returned a login or error page instead of the file',
        );
      }
    }

    final bool looksLikePdf = bytes.length > 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;

    if (source.toLowerCase().endsWith('.pdf') && !looksLikePdf) {
      debugPrint('RfiPreviewFetch: expected PDF for $source');
      throw Exception('Downloaded file is not a valid PDF');
    }

    return bytes;
  }

  static bool looksLikePdfPath(String path) {
    final lower = path.toLowerCase();
    if (lower.contains('view-enclosure')) return true;
    if (lower.endsWith('.pdf')) return true;
    if (_needsPreviewFilesEndpoint(path)) {
      return !lower.endsWith('.jpg') &&
          !lower.endsWith('.jpeg') &&
          !lower.endsWith('.png') &&
          !lower.endsWith('.webp');
    }
    return false;
  }

  static bool looksLikePdfBytes(Uint8List bytes) {
    return bytes.length > 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }
}
