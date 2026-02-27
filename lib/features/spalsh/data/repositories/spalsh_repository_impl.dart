import 'package:dartz/dartz.dart';
import '../../domain/repositories/spalsh_repository.dart';
import '../data_sources/remote/spalsh_remote_data_source.dart';

class SpalshRepositoryImpl implements SpalshRepository {
  final SpalshRemoteDataSource remoteDataSource;

  SpalshRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, Unit>> callApi() async {
    try {
      return Right(await remoteDataSource.callApi());
    } on Exception catch (exception) {
      return Left(exception);
    }
  }
}
