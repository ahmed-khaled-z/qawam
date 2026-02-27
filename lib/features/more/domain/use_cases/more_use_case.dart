import 'package:dartz/dartz.dart';
import '../repositories/more_repository.dart';

class MoreUseCase {
  final MoreRepository repository;

  MoreUseCase(this.repository);

  Future<Either<Exception, Unit>> call() async {
    return await repository.callApi();
  }
}
