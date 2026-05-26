import 'package:wcr_pmis_mobile/src/core/constants/api_constants.dart';

abstract final class Environment {
  static String get baseUrl => ApiConstants.rfiBaseUrl;
}
