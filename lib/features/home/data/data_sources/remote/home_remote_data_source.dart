import 'package:dartz/dartz.dart';


abstract class HomeRemoteDataSource {
  Future<Unit> callApi();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl();

  @override
  Future<Unit> callApi() async {
    // send api request here
    return Future.value(unit);
  }

}


  