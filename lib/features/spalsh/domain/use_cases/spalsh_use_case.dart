import 'package:dartz/dartz.dart';
import '../repositories/spalsh_repository.dart';


class SpalshUseCase {
  final SpalshRepository repository;

  SpalshUseCase(this.repository);

  Future<Either<Exception, Unit>> call() async {
    return await repository.callApi();
  }
}

