import 'package:dartz/dartz.dart';
import '../../domain/repositories/bottom_nav_repository.dart';
import '../data_sources/remote/bottom_nav_remote_data_source.dart';


class BottomNavRepositoryImpl implements BottomNavRepository {
  final BottomNavRemoteDataSource remoteDataSource;

  BottomNavRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Exception, Unit>> callApi() async {
    try {
      return Right(await remoteDataSource.callApi());
    } on Exception catch (exception) {
      return Left(exception);
    }
  }

}

