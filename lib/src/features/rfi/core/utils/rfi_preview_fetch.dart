import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/core/network/environment.dart';

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

  static List<String> resolveFetchCandidates(String urlOrPath) {
    final trimmed = urlOrPath.trim();
    if (trimmed.isEmpty) return [];

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return [trimmed];
    }

    if (trimmed.contains('previewFiles')) {
      return [trimmed];
    }

    if (_extractViewEnclosureId(trimmed) != null) {
      return [trimmed];
    }

    if (_isAbsoluteServerPath(trimmed)) {
      return [trimmed];
    }

    if (trimmed.startsWith('api/')) {
      return [trimmed];
    }

    if (trimmed.contains('/')) {
      return [
        trimmed,
        '/home/ec2-user/uploads/$trimmed',
      ];
    }

    return _bareFileNameCandidates(trimmed);
  }

  static List<String> _bareFileNameCandidates(String fileName) {
    final lower = fileName.toLowerCase();
    final dirs = <String>[];

    if (lower.contains('supporting')) {
      dirs.addAll([
        '/home/ec2-user/uploads/rfi-inspections/',
        '/home/ec2-user/uploads/supporting-documents/',
        '/home/ec2-user/uploads/inspection-supporting/',
      ]);
    }
    if (lower.contains('enclosure')) {
      dirs.add('/home/ec2-user/uploads/rfi-enclosures/');
    }
    if (lower.contains('visual') ||
        lower.contains('site-doc') ||
        (lower.contains('report') && lower.contains('rfi_'))) {
      dirs.add('/home/ec2-user/uploads/inspection-site-documents/');
    }

    dirs.addAll([
      '/home/ec2-user/uploads/rfi-inspections/',
      '/home/ec2-user/uploads/rfi-enclosures/',
      '/home/ec2-user/uploads/inspection-site-documents/',
      '/home/ec2-user/uploads/',
    ]);

    return dirs.map((dir) => '$dir$fileName').toSet().toList();
  }

  static String resolvePublicUrl(String urlOrPath) {
    final candidates = resolveFetchCandidates(urlOrPath);
    if (candidates.isEmpty) return '';

    final primary = candidates.first;
    if (primary.startsWith('http://') || primary.startsWith('https://')) {
      return primary;
    }

    final enclosureId = _extractViewEnclosureId(primary);
    if (enclosureId != null) {
      return '${Environment.baseUrl}api/rfi/view-enclosure?id=$enclosureId';
    }

    if (_needsPreviewFilesEndpoint(primary)) {
      return '${Environment.baseUrl}api/validation/previewFiles?'
          'filepath=${Uri.encodeComponent(primary)}';
    }

    var path = primary;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return '${Environment.baseUrl}$path';
  }

  static Future<Uint8List> fetchBytes(Dio dio, String urlOrPath) async {
    final candidates = resolveFetchCandidates(urlOrPath);
    if (candidates.isEmpty) {
      throw Exception('Empty file path');
    }

    if (candidates.length == 1) {
      return _fetchBytesForCandidate(dio, candidates.first);
    }

    Object? lastError;
    for (final candidate in candidates) {
      try {
        return await _fetchBytesForCandidate(dio, candidate);
      } catch (e, st) {
        lastError = e;
        if (kDebugMode) {
          debugPrint('RfiPreviewFetch miss for $candidate: $e\n$st');
        }
      }
    }

    throw lastError ?? Exception('Failed to load file');
  }

  static Future<Uint8List> _fetchBytesForCandidate(
    Dio dio,
    String trimmed,
  ) async {
    if (trimmed.contains('previewFiles')) {
      final uri = Uri.parse(
        trimmed.startsWith('http') ? trimmed : resolvePublicUrl(trimmed),
      );
      final filepath = uri.queryParameters['filepath'];
      if (filepath != null && filepath.isNotEmpty) {
        return _fetchBytesForCandidate(dio, filepath);
      }
    }

    final enclosureId = _extractViewEnclosureId(trimmed);
    if (enclosureId != null) {
      final response = await dio.get<List<int>>(
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
      final response = await dio.get<List<int>>(
        'api/validation/previewFiles',
        queryParameters: <String, String>{'filepath': trimmed},
        options: _byteOptions,
      );
      return _validatePdfOrImageBytes(response.data, trimmed);
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final response = await dio.get<List<int>>(
        trimmed,
        options: _byteOptions,
      );
      return _validatePdfOrImageBytes(response.data, trimmed);
    }

    var relativePath = trimmed;
    if (relativePath.startsWith('/')) {
      relativePath = relativePath.substring(1);
    }

    final response = await dio.get<List<int>>(
      relativePath,
      options: _byteOptions,
    );
    return _validatePdfOrImageBytes(response.data, trimmed);
  }

  static String? _extractViewEnclosureId(String urlOrPath) {
    return _viewEnclosureIdPattern.firstMatch(urlOrPath)?.group(1);
  }

  static bool _needsPreviewFilesEndpoint(String path) {
    if (_isServerFilesystemPath(path)) return true;
    return path.startsWith('/home/ec2-user/') ||
        (path.startsWith('/') && !path.startsWith('/api/'));
  }

  static bool _isAbsoluteServerPath(String path) {
    return path.startsWith('/home/ec2-user/') ||
        path.startsWith('/home/') ||
        _isServerFilesystemPath(path);
  }

  static bool _isServerFilesystemPath(String path) {
    if (path.contains(r'\')) return true;
    return _windowsOrDrivePathPattern.hasMatch(path);
  }

  static Uint8List _validatePdfOrImageBytes(List<int>? data, String source) {
    if (data == null || data.isEmpty) {
      throw Exception('Empty response from server');
    }

    final bytes = Uint8List.fromList(data);

    if (bytes.length > 15) {
      final header =
          String.fromCharCodes(bytes.sublist(0, 15)).toLowerCase();
      if (header.contains('<!doctype') || header.contains('<html')) {
        throw Exception(
          'Server returned a login or error page instead of the file',
        );
      }
    }

    final looksLikePdf = bytes.length > 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;

    if (source.toLowerCase().endsWith('.pdf') && !looksLikePdf) {
      throw Exception('Downloaded file is not a valid PDF');
    }

    return bytes;
  }

  static bool looksLikePdfPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.svg') || lower.contains('.svg?')) return false;
    if (lower.contains('view-enclosure')) return true;
    if (lower.endsWith('.pdf')) return true;
    if (_needsPreviewFilesEndpoint(path)) {
      return !lower.endsWith('.jpg') &&
          !lower.endsWith('.jpeg') &&
          !lower.endsWith('.png') &&
          !lower.endsWith('.webp') &&
          !lower.endsWith('.gif') &&
          !lower.endsWith('.svg');
    }
    return false;
  }

  static bool looksLikeSvgPath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.svg') || lower.contains('.svg?');
  }

  static bool looksLikePdfBytes(Uint8List bytes) {
    return bytes.length > 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }

  /// Paths that must be fetched from the API — not readable as on-device files.
  static bool isRemoteInspectablePath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return true;
    }
    if (trimmed.contains('previewFiles') ||
        trimmed.contains('view-enclosure')) {
      return true;
    }
    if (trimmed.startsWith('api/')) return true;
    if (trimmed.startsWith('/home/') || trimmed.contains('ec2-user')) {
      return true;
    }
    return _needsPreviewFilesEndpoint(trimmed) || _isServerFilesystemPath(trimmed);
  }
}
