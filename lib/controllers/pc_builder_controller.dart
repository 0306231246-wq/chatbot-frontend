import 'package:flutter/foundation.dart';
import '../models/component.dart';

class PcBuilderController extends ChangeNotifier {
  PcComponent? _selectedCpu;
  PcComponent? _selectedMainboard;
  PcComponent? _selectedGpu;

  PcComponent? get selectedCpu => _selectedCpu;
  PcComponent? get selectedMainboard => _selectedMainboard;
  PcComponent? get selectedGpu => _selectedGpu;

  void selectCpu(PcComponent component) {
    _selectedCpu = component;
    notifyListeners();
  }

  void removeCpu() {
    _selectedCpu = null;
    notifyListeners();
  }

  void selectMainboard(PcComponent component) {
    _selectedMainboard = component;
    notifyListeners();
  }

  void removeMainboard() {
    _selectedMainboard = null;
    notifyListeners();
  }

  void selectGpu(PcComponent component) {
    _selectedGpu = component;
    notifyListeners();
  }

  void removeGpu() {
    _selectedGpu = null;
    notifyListeners();
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
}
