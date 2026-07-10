import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/component.dart';
import '../models/pc_build.dart';
import '../models/user_build.dart';
import '../widgets/component_catalog/catalog_data_generated.dart';

final Map<String, String> _catalogImageByName = {
  for (final c in generatedCatalog) c.name: c.imageUrl,
};

class PcBuilderController extends ChangeNotifier {
  PcComponent? _selectedCpu;
  PcComponent? _selectedMainboard;
  PcComponent? _selectedGpu;
  String? _editingUserBuildId;
  bool _isPrebuiltSelection = false;
  String? _prebuiltId;

  PcComponent? get selectedCpu => _selectedCpu;
  PcComponent? get selectedMainboard => _selectedMainboard;
  PcComponent? get selectedGpu => _selectedGpu;
  String? get editingUserBuildId => _editingUserBuildId;
  bool get isPrebuiltSelection => _isPrebuiltSelection;
  String? get prebuiltId => _prebuiltId;

  void selectCpu(PcComponent component) {
    _isPrebuiltSelection = false;
    _selectedCpu = component;
    notifyListeners();
    saveState();
  }

  void removeCpu() {
    _isPrebuiltSelection = false;
    _selectedCpu = null;
    notifyListeners();
    saveState();
  }

  void selectMainboard(PcComponent component) {
    _isPrebuiltSelection = false;
    _selectedMainboard = component;
    notifyListeners();
    saveState();
  }

  void removeMainboard() {
    _isPrebuiltSelection = false;
    _selectedMainboard = null;
    notifyListeners();
    saveState();
  }

  void selectGpu(PcComponent component) {
    _isPrebuiltSelection = false;
    _selectedGpu = component;
    notifyListeners();
    saveState();
  }

  void removeGpu() {
    _isPrebuiltSelection = false;
    _selectedGpu = null;
    notifyListeners();
    saveState();
  }
  
  void toggleComponent(PcComponent component, String category) {
    if (category.toLowerCase() == 'cpu') {
      if (_selectedCpu?.id == component.id) removeCpu();
      else selectCpu(component);
    } else if (category.toLowerCase() == 'mainboard' || category.toLowerCase() == 'motherboard') {
      if (_selectedMainboard?.id == component.id) removeMainboard();
      else selectMainboard(component);
    } else if (category.toLowerCase() == 'gpu') {
      if (_selectedGpu?.id == component.id) removeGpu();
      else selectGpu(component);
    }
  }

  bool isSelected(PcComponent component) {
    return _selectedCpu?.id == component.id ||
           _selectedMainboard?.id == component.id ||
           _selectedGpu?.id == component.id;
  }

  int get selectedCount {
    int count = 0;
    if (_selectedCpu != null) count++;
    if (_selectedMainboard != null) count++;
    if (_selectedGpu != null) count++;
    return count;
  }

  double get totalPrice {
    double total = 0;
    if (_selectedCpu != null) total += _selectedCpu!.price;
    if (_selectedMainboard != null) total += _selectedMainboard!.price;
    if (_selectedGpu != null) total += _selectedGpu!.price;
    return total;
  }

  String _imageForName(String? name) {
    if (name == null || name.isEmpty) return '';
    return _catalogImageByName[name] ?? '';
  }

  String _getStorageKey() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? 'builder_state_${user.uid}' : 'builder_state_guest';
  }

  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_getStorageKey());
    if (data != null) {
      try {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        if (decoded['cpu'] != null) _selectedCpu = PcComponent.fromJson(decoded['cpu']);
        if (decoded['mainboard'] != null) _selectedMainboard = PcComponent.fromJson(decoded['mainboard']);
        if (decoded['gpu'] != null) _selectedGpu = PcComponent.fromJson(decoded['gpu']);
        _isPrebuiltSelection = decoded['isPrebuiltSelection'] == true;
        notifyListeners();
      } catch (e) {
        print("Lỗi load builder state: $e");
      }
    }
  }

  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      if (_selectedCpu != null) 'cpu': _selectedCpu!.toJson(),
      if (_selectedMainboard != null) 'mainboard': _selectedMainboard!.toJson(),
      if (_selectedGpu != null) 'gpu': _selectedGpu!.toJson(),
      'isPrebuiltSelection': _isPrebuiltSelection,
    };
    await prefs.setString(_getStorageKey(), jsonEncode(data));
  }

  void applyBuild(PcBuild build) {
    _isPrebuiltSelection = true;
    _prebuiltId = build.buildId;
    _editingUserBuildId = null;
    
    // Tìm image URL từ catalog nếu có
    final cpuImg = _imageForName(build.cpuModel);
    final mbImg = _imageForName(build.motherboardModel);
    final gpuImg = _imageForName(build.gpuModel);

    _selectedCpu = PcComponent(
      id: 'cpu_${build.cpuModel.hashCode}',
      name: build.cpuModel,
      category: 'CPU',
      manufacturer: 'Unknown',
      price: build.cpuPrice.toDouble(),
      inStock: true,
      imageUrl: cpuImg,
    );
    _selectedMainboard = PcComponent(
      id: 'mb_${build.motherboardModel.hashCode}',
      name: build.motherboardModel,
      category: 'MAINBOARD',
      manufacturer: 'Unknown',
      price: build.motherboardPrice.toDouble(),
      inStock: true,
      imageUrl: mbImg,
    );
    _selectedGpu = PcComponent(
      id: 'gpu_${build.gpuModel.hashCode}',
      name: build.gpuModel,
      category: 'GPU',
      manufacturer: 'Unknown',
      price: build.gpuPrice.toDouble(),
      inStock: true,
      imageUrl: gpuImg,
    );
    notifyListeners();
    saveState();
  }

  void clearBuild() {
    _selectedCpu = null;
    _selectedMainboard = null;
    _selectedGpu = null;
    _editingUserBuildId = null;
    _isPrebuiltSelection = false;
    _prebuiltId = null;
    notifyListeners();
    saveState();
  }

  void loadUserBuild(UserBuild build) {
    _editingUserBuildId = build.id;
    _isPrebuiltSelection = false;
    _prebuiltId = null;
    
    // Tìm image URL từ catalog nếu có
    final cpuImg = _imageForName(build.cpuName);
    final mbImg = _imageForName(build.mainboardName);
    final gpuImg = _imageForName(build.gpuName);

    _selectedCpu = build.cpuName != null ? PcComponent(
      id: 'cpu_${build.cpuName.hashCode}',
      name: build.cpuName!,
      category: 'CPU',
      manufacturer: 'Unknown',
      price: build.cpuPrice ?? 0,
      inStock: true,
      imageUrl: cpuImg,
    ) : null;
    
    _selectedMainboard = build.mainboardName != null ? PcComponent(
      id: 'mb_${build.mainboardName.hashCode}',
      name: build.mainboardName!,
      category: 'MAINBOARD',
      manufacturer: 'Unknown',
      price: build.mainboardPrice ?? 0,
      inStock: true,
      imageUrl: mbImg,
    ) : null;

    _selectedGpu = build.gpuName != null ? PcComponent(
      id: 'gpu_${build.gpuName.hashCode}',
      name: build.gpuName!,
      category: 'GPU',
      manufacturer: 'Unknown',
      price: build.gpuPrice ?? 0,
      inStock: true,
      imageUrl: gpuImg,
    ) : null;

    notifyListeners();
    saveState();
  }

  void clearEditingUserBuild() {
    _editingUserBuildId = null;
    notifyListeners();
  }
}
