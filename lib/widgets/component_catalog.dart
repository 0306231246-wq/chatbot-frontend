import 'package:flutter/material.dart';
import '/models/component.dart';
import 'component_catalog/component_category.dart';
import 'component_catalog/category_page.dart';
import 'component_catalog/catalog_data_generated.dart';
import '../controllers/pc_builder_controller.dart';

final Map<ComponentCategory, List<PcComponent>> _generatedByCategory = {
  for (final cat in ComponentCategory.values)
    cat: generatedCatalog
        .where((c) => c.category == cat.apiCategory)
        .toList(growable: false),
};

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — wrapper giữ TabBar
// ─────────────────────────────────────────────────────────────────────────────
class ComponentCatalogPage extends StatelessWidget {
  /// Truyền null → dùng sample data xem trước UI
  final List<PcComponent>? components;
  final String? searchQuery;
  final PcBuilderController? pcBuilderController;
  final VoidCallback? onEditingComponentSelected;

  const ComponentCatalogPage({
    super.key,
    this.components,
    this.searchQuery,
    this.pcBuilderController,
    this.onEditingComponentSelected,
  });

  List<PcComponent> _forCategory(ComponentCategory cat) {
    if (components == null) {
      return _generatedByCategory[cat] ?? const <PcComponent>[];
    }
    final all = components ?? generatedCatalog;
    return all.where((c) => c.category == cat.apiCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: ComponentCategory.values.map((cat) {
        return CategoryPage(
          category: cat,
          components: _forCategory(cat),
          searchQuery: searchQuery,
          pcBuilderController: pcBuilderController,
          onEditingComponentSelected: onEditingComponentSelected,
        );
      }).toList(),
    );
  }
}
