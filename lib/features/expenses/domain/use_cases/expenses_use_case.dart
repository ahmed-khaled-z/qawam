import 'package:dartz/dartz.dart';
import '../repositories/expenses_repository.dart';


class ExpensesUseCase {
  final ExpensesRepository repository;

  ExpensesUseCase(this.repository);

  Future<Either<Exception, Unit>> call() async {
    return await repository.callApi();
  }
}

