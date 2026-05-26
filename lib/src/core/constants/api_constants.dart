class ApiConstants {
  const ApiConstants._();

  static const bool useQaServer = true;

  static const String wcrQaBaseUrl =
      'https://pmis-wcrindianrailways.org/wcrpmis_qa/';

  static const String wcrProdBaseUrl =
      'https://pmis-wcrindianrailways.org/wcrpmis/';

  static const String rfiQaBaseUrl =
      'https://pmis-wcrindianrailways.org/rfiSystem_qa/';

  static const String rfiProdBaseUrl =
      'https://pmis-wcrindianrailways.org/rfiSystem/';

  static const String wcrHomePath = 'home';
  static const String wcrLoginPath = 'login';
  static const String wcrRfiRedirectPath = 'rfi/redirect';
  static const String rfiSsoLoginPath = '/api/auth/login';
  static const String rfiDashboardPath = 'dashboard';

  static String get wcrBaseUrl {
    const String fromEnv = String.fromEnvironment('BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return useQaServer ? wcrQaBaseUrl : wcrProdBaseUrl;
  }

  static String get baseUrl => wcrBaseUrl;

  static String get rfiBaseUrl => useQaServer ? rfiQaBaseUrl : rfiProdBaseUrl;

  static Uri originUriFor(String baseUrl) {
    final Uri parsed = Uri.parse(baseUrl);
    return Uri(
      scheme: parsed.scheme,
      host: parsed.host,
      port: parsed.hasPort ? parsed.port : null,
    );
  }

  static Uri get wcrOriginUri => originUriFor(wcrBaseUrl);

  static Uri get rfiOriginUri => originUriFor(rfiBaseUrl);

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
