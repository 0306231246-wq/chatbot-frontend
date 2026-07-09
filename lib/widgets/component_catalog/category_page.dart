import 'package:flutter/material.dart';
import '../../models/component.dart';
import '../../controllers/category_controller.dart';
import 'component_category.dart';
import 'product_card.dart';
import 'category_filter_sheet.dart';
import '../../controllers/pc_builder_controller.dart';

class CategoryPage extends StatefulWidget {
  final ComponentCategory category;
  final List<PcComponent> components;
  final String? searchQuery;
  final PcBuilderController? pcBuilderController;
  final VoidCallback? onEditingComponentSelected;

  const CategoryPage({
    super.key,
    required this.category,
    required this.components,
    this.searchQuery,
    this.pcBuilderController,
    this.onEditingComponentSelected,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final CategoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CategoryController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatVnd(num value) {
    final str = value.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return '${buf.toString()}đ';
  }

  void _showMobileFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Color(0xFF0D0D12),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                ),
                Expanded(
                  child: CategoryFilterSheet(
                    category: widget.category,
                    controller: _controller,
                    isDesktop: false,
                    onClose: () => Navigator.pop(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Xem kết quả',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDesktop = sw > 900;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final filtered =
            _controller.getFiltered(widget.components, widget.searchQuery);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop)
              CategoryFilterSheet(
                category: widget.category,
                controller: _controller,
                isDesktop: true,
              ),
            Expanded(child: _buildContent(filtered, isDesktop)),
          ],
        );
      },
    );
  }

  Widget _buildContent(List<PcComponent> items, bool isDesktop) {
    final total = widget.components.length;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isDesktop) ...[
                  Row(
                    children: [
                      Expanded(child: _buildSortDropdown(isDesktop)),
                      const SizedBox(width: 8),
                      _buildFilterButton(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tìm thấy ${items.length} sản phẩm phù hợp',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ] else ...[
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hiển thị ${items.length} sản phẩm phù hợp',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text('trên tổng $total sản phẩm',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                      _buildSortDropdown(isDesktop),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: items.isEmpty
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Không tìm thấy linh kiện phù hợp.',
                          style: TextStyle(color: Colors.white38)),
                    ),
                  ),
                )
              : SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 5 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: isDesktop ? 0.65 : 0.52,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => ProductCard(
                    component: items[i],
                    category: widget.category,
                    formatVnd: _formatVnd,
                    pcBuilderController: widget.pcBuilderController,
                    onEditingComponentSelected:
                        widget.onEditingComponentSelected,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterButton() {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A22),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.filter_list, size: 18),
        label: const Text('Filters'),
        onPressed: _showMobileFilters,
      ),
    );
  }

  Widget _buildSortDropdown(bool isDesktop) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A22),
          borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _controller.sortOption,
          isExpanded: !isDesktop,
          dropdownColor: const Color(0xFF1A1A22),
          icon: const Icon(Icons.swap_vert, color: Colors.white54, size: 18),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: ['Mặc định', 'Giá tăng dần', 'Giá giảm dần', 'Tên A-Z']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => _controller.setSortOption(v!),
        ),
      ),
    );
  }
}
