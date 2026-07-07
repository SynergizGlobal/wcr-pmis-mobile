class SupportChatMessage {
  const SupportChatMessage({
    required this.id,
    required this.chatId,
    required this.senderType,
    required this.message,
    required this.createdDate,
    this.senderId,
    this.senderName,
  });

  final int id;
  final int chatId;
  final String senderType;
  final String message;
  final DateTime? createdDate;
  final String? senderId;
  final String? senderName;

  bool get isUser => senderType.toUpperCase() == 'USER';

  static SupportChatMessage? fromJson(Map<String, dynamic> json) {
    final String text = json['message']?.toString().trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    final int? id = _intOrNull(json['id']);
    final int? chatId = _intOrNull(json['chatId']);
    if (id == null || chatId == null) {
      return null;
    }
    return SupportChatMessage(
      id: id,
      chatId: chatId,
      senderType: json['senderType']?.toString() ?? 'USER',
      message: text,
      createdDate: _dateFromJson(json['createdDate']),
      senderId: json['senderId']?.toString(),
      senderName: json['senderName']?.toString(),
    );
  }

  static int? _intOrNull(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return DateTime.tryParse(value.toString());
  }
}

class SupportChatSendResult {
  const SupportChatSendResult({
    required this.chatId,
    required this.message,
  });

  final int chatId;
  final String message;

  factory SupportChatSendResult.fromJson(Map<String, dynamic> json) {
    final int? chatId = SupportChatMessage._intOrNull(json['chatId']);
    if (chatId == null) {
      throw const FormatException('Missing chatId in send response.');
    }
    return SupportChatSendResult(
      chatId: chatId,
      message: json['message']?.toString() ?? '',
    );
  }
}

class SupportChatConversationResult {
  const SupportChatConversationResult({
    required this.messages,
  });

  final List<SupportChatMessage> messages;
}

enum SupportChatStatus { open, inProgress, closed, unknown }
