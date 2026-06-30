import 'package:flutter/material.dart';
import '../../controllers/category_controller.dart';
import 'component_category.dart';

class CategoryFilterSheet extends StatelessWidget {
  final ComponentCategory category;
  final CategoryController controller;
  final bool isDesktop;
  final VoidCallback? onClose;

  const CategoryFilterSheet({
    super.key,
    required this.category,
    required this.controller,
    this.isDesktop = false,
    this.onClose,
  });

  static const _cpuSockets = ['AM5', 'AM4', 'LGA 1700', 'LGA 1851', 'LGA 1200', 'LGA 1151', 'LGA 1150', 'sTR5'];
  static const _mainSockets = ['AM5', 'AM4', 'LGA 1700', 'LGA 1851', 'LGA 1200', 'LGA 1151'];
  static const _mainChipsets = ['B850', 'X870', 'Z890', 'B760', 'Z790', 'X670', 'B650', 'A520', 'B550'];
  static const _gpuVram = ['4.0 GB', '6.0 GB', '8.0 GB', '10.0 GB', '12.0 GB', '16.0 GB', '24.0 GB', '32.0 GB'];
  static const _gpuManufacturers = ['ASUS', 'MSI', 'Gigabyte', 'ASRock', 'EVGA', 'Sapphire', 'Zotac', 'Inno3D', 'Acer'];
  static const _mainManufacturers = ['ASUS', 'MSI', 'Gigabyte', 'ASRock', 'Biostar', 'Supermicro'];

  String _formatVnd(num value) {
    final str = value.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return '${buf.toString()}đ';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Container(
          width: isDesktop ? 260 : double.infinity,
          color: isDesktop ? const Color(0xFF0D0D12) : Colors.transparent,
          padding: const EdgeInsets.all(16),
          child: ListView(
            primary: false,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => controller.clearFilters(),
                        child: const Text('Reset', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ),
                      if (!isDesktop && onClose != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: onClose,
                        ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),

              // In Stock toggle
              InkWell(
                onTap: () => controller.toggleInStock(!controller.inStockOnly),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: controller.inStockOnly ? primary.withOpacity(0.15) : Colors.transparent,
                    border: Border.all(color: controller.inStockOnly ? primary : Colors.white24),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 14, color: controller.inStockOnly ? primary : Colors.white38),
                      const SizedBox(width: 6),
                      Text('In Stock', style: TextStyle(color: controller.inStockOnly ? primary : Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Price slider
              const Text('Giá', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              RangeSlider(
                values: controller.priceRange,
                min: 0,
                max: 100000000,
                activeColor: primary,
                inactiveColor: Colors.white12,
                onChanged: (v) => controller.setPriceRange(v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatVnd(controller.priceRange.start), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(_formatVnd(controller.priceRange.end), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 20),

              // Manufacturer
              const Text('Hãng sản xuất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (category == ComponentCategory.cpu)
                Row(children: [
                  _buildManufacturerChip('AMD', primary),
                  const SizedBox(width: 8),
                  _buildManufacturerChip('Intel', primary),
                ])
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (category == ComponentCategory.gpu ? _gpuManufacturers : _mainManufacturers)
                      .map((brand) => _buildManufacturerChip(brand, primary))
                      .toList(),
                ),
              const SizedBox(height: 20),

              // CPU / Mainboard -> Socket
              if (category == ComponentCategory.cpu || category == ComponentCategory.mainboard) ...[
                const Text('Socket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...(category == ComponentCategory.cpu ? _cpuSockets : _mainSockets)
                    .map((s) => _buildSocketCheckbox(s, primary)),
                const SizedBox(height: 20),
              ],

              // Mainboard -> Chipset
              if (category == ComponentCategory.mainboard) ...[
                const Text('Chipset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ..._mainChipsets.map((c) => _buildChipsetCheckbox(c, primary)),
                const SizedBox(height: 20),
              ],

              // GPU -> VRAM
              if (category == ComponentCategory.gpu) ...[
                const Text('VRAM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ..._gpuVram.map((v) => _buildVramCheckbox(v, primary)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildManufacturerChip(String brand, Color primary) {
    final isSelected = controller.selectedManufacturers.contains(brand);
    final inkWell = InkWell(
      onTap: () => controller.toggleManufacturer(brand),
      child: _innerChip(brand, isSelected, primary),
    );
    if (category == ComponentCategory.cpu) {
      return Expanded(child: inkWell);
    }
    return inkWell;
  }

  Widget _innerChip(String brand, bool isSelected, Color primary) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? primary : Colors.transparent, width: 2),
      ),
      child: Center(
        child: Text(brand, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildSocketCheckbox(String socket, Color primary) {
    final isChecked = controller.selectedSockets.contains(socket);
    return CheckboxListTile(
      value: isChecked,
      onChanged: (v) {
        if (v != null) controller.toggleSocket(socket);
      },
      title: Text(socket, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: primary,
      checkColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildChipsetCheckbox(String chipset, Color primary) {
    final isChecked = controller.selectedChipsets.contains(chipset);
    return CheckboxListTile(
      value: isChecked,
      onChanged: (v) {
        if (v != null) controller.toggleChipset(chipset);
      },
      title: Text(chipset, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: primary,
      checkColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildVramCheckbox(String vram, Color primary) {
    final isChecked = controller.selectedVram.contains(vram);
    return CheckboxListTile(
      value: isChecked,
      onChanged: (v) {
        if (v != null) controller.toggleVram(vram);
      },
      title: Text(vram, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: primary,
      checkColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
