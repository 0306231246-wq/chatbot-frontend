import 'package:flutter/material.dart';
import '../../../controllers/main_store_controller.dart';
import '../../../controllers/pc_builder_controller.dart';
import '../../../controllers/user_builds_controller.dart';
import '../../chat/chat_bot_widget.dart';
import '../pc_builder_sheet.dart';

class PcBuilderBadge extends StatelessWidget {
  final PcBuilderController pcBuilderController;
  final UserBuildsController userBuildsController;
  final GlobalKey<ChatBotWidgetState> chatBotKey;
  final MainStoreController controller;

  const PcBuilderBadge({
    super.key,
    required this.pcBuilderController,
    required this.userBuildsController,
    required this.chatBotKey,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: pcBuilderController,
      builder: (context, _) {
        final count = pcBuilderController.selectedCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.build_circle_outlined,
                color: count > 0 ? Theme.of(context).colorScheme.primary : Colors.white,
              ),
              onPressed: () {
                final tabController = DefaultTabController.of(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => PcBuilderSheet(
                    controller: pcBuilderController,
                    userBuildsController: userBuildsController,
                    chatBotKey: chatBotKey,
                    onSaved: () => controller.setTab(StoreTab.myBuilds),
                    onNavigateToCategory: (index) {
                      controller.setTab(StoreTab.components);
                      tabController.animateTo(index);
                    },
                  ),
                );
              },
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
