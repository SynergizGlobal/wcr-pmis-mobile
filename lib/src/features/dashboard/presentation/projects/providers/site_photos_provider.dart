import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/site_photo_row.dart';

final sitePhotosProvider =
    FutureProvider.family<List<SitePhotoRow>, String>((ref, String projectId) async {
  final List<Map<String, dynamic>> rows = await ref
      .read(dashboardRemoteDataSourceProvider)
      .fetchSitePhotos(projectId: projectId);
  return rows.map(SitePhotoRow.fromMap).toList();
});

final structurePhotoBytesProvider =
    FutureProvider.family<Uint8List, String>((ref, String fileName) async {
  return ref
      .read(dashboardRemoteDataSourceProvider)
      .fetchStructurePhotoBytes(fileName);
});
