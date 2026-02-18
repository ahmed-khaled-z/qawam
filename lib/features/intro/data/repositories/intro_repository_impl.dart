import 'package:dartz/dartz.dart';
import '../../domain/repositories/intro_repository.dart';
import '../data_sources/remote/intro_remote_data_source.dart';


class IntroRepositoryImpl implements IntroRepository {
  final IntroRemoteDataSource remoteDataSource;

  IntroRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, Unit>> callApi() async {
    try {
      return Right(await remoteDataSource.callApi());
    } on Exception catch (exception) {
      return Left(exception);
    }
  }

}

