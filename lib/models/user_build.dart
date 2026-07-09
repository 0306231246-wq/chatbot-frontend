import 'dart:convert';

/// Model cho build PC do người dùng tự tạo và lưu lại
class UserBuild {
  final String id;
  String name;

  // CPU
  String? cpuName;
  double? cpuPrice;

  // Mainboard
  String? mainboardName;
  double? mainboardPrice;

  // GPU
  String? gpuName;
  double? gpuPrice;

  final DateTime createdAt;

  UserBuild({
    required this.id,
    required this.name,
    this.cpuName,
    this.cpuPrice,
    this.mainboardName,
    this.mainboardPrice,
    this.gpuName,
    this.gpuPrice,
    required this.createdAt,
  });

  double get totalPrice =>
      (cpuPrice ?? 0) + (mainboardPrice ?? 0) + (gpuPrice ?? 0);

  /// Tạo bản sao với một số trường được cập nhật
  UserBuild copyWith({
    String? name,
    String? cpuName,
    double? cpuPrice,
    String? mainboardName,
    double? mainboardPrice,
    String? gpuName,
    double? gpuPrice,
  }) {
    return UserBuild(
      id: id,
      name: name ?? this.name,
      cpuName: cpuName ?? this.cpuName,
      cpuPrice: cpuPrice ?? this.cpuPrice,
      mainboardName: mainboardName ?? this.mainboardName,
      mainboardPrice: mainboardPrice ?? this.mainboardPrice,
      gpuName: gpuName ?? this.gpuName,
      gpuPrice: gpuPrice ?? this.gpuPrice,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cpuName': cpuName,
        'cpuPrice': cpuPrice,
        'mainboardName': mainboardName,
        'mainboardPrice': mainboardPrice,
        'gpuName': gpuName,
        'gpuPrice': gpuPrice,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserBuild.fromJson(Map<String, dynamic> json) => UserBuild(
        id: json['id'] as String,
        name: json['name'] as String,
        cpuName: json['cpuName'] as String?,
        cpuPrice: (json['cpuPrice'] as num?)?.toDouble(),
        mainboardName: json['mainboardName'] as String?,
        mainboardPrice: (json['mainboardPrice'] as num?)?.toDouble(),
        gpuName: json['gpuName'] as String?,
        gpuPrice: (json['gpuPrice'] as num?)?.toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  /// Encode danh sách để lưu vào SharedPreferences
  static String encodeList(List<UserBuild> builds) =>
      jsonEncode(builds.map((b) => b.toJson()).toList());

  /// Decode danh sách từ SharedPreferences
  static List<UserBuild> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => UserBuild.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
