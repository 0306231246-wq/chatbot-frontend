import 'package:flutter/material.dart';
import '../widgets/chat/chat_bot_widget.dart';
import '../widgets/component_catalog.dart';
import '../widgets/store/build_list.dart';
import '../widgets/store/build_filters.dart';
import '../controllers/main_store_controller.dart';
import '../widgets/store/store_header.dart';
import '../controllers/pc_builder_controller.dart';


class MainStorePage extends StatefulWidget {
  const MainStorePage({super.key});

  @override
  State<MainStorePage> createState() => _MainStorePageState();
}

class _MainStorePageState extends State<MainStorePage> {
  late final MainStoreController _controller;
  late final PcBuilderController _pcBuilderController;
  final GlobalKey<ChatBotWidgetState> _chatBotKey = GlobalKey<ChatBotWidgetState>();

  @override
  void initState() {
    super.initState();
    _controller = MainStoreController();
    _pcBuilderController = PcBuilderController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pcBuilderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
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
                        StoreHeader(
                          controller: _controller,
                          isDesktop: isDesktop,
                          pcBuilderController: _pcBuilderController,
                          chatBotKey: _chatBotKey,
                        ),
                      ];
                    },
                    body: _controller.tab == StoreTab.builds
                        ? Row(
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
                          )
                        : ComponentCatalogPage(
                            searchQuery: _controller.globalSearchController.text,
                            pcBuilderController: _pcBuilderController,
                          ),
                  ),
                  Positioned.fill(
                    child: ChatBotWidget(key: _chatBotKey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBuildContentArea(bool isDesktop) {
    final items = _controller.filteredBuilds;
    final primary = Theme.of(context).colorScheme.primary;

    return CustomScrollView(
      controller: ScrollController(),
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
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: BuildList(builds: items),
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
}
