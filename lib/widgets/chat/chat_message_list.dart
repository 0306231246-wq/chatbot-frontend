import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/pc_build.dart';

part 'chat_build_card.dart';
part 'chat_formatters.dart';
part 'chat_jump_to_latest_button.dart';
part 'chat_message_item.dart';
part 'chat_typing_indicator.dart';

class ChatMessageList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final bool isLoading;
  final Color primary;
  final ScrollController scrollController;
  final VoidCallback onJumpToLatest;
  final Function(int)? onRetry;
  final Function(PcBuild)? onApplyBuild;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.isLoading,
    required this.primary,
    required this.scrollController,
    required this.onJumpToLatest,
    this.onRetry,
    this.onApplyBuild,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildMessageList(),
        _JumpToLatestButton(
          primary: primary,
          scrollController: scrollController,
          onPressed: onJumpToLatest,
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 52),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0 && isLoading) {
          return const _TypingIndicator();
        }
        final messageIndex = _messageIndexFor(index);
        return _MessageItem(
          msg: messages[messageIndex],
          index: messageIndex,
          isLastMessage: messageIndex == messages.length - 1,
          primary: primary,
          onRetry: onRetry,
          onApplyBuild: onApplyBuild,
        );
      },
    );
  }

  int _messageIndexFor(int visibleIndex) {
    final adjustedIndex = isLoading ? visibleIndex - 1 : visibleIndex;
    return messages.length - 1 - adjustedIndex;
  }
}
