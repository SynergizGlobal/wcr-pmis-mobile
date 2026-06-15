import 'package:dio/dio.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

String rfiDioErrorMessage(DioException error) => userFriendlyErrorMessage(error);
