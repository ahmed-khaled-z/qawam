import 'package:dartz/dartz.dart';
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
      // Attempt immediate sync
      syncRepository.syncExpenses();
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> deleteExpense(String id) async {
    try {
      await localDataSource.deleteExpense(id);
      await syncRepository.addPendingDeletion(id, 'expenses');
      syncRepository.processPendingDeletions();
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<Expense>>> getExpenses() async {
    try {
      final expenses = await localDataSource.getAllExpenses();
      return Right(expenses);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
