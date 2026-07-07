import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/core/providers/shared_prefs_provider.dart';
import 'package:wcr_pmis_mobile/src/features/support_chat/data/datasources/support_chat_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/support_chat/domain/entities/support_chat_message.dart';

const Duration supportChatPollInterval = Duration(seconds: 2);
const String _chatIdPrefsKey = 'support_chat_active_id';
const String _chatClosedPrefsKey = 'support_chat_closed';

class SupportChatState {
  const SupportChatState({
    this.chatId,
    this.messages = const <SupportChatMessage>[],
    this.status = SupportChatStatus.unknown,
    this.isClosed = false,
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
  });

  final int? chatId;
  final List<SupportChatMessage> messages;
  final SupportChatStatus status;
  final bool isClosed;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;

  bool get canSend => !isClosed && !isSending && !isLoading;
  bool get hasStartedSession => chatId != null || messages.isNotEmpty;

  SupportChatState copyWith({
    int? chatId,
    bool clearChatId = false,
    List<SupportChatMessage>? messages,
    SupportChatStatus? status,
    bool? isClosed,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupportChatState(
      chatId: clearChatId ? null : (chatId ?? this.chatId),
      messages: messages ?? this.messages,
      status: status ?? this.status,
      isClosed: isClosed ?? this.isClosed,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SupportChatController extends StateNotifier<SupportChatState> {
  SupportChatController(this._ref) : super(const SupportChatState()) {
    Future<void>.microtask(_initialize);
    _ref.onDispose(_stopPolling);
  }

  final Ref _ref;
  Timer? _pollTimer;

  SupportChatRemoteDataSource get _dataSource =>
      _ref.read(supportChatRemoteDataSourceProvider);

  Future<void> _initialize() async {
    final prefs = _ref.read(sharedPrefsProvider);
    final int? storedChatId = prefs.getInt(_chatIdPrefsKey);
    final bool isClosed = prefs.getBool(_chatClosedPrefsKey) ?? false;
    if (storedChatId != null && isClosed) {
      await prefs.remove(_chatIdPrefsKey);
      await prefs.setBool(_chatClosedPrefsKey, false);
      if (!mounted) {
        return;
      }
      state = const SupportChatState();
      return;
    }
    if (storedChatId == null) {
      if (isClosed) {
        await prefs.setBool(_chatClosedPrefsKey, false);
      }
      if (!mounted) {
        return;
      }
      state = const SupportChatState();
      return;
    }
    state = state.copyWith(
      chatId: storedChatId,
      status: isClosed ? SupportChatStatus.closed : SupportChatStatus.unknown,
      isClosed: isClosed,
      isLoading: true,
      clearError: true,
    );
    await _pollStatus();
    if (!mounted) {
      return;
    }
    state = state.copyWith(isLoading: false);
  }

  Future<void> restartChat() async {
    _stopPolling();
    final prefs = _ref.read(sharedPrefsProvider);
    await prefs.remove(_chatIdPrefsKey);
    await prefs.setBool(_chatClosedPrefsKey, false);
    if (!mounted) {
      return;
    }
    state = const SupportChatState(messages: <SupportChatMessage>[]);
  }

  Future<void> closeChatIfPossible() async {
    final int? chatId = state.chatId;
    if (chatId == null) {
      return;
    }
    try {
      await _dataSource.closeChat(chatId);
    } catch (_) {
      // Best effort only. Status polling remains the source of truth.
    }
  }

  Future<void> sendMessage(String rawMessage) async {
    final String message = rawMessage.trim();
    if (message.isEmpty || !state.canSend) {
      return;
    }

    state = state.copyWith(isSending: true, clearError: true);
    try {
      final SupportChatSendResult result = await _dataSource.sendMessage(
        chatId: state.chatId,
        message: message,
      );
      final SupportChatMessage localMessage = SupportChatMessage(
        id: DateTime.now().microsecondsSinceEpoch,
        chatId: result.chatId,
        senderType: 'USER',
        message: message,
        createdDate: DateTime.now(),
      );
      final List<SupportChatMessage> nextMessages = <SupportChatMessage>[
        ...state.messages.where(
          (SupportChatMessage item) =>
              !(item.isUser &&
                  item.chatId == result.chatId &&
                  item.message.trim() == message),
        ),
        localMessage,
      ];
      final prefs = _ref.read(sharedPrefsProvider);
      await prefs.setInt(_chatIdPrefsKey, result.chatId);
      await prefs.setBool(_chatClosedPrefsKey, false);
      state = state.copyWith(
        chatId: result.chatId,
        messages: nextMessages,
        status: SupportChatStatus.open,
        isClosed: false,
        isSending: false,
      );
      await _pollStatus();
    } catch (error) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        isSending: false,
        errorMessage: userFriendlyErrorMessage(error),
      );
    }
  }

  Future<void> _pollStatus() async {
    final int? chatId = state.chatId;
    if (chatId == null) {
      return;
    }
    try {
      final SupportChatStatus status = await _dataSource.fetchStatus(chatId);
      if (!mounted) {
        return;
      }
      state = state.copyWith(status: status, clearError: true);
      if (status == SupportChatStatus.closed) {
        await _handleClosedChat();
        return;
      }
      if (status == SupportChatStatus.inProgress) {
        await _refreshConversation();
      }
      _startPolling();
    } catch (error) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        errorMessage: userFriendlyErrorMessage(error),
      );
    }
  }

  Future<void> _refreshConversation() async {
    final int? chatId = state.chatId;
    if (chatId == null) {
      return;
    }
    try {
      final SupportChatConversationResult result =
          await _dataSource.fetchConversation(chatId);
      if (!mounted) {
        return;
      }
      state = state.copyWith(messages: result.messages, clearError: true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        errorMessage: userFriendlyErrorMessage(error),
      );
    }
  }

  Future<void> _handleClosedChat() async {
    _stopPolling();
    final prefs = _ref.read(sharedPrefsProvider);
    await prefs.setBool(_chatClosedPrefsKey, true);
    if (!mounted) {
      return;
    }
    state = state.copyWith(
      status: SupportChatStatus.closed,
      isClosed: true,
      isLoading: false,
      isSending: false,
    );
  }

  void _startPolling() {
    if (_pollTimer != null || state.isClosed || state.chatId == null) {
      return;
    }
    _pollTimer = Timer.periodic(supportChatPollInterval, (_) {
      unawaited(_pollStatus());
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}

final supportChatControllerProvider =
    StateNotifierProvider.autoDispose<SupportChatController, SupportChatState>(
  (Ref ref) => SupportChatController(ref),
);
