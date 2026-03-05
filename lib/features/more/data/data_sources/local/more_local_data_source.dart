import 'package:dartz/dartz.dart';

abstract class MoreLocalDataSource {
  Future<Unit> getFromLocalDataBase();
}

class MoreLocalDataSourceImpl implements MoreLocalDataSource {
  MoreLocalDataSourceImpl();

  @override
  Future<Unit> getFromLocalDataBase() async {
    // send api request here
    return Future.value(unit);
  }
}
