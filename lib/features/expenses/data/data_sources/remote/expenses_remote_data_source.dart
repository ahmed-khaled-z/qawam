import 'package:dartz/dartz.dart';


abstract class ExpensesRemoteDataSource {
  Future<Unit> callApi();
}

class ExpensesRemoteDataSourceImpl implements ExpensesRemoteDataSource {
  ExpensesRemoteDataSourceImpl();

  @override
  Future<Unit> callApi() async {
    // send api request here
    return Future.value(unit);
  }

}


  