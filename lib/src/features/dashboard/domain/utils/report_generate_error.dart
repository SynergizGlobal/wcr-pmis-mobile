import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

/// Thrown when the server returns no report file (e.g. HTTP 204 or empty body).
class ReportNoDataException implements Exception {
  const ReportNoDataException();

  @override
  String toString() => reportNoDataMessage;
}

const String reportNoDataTitle = 'No Data Found';

const String reportNoDataMessage =
    'Oops... No data found for this report. Try changing your filters and generate again.';

const String reportGenerateFailedTitle = 'Unable to Generate Report';

const String reportDownloadFailedTitle = 'Unable to Download Report';

const String reportGenerateFailedMessage =
    'Oops... Something went wrong while generating the report. Please try again.';

const String reportDownloadFailedMessage =
    'Oops... Something went wrong while downloading the report. Please try again.';

bool isReportNoDataError(Object error) {
  if (error is ReportNoDataException) {
    return true;
  }
  final String lower = error.toString().toLowerCase();
  return lower.contains('empty report received from server') ||
      lower.contains('no data found for this report');
}

void ensureReportHasData(List<int> bytes) {
  if (bytes.isEmpty) {
    throw const ReportNoDataException();
  }
}

String reportErrorTitle(
  Object error, {
  String generateFailureTitle = reportGenerateFailedTitle,
  String downloadFailureTitle = reportDownloadFailedTitle,
  bool isDownload = false,
}) {
  if (isReportNoDataError(error)) {
    return reportNoDataTitle;
  }
  return isDownload ? downloadFailureTitle : generateFailureTitle;
}

String reportErrorMessage(
  Object error, {
  bool isDownload = false,
}) {
  if (isReportNoDataError(error)) {
    return reportNoDataMessage;
  }
  return userFriendlyErrorMessage(
    error,
    fallback: isDownload
        ? reportDownloadFailedMessage
        : reportGenerateFailedMessage,
  );
}
