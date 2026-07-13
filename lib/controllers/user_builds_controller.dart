import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_build.dart';

/// Controller quản lý danh sách build PC do người dùng tự tạo.
/// Dữ liệu được persist vào SharedPreferences theo từng tài khoản.
class UserBuildsController extends ChangeNotifier {
  final List<UserBuild> _builds = [];

  List<UserBuild> get builds => List.unmodifiable(_builds);

  // ─── Key lưu theo user ───────────────────────────────────────────────────
  String _storageKey() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? 'user_builds_${user.uid}' : 'user_builds_guest';
  }

  // ─── Load từ flutter_secure_storage ──────────────────────────────────────────
  Future<void> load() async {
    try {
      const storage = FlutterSecureStorage();
      final raw = await storage.read(key: _storageKey());
      if (raw != null) {
        final loaded = UserBuild.decodeList(raw);
        _builds
          ..clear()
          ..addAll(loaded);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('UserBuildsController.load error: $e');
    }
  }

  // ─── Lưu vào flutter_secure_storage ──────────────────────────────────────────
  Future<void> _save() async {
    try {
      const storage = FlutterSecureStorage();
      await storage.write(key: _storageKey(), value: UserBuild.encodeList(_builds));
    } catch (e) {
      debugPrint('UserBuildsController._save error: $e');
    }
  }

  // ─── CRUD ────────────────────────────────────────────────────────────────

  /// Thêm một build mới vào đầu danh sách
  Future<void> addBuild(UserBuild build) async {
    _builds.insert(0, build);
    notifyListeners();
    await _save();
  }

  /// Cập nhật tên của một build
  Future<void> updateBuildName(String id, String name) async {
    final index = _builds.indexWhere((b) => b.id == id);
    if (index == -1) return;

    final old = _builds[index];
    _builds[index] = UserBuild(
      id: old.id,
      name: name,
      cpuName: old.cpuName,
      cpuPrice: old.cpuPrice,
      mainboardName: old.mainboardName,
      mainboardPrice: old.mainboardPrice,
      gpuName: old.gpuName,
      gpuPrice: old.gpuPrice,
      createdAt: old.createdAt,
    );
    notifyListeners();
    await _save();
  }

  /// Cập nhật linh kiện của một build
  Future<void> updateBuildComponents(
    String id, {
    String? name,
    String? cpuName,
    double? cpuPrice,
    String? mainboardName,
    double? mainboardPrice,
    String? gpuName,
    double? gpuPrice,
  }) async {
    final index = _builds.indexWhere((b) => b.id == id);
    if (index == -1) return;

    final old = _builds[index];
    _builds[index] = UserBuild(
      id: old.id,
      name: name ?? old.name,
      cpuName: cpuName, // Cho phép null để xóa linh kiện
      cpuPrice: cpuPrice,
      mainboardName: mainboardName,
      mainboardPrice: mainboardPrice,
      gpuName: gpuName,
      gpuPrice: gpuPrice,
      createdAt: old.createdAt,
    );
    notifyListeners();
    await _save();
  }

  /// Xóa một build theo id
  Future<void> deleteBuild(String id) async {
    _builds.removeWhere((b) => b.id == id);
    notifyListeners();
    await _save();
  }
}
