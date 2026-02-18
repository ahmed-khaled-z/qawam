import 'package:dartz/dartz.dart';


abstract class SpalshRepository {
  Future<Either<Exception, Unit>> callApi();
}

