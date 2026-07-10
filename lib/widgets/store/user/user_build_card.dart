import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/user_build.dart';
import '../../../controllers/user_builds_controller.dart';
import '../../../controllers/pc_builder_controller.dart';
import '../../../controllers/main_store_controller.dart';
import '../pc_builder_sheet.dart';
import '../../chat/chat_bot_widget.dart';

/// Card hiển thị 1 build PC do người dùng tự tạo.
/// Có nút Sửa (nạp lại vào giỏ build) và Xóa (confirm trước khi xóa).
class UserBuildCard extends StatelessWidget {
  final UserBuild userBuild;
  final UserBuildsController controller;
  final PcBuilderController pcBuilderController;
  final MainStoreController mainStoreController;
  final GlobalKey<ChatBotWidgetState> chatBotKey;

  const UserBuildCard({
    super.key,
    required this.userBuild,
    required this.controller,
    required this.pcBuilderController,
    required this.mainStoreController,
    required this.chatBotKey,
  });

  String _formatVnd(double value) {
    if (value == 0) return '0đ';
    final str = value.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return '${buffer.toString()}đ';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  // ─── Confirm xóa ─────────────────────────────────────────────────────────
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Xóa Build?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Bạn có chắc muốn xóa build "${userBuild.name}" không?\nHành động này không thể hoàn tác.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteBuild(userBuild.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa build "${userBuild.name}"'),
                  backgroundColor: Colors.redAccent.shade400,
                ),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // ─── Nạp lại build để chỉnh sửa ─────────────────────────────────────────
  void _editBuild(BuildContext context) {
    pcBuilderController.loadUserBuild(userBuild);
    final tabController = DefaultTabController.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PcBuilderSheet(
        controller: pcBuilderController,
        userBuildsController: controller,
        chatBotKey: chatBotKey,
        onSaved: () => mainStoreController.setTab(StoreTab.myBuilds),
        onNavigateToCategory: (tabIndex) {
          mainStoreController.setTab(StoreTab.components);
          tabController.animateTo(tabIndex);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF7C3AED); // purple accent for MY BUILD
    const cardBg = Color(0xFFF8F4FF); // very light lavender

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: accentColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userBuild.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Sao chép cấu hình',
                  child: InkWell(
                    onTap: () {
                      final totalPriceStr = userBuild.totalPrice
                          .round()
                          .toString()
                          .replaceAllMapped(
                              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                              (m) => '${m[1]}.');
                      final copyText =
                          '${userBuild.name}\nVi xử lý: ${userBuild.cpuName ?? "Chưa có"}\nBo mạch chủ: ${userBuild.mainboardName ?? "Chưa có"}\nCard đồ họa: ${userBuild.gpuName ?? "Chưa có"}\nTổng cộng: $totalPriceStrđ';
                      Clipboard.setData(ClipboardData(text: copyText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã sao chép cấu hình'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF1B9E5A),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Icon(Icons.copy_rounded, color: Colors.black54, size: 18),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'MY BUILD',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'Tạo ngày ${_formatDate(userBuild.createdAt)}',
              style: const TextStyle(color: Colors.black38, fontSize: 11),
            ),
          ),
          Divider(color: Colors.grey.shade200, height: 1),

          // ── Component rows ───────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                if (userBuild.cpuName != null)
                  _ComponentRow(
                    icon: Icons.memory,
                    label: 'CPU',
                    model: userBuild.cpuName!,
                    price: _formatVnd(userBuild.cpuPrice ?? 0),
                    accent: accentColor,
                  ),
                if (userBuild.cpuName != null) const SizedBox(height: 10),
                if (userBuild.mainboardName != null)
                  _ComponentRow(
                    icon: Icons.developer_board,
                    label: 'Mainboard',
                    model: userBuild.mainboardName!,
                    price: _formatVnd(userBuild.mainboardPrice ?? 0),
                    accent: accentColor,
                  ),
                if (userBuild.mainboardName != null) const SizedBox(height: 10),
                if (userBuild.gpuName != null)
                  _ComponentRow(
                    icon: Icons.videogame_asset,
                    label: 'GPU',
                    model: userBuild.gpuName!,
                    price: _formatVnd(userBuild.gpuPrice ?? 0),
                    accent: accentColor,
                  ),
                if (userBuild.cpuName == null &&
                    userBuild.mainboardName == null &&
                    userBuild.gpuName == null)
                  const Text(
                    'Chưa có linh kiện nào.',
                    style: TextStyle(color: Colors.black38, fontSize: 12),
                  ),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade200, height: 1),

          // ── Footer: tổng giá + actions ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng giá',
                        style:
                            TextStyle(color: Colors.black54, fontSize: 11)),
                    Text(
                      _formatVnd(userBuild.totalPrice),
                      style: const TextStyle(
                        color: Color(0xFF1B9E5A),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Nút Sửa
                    OutlinedButton.icon(
                      onPressed: () => _editBuild(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentColor,
                        side: const BorderSide(color: accentColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 15),
                      label: const Text('Sửa',
                          style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    // Nút Xóa
                    OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 15),
                      label: const Text('Xóa',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ───────────────────────────────────────────────────────────

class _ComponentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String model;
  final String price;
  final Color accent;

  const _ComponentRow({
    required this.icon,
    required this.label,
    required this.model,
    required this.price,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black38),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: accent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              Text(model,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87, fontSize: 12)),
            ],
          ),
        ),
        Text(price,
            style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    );
  }
}
