import 'package:dartz/dartz.dart';

import '../../domain/entities/login.dart';
import '../../domain/repositories/login_repository.dart';
import '../data_sources/remote/login_remote_data_source.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;

  LoginRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, UserEntity>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      return Right(user);
    } on Exception catch (exception) {
      return Left(exception);
    }
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }
}
