import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One-shot message shown on [LoginPage] after forced logout (e.g. session expired).
final loginNoticeProvider = StateProvider<String?>((ref) => null);
