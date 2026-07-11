part of 'chat_message_list.dart';

class _JumpToLatestButton extends StatefulWidget {
  final Color primary;
  final ScrollController scrollController;
  final VoidCallback onPressed;

  const _JumpToLatestButton({
    required this.primary,
    required this.scrollController,
    required this.onPressed,
  });

  @override
  State<_JumpToLatestButton> createState() => _JumpToLatestButtonState();
}

class _JumpToLatestButtonState extends State<_JumpToLatestButton> {
  static const _showAfterOffset = 24.0;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateVisibility());
  }

  @override
  void didUpdateWidget(covariant _JumpToLatestButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController == widget.scrollController) return;
    oldWidget.scrollController.removeListener(_updateVisibility);
    widget.scrollController.addListener(_updateVisibility);
    _updateVisibility();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateVisibility);
    super.dispose();
  }

  void _updateVisibility() {
    if (!mounted || !widget.scrollController.hasClients) return;
    final shouldShow = widget.scrollController.offset > _showAfterOffset;
    if (shouldShow == _visible) return;
    setState(() => _visible = shouldShow);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 8,
      bottom: 8,
      child: AnimatedScale(
        scale: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 120),
        child: IgnorePointer(
          ignoring: !_visible,
          child: Material(
            color: widget.primary,
            shape: const CircleBorder(),
            elevation: 3,
            child: IconButton(
              icon: const Icon(Icons.keyboard_double_arrow_down_rounded),
              iconSize: 18,
              color: Colors.white,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              visualDensity: VisualDensity.compact,
              tooltip: 'Tin nhắn mới nhất',
              onPressed: widget.onPressed,
            ),
          ),
        ),
      ),
    );
  }
}
