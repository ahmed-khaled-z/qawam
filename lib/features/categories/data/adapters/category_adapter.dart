import 'package:hive/hive.dart';
import '../models/category_model.dart';

class CategoryAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 0;

  @override
  CategoryModel read(BinaryReader reader) {
    String id;
    String name;
    int iconCode;
    int color;
    bool isSyncedToFirebase;
    DateTime? lastSyncedAt;

    try {
      id = reader.read() as String;
      name = reader.read() as String;
      iconCode = reader.read() as int;
      color = reader.read() as int;
      isSyncedToFirebase = reader.read() as bool;
    } catch (e) {
      // In case basic fields fail (should not happen if data is valid)
      throw e;
    }

    try {
      // Try to read lastSyncedAt if available
      lastSyncedAt = reader.read() as DateTime?;
    } catch (_) {
      // Backward compatibility: old data doesn't have this field
      lastSyncedAt = null;
    }

    return CategoryModel(
      id: id,
      name: name,
      iconCode: iconCode,
      color: color,
      isSyncedToFirebase: isSyncedToFirebase,
      lastSyncedAt: lastSyncedAt,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.iconCode);
    writer.write(obj.color);
    writer.write(obj.isSyncedToFirebase);
    writer.write(obj.lastSyncedAt);
  }
}
