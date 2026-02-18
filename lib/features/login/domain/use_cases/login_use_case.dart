import 'package:dartz/dartz.dart';

import '../entities/login.dart';
import '../repositories/login_repository.dart';

class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Exception, UserEntity>> call() async {
    return await repository.signInWithGoogle();
  }
}
