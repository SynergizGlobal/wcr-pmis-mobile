import 'package:wcr_pmis_mobile/src/app/bootstrap/bootstrap.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_config.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_flavor.dart';
import 'package:wcr_pmis_mobile/src/core/constants/api_constants.dart';

void main() {
  bootstrap(
    const AppConfig(
      flavor: AppFlavor.dev,
      appName: 'WCR PMIS Dev',
      baseUrl: ApiConstants.baseUrl,
    ),
  );
}
