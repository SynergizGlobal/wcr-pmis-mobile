import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/app_update/app_update_service.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/core/providers/shared_prefs_provider.dart';

final appUpdateServiceProvider = Provider<AppUpdateService>((Ref ref) {
  return AppUpdateService(prefs: ref.watch(sharedPrefsProvider));
});
