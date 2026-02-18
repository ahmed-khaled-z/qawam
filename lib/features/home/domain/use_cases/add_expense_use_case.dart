import 'package:dartz/dartz.dart';
import '../entities/expense.dart';
import '../repositories/expenses_repository.dart';

class AddExpenseUseCase {
  final ExpensesRepository repository;

  AddExpenseUseCase(this.repository);

  Future<Either<Exception, void>> call(Expense expense) async {
    return repository.addExpense(expense);
  }
}
