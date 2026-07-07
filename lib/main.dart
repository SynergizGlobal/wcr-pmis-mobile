import 'package:wcr_pmis_mobile/src/app/bootstrap/bootstrap.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_config.dart';
import 'package:wcr_pmis_mobile/src/core/config/env.dart';
import 'package:wcr_pmis_mobile/src/core/config/environment.dart';
import 'package:wcr_pmis_mobile/src/core/constants/legal_constants.dart';

Future<void> main() async {
  Environment.init(Env.prod);

  await bootstrap(
    AppConfig(
      appName: Environment.isQa
          ? '${LegalConstants.onDeviceAppName} (QA)'
          : LegalConstants.onDeviceAppName,
      baseUrl: Environment.wcrBaseUrl,
    ),
  );
}
