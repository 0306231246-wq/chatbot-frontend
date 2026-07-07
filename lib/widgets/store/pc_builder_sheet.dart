import 'package:flutter/material.dart';
import '../../controllers/pc_builder_controller.dart';
import '../../models/component.dart';
import '../chat/chat_bot_widget.dart';

class PcBuilderSheet extends StatelessWidget {
  final PcBuilderController controller;
  final GlobalKey<ChatBotWidgetState> chatBotKey;
  final void Function(int tabIndex)? onNavigateToCategory;

  const PcBuilderSheet({
    super.key,
    required this.controller,
    required this.chatBotKey,
    this.onNavigateToCategory,
  });

  void _askAI(BuildContext context) {
    if (controller.selectedCount < 2) return;
    
    final cpu = controller.selectedCpu;
    final mainboard = controller.selectedMainboard;
    final gpu = controller.selectedGpu;
    
    List<String> names = [];
    if (cpu != null) names.add(cpu.name);
    if (mainboard != null) names.add(mainboard.name);
    if (gpu != null) names.add(gpu.name);
    
    final prompt = "${names.join(' + ')} có tương thích với nhau không?";
    
    Navigator.pop(context); // Close sheet
    chatBotKey.currentState?.openAndSendMessage(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasEnoughItems = controller.selectedCount >= 2;
        
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF0D0D12),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cấu hình PC đang chọn',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${controller.selectedCount}/3 linh kiện',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildSlot(context, 'CPU', 0, controller.selectedCpu, () => controller.removeCpu()),
                        const SizedBox(height: 12),
                        _buildSlot(context, 'Mainboard', 2, controller.selectedMainboard, () => controller.removeMainboard()),
                        const SizedBox(height: 12),
                        _buildSlot(context, 'GPU', 1, controller.selectedGpu, () => controller.removeGpu()),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A22),
                    border: Border(top: BorderSide(color: Colors.white10)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng tạm tính', style: TextStyle(color: Colors.white70)),
                          Text(
                            _formatVnd(controller.totalPrice),
                            style: const TextStyle(color: Color(0xFF1B9E5A), fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasEnoughItems ? Theme.of(context).colorScheme.secondary : Colors.grey.shade800,
                            foregroundColor: hasEnoughItems ? Colors.white : Colors.white38,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('✨ Hỏi AI độ tương thích', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: hasEnoughItems ? () => _askAI(context) : null,
                        ),
                      ),
                      if (!hasEnoughItems)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Hãy chọn thêm ít nhất 1 linh kiện nữa để AI có thể kiểm tra.',
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

  Widget _buildSlot(BuildContext context, String title, int tabIndex, PcComponent? component, VoidCallback onRemove) {
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
              width: 48, height: 48,
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
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
                if (onNavigateToCategory != null) {
                  onNavigateToCategory!(tabIndex);
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
              ),
              child: Text('Chọn $title'),
            )
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(component.imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  component.name,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatVnd(component.price),
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
