class ReportFormArgs {
  const ReportFormArgs({
    required this.formId,
    required this.formName,
    this.webFormUrl,
    this.mobileFormUrl,
    this.parentFormName,
  });

  final String formId;
  final String formName;
  final String? webFormUrl;
  final String? mobileFormUrl;
  final String? parentFormName;

  String get routeKey => formId.trim().isNotEmpty
      ? formId.trim()
      : (webFormUrl ?? mobileFormUrl ?? formName).trim();
}
