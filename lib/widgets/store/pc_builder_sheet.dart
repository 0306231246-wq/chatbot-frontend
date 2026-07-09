import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/pc_builder_controller.dart';
import '../../controllers/user_builds_controller.dart';
import '../../models/component.dart';
import '../../models/user_build.dart';
import '../chat/chat_bot_widget.dart';
import 'components/pc_component_slot.dart';
import 'components/save_build_dialog.dart';

class PcBuilderSheet extends StatelessWidget {
  final PcBuilderController controller;
  final UserBuildsController userBuildsController;
  final GlobalKey<ChatBotWidgetState> chatBotKey;
  final void Function(int tabIndex)? onNavigateToCategory;
  final VoidCallback? onSaved;

  const PcBuilderSheet({
    super.key,
    required this.controller,
    required this.userBuildsController,
    required this.chatBotKey,
    this.onNavigateToCategory,
    this.onSaved,
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

    final parts = names.join(' + ');
    final prompt = controller.isPrebuiltSelection
        ? 'Hãy đánh giá bộ PC build sẵn này: $parts. Bộ này phù hợp nhu cầu nào, hiệu năng ra sao, giá trị so với chi phí thế nào và có nên mua không?'
        : 'Hãy tư vấn các linh kiện PC tôi đang chọn: $parts. Kiểm tra độ tương thích của của bộ pc này.';

    Navigator.pop(context); // Close sheet
    chatBotKey.currentState?.openWithDraftMessage(prompt);
  }

  // ── Lưu build cá nhân ──────────────────────────────────────────────────
  void _saveBuild(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SaveBuildDialog(
        controller: controller,
        userBuildsController: userBuildsController,
        onSaved: onSaved,
        onDialogClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasEnoughItems = controller.selectedCount >= 2;
        final hasAnyItem = controller.selectedCount >= 1;

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
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cấu hình PC đang chọn',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${controller.selectedCount}/3 linh kiện',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        PcComponentSlot(
                          title: 'CPU',
                          tabIndex: 0,
                          component: controller.selectedCpu,
                          onRemove: () => controller.removeCpu(),
                          onNavigateToCategory: onNavigateToCategory,
                        ),
                        const SizedBox(height: 12),
                        PcComponentSlot(
                          title: 'Mainboard',
                          tabIndex: 2,
                          component: controller.selectedMainboard,
                          onRemove: () => controller.removeMainboard(),
                          onNavigateToCategory: onNavigateToCategory,
                        ),
                        const SizedBox(height: 12),
                        PcComponentSlot(
                          title: 'GPU',
                          tabIndex: 1,
                          component: controller.selectedGpu,
                          onRemove: () => controller.removeGpu(),
                          onNavigateToCategory: onNavigateToCategory,
                        ),
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
                          const Text('Tổng tạm tính',
                              style: TextStyle(color: Colors.white70)),
                          Text(
                            _formatVnd(controller.totalPrice),
                            style: const TextStyle(
                                color: Color(0xFF1B9E5A),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasEnoughItems
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey.shade800,
                            foregroundColor:
                                hasEnoughItems ? Colors.white : Colors.white38,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Tư vấn với AI',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed:
                              hasEnoughItems ? () => _askAI(context) : null,
                        ),
                      ),
                      if (!hasEnoughItems)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Hãy chọn thêm ít nhất 1 linh kiện nữa để AI có thể kiểm tra.',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasAnyItem
                                ? const Color(0xFF7C3AED)
                                : Colors.grey.shade800,
                            foregroundColor:
                                hasAnyItem ? Colors.white : Colors.white38,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: Icon(controller.editingUserBuildId != null
                              ? Icons.update
                              : Icons.bookmark_add_outlined),
                          label: Text(
                              controller.editingUserBuildId != null
                                  ? 'Cập nhật Cấu hình'
                                  : 'Lưu thành Build',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed:
                              hasAnyItem ? () => _saveBuild(context) : null,
                        ),
                      ),
                      if (controller.editingUserBuildId != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.close),
                              label: const Text('Hủy cập nhật',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                controller.clearBuild();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      if (!hasAnyItem)
                        const Padding(
                          padding: EdgeInsets.only(top: 6.0),
                          child: Text(
                            'Chọn ít nhất 1 linh kiện để lưu build.',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 12),
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
}
