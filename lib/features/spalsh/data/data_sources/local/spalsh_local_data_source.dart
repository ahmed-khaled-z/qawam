import 'package:dartz/dartz.dart';


abstract class SpalshLocalDataSource {
  Future<Unit> getFromLocalDataBase();
}

class SpalshLocalDataSourceImpl implements SpalshLocalDataSource {
  SpalshLocalDataSourceImpl();

  @override
  Future<Unit> getFromLocalDataBase() async {
    // send api request here
    return Future.value(unit);
  }

}
  