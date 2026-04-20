import 'package:wcr_pmis_mobile/src/app/bootstrap/bootstrap.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_config.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_flavor.dart';

void main() {
  bootstrap(
    const AppConfig(
      flavor: AppFlavor.prod,
      appName: 'WCR PMIS',
      baseUrl: String.fromEnvironment(
        'BASE_URL',
        defaultValue: 'https://api.example.com',
      ),
    ),
  );
}
