import 'package:dartz/dartz.dart';

import '../entities/currency.dart';
import '../repositories/settings_repository.dart';

class FetchCurrenciesUseCase {
  final SettingsRepository _repository;

  FetchCurrenciesUseCase(this._repository);

  Future<Either<Exception, List<Currency>>> call() async {
    return await _repository.fetchCurrencies();
  }
}
