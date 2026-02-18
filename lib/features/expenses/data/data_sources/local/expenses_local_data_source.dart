import 'package:dartz/dartz.dart';


abstract class ExpensesLocalDataSource {
  Future<Unit> getFromLocalDataBase();
}

class ExpensesLocalDataSourceImpl implements ExpensesLocalDataSource {
  ExpensesLocalDataSourceImpl();

  @override
  Future<Unit> getFromLocalDataBase() async {
    // send api request here
    return Future.value(unit);
  }

}
  