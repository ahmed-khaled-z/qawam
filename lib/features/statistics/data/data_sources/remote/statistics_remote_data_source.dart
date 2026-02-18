import 'package:dartz/dartz.dart';


abstract class StatisticsRemoteDataSource {
  Future<Unit> callApi();
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  StatisticsRemoteDataSourceImpl();

  @override
  Future<Unit> callApi() async {
    // send api request here
    return Future.value(unit);
  }

}


  