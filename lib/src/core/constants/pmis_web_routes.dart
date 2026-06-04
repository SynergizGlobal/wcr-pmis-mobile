import 'package:wcr_pmis_mobile/src/core/constants/api_constants.dart';

enum PmisEmbeddedWebPage {
  executionOverview('execution-overview'),
  progressTable('progress-table');

  const PmisEmbeddedWebPage(this.pathSegment);

  final String pathSegment;

  String urlForProject(String projectId) {
    final String trimmed = projectId.trim();
    final String encoded = Uri.encodeComponent(trimmed);
    return '${ApiConstants.wcrBaseUrl}$pathSegment/$encoded';
  }
}
