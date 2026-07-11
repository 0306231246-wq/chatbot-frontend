part of 'chat_message_list.dart';

class _MessageItem extends StatelessWidget {
  final Map<String, dynamic> msg;
  final int index;
  final bool isLastMessage;
  final Color primary;
  final Function(int)? onRetry;
  final Function(PcBuild)? onApplyBuild;

  const _MessageItem({
    required this.msg,
    required this.index,
    required this.isLastMessage,
    required this.primary,
    this.onRetry,
    this.onApplyBuild,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = msg['isUser'] == true;
    final text = msg['text']?.toString() ?? '';

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _MessageBubble(text: text, isUser: isUser, primary: primary),
        _MessageActions(
          isUser: isUser,
          canRetry: !isUser && isLastMessage,
          onCopy: () => _copyMessage(context, text),
          onRetry: () => onRetry?.call(index),
        ),
        if (msg['hasCard'] == true && msg['buildData'] != null)
          _BuildCard(
            pcBuild: msg['buildData'] as PcBuild,
            onApplyBuild: onApplyBuild,
            primary: primary,
          ),
      ],
    );
  }

  void _copyMessage(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã sao chép tin nhắn'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey.shade800,
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final Color primary;

  const _MessageBubble({
    required this.text,
    required this.isUser,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      decoration: BoxDecoration(
        color: isUser ? primary : Colors.grey.shade100,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: const Radius.circular(14),
          bottomLeft: Radius.circular(isUser ? 14 : 3),
          bottomRight: Radius.circular(isUser ? 3 : 14),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionColor:
                isUser ? Colors.white.withOpacity(0.3) : primary.withOpacity(0.3),
            selectionHandleColor: isUser ? Colors.white : primary,
          ),
        ),
        child: SelectionArea(
          contextMenuBuilder: _buildSelectionMenu,
          child: Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black87,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionMenu(
    BuildContext context,
    SelectableRegionState selectableRegionState,
  ) {
    final buttonItems = selectableRegionState.contextMenuButtonItems.map((item) {
      String? label = item.label;
      if (item.type == ContextMenuButtonType.selectAll) {
        label = 'Chọn tất cả';
      } else if (item.type == ContextMenuButtonType.copy) {
        label = 'Sao chép';
      }

      return ContextMenuButtonItem(
        onPressed: item.onPressed,
        type: item.type,
        label: label,
      );
    }).toList();

    return Theme(
      data: ThemeData.light(),
      child: AdaptiveTextSelectionToolbar.buttonItems(
        anchors: selectableRegionState.contextMenuAnchors,
        buttonItems: buttonItems,
      ),
    );
  }
}

class _MessageActions extends StatelessWidget {
  final bool isUser;
  final bool canRetry;
  final VoidCallback onCopy;
  final VoidCallback onRetry;

  const _MessageActions({
    required this.isUser,
    required this.canRetry,
    required this.onCopy,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 0 : 4,
        right: isUser ? 4 : 0,
        bottom: 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MessageActionButton(
            icon: Icons.copy_rounded,
            tooltip: 'Sao chép',
            onTap: onCopy,
          ),
          if (!isUser) const SizedBox(width: 4),
          if (!isUser)
            _MessageActionButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Thử lại',
              disabled: !canRetry,
              onTap: onRetry,
            ),
        ],
      ),
    );
  }
}

class _MessageActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;
  final String? tooltip;

  const _MessageActionButton({
    required this.icon,
    required this.onTap,
    this.disabled = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 16,
          color: disabled ? Colors.grey.shade300 : Colors.grey.shade500,
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return Material(color: Colors.transparent, child: button);
  }
}
