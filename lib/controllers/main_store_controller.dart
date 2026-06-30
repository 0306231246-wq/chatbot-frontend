import 'package:flutter/material.dart';
import '../models/pc_build.dart';
import '../data/mock_data.dart';

enum StoreTab { builds, components }

class MainStoreController extends ChangeNotifier {
  StoreTab _tab = StoreTab.builds;
  String _selectedBrand = 'All';
  double _maxBuildPrice = 100000000.0;
  final TextEditingController globalSearchController = TextEditingController();

  MainStoreController() {
    globalSearchController.addListener(() {
      notifyListeners();
    });
  }

  StoreTab get tab => _tab;
  String get selectedBrand => _selectedBrand;
  double get maxBuildPrice => _maxBuildPrice;

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

  String _brandOf(PcBuild build) => build.cpuModel.toLowerCase().contains('intel') ? 'Intel' : 'AMD';

  List<PcBuild> get filteredBuilds {
    final globalKw = globalSearchController.text.toLowerCase();
    return mockPcBuilds.where((b) {
      final buildString = '${b.buildId} ${b.cpuModel} ${b.motherboardModel} ${b.gpuModel}'.toLowerCase();
      
      if (globalKw.isNotEmpty && !buildString.contains(globalKw)) {
        return false;
      }
      if (_selectedBrand != 'All' && _brandOf(b) != _selectedBrand) return false;
      if (b.totalPrice > _maxBuildPrice) return false;
      return true;
    }).toList();
  }

  @override
  void dispose() {
    globalSearchController.dispose();
    super.dispose();
  }
}
