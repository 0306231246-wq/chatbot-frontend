import 'package:flutter/material.dart';
import '../../../models/component.dart';

/// Fallback icon per component type.
IconData componentFallbackIcon(String title) {
  switch (title.toLowerCase()) {
    case 'cpu':
      return Icons.memory;
    case 'mainboard':
      return Icons.developer_board;
    case 'gpu':
      return Icons.videogame_asset;
    default:
      return Icons.memory;
  }
}

/// One slot in the PC builder (empty or filled).
class PcComponentSlot extends StatelessWidget {
  final String title;
  final int tabIndex;
  final PcComponent? component;
  final VoidCallback onRemove;
  final void Function(int tabIndex)? onNavigateToCategory;

  const PcComponentSlot({
    super.key,
    required this.title,
    required this.tabIndex,
    required this.component,
    required this.onRemove,
    this.onNavigateToCategory,
  });

  String _formatVnd(num value) {
    if (value == 0) return '0đ';
    final str = value.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return '${buf.toString()}đ';
  }

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = componentFallbackIcon(title);

    if (component == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add, color: Colors.white38),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Chưa chọn $title',
                style: const TextStyle(color: Colors.white38, fontSize: 15),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                onNavigateToCategory?.call(tabIndex);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
              ),
              child: Text('Chọn $title'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: component!.imageUrl.isNotEmpty
                  ? Image.network(
                      component!.imageUrl,
                      fit: BoxFit.contain,
                      cacheWidth: 96,
                      errorBuilder: (_, __, ___) =>
                          Icon(fallbackIcon, color: Colors.black54),
                    )
                  : Icon(fallbackIcon, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  component!.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatVnd(component!.price),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
