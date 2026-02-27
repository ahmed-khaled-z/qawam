import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../data_sources/local/expenses_local_data_source.dart';
import '../models/expense_model.dart';
import '../../../../../../core/sync/sync_repository.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesLocalDataSource localDataSource;
  final SyncRepository syncRepository;

  ExpensesRepositoryImpl({
    required this.localDataSource,
    required this.syncRepository,
  });

  @override
  Future<Either<Exception, void>> addExpense(Expense expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      // Force unsynced status for new additions
      final unsyncedModel = ExpenseModel(
        id: model.id,
        amount: model.amount,
        date: model.date,
        categoryId: model.categoryId,
        note: model.note,
        isSyncedToFirebase: false,
        lastSyncedAt: model.lastSyncedAt,
      );
      await localDataSource.addExpense(unsyncedModel);
      debugPrint(
        'ExpensesRepository: Expense ${expense.id} saved locally '
        '(amount: ${expense.amount}).',
      );

      // Attempt immediate sync (fire-and-forget, don't block local save)
      try {
        syncRepository.syncExpenses();
      } catch (syncError) {
        debugPrint(
          'ExpensesRepository: Sync attempt failed for ${expense.id}, '
          'will retry later. Error: $syncError',
        );
      }

      return const Right(null);
    } catch (e, stackTrace) {
      debugPrint(
        'ExpensesRepository: FAILED to save expense ${expense.id}. '
        'Error: $e\nStack: $stackTrace',
      );
      return Left(Exception('Failed to save expense: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> deleteExpense(String id) async {
    try {
      await localDataSource.deleteExpense(id);
      await syncRepository.addPendingDeletion(id, 'expenses');
      debugPrint('ExpensesRepository: Expense $id deleted locally.');

      try {
        syncRepository.processPendingDeletions();
      } catch (syncError) {
        debugPrint(
          'ExpensesRepository: Pending deletion sync failed for $id: '
          '$syncError',
        );
      }

      return const Right(null);
    } catch (e) {
      debugPrint('ExpensesRepository: FAILED to delete expense $id: $e');
      return Left(Exception('Failed to delete expense: $e'));
    }
  }

  @override
  Future<Either<Exception, List<Expense>>> getExpenses() async {
    try {
      final expenses = await localDataSource.getAllExpenses();
      debugPrint(
        'ExpensesRepository: Loaded ${expenses.length} expenses from local.',
      );
      return Right(expenses);
    } catch (e) {
      debugPrint('ExpensesRepository: FAILED to load expenses: $e');
      return Left(Exception('Failed to load expenses: $e'));
    }
  }
}
