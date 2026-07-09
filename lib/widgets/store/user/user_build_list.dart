import 'package:flutter/material.dart';
import '../../../controllers/user_builds_controller.dart';
import '../../../controllers/pc_builder_controller.dart';
import '../../../controllers/main_store_controller.dart';
import '../../chat/chat_bot_widget.dart';
import 'user_build_card.dart';

/// Sliver section hiển thị danh sách build cá nhân của người dùng.
class UserBuildList extends StatelessWidget {
  final UserBuildsController controller;
  final PcBuilderController pcBuilderController;
  final MainStoreController mainStoreController;
  final GlobalKey<ChatBotWidgetState> chatBotKey;

  const UserBuildList({
    super.key,
    required this.controller,
    required this.pcBuilderController,
    required this.mainStoreController,
    required this.chatBotKey,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final builds = controller.builds;

        if (builds.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_border_outlined, color: Colors.white24, size: 64),
                    SizedBox(height: 16),
                    Text('Chưa có cấu hình nào.',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Hãy dùng tính năng "Lưu thành Build" trong Giỏ Build để lưu cấu hình của bạn vào đây.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => UserBuildCard(
                userBuild: builds[index],
                controller: controller,
                pcBuilderController: pcBuilderController,
                mainStoreController: mainStoreController,
                chatBotKey: chatBotKey,
              ),
              childCount: builds.length,
            ),
          ),
        );
      },
    );
  }
}
