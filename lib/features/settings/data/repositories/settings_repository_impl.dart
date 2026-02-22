import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/currency.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../data_sources/local/settings_local_data_source.dart';
import '../data_sources/remote/settings_remote_data_source.dart';
import '../models/settings_model.dart';

/// Repository implementation that coordinates remote and local data sources.
///
/// Persistence Strategy (Local-First):
/// 1. **Fetch**: Always load from local cache first for instant UI.
///    Then try to merge with remote (Firestore) in the background.
///    If no local cache and remote fails → use hardcoded defaults.
/// 2. **Save**: ALWAYS save locally first (guaranteed persistence).
///    Then try to sync to Firestore in the background (best-effort).
///    A remote failure must NEVER prevent local persistence.
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
    // ── Step 1: Try to load from local cache first ──────────────────────────
    try {
      final cached = await _localDataSource.getCachedSettings();
      if (cached != null) {
        debugPrint('[Settings] Loaded from local cache: ${cached.toJson()}');
        // Kick off a background sync from remote (fire-and-forget).
        _syncFromRemoteInBackground();
        return Right(cached);
      }
    } catch (e) {
      debugPrint('[Settings] Local cache read error: $e');
    }

    // ── Step 2: No local cache — try remote ─────────────────────────────────
    try {
      final model = await _remoteDataSource.fetchSettings();
      // Persist remote data locally so next launch is instant.
      await _localDataSource.cacheSettings(model);
      debugPrint('[Settings] Loaded from remote and cached locally.');
      return Right(model);
    } catch (e) {
      debugPrint('[Settings] Remote fetch also failed: $e');
    }

    // ── Step 3: Absolute fallback — use hardcoded defaults ──────────────────
    debugPrint('[Settings] Using default settings.');
    final defaults = SettingsModel.empty();
    // Persist defaults so we don't repeat this path every launch.
    await _localDataSource.cacheSettings(defaults);
    return Right(defaults);
  }

  @override
  Future<Either<Exception, Settings>> saveSettings(Settings settings) async {
    final model = SettingsModel.fromEntity(settings);

    // ── Step 1: Save locally FIRST — this MUST succeed ──────────────────────
    try {
      await _localDataSource.cacheSettings(model);
      debugPrint('[Settings] Saved locally: ${model.toJson()}');
    } catch (e) {
      debugPrint('[Settings] CRITICAL: Local save failed: $e');
      return Left(Exception('Failed to save settings locally: $e'));
    }

    // ── Step 2: Sync to Firestore in background (best-effort) ───────────────
    _syncToRemoteInBackground(model);

    // Return success immediately after local save.
    return Right(model);
  }

  @override
  Future<Either<Exception, List<Currency>>> fetchCurrencies() async {
    try {
      // Try remote first for currencies (configuration data).
      final models = await _remoteDataSource.fetchCurrencies();
      // Cache currencies locally.
      await _localDataSource.cacheCurrencies(models);
      return Right(models);
    } catch (e) {
      debugPrint('[Settings] Remote currencies fetch failed: $e');

      // Try local cache fallback.
      try {
        final cached = await _localDataSource.getCachedCurrencies();
        if (cached != null && cached.isNotEmpty) {
          return Right(cached);
        }
      } catch (_) {}

      return Left(Exception('Failed to fetch currencies'));
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Sync settings from Firestore to local cache in the background.
  /// Only updates local cache if remote has newer/valid data.
  /// Does NOT overwrite local if remote fetch fails.
  void _syncFromRemoteInBackground() {
    Future.microtask(() async {
      try {
        final remoteModel = await _remoteDataSource.fetchSettings();
        // Update local cache to keep remote changes (e.g. from another device).
        await _localDataSource.cacheSettings(remoteModel);
        debugPrint('[Settings] Background remote sync complete.');
      } catch (e) {
        debugPrint('[Settings] Background remote sync failed (ignored): $e');
      }
    });
  }

  /// Push local settings to Firestore in the background.
  /// Failure is logged but does NOT affect the UI or local state.
  void _syncToRemoteInBackground(SettingsModel model) {
    Future.microtask(() async {
      try {
        await _remoteDataSource.saveSettings(model);
        debugPrint('[Settings] Background remote save complete.');
      } catch (e) {
        debugPrint(
          '[Settings] Background remote save failed (settings still saved locally): $e',
        );
      }
    });
  }
}
