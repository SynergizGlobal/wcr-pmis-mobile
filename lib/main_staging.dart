import 'package:wcr_pmis_mobile/src/app/bootstrap/bootstrap.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_config.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_flavor.dart';

void main() {
  bootstrap(
    const AppConfig(
      flavor: AppFlavor.staging,
      appName: 'WCR PMIS Staging',
      baseUrl: String.fromEnvironment(
        'BASE_URL',
        defaultValue: 'https://staging-api.example.com',
      ),
    ),
  );
}
