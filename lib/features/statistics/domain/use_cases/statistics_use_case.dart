import 'package:dartz/dartz.dart';
import '../repositories/statistics_repository.dart';

class StatisticsUseCase {
  final StatisticsRepository repository;

  StatisticsUseCase(this.repository);

  Future<Either<Exception, Unit>> call() async {
    return await repository.callApi();
  }
}
