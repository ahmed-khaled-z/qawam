import 'package:dartz/dartz.dart';


abstract class SpalshRemoteDataSource {
  Future<Unit> callApi();
}

class SpalshRemoteDataSourceImpl implements SpalshRemoteDataSource {
  SpalshRemoteDataSourceImpl();

  @override
  Future<Unit> callApi() async {
    // send api request here
    return Future.value(unit);
  }

}


  