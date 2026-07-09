import 'package:flutter/material.dart';
import '../../../controllers/main_store_controller.dart';

class StoreTabBar extends StatelessWidget {
  final MainStoreController controller;

  const StoreTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0D12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _TabItem(
            text: 'Cấu hình mẫu',
            isSelected: controller.tab == StoreTab.builds,
            onTap: () => controller.setTab(StoreTab.builds),
          ),
          const SizedBox(width: 12),
          _TabItem(
            text: 'Linh kiện rời',
            isSelected: controller.tab == StoreTab.components,
            onTap: () => controller.setTab(StoreTab.components),
          ),
          const SizedBox(width: 12),
          _TabItem(
            text: 'Của tôi',
            isSelected: controller.tab == StoreTab.myBuilds,
            onTap: () => controller.setTab(StoreTab.myBuilds),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? primary.withOpacity(0.5) : Colors.transparent),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? primary : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
