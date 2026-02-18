import 'package:dartz/dartz.dart';

import '../entities/currency.dart';
import '../entities/settings.dart';

/// Repository interface for Settings data operations
abstract class SettingsRepository {
  /// Fetch current user settings
  Future<Either<Exception, Settings>> fetchSettings();

  /// Save / update user settings
  Future<Either<Exception, Settings>> saveSettings(Settings settings);

  /// Fetch list of supported currencies
  Future<Either<Exception, List<Currency>>> fetchCurrencies();
}
