import 'package:flutter/material.dart';
import '../models/pc_build.dart';
import '../data/mock_data.dart';

enum StoreTab { builds, components }

class MainStoreController extends ChangeNotifier {
  StoreTab _tab = StoreTab.builds;
  String _selectedBrand = 'All';
  double _maxBuildPrice = 100000000.0;
  String _buildSortOption = 'Mặc định';
  final TextEditingController globalSearchController = TextEditingController();

  MainStoreController() {
    globalSearchController.addListener(() {
      notifyListeners();
    });
  }

  StoreTab get tab => _tab;
  String get selectedBrand => _selectedBrand;
  double get maxBuildPrice => _maxBuildPrice;
  String get buildSortOption => _buildSortOption;

  void setTab(StoreTab newTab) {
    if (_tab != newTab) {
      _tab = newTab;
      notifyListeners();
    }
  }

  void setSelectedBrand(String brand) {
    if (_selectedBrand != brand) {
      _selectedBrand = brand;
      notifyListeners();
    }
  }

  void setMaxBuildPrice(double price) {
    if (_maxBuildPrice != price) {
      _maxBuildPrice = price;
      notifyListeners();
    }
  }

  void setBuildSortOption(String option) {
    if (_buildSortOption != option) {
      _buildSortOption = option;
      notifyListeners();
    }
  }

  String _brandOf(PcBuild build) => build.cpuModel.toLowerCase().contains('intel') ? 'Intel' : 'AMD';

  List<PcBuild> get filteredBuilds {
    final globalKw = globalSearchController.text.toLowerCase();
    var list = mockPcBuilds.where((b) {
      final buildString = '${b.buildId} ${b.cpuModel} ${b.motherboardModel} ${b.gpuModel}'.toLowerCase();
      
      if (globalKw.isNotEmpty && !buildString.contains(globalKw)) {
        return false;
      }
      if (_selectedBrand != 'All' && _brandOf(b) != _selectedBrand) return false;
      if (b.totalPrice > _maxBuildPrice) return false;
      return true;
    }).toList();

    switch (_buildSortOption) {
      case 'Giá tăng dần':
        list.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
        break;
      case 'Giá giảm dần':
        list.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
        break;
    }

    return list;
  }

  @override
  void dispose() {
    globalSearchController.dispose();
    super.dispose();
  }
}
