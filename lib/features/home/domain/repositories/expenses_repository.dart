import 'package:dartz/dartz.dart';
import '../entities/expense.dart';

abstract class ExpensesRepository {
  Future<Either<Exception, void>> addExpense(Expense expense);
  Future<Either<Exception, void>> deleteExpense(String id);
  Future<Either<Exception, List<Expense>>> getExpenses();
}
