import 'package:dartz/dartz.dart';

abstract class MoreRepository {
  Future<Either<Exception, Unit>> callApi();
}
