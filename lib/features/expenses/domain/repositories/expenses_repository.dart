import 'package:dartz/dartz.dart';

abstract class ExpensesRepository {
  Future<Either<Exception, Unit>> callApi();
}
