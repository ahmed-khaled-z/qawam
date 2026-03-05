import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String note;
  final bool isSyncedToFirebase;
  final DateTime? lastSyncedAt;

  const Expense({
    required this.id,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.note = '',
    this.isSyncedToFirebase = false,
    this.lastSyncedAt,
  });

  @override
  List<Object?> get props => [
    id,
    amount,
    date,
    categoryId,
    note,
    isSyncedToFirebase,
    lastSyncedAt,
  ];
}
