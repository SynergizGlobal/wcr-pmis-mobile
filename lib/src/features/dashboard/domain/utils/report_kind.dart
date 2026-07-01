import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';

enum ReportKind {
  contractDetail,
  listOfContractors,
  listOfContracts,
  bgInsuranceReport,
  dateOfCompletionReport,
  bgContractualLetters,
  insuranceContractualLetters,
  docContractualLetters,
  contractWiseActivities,
  progressReport,
  fobProgressReport,
  tpcProgressReport,
  stationImprovementsReport,
  pendingIssuesReport,
  issuesSummaryReport,
  issueDetailsReport,
  landAcquisitionReport,
  utilityReport,
  unknown,
}

ReportKind resolveReportKind(ReportFormArgs args) {
  final String formId = args.formId.trim();
  final String url = _normalize(args.webFormUrl ?? args.mobileFormUrl ?? '');
  final String name = _normalize(args.formName);

  final ReportKind? fromName = _resolveReportKindFromName(name);
  if (fromName != null) {
    return fromName;
  }

  return switch (formId) {
    '285' => ReportKind.contractDetail,
    '290' => ReportKind.listOfContractors,
    '1335' => ReportKind.listOfContracts,
    '1336' => ReportKind.bgInsuranceReport,
    '1337' => ReportKind.dateOfCompletionReport,
    '1369' => ReportKind.bgContractualLetters,
    '1370' => ReportKind.insuranceContractualLetters,
    '1371' => ReportKind.docContractualLetters,
    '1319' => ReportKind.contractWiseActivities,
    '275' => ReportKind.progressReport,
    '305' => ReportKind.fobProgressReport,
    'progress-tcp' => ReportKind.tpcProgressReport,
    'progress-station-improvements' => ReportKind.stationImprovementsReport,
    '296' => ReportKind.pendingIssuesReport,
    '297' => ReportKind.issuesSummaryReport,
    '298' => ReportKind.issueDetailsReport,
    '1316' => ReportKind.landAcquisitionReport,
    '1317' || '1323' => ReportKind.utilityReport,
    _ => _resolveReportKindFromUrl(url),
  };
}

ReportKind _resolveReportKindFromUrl(String url) {
  if (url.contains('contract-report/2')) {
    return ReportKind.contractDetail;
  }
  if (url.contains('contractorslist')) {
    return ReportKind.listOfContractors;
  }
  if (url.contains('contract-report/7')) {
    return ReportKind.listOfContracts;
  }
  if (url.contains('contract-report/8')) {
    return ReportKind.bgInsuranceReport;
  }
  if (url.contains('contract-report/9')) {
    return ReportKind.dateOfCompletionReport;
  }
  if (url.contains('bg-contractual-letters')) {
    return ReportKind.bgContractualLetters;
  }
  if (url.contains('insurance-contractual-letters')) {
    return ReportKind.insuranceContractualLetters;
  }
  if (url.contains('doc-contractual-letters')) {
    return ReportKind.docContractualLetters;
  }
  if (url.contains('activities-export-report')) {
    return ReportKind.contractWiseActivities;
  }
  if (url.contains('tpc-status-report') || url.contains('tcp-progress')) {
    return ReportKind.tpcProgressReport;
  }
  if (url.contains('station-improvements-report') ||
      url.contains('station-improvements')) {
    return ReportKind.stationImprovementsReport;
  }
  if (url.contains('progress-report') || url.contains('mcdo-progress-report')) {
    return ReportKind.progressReport;
  }
  if (url.contains('issues-report')) {
    return ReportKind.pendingIssuesReport;
  }
  if (url.contains('generate-issues-summary-report')) {
    return ReportKind.issuesSummaryReport;
  }
  if (url.contains('issue-details-report')) {
    return ReportKind.issueDetailsReport;
  }
  if (url.contains('la-report')) {
    return ReportKind.landAcquisitionReport;
  }
  if (url.contains('utility-report')) {
    return ReportKind.utilityReport;
  }
  return ReportKind.unknown;
}

ReportKind? _resolveReportKindFromName(String name) {
  if (name.contains('station improvements') ||
      name.contains('station-improvements')) {
    return ReportKind.stationImprovementsReport;
  }
  if (name == 'tcp' ||
      name.contains('tcp ') ||
      name.startsWith('tcp') ||
      name.contains('tpc')) {
    return ReportKind.tpcProgressReport;
  }
  return null;
}

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
