import 'package:flutter/material.dart';
import '../../controllers/main_store_controller.dart';
import '../../controllers/pc_builder_controller.dart';
import '../../controllers/user_builds_controller.dart';
import '../chat/chat_bot_widget.dart';
import 'components/global_search_bar.dart';
import 'components/auth_button.dart';
import 'components/store_tab_bar.dart';
import 'components/pc_builder_badge.dart';

class StoreHeader extends StatelessWidget {
  final MainStoreController controller;
  final bool isDesktop;
  final PcBuilderController? pcBuilderController;
  final UserBuildsController? userBuildsController;
  final GlobalKey<ChatBotWidgetState>? chatBotKey;

  const StoreHeader({
    super.key,
    required this.controller,
    required this.isDesktop,
    this.pcBuilderController,
    this.userBuildsController,
    this.chatBotKey,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SliverMainAxisGroup(
          slivers: [
            if (!isDesktop)
              SliverAppBar(
                primary: false,
                floating: true,
                snap: true,
                pinned: false,
                backgroundColor: const Color(0xFF0D0D12),
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Icon(Icons.memory_rounded, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text('TECH-GEAR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 16, color: Colors.white)),
                  ],
                ),
                actions: [
                  if (pcBuilderController != null && chatBotKey != null)
                    PcBuilderBadge(
                      pcBuilderController: pcBuilderController!,
                      userBuildsController: userBuildsController ?? UserBuildsController(),
                      chatBotKey: chatBotKey!,
                      controller: controller,
                    ),
                  _buildProBadge(context),
                  AuthButton(controller: controller),
                ],
              ),
            SliverAppBar(
              primary: false,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF0D0D12),
              automaticallyImplyLeading: false,
              toolbarHeight: isDesktop ? 56 : 0,
              title: isDesktop ? _buildDesktopTitle(context) : null,
              actions: isDesktop ? [
                if (pcBuilderController != null && chatBotKey != null)
                  PcBuilderBadge(
                    pcBuilderController: pcBuilderController!,
                    userBuildsController: userBuildsController ?? UserBuildsController(),
                    chatBotKey: chatBotKey!,
                    controller: controller,
                  ),
                _buildProBadge(context),
                AuthButton(controller: controller)
              ] : null,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(isDesktop ? 56 : 104),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isDesktop)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: GlobalSearchBar(controller: controller),
                      ),
                    StoreTabBar(controller: controller),
                  ],
                ),
              ),
            ),
            if (controller.tab == StoreTab.components)
              SliverAppBar(
                primary: false,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xFF0D0D12),
                toolbarHeight: 0,
                bottom: TabBar(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  indicatorWeight: 3,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.white38,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), // Giảm nhẹ size font
                  labelPadding: EdgeInsets.zero, // Bỏ padding thừa
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.memory, size: 16), SizedBox(width: 4), Text('CPU', overflow: TextOverflow.ellipsis)],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.videogame_asset, size: 16), SizedBox(width: 4), Text('GPU', overflow: TextOverflow.ellipsis)],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.developer_board, size: 16), SizedBox(width: 4), Flexible(child: Text('Mainboard', overflow: TextOverflow.ellipsis))],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopTitle(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.memory_rounded, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        const Text('TECH-GEAR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 16, color: Colors.white)),
        const SizedBox(width: 24),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: GlobalSearchBar(controller: controller),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(6)),
      child: const Text('PCSTORE PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}
