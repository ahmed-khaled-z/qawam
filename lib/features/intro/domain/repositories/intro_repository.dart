import 'package:dartz/dartz.dart';


abstract class IntroRepository {
  Future<Either<Exception, Unit>> callApi();
}

