import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/dio_client.dart';
import 'package:wcr_pmis_mobile/src/features/support_chat/domain/entities/support_chat_message.dart';

class SupportChatRemoteDataSource {
  const SupportChatRemoteDataSource(this._dio);

  final Dio _dio;

  Future<SupportChatSendResult> sendMessage({
    int? chatId,
    required String message,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/chat/send',
      data: <String, dynamic>{
        'chatId': chatId,
        'message': message,
      },
    );
    final dynamic data = response.data;
    if (data is! Map) {
      throw const FormatException('Unexpected send chat response.');
    }
    return SupportChatSendResult.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<SupportChatConversationResult> fetchConversation(int chatId) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/chat/conversation/$chatId',
    );
    return _parseConversation(response.data);
  }

  Future<SupportChatStatus> fetchStatus(int chatId) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/chat/status/$chatId',
    );
    final dynamic data = response.data;
    if (data is! Map) {
      return SupportChatStatus.unknown;
    }
    return _parseStatus(Map<String, dynamic>.from(data)['status']);
  }

  Future<void> closeChat(int chatId) async {
    await _dio.post<dynamic>('/chat/close/$chatId');
  }

  SupportChatConversationResult _parseConversation(dynamic data) {
    if (data is Map) {
      return SupportChatConversationResult(
        messages: _parseMessageList(
          Map<String, dynamic>.from(data)['messages'] ??
              Map<String, dynamic>.from(data)['data'] ??
              data,
        ),
      );
    }
    if (data is List) {
      final List<SupportChatMessage> messages = <SupportChatMessage>[];
      for (final dynamic item in data) {
        if (item is! Map) {
          continue;
        }
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        final SupportChatMessage? message = SupportChatMessage.fromJson(map);
        if (message != null) {
          messages.add(message);
        }
      }
      messages.sort(
        (SupportChatMessage a, SupportChatMessage b) {
          final DateTime? left = a.createdDate;
          final DateTime? right = b.createdDate;
          if (left == null && right == null) {
            return a.id.compareTo(b.id);
          }
          if (left == null) {
            return -1;
          }
          if (right == null) {
            return 1;
          }
          return left.compareTo(right);
        },
      );
      return SupportChatConversationResult(
        messages: messages,
      );
    }
    return const SupportChatConversationResult(
      messages: <SupportChatMessage>[],
    );
  }

  List<SupportChatMessage> _parseMessageList(dynamic raw) {
    if (raw is! List) {
      return const <SupportChatMessage>[];
    }
    final List<SupportChatMessage> messages = <SupportChatMessage>[];
    for (final dynamic item in raw) {
      if (item is! Map) {
        continue;
      }
      final SupportChatMessage? message = SupportChatMessage.fromJson(
        Map<String, dynamic>.from(item),
      );
      if (message != null) {
        messages.add(message);
      }
    }
    messages.sort(
      (SupportChatMessage a, SupportChatMessage b) {
        final DateTime? left = a.createdDate;
        final DateTime? right = b.createdDate;
        if (left == null && right == null) {
          return a.id.compareTo(b.id);
        }
        if (left == null) {
          return -1;
        }
        if (right == null) {
          return 1;
        }
        return left.compareTo(right);
      },
    );
    return messages;
  }

  SupportChatStatus _parseStatus(dynamic value) {
    switch (value?.toString().trim().toUpperCase()) {
      case 'OPEN':
        return SupportChatStatus.open;
      case 'IN_PROGRESS':
        return SupportChatStatus.inProgress;
      case 'CLOSED':
        return SupportChatStatus.closed;
      default:
        return SupportChatStatus.unknown;
    }
  }
}

final supportChatRemoteDataSourceProvider =
    Provider<SupportChatRemoteDataSource>((Ref ref) {
  return SupportChatRemoteDataSource(ref.watch(dioProvider));
});
