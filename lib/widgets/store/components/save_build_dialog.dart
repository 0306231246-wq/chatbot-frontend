import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../controllers/pc_builder_controller.dart';
import '../../../controllers/user_builds_controller.dart';
import '../../../models/user_build.dart';

class SaveBuildDialog extends StatelessWidget {
  final PcBuilderController controller;
  final UserBuildsController userBuildsController;
  final VoidCallback? onSaved;
  final VoidCallback onDialogClose; // Callback to close the bottom sheet

  const SaveBuildDialog({
    super.key,
    required this.controller,
    required this.userBuildsController,
    this.onSaved,
    required this.onDialogClose,
  });

  @override
  Widget build(BuildContext context) {
    final editingId = controller.editingUserBuildId;
    final isEditing = editingId != null;

    String oldName = 'Build ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    if (isEditing) {
      try {
        final existing = userBuildsController.builds.firstWhere((b) => b.id == editingId);
        oldName = existing.name;
      } catch (_) {}
    }

    final nameCtrl = TextEditingController(text: oldName);

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.bookmark_add_outlined, color: Color(0xFF7C3AED)),
          const SizedBox(width: 8),
          Text(isEditing ? 'Cập nhật Tên Build' : 'Đặt tên cho Build',
              style: const TextStyle(color: Colors.white, fontSize: 17)),
        ],
      ),
      content: TextField(
        controller: nameCtrl,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Ví dụ: Gaming 2025, Đồ họa cao cấp...',
          hintStyle: const TextStyle(color: Colors.white30),
          filled: true,
          fillColor: const Color(0xFF0D0D12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF7C3AED)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.save_outlined, size: 18),
          label: Text(isEditing ? 'Cập nhật' : 'Lưu Build'),
          onPressed: () {
            final name = nameCtrl.text.trim();
            Navigator.pop(context); // close dialog
            onDialogClose(); // close sheet

            if (isEditing) {
              userBuildsController.updateBuildComponents(
                editingId,
                name: name.isEmpty ? oldName : name,
                cpuName: controller.selectedCpu?.name,
                cpuPrice: controller.selectedCpu?.price,
                mainboardName: controller.selectedMainboard?.name,
                mainboardPrice: controller.selectedMainboard?.price,
                gpuName: controller.selectedGpu?.name,
                gpuPrice: controller.selectedGpu?.price,
              );
              controller.clearBuild();
              onSaved?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Đã cập nhật cấu hình thành công!'),
                  backgroundColor: Color(0xFF1B9E5A),
                ),
              );
            } else {
              final build = UserBuild(
                id: const Uuid().v4(),
                name: name.isEmpty ? 'Build của tôi' : name,
                cpuName: controller.selectedCpu?.name,
                cpuPrice: controller.selectedCpu?.price,
                mainboardName: controller.selectedMainboard?.name,
                mainboardPrice: controller.selectedMainboard?.price,
                gpuName: controller.selectedGpu?.name,
                gpuPrice: controller.selectedGpu?.price,
                createdAt: DateTime.now(),
              );
              userBuildsController.addBuild(build);
              onSaved?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('💾 Đã lưu build "${build.name}"!'),
                  backgroundColor: const Color(0xFF7C3AED),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
