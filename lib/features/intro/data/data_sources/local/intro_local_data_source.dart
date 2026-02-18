import 'package:dartz/dartz.dart';


abstract class IntroLocalDataSource {
  Future<Unit> getFromLocalDataBase();
}

class IntroLocalDataSourceImpl implements IntroLocalDataSource {
  IntroLocalDataSourceImpl();

  @override
  Future<Unit> getFromLocalDataBase() async {
    // send api request here
    return Future.value(unit);
  }

}
  