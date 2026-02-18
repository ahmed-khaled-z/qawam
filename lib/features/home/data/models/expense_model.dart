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
    if (json['encryptedAmount'] != null) {
      try {
        amount = encryptionService.decryptValue(
          json['encryptedAmount'] as String,
        );
      } catch (e) {
        // Fallback or rethrow?
        // If decryption fails, data is unreadable.
        amount = 0.0;
      }
    } else {
      amount = (json['amount'] as num).toDouble();
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
    return {
      'id': id,
      'encryptedAmount': encryptionService.encryptValue(amount),
      // 'amount': amount, // Removed for security
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'note': note,
      'isSyncedToFirebase': isSyncedToFirebase,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }
}
