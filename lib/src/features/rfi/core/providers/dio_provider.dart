import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/rfi_dio_client.dart';

/// Bridge for ported standalone RFI code that expects [dioProvider].
final dioProvider = Provider<Dio>((Ref ref) => ref.watch(rfiDioProvider));
