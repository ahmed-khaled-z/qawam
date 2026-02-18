import 'package:dartz/dartz.dart';

import '../entities/login.dart';

abstract class LoginRepository {
  Future<Either<Exception, UserEntity>> signInWithGoogle();
  Future<void> signOut();
}
