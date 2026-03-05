import 'package:dartz/dartz.dart';

abstract class BottomNavRepository {
  Future<Either<Exception, Unit>> callApi();
}
