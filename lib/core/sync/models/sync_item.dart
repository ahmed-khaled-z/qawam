import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class SyncItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String collection; // 'expenses' or 'categories'

  @HiveField(2)
  final String operation; // 'delete' (we only need pending *deletions* usually, create/update are implied by isSynced=false)

  @HiveField(3)
  final DateTime timestamp;

  SyncItem({
    required this.id,
    required this.collection,
    required this.operation,
    required this.timestamp,
  });
}

class SyncItemAdapter extends TypeAdapter<SyncItem> {
  @override
  final int typeId = 2;

  @override
  SyncItem read(BinaryReader reader) {
    return SyncItem(
      id: reader.read() as String,
      collection: reader.read() as String,
      operation: reader.read() as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.read() as int),
    );
  }

  @override
  void write(BinaryWriter writer, SyncItem obj) {
    writer.write(obj.id);
    writer.write(obj.collection);
    writer.write(obj.operation);
    writer.write(obj.timestamp.millisecondsSinceEpoch);
  }
}
