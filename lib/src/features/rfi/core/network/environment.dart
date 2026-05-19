import 'package:wcr_pmis_mobile/src/core/constants/api_constants.dart';

/// Bridge for ported standalone RFI code that reads [Environment.baseUrl].
abstract final class Environment {
  static String get baseUrl => ApiConstants.rfiBaseUrl;
}
