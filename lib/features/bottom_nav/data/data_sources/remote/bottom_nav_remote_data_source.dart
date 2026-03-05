import 'package:dartz/dartz.dart';

abstract class BottomNavRemoteDataSource {
  Future<Unit> callApi();
}

class BottomNavRemoteDataSourceImpl implements BottomNavRemoteDataSource {
  BottomNavRemoteDataSourceImpl();

  @override
  Future<Unit> callApi() async {
    // send api request here
    return Future.value(unit);
  }
}
