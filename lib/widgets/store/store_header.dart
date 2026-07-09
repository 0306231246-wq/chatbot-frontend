import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/main_store_controller.dart';
import '../../controllers/pc_builder_controller.dart';
import '../../controllers/user_builds_controller.dart';
import '../../screens/login_page.dart';
import 'pc_builder_sheet.dart';
import '../chat/chat_bot_widget.dart';
import '../../services/auth_service.dart';

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
                    _buildPcBuilderIcon(context),
                  _buildProBadge(context),
                  _buildAuthButton(context),
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
                  _buildPcBuilderIcon(context),
                _buildProBadge(context),
                _buildAuthButton(context)
              ] : null,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(isDesktop ? 56 : 104),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isDesktop)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: _buildGlobalSearchBar(context),
                      ),
                    _buildTabBar(context),
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
              child: _buildGlobalSearchBar(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalSearchBar(BuildContext context) {
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
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0D12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildTabItem(context, 'Cấu hình mẫu', controller.tab == StoreTab.builds, () => controller.setTab(StoreTab.builds)),
          const SizedBox(width: 12),
          _buildTabItem(context, 'Linh kiện rời', controller.tab == StoreTab.components, () => controller.setTab(StoreTab.components)),
          const SizedBox(width: 12),
          _buildTabItem(context, 'Của tôi', controller.tab == StoreTab.myBuilds, () => controller.setTab(StoreTab.myBuilds)),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String text, bool isSelected, VoidCallback onTap) {
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
        child: Text(text,
            style: TextStyle(
              color: isSelected ? primary : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            )),
      ),
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

  Widget _buildAuthButton(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: FirebaseAuth.instance.currentUser != null
          ? PopupMenuButton<String>(
              offset: const Offset(0, 48),
              color: const Color(0xFF1A1A22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (val) async {
                if (val == 'signout') {
                  await AuthService().signOut();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đăng xuất thành công')),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'signout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.redAccent.shade400, size: 18),
                      const SizedBox(width: 10),
                      const Text(
                        'Đăng xuất',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FirebaseAuth.instance.currentUser?.photoURL != null
                    ? Image.network(
                        FirebaseAuth.instance.currentUser!.photoURL!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.account_circle, size: 36, color: primary),
                      )
                    : Icon(Icons.account_circle, size: 36, color: primary),
              ),
            )
          : TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: primary.withOpacity(0.15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: Icon(Icons.person_outline_rounded, size: 16, color: primary),
              label: Text('Đăng nhập', style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              },
            ),
    );
  }

  Widget _buildPcBuilderIcon(BuildContext context) {
    return ListenableBuilder(
      listenable: pcBuilderController!,
      builder: (context, _) {
        final count = pcBuilderController!.selectedCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.build_circle_outlined, color: count > 0 ? Theme.of(context).colorScheme.primary : Colors.white),
              onPressed: () {
                final tabController = DefaultTabController.of(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => PcBuilderSheet(
                    controller: pcBuilderController!,
                    userBuildsController: userBuildsController ?? UserBuildsController(),
                    chatBotKey: chatBotKey!,
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
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
