import 'package:flutter_riverpod/flutter_riverpod.dart';

final authTokenProvider = StateProvider<String?>((ref) => null);

final rfiAuthTokenProvider = StateProvider<String?>((ref) => null);

/// True while a WCR login session is active (cookie-based; JWT may be empty).
final wcrSessionActiveProvider = StateProvider<bool>((ref) => false);
