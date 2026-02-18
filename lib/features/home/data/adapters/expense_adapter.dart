import 'package:hive/hive.dart';
import '../models/expense_model.dart';
import '../../../../../../core/security/encryption_service.dart';
import '../../../../../../injection_container.dart';

class ExpenseAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 1;

  @override
  ExpenseModel read(BinaryReader reader) {
    String id;
    double amount;
    DateTime date;
    String categoryId;
    String note;
    bool isSyncedToFirebase;
    DateTime? lastSyncedAt;

    try {
      id = reader.read() as String;

      // Migration: Check if amount is Double (Old) or String (New Encrypted)
      final amountRaw = reader.read();
      if (amountRaw is double) {
        amount = amountRaw;
      } else if (amountRaw is String) {
        // Decrypt
        final encryptionService = getIt<EncryptionService>();
        amount = encryptionService.decryptValue(amountRaw);
      } else {
        amount = 0.0;
      }

      date = DateTime.fromMillisecondsSinceEpoch(reader.read() as int);
      categoryId = reader.read() as String;
      note = reader.read() as String;
      isSyncedToFirebase = reader.read() as bool;
    } catch (e) {
      rethrow;
    }

    try {
      lastSyncedAt = reader.read() as DateTime?;
    } catch (_) {
      lastSyncedAt = null;
    }

    return ExpenseModel(
      id: id,
      amount: amount,
      date: date,
      categoryId: categoryId,
      note: note,
      isSyncedToFirebase: isSyncedToFirebase,
      lastSyncedAt: lastSyncedAt,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer.write(obj.id);

    // Encrypt amount before writing
    final encryptionService = getIt<EncryptionService>();
    final encryptedAmount = encryptionService.encryptValue(obj.amount);
    writer.write(encryptedAmount);

    writer.write(obj.date.millisecondsSinceEpoch);
    writer.write(obj.categoryId);
    writer.write(obj.note);
    writer.write(obj.isSyncedToFirebase);
    writer.write(obj.lastSyncedAt);
  }
}
