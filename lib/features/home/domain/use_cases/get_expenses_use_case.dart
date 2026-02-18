import 'package:dartz/dartz.dart';
import '../entities/expense.dart';
import '../repositories/expenses_repository.dart';

class GetExpensesUseCase {
  final ExpensesRepository repository;

  GetExpensesUseCase(this.repository);

  Future<Either<Exception, List<Expense>>> call() async {
    return repository.getExpenses();
  }
}
