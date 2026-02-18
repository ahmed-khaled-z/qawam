import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/currency.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../data_sources/local/settings_local_data_source.dart';
import '../data_sources/remote/settings_remote_data_source.dart';
import '../models/settings_model.dart';

/// Repository implementation that coordinates remote and local data sources
///
/// Strategy:
/// 1. Always try remote (Firestore) first
/// 2. Cache result locally on success
/// 3. Fall back to local cache on remote failure
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _remoteDataSource;
  final SettingsLocalDataSource _localDataSource;

  const SettingsRepositoryImpl({
    required SettingsRemoteDataSource remoteDataSource,
    required SettingsLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<Either<Exception, Settings>> fetchSettings() async {
    try {
      // Try remote first
      final model = await _remoteDataSource.fetchSettings();

      // Cache for offline access
      await _localDataSource.cacheSettings(model);

      return Right(model);
    } catch (e) {
      debugPrint('[Settings] Remote fetch failed, trying cache: $e');

      // Fall back to local cache
      try {
        final cached = await _localDataSource.getCachedSettings();
        if (cached != null) {
          return Right(cached);
        }
      } catch (_) {}

      // No remote, no cache — return defaults
      return const Right(Settings());
    }
  }

  @override
  Future<Either<Exception, Settings>> saveSettings(Settings settings) async {
    try {
      final model = SettingsModel.fromEntity(settings);

      // Save remotely
      final saved = await _remoteDataSource.saveSettings(model);

      // Update local cache
      await _localDataSource.cacheSettings(saved);

      return Right(saved);
    } catch (e) {
      debugPrint('[Settings] Save failed: $e');
      return Left(Exception('Failed to save settings: $e'));
    }
  }

  @override
  Future<Either<Exception, List<Currency>>> fetchCurrencies() async {
    try {
      // Try remote first
      final models = await _remoteDataSource.fetchCurrencies();

      // Cache
      await _localDataSource.cacheCurrencies(models);

      return Right(models);
    } catch (e) {
      debugPrint('[Settings] Remote currencies fetch failed: $e');

      // Try cache
      final cached = await _localDataSource.getCachedCurrencies();
      if (cached != null) {
        return Right(cached);
      }

      return Left(Exception('Failed to fetch currencies'));
    }
  }
}
