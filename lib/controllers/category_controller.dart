import 'package:flutter/material.dart';
import '../models/component.dart';

class CategoryController extends ChangeNotifier {
  bool inStockOnly = false;
  RangeValues priceRange = const RangeValues(0, 100000000);
  final Set<String> selectedManufacturers = {};
  final Set<String> selectedSockets = {};
  final Set<String> selectedVram = {};
  final Set<String> selectedChipsets = {};
  String sortOption = 'Mặc định';

  void toggleInStock(bool value) {
    if (inStockOnly != value) {
      inStockOnly = value;
      notifyListeners();
    }
  }

  void setPriceRange(RangeValues range) {
    if (priceRange != range) {
      priceRange = range;
      notifyListeners();
    }
  }

  void toggleManufacturer(String m) {
    if (selectedManufacturers.contains(m)) {
      selectedManufacturers.remove(m);
    } else {
      selectedManufacturers.add(m);
    }
    notifyListeners();
  }

  void toggleSocket(String s) {
    if (selectedSockets.contains(s)) {
      selectedSockets.remove(s);
    } else {
      selectedSockets.add(s);
    }
    notifyListeners();
  }

  void toggleVram(String v) {
    if (selectedVram.contains(v)) {
      selectedVram.remove(v);
    } else {
      selectedVram.add(v);
    }
    notifyListeners();
  }

  void toggleChipset(String c) {
    if (selectedChipsets.contains(c)) {
      selectedChipsets.remove(c);
    } else {
      selectedChipsets.add(c);
    }
    notifyListeners();
  }

  void setSortOption(String option) {
    if (sortOption != option) {
      sortOption = option;
      notifyListeners();
    }
  }

  void clearFilters() {
    inStockOnly = false;
    priceRange = const RangeValues(0, 100000000);
    selectedManufacturers.clear();
    selectedSockets.clear();
    selectedVram.clear();
    selectedChipsets.clear();
    notifyListeners();
  }

  List<PcComponent> getFiltered(List<PcComponent> components, String? searchQuery) {
    var list = components.toList();
    final globalKw = searchQuery?.toLowerCase().trim() ?? '';
    final kwTokens = globalKw.isNotEmpty ? globalKw.split(RegExp(r'\s+')) : [];

    list = list.where((c) {
      if (inStockOnly && !c.inStock) return false;
      if (c.price < priceRange.start || c.price > priceRange.end) return false;
      if (selectedManufacturers.isNotEmpty) {
        bool matches = false;
        for (final m in selectedManufacturers) {
          if (c.manufacturer == m || c.name.toLowerCase().contains(m.toLowerCase())) {
            matches = true;
            break;
          }
        }
        if (!matches) return false;
      }

      if (selectedSockets.isNotEmpty) {
        if (c.socket == null || !selectedSockets.contains(c.socket)) return false;
      }

      if (selectedChipsets.isNotEmpty) {
        final chipset = (c.chipset ?? c.name).toUpperCase();
        if (!selectedChipsets.any((ch) => chipset.contains(ch.toUpperCase()))) return false;
      }

      if (selectedVram.isNotEmpty) {
        final vram = c.vramLabel ?? '';
        if (!selectedVram.contains(vram)) return false;
      }

      if (kwTokens.isNotEmpty) {
        final searchTarget = '${c.name} ${c.manufacturer ?? ''}'.toLowerCase();
        if (!kwTokens.every((token) => searchTarget.contains(token))) return false;
      }
      return true;
    }).toList();

    switch (sortOption) {
      case 'Giá tăng dần':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Giá giảm dần':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Tên A-Z':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return list;
  }
}
