class ApiConstants {
  const ApiConstants._();

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
  static const String forgotSendOtpPath = '/api/forgot/send-otp';
  static const String forgotVerifyOtpPath = '/api/forgot/verify-otp';
  static const String forgotResetPasswordPath = '/api/forgot/reset-password';
  static const String deviceTokenRegisterPath =
      '/api/auth/device-tokens/register';
  static const String deviceTokenDeactivatePath =
      '/api/auth/device-tokens/deactivate';
  static const String authLogoutPath = '/logout';
  static const String wcrRfiRedirectPath = 'rfi/redirect';
  static const String rfiSsoLoginPath = '/api/auth/login';
  static const String rfiDashboardPath = 'dashboard';

  static Uri originUriFor(String baseUrl) {
    final Uri parsed = Uri.parse(baseUrl);
    return Uri(
      scheme: parsed.scheme,
      host: parsed.host,
      port: parsed.hasPort ? parsed.port : null,
    );
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 45);
}
