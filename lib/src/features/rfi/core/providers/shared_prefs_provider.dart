import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((Ref ref) {
  throw UnimplementedError('SharedPreferences must be overridden at app root');
});
