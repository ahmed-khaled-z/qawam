import 'package:dartz/dartz.dart';


abstract class IntroRemoteDataSource {
  Future<Unit> callApi();
}

class IntroRemoteDataSourceImpl implements IntroRemoteDataSource {
  IntroRemoteDataSourceImpl();

  @override
  Future<Unit> callApi() async {
    // send api request here
    return Future.value(unit);
  }

}


  