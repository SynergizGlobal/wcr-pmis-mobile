import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

class NetworkConnectivity {
  const NetworkConnectivity();

  static const String noInternetMessage = noInternetUserMessage;

  Future<bool> hasConnection() async {
    try {
      final List<InternetAddress> result = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on Exception {
      return false;
    }
  }

  Future<void> ensureConnected(RequestOptions options) async {
    final bool connected = await hasConnection();
    if (connected) {
      return;
    }
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      message: noInternetMessage,
    );
  }
}

final networkConnectivityProvider = Provider<NetworkConnectivity>((ref) {
  return const NetworkConnectivity();
});
