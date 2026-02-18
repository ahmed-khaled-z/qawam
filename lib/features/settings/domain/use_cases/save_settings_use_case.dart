import 'package:dartz/dartz.dart';

import '../entities/settings.dart';
import '../repositories/settings_repository.dart';

/// Use case for saving / updating user settings
///
/// Single Responsibility: only handles settings persistence.
class SaveSettingsUseCase {
  final SettingsRepository _repository;

  const SaveSettingsUseCase(this._repository);

  Future<Either<Exception, Settings>> call(Settings settings) async {
    return await _repository.saveSettings(settings);
  }
}
