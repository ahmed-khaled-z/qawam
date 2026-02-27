import 'package:flutter/foundation.dart';
import '../../domain/entities/expense.dart';
import '../../../../../../core/security/encryption_service.dart';
import '../../../../../../injection_container.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.amount,
    required super.date,
    required super.categoryId,
    super.note,
    super.isSyncedToFirebase,
    super.lastSyncedAt,
  });

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      amount: expense.amount,
      date: expense.date,
      categoryId: expense.categoryId,
      note: expense.note,
      isSyncedToFirebase: expense.isSyncedToFirebase,
      lastSyncedAt: expense.lastSyncedAt,
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final encryptionService = getIt<EncryptionService>();
    double amount;

    // Decrypt if available, otherwise use plain text (migration/legacy)
    if (json['encryptedAmount'] != null && encryptionService.isReady) {
      try {
        amount = encryptionService.decryptValue(
          json['encryptedAmount'] as String,
        );
      } catch (e) {
        debugPrint(
          'ExpenseModel.fromJson: Decryption failed for ${json['id']}: $e',
        );
        // Fall back to plain amount if available, otherwise 0.0
        amount = (json['amount'] as num?)?.toDouble() ?? 0.0;
      }
    } else if (json['amount'] != null) {
      amount = (json['amount'] as num).toDouble();
    } else if (json['encryptedAmount'] != null && !encryptionService.isReady) {
      debugPrint(
        'ExpenseModel.fromJson: Encryption not ready, cannot decrypt '
        'expense ${json['id']}. Setting amount to 0.0.',
      );
      amount = 0.0;
    } else {
      amount = 0.0;
    }

    return ExpenseModel(
      id: json['id'] as String,
      amount: amount,
      date: DateTime.parse(json['date'] as String),
      categoryId: json['categoryId'] as String,
      note: json['note'] as String? ?? '',
      isSyncedToFirebase: json['isSyncedToFirebase'] as bool? ?? false,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final encryptionService = getIt<EncryptionService>();
    final json = <String, dynamic>{
      'id': id,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'note': note,
      'isSyncedToFirebase': isSyncedToFirebase,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };

    // Encrypt amount if encryption is ready; otherwise store plain amount.
    if (encryptionService.isReady) {
      try {
        json['encryptedAmount'] = encryptionService.encryptValue(amount);
      } catch (e) {
        debugPrint(
          'ExpenseModel.toJson: Encryption failed for $id, '
          'storing plain amount. Error: $e',
        );
        json['amount'] = amount;
      }
    } else {
      debugPrint(
        'ExpenseModel.toJson: Encryption not ready for $id, '
        'storing plain amount.',
      );
      json['amount'] = amount;
    }

    return json;
  }
}
