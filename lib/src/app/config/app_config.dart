import 'package:wcr_pmis_mobile/src/app/config/app_flavor.dart';

class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
  });

  final AppFlavor flavor;
  final String appName;
  final String baseUrl;
}
