import 'package:dartz/dartz.dart';


abstract class StatisticsRepository {
  Future<Either<Exception, Unit>> callApi();
}

