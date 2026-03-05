import 'package:dartz/dartz.dart';

abstract class MoreRemoteDataSource {
  Future<Unit> callApi();
}

class MoreRemoteDataSourceImpl implements MoreRemoteDataSource {
  MoreRemoteDataSourceImpl();

  @override
  Future<Unit> callApi() async {
    // send api request here
    return Future.value(unit);
  }
}
