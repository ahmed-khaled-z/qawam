import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.iconCode,
    required super.color,
    super.isSyncedToFirebase,
    super.lastSyncedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCode: json['iconCode'] as int,
      color: json['color'] as int,
      isSyncedToFirebase: json['isSyncedToFirebase'] as bool? ?? false,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCode': iconCode,
      'color': color,
      'isSyncedToFirebase': isSyncedToFirebase,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      iconCode: category.iconCode,
      color: category.color,
      isSyncedToFirebase: category.isSyncedToFirebase,
      lastSyncedAt: category.lastSyncedAt,
    );
  }
}
