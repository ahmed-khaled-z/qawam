import 'package:dartz/dartz.dart';
import '../repositories/intro_repository.dart';


class IntroUseCase {
  final IntroRepository repository;

  IntroUseCase(this.repository);

  Future<Either<Exception, Unit>> call() async {
    return await repository.callApi();
  }
}

