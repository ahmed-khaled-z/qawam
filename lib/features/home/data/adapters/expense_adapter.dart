import 'package:flutter/foundation.dart';
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

      // Migration: Check if amount is Double (plain/legacy) or String (encrypted)
      final amountRaw = reader.read();
      if (amountRaw is double) {
        amount = amountRaw;
      } else if (amountRaw is String) {
        // Attempt decryption
        final encryptionService = getIt<EncryptionService>();
        if (encryptionService.isReady) {
          try {
            amount = encryptionService.decryptValue(amountRaw);
          } catch (e) {
            debugPrint(
              'ExpenseAdapter.read: Decryption failed for expense, '
              'setting amount to 0.0. Error: $e',
            );
            amount = 0.0;
          }
        } else {
          debugPrint(
            'ExpenseAdapter.read: Encryption not ready, cannot decrypt. '
            'Setting amount to 0.0.',
          );
          amount = 0.0;
        }
      } else {
        debugPrint(
          'ExpenseAdapter.read: Unexpected amount type: '
          '${amountRaw.runtimeType}. Setting amount to 0.0.',
        );
        amount = 0.0;
      }

      date = DateTime.fromMillisecondsSinceEpoch(reader.read() as int);
      categoryId = reader.read() as String;
      note = reader.read() as String;
      isSyncedToFirebase = reader.read() as bool;
    } catch (e) {
      debugPrint('ExpenseAdapter.read: Critical read error: $e');
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

    // Encrypt amount if encryption is ready; otherwise store plain double.
    // This ensures expenses can always be saved locally even when encryption
    // is not yet initialized (first launch, new device pending approval, etc.).
    final encryptionService = getIt<EncryptionService>();
    if (encryptionService.isReady) {
      try {
        final encryptedAmount = encryptionService.encryptValue(obj.amount);
        writer.write(encryptedAmount);
      } catch (e) {
        debugPrint(
          'ExpenseAdapter.write: Encryption failed, storing plain amount. '
          'Error: $e',
        );
        writer.write(obj.amount);
      }
    } else {
      debugPrint(
        'ExpenseAdapter.write: Encryption not ready, storing plain amount '
        'for expense ${obj.id}. Will be encrypted on next migration/sync.',
      );
      writer.write(obj.amount);
    }

    writer.write(obj.date.millisecondsSinceEpoch);
    writer.write(obj.categoryId);
    writer.write(obj.note);
    writer.write(obj.isSyncedToFirebase);
    writer.write(obj.lastSyncedAt);
  }
}
