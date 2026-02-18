import 'package:dartz/dartz.dart';

import '../entities/settings.dart';
import '../repositories/settings_repository.dart';

/// Use case for fetching user settings
///
/// Single Responsibility: only handles settings retrieval.
class FetchSettingsUseCase {
  final SettingsRepository _repository;

  const FetchSettingsUseCase(this._repository);

  Future<Either<Exception, Settings>> call() async {
    return await _repository.fetchSettings();
  }
}
