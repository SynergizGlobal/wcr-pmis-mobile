import 'package:wcr_pmis_mobile/src/app/bootstrap/bootstrap.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_config.dart';
import 'package:wcr_pmis_mobile/src/core/constants/api_constants.dart';
import 'package:wcr_pmis_mobile/src/core/constants/legal_constants.dart';

Future<void> main() async {
  await bootstrap(
    AppConfig(
      appName: ApiConstants.useQaServer
          ? '${LegalConstants.onDeviceAppName} (QA)'
          : LegalConstants.onDeviceAppName,
      baseUrl: ApiConstants.baseUrl,
    ),
  );
}
