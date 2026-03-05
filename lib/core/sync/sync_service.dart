import 'package:flutter/foundation.dart';

import 'package:qawam/core/security/encryption_service.dart';
import 'sync_repository.dart';

class SyncService {
  final SyncRepository _repository;
  final EncryptionService _encryptionService;

  SyncService(this._repository, this._encryptionService);

  /// Triggers a full synchronization cycle:
  /// 1. Process pending deletions
  /// 2. Sync Categories (Push)
  /// 3. Sync Expenses (Push)
  /// 4. Fetch Remote Data (Pull)
  /// Skips expense sync and fetch when encryption is not ready (e.g. new device pending approval).
  Future<void> syncData() async {
    debugPrint("SyncService: Starting sync...");
    try {
      await _repository.processPendingDeletions();
      await _repository.syncCategories();
      if (!_encryptionService.isReady) {
        debugPrint(
          "SyncService: Skipping expenses sync and pull - encryption not ready.",
        );
        return;
      }
      await _repository.syncExpenses();
      await _repository.fetchRemoteData();
      debugPrint("SyncService: Sync completed successfully.");
    } catch (e) {
      debugPrint("SyncService: Error during sync: $e");
    }
  }

  /// Explicitly pulls data from Firebase to local storage.
  /// Useful after login or manual refresh. No-op if encryption not ready.
  Future<void> pullData() async {
    if (!_encryptionService.isReady) {
      debugPrint("SyncService: Skipping pullData - encryption not ready.");
      return;
    }
    try {
      await _repository.fetchRemoteData();
    } catch (e) {
      debugPrint("SyncService: Error pulling data: $e");
    }
  }

  /// Checks if there is any unsynced data (created/updated/deleted)
  Future<bool> hasUnsyncedData() async {
    return _repository.hasUnsyncedData();
  }

  /// Clears all local data (Expenses, Categories, Pending Deletions)
  /// Used when logging out to prevent data mixing or if user wants to clear.
  Future<void> clearLocalData() async {
    await _repository.clearAllLocalData();
  }
}
