import 'package:dartz/dartz.dart';


abstract class CategoriesRemoteDataSource {
  Future<Unit> callApi();
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  CategoriesRemoteDataSourceImpl();

  @override
  Future<Unit> callApi() async {
    // send api request here
    return Future.value(unit);
  }

}


  