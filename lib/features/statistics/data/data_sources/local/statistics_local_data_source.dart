import 'package:dartz/dartz.dart';


abstract class StatisticsLocalDataSource {
  Future<Unit> getFromLocalDataBase();
}

class StatisticsLocalDataSourceImpl implements StatisticsLocalDataSource {
  StatisticsLocalDataSourceImpl();

  @override
  Future<Unit> getFromLocalDataBase() async {
    // send api request here
    return Future.value(unit);
  }

}
  