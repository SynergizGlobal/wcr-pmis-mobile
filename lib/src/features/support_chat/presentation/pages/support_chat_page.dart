import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wcr_pmis_mobile/src/features/support_chat/domain/entities/support_chat_message.dart';
import 'package:wcr_pmis_mobile/src/features/support_chat/presentation/providers/support_chat_provider.dart';

class SupportChatPage extends ConsumerStatefulWidget {
  const SupportChatPage({super.key});

  static const String routeName = 'support-chat';
  static const String routePath = '/support-chat';

  @override
  ConsumerState<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends ConsumerState<SupportChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _closedDialogShown = false;
  bool _suppressNextClosedDialog = false;
  bool _hasTypedMessage = false;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_handleMessageChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_handleMessageChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SupportChatState chatState = ref.watch(supportChatControllerProvider);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    ref.listen<SupportChatState>(supportChatControllerProvider, (
      SupportChatState? previous,
      SupportChatState next,
    ) {
      if ((previous?.messages.length ?? 0) < next.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
      if (previous != null &&
          previous.hasStartedSession &&
          !(previous.isClosed) &&
          next.isClosed &&
          !_closedDialogShown &&
          !_suppressNextClosedDialog) {
        _closedDialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          _showClosedDialog();
        });
      }
      if ((previous?.isClosed ?? false) && !next.isClosed) {
        _closedDialogShown = false;
        _suppressNextClosedDialog = false;
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop || !mounted || _isExiting) {
          return;
        }
        await _handleBackNavigation(chatState);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Support Chat'),
        ),
        body: Column(
          children: <Widget>[
            if (chatState.errorMessage != null)
              Material(
                color: colorScheme.errorContainer.withValues(alpha: 0.35),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.error_outline, color: colorScheme.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          chatState.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: chatState.isLoading && chatState.messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : chatState.messages.isEmpty
                      ? _emptyState(context)
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: chatState.messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            final int reversedIndex =
                                chatState.messages.length - 1 - index;
                            return _MessageBubble(
                              message: chatState.messages[reversedIndex],
                            );
                          },
                        ),
            ),
            if (!chatState.isClosed && chatState.chatId != null)
              _statusFooter(
                context,
                status: chatState.status,
              ),
            _composer(
              context: context,
              enabled: chatState.canSend,
              hasText: _hasTypedMessage,
              isSending: chatState.isSending,
              onSend: () async {
                final String text = _messageController.text;
                _messageController.clear();
                await ref
                    .read(supportChatControllerProvider.notifier)
                    .sendMessage(text);
                _scrollToBottom();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusFooter(
    BuildContext context, {
    required SupportChatStatus status,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool online = status == SupportChatStatus.inProgress;
    final Color dotColor = online ? const Color(0xFF2E7D32) : colorScheme.error;
    final String label = online ? 'Support is online' : 'Support is offline';
    final String detail = online
        ? 'You can continue this conversation now.'
        : 'Waiting for support team to join...';

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Row(
          children: <Widget>[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    detail,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.support_agent_rounded,
              size: 56,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Start a conversation with Support',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Describe your issue and our support team will respond shortly.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _composer({
    required BuildContext context,
    required bool enabled,
    required bool hasText,
    required bool isSending,
    required Future<void> Function() onSend,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool canSubmit = enabled && hasText && !isSending;
    return SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        color: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: canSubmit ? (_) => onSend() : null,
                  decoration: InputDecoration(
                    hintText: enabled
                        ? 'Type your message...'
                        : 'Chat session is closed',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.45,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: canSubmit ? onSend : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                ),
                child: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMessageChanged() {
    final bool hasText = _messageController.text.trim().isNotEmpty;
    if (_hasTypedMessage == hasText || !mounted) {
      return;
    }
    setState(() => _hasTypedMessage = hasText);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleBackNavigation(SupportChatState chatState) async {
    if (chatState.isClosed || !chatState.hasStartedSession) {
      _exitPage();
      return;
    }
    final bool shouldClose = await _showLeaveDialog() ?? false;
    if (!mounted || !shouldClose) {
      return;
    }
    _suppressNextClosedDialog = true;
    await ref.read(supportChatControllerProvider.notifier).closeChatIfPossible();
    if (!mounted) {
      return;
    }
    _exitPage();
  }

  Future<bool?> _showLeaveDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Close Chat Session?'),
          content: const Text(
            'Do you want to close this chat session or stay and continue chatting?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Stay'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Close Session'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showClosedDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Chat Session Closed'),
          content: const Text(
            'This chat session is closed.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  _exitPage();
                }
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _exitPage() {
    _isExiting = true;
    Navigator.of(context).pop();
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final SupportChatMessage message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isUser = message.isUser;
    final Color bubbleColor = isUser
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final Color textColor =
        isUser ? colorScheme.onPrimary : colorScheme.onSurface;
    final String timeLabel = message.createdDate == null
        ? ''
        : DateFormat('hh:mm a').format(message.createdDate!.toLocal());

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (!isUser) ...<Widget>[
            CircleAvatar(
              radius: 14,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              child: Icon(
                Icons.support_agent_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                if (!isUser && (message.senderName?.isNotEmpty ?? false))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      'Support',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Text(
                      message.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                if (timeLabel.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    child: Text(
                      timeLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
