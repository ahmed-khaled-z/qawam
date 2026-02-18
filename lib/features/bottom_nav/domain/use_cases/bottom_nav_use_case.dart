import 'package:dartz/dartz.dart';
import '../repositories/bottom_nav_repository.dart';


class BottomNavUseCase {
  final BottomNavRepository repository;

  BottomNavUseCase(this.repository);

  Future<Either<Exception, Unit>> call() async {
    return await repository.callApi();
  }
}

