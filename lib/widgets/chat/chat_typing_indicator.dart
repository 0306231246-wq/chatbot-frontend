part of 'chat_message_list.dart';

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(3),
            bottomRight: Radius.circular(14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = index * 0.2;
                var t = _controller.value - delay;
                if (t < 0) t += 1;

                final dy = t < 0.25
                    ? -t * 16
                    : t < 0.5
                        ? -(0.5 - t) * 16
                        : 0.0;
                final opacity = t < 0.5 ? 1.0 : 0.4;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: Transform.translate(
                    offset: Offset(0, dy),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
