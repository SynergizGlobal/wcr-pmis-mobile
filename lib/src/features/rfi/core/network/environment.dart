import 'package:wcr_pmis_mobile/src/core/config/environment.dart' as pmis;

/// RFI module API base URL (resolved from [pmis.Environment]).
abstract final class Environment {
  static String get baseUrl => pmis.Environment.rfiBaseUrl;
}
