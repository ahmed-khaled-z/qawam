import 'package:dartz/dartz.dart';

abstract class BottomNavLocalDataSource {
  Future<Unit> getFromLocalDataBase();
}

class BottomNavLocalDataSourceImpl implements BottomNavLocalDataSource {
  BottomNavLocalDataSourceImpl();

  @override
  Future<Unit> getFromLocalDataBase() async {
    // send api request here
    return Future.value(unit);
  }
}
