import 'package:wcr_pmis_mobile/src/core/config/env.dart';
import 'package:wcr_pmis_mobile/src/core/constants/api_constants.dart';

/// App-wide API environment. Call [init] once from `main` before [runApp].
abstract final class Environment {
  static String? _current;

  static void init(String env) {
    if (env != Env.prod && env != Env.qa) {
      throw ArgumentError.value(
        env,
        'env',
        'Must be Env.prod or Env.qa',
      );
    }
    _current = env;
  }

  static String get current {
    final String? env = _current;
    if (env == null) {
      throw StateError(
        'Environment.init(Env.prod) or Environment.init(Env.qa) '
        'must be called before using the app.',
      );
    }
    return env;
  }

  static bool get isProd => current == Env.prod;

  static bool get isQa => current == Env.qa;

  static String get wcrBaseUrl =>
      isQa ? ApiConstants.wcrQaBaseUrl : ApiConstants.wcrProdBaseUrl;

  static String get rfiBaseUrl =>
      isQa ? ApiConstants.rfiQaBaseUrl : ApiConstants.rfiProdBaseUrl;

  static Uri get wcrOriginUri => ApiConstants.originUriFor(wcrBaseUrl);

  static Uri get rfiOriginUri => ApiConstants.originUriFor(rfiBaseUrl);
}
