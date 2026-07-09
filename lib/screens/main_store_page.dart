import 'package:flutter/material.dart';
import '../widgets/chat/chat_bot_widget.dart';
import '../widgets/component_catalog.dart';
import '../widgets/store/build_list.dart';
import '../widgets/store/build_filters.dart';
import '../controllers/main_store_controller.dart';
import '../controllers/user_builds_controller.dart';
import '../widgets/store/components/global_search_bar.dart';
import '../widgets/store/components/store_tab_bar.dart';
import '../widgets/store/components/pc_builder_badge.dart';
import '../widgets/store/components/auth_button.dart';
import '../controllers/pc_builder_controller.dart';
import '../widgets/store/user/user_build_list.dart';
import '../widgets/store/pc_builder_sheet.dart';


class MainStorePage extends StatefulWidget {
  const MainStorePage({super.key});

  @override
  State<MainStorePage> createState() => _MainStorePageState();
}

class _MainStorePageState extends State<MainStorePage> {
  late final MainStoreController _controller;
  late final PcBuilderController _pcBuilderController;
  late final UserBuildsController _userBuildsController;
  final GlobalKey<ChatBotWidgetState> _chatBotKey = GlobalKey<ChatBotWidgetState>();

  @override
  void initState() {
    super.initState();
    _controller = MainStoreController();
    _pcBuilderController = PcBuilderController();
    _pcBuilderController.loadState();
    _userBuildsController = UserBuildsController();
    _userBuildsController.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pcBuilderController.dispose();
    _userBuildsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D12),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              NestedScrollView(
                floatHeaderSlivers: true,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    if (!isDesktop)
                      SliverAppBar(
                        primary: false,
                        floating: false,
                        pinned: true,
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
                          PcBuilderBadge(
                            pcBuilderController: _pcBuilderController,
                            userBuildsController: _userBuildsController,
                            chatBotKey: _chatBotKey,
                            controller: _controller,
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(6)),
                            child: const Text('PCSTORE PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                          AuthButton(controller: _controller),
                        ],
                      ),
                    SliverAppBar(
                      primary: false,
                      floating: false,
                      pinned: true,
                      backgroundColor: const Color(0xFF0D0D12),
                      automaticallyImplyLeading: false,
                      toolbarHeight: isDesktop ? 56 : 0,
                      title: isDesktop ? Row(
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
                                child: GlobalSearchBar(controller: _controller),
                              ),
                            ),
                          ),
                        ],
                      ) : null,
                      actions: isDesktop ? [
                        PcBuilderBadge(
                          pcBuilderController: _pcBuilderController,
                          userBuildsController: _userBuildsController,
                          chatBotKey: _chatBotKey,
                          controller: _controller,
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(6)),
                          child: const Text('PCSTORE PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                        AuthButton(controller: _controller)
                      ] : null,
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(isDesktop ? 56 : 104),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isDesktop)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                child: GlobalSearchBar(controller: _controller),
                              ),
                            ListenableBuilder(
                              listenable: _controller,
                              builder: (ctx, _) => StoreTabBar(controller: _controller),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _ConditionalComponentsHeader(controller: _controller),
                  ];
                },
                body: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => _buildBody(isDesktop),
                ),
              ),
              Positioned.fill(
                child: ChatBotWidget(
                  key: _chatBotKey,
                  onApplyBuild: (build) {
                    _pcBuilderController.applyBuild(build);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã nạp cấu hình ${build.buildId} vào Tự Build PC!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDesktop) {
    switch (_controller.tab) {
      case StoreTab.builds:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop)
              BuildFilters(
                isDesktop: isDesktop,
                selectedBrand: _controller.selectedBrand,
                maxBuildPrice: _controller.maxBuildPrice,
                sortOption: _controller.buildSortOption,
                onBrandChanged: (val) => _controller.setSelectedBrand(val),
                onPriceChanged: (val) => _controller.setMaxBuildPrice(val),
                onSortChanged: (val) => _controller.setBuildSortOption(val),
                onClear: () {
                  _controller.setSelectedBrand('All');
                  _controller.setMaxBuildPrice(100000000.0);
                  _controller.setBuildSortOption('Mặc định');
                },
              ),
            Expanded(child: _buildBuildContentArea(isDesktop)),
          ],
        );
      case StoreTab.components:
        return ComponentCatalogPage(
          searchQuery: _controller.globalSearchController.text,
          pcBuilderController: _pcBuilderController,
          onEditingComponentSelected: _showPcBuilderSheet,
        );
      case StoreTab.myBuilds:
        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text('Cấu hình đã lưu',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            UserBuildList(
              controller: _userBuildsController,
              pcBuilderController: _pcBuilderController,
              mainStoreController: _controller,
              chatBotKey: _chatBotKey,
            ),
          ],
        );
    }
  }

  Widget _buildBuildContentArea(bool isDesktop) {
    final items = _controller.filteredBuilds;
    final primary = Theme.of(context).colorScheme.primary;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Gợi ý ${items.length} cấu hình PC',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    if (!isDesktop)
                      IconButton(
                        icon: Icon(Icons.filter_list, color: primary),
                        onPressed: _showMobileBuildFilters,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // ── Danh sách build gợi ý ──────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: BuildList(
            builds: items,
            onApplyBuild: (build) {
              _pcBuilderController.applyBuild(build);
              _showPcBuilderSheet();
            },
          ),
        ),
      ],
    );
  }

  void _showMobileBuildFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D0D12),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (ctx, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 16),
                    BuildFilters(
                      isDesktop: false,
                      selectedBrand: _controller.selectedBrand,
                      maxBuildPrice: _controller.maxBuildPrice,
                      sortOption: _controller.buildSortOption,
                      onBrandChanged: (val) => _controller.setSelectedBrand(val),
                      onPriceChanged: (val) => _controller.setMaxBuildPrice(val),
                      onSortChanged: (val) => _controller.setBuildSortOption(val),
                      onClear: () {
                        _controller.setSelectedBrand('All');
                        _controller.setMaxBuildPrice(100000000.0);
                        _controller.setBuildSortOption('Mặc định');
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showPcBuilderSheet() {
    final tabController = DefaultTabController.maybeOf(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PcBuilderSheet(
        controller: _pcBuilderController,
        userBuildsController: _userBuildsController,
        chatBotKey: _chatBotKey,
        onSaved: () => _controller.setTab(StoreTab.myBuilds),
        onNavigateToCategory: (index) {
          _controller.setTab(StoreTab.components);
          tabController?.animateTo(index);
        },
      ),
    );
  }
}

class _ConditionalComponentsHeader extends StatefulWidget {
  final MainStoreController controller;
  const _ConditionalComponentsHeader({required this.controller});

  @override
  State<_ConditionalComponentsHeader> createState() => _ConditionalComponentsHeaderState();
}

class _ConditionalComponentsHeaderState extends State<_ConditionalComponentsHeader> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.tab != StoreTab.components) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverAppBar(
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
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        labelPadding: EdgeInsets.zero,
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
    );
  }
}
