import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../controllers/pc_builder_controller.dart';
import '../../../controllers/user_builds_controller.dart';
import '../../../models/user_build.dart';

class SaveBuildDialog extends StatefulWidget {
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
  State<SaveBuildDialog> createState() => _SaveBuildDialogState();
}

class _SaveBuildDialogState extends State<SaveBuildDialog> {
  late final TextEditingController _nameCtrl;
  String _oldName = '';
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final editingId = widget.controller.editingUserBuildId;
    final isEditing = editingId != null;

    _oldName =
        'Build ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    if (isEditing) {
      try {
        final existing = widget.userBuildsController.builds
            .firstWhere((b) => b.id == editingId);
        _oldName = existing.name;
      } catch (_) {}
    }

    _nameCtrl = TextEditingController(text: _oldName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editingId = widget.controller.editingUserBuildId;
    final isEditing = editingId != null;

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
        controller: _nameCtrl,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        onChanged: (_) {
          if (_errorText != null) {
            setState(() => _errorText = null);
          }
        },
        decoration: InputDecoration(
          hintText: 'Ví dụ: Gaming 2025, Đồ họa cao cấp...',
          hintStyle: const TextStyle(color: Colors.white30),
          errorText: _errorText,
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.save_outlined, size: 18),
          label: Text(isEditing ? 'Cập nhật' : 'Lưu Build'),
          onPressed: () {
            final name = _nameCtrl.text.trim();
            final finalName = name.isEmpty ? _oldName : name;

            final isDuplicate = widget.userBuildsController.builds.any((b) =>
                b.name.toLowerCase() == finalName.toLowerCase() &&
                b.id != editingId);

            if (isDuplicate) {
              setState(() {
                _errorText = 'Tên cấu hình đã tồn tại!';
              });
              return;
            }

            Navigator.pop(context); // close dialog
            widget.onDialogClose(); // close sheet

            if (isEditing) {
              widget.userBuildsController.updateBuildComponents(
                editingId,
                name: finalName,
                cpuName: widget.controller.selectedCpu?.name,
                cpuPrice: widget.controller.selectedCpu?.price,
                mainboardName: widget.controller.selectedMainboard?.name,
                mainboardPrice: widget.controller.selectedMainboard?.price,
                gpuName: widget.controller.selectedGpu?.name,
                gpuPrice: widget.controller.selectedGpu?.price,
              );
              widget.controller.clearBuild();
              widget.onSaved?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Đã cập nhật cấu hình thành công!'),
                  backgroundColor: Color(0xFF1B9E5A),
                ),
              );
            } else {
              final newBuild = UserBuild(
                id: const Uuid().v4(),
                name: finalName,
                cpuName: widget.controller.selectedCpu?.name,
                cpuPrice: widget.controller.selectedCpu?.price,
                mainboardName: widget.controller.selectedMainboard?.name,
                mainboardPrice: widget.controller.selectedMainboard?.price,
                gpuName: widget.controller.selectedGpu?.name,
                gpuPrice: widget.controller.selectedGpu?.price,
                createdAt: DateTime.now(),
              );
              widget.userBuildsController.addBuild(newBuild);
              widget.controller.clearBuild();
              widget.onSaved?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('💾 Đã lưu build "${newBuild.name}"!'),
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
