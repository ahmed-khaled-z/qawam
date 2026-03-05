import 'package:dartz/dartz.dart';
import '../../domain/repositories/more_repository.dart';
import '../data_sources/remote/more_remote_data_source.dart';

class MoreRepositoryImpl implements MoreRepository {
  final MoreRemoteDataSource remoteDataSource;

  MoreRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, Unit>> callApi() async {
    try {
      return Right(await remoteDataSource.callApi());
    } on Exception catch (exception) {
      return Left(exception);
    }
  }
}
