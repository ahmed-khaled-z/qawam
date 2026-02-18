import 'package:dartz/dartz.dart';
import '../repositories/expenses_repository.dart';

class DeleteExpenseUseCase {
  final ExpensesRepository repository;

  DeleteExpenseUseCase(this.repository);

  Future<Either<Exception, void>> call(String id) async {
    return repository.deleteExpense(id);
  }
}
