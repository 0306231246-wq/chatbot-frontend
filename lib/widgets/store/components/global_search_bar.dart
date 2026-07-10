import 'package:flutter/material.dart';
import '../../../controllers/main_store_controller.dart';

class GlobalSearchBar extends StatelessWidget {
  final MainStoreController controller;

  const GlobalSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.search, color: Colors.white38, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller.globalSearchController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Tìm linh kiện, cấu hình...',
                hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.globalSearchController,
            builder: (context, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  controller.globalSearchController.clear();
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.close, color: Colors.white54, size: 16),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
