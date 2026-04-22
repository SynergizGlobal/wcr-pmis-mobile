class ApiConstants {
  const ApiConstants._();

  /// Manually flip to `false` when you want the production base URL.
  static const bool useDevServer = true;

  static const String devBaseUrl = 'http://115.124.125.227:92/wcrpmis_qa/';
  static const String prodBaseUrl = 'http://115.124.125.227:8444/wcrpmis/';

  /// Optional override: `flutter run --dart-define=BASE_URL=https://.../`
  static String get baseUrl {
    const String fromEnv = String.fromEnvironment('BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return useDevServer ? devBaseUrl : prodBaseUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
