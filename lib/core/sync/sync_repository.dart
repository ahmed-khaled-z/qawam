import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

import '../security/encryption_service.dart';
import '../../features/home/data/models/expense_model.dart';
import '../../features/categories/data/models/category_model.dart';
import '../../features/settings/data/data_sources/local/settings_local_data_source.dart';
import 'models/sync_item.dart';

abstract class SyncRepository {
  Future<void> addPendingDeletion(String id, String collection);
  Future<void> syncExpenses();
  Future<void> syncCategories();
  Future<void> processPendingDeletions();
  Future<bool> hasUnsyncedData();
  Future<void> clearAllLocalData();
  Future<void> fetchRemoteData();
}

class SyncRepositoryImpl implements SyncRepository {
  final FirebaseFirestore _firestore;
  final SettingsLocalDataSource _settingsLocalDataSource;
  final EncryptionService _encryptionService;
  static const String EXPENSES_BOX = 'expenses';
  static const String CATEGORIES_BOX = 'categories';
  static const String PENDING_DELETIONS_BOX = 'pending_deletions';

  SyncRepositoryImpl(
    this._firestore,
    this._settingsLocalDataSource,
    this._encryptionService,
  );

  Box<ExpenseModel> get _expensesBox => Hive.box<ExpenseModel>(EXPENSES_BOX);
  Box<CategoryModel> get _categoriesBox =>
      Hive.box<CategoryModel>(CATEGORIES_BOX);
  Box<SyncItem> get _pendingBox => Hive.box<SyncItem>(PENDING_DELETIONS_BOX);

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<bool> _isSyncEnabled() async {
    final settings = await _settingsLocalDataSource.getCachedSettings();
    return settings?.dataSyncEnabled ?? true;
  }

  @override
  Future<void> addPendingDeletion(String id, String collection) async {
    final item = SyncItem(
      id: id,
      collection: collection,
      operation: 'delete',
      timestamp: DateTime.now(),
    );
    await _pendingBox.put('${collection}_$id', item);
  }

  @override
  Future<bool> hasUnsyncedData() async {
    if (_pendingBox.isNotEmpty) return true;

    // Check expenses
    if (_expensesBox.values.any((e) => !e.isSyncedToFirebase)) return true;

    // Check categories
    if (_categoriesBox.values.any((c) => !c.isSyncedToFirebase)) return true;

    return false;
  }

  @override
  Future<void> clearAllLocalData() async {
    await _expensesBox.clear();
    await _categoriesBox.clear();
    await _pendingBox.clear();
  }

  @override
  Future<void> processPendingDeletions() async {
    if (!await _isSyncEnabled()) {
      debugPrint(
        "SyncRepository: Skipping processPendingDeletions - data sync disabled.",
      );
      return;
    }

    final userId = _userId;
    if (userId == null) return;

    final pending = _pendingBox.values.toList();
    if (pending.isEmpty) return;

    // chunk by 500
    for (var i = 0; i < pending.length; i += 500) {
      final chunk = pending.skip(i).take(500).toList();
      final batch = _firestore.batch();

      for (var item in chunk) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection(item.collection)
            .doc(item.id);
        batch.delete(docRef);
      }

      try {
        await batch.commit();
        // Remove from pending box
        final keysToDelete = chunk
            .map((e) => '${e.collection}_${e.id}')
            .toList();
        await _pendingBox.deleteAll(keysToDelete);
      } catch (e) {
        debugPrint("Error processing deletion batch: $e");
        // Keep in box to retry later
      }
    }
  }

  @override
  Future<void> syncExpenses() async {
    if (!await _isSyncEnabled()) {
      debugPrint("SyncRepository: Skipping syncExpenses - data sync disabled.");
      return;
    }
    if (!_encryptionService.isReady) {
      debugPrint(
        "SyncRepository: Skipping syncExpenses - encryption not ready.",
      );
      return;
    }

    final userId = _userId;
    if (userId == null) return;

    final unsynced = _expensesBox.values
        .where((e) => !e.isSyncedToFirebase)
        .toList();
    if (unsynced.isEmpty) return;

    for (var i = 0; i < unsynced.length; i += 500) {
      final chunk = unsynced.skip(i).take(500).toList();
      final batch = _firestore.batch();

      for (var expense in chunk) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('expenses')
            .doc(expense.id);

        final data = expense.toJson();
        data['updatedAt'] = FieldValue.serverTimestamp();
        // Ensure isSyncedToFirebase is set to true in the cloud?
        // Or false? Doesn't matter for cloud, but clean to set true.
        data['isSyncedToFirebase'] = true;
        data['lastSyncedAt'] = DateTime.now().toIso8601String();

        batch.set(docRef, data, SetOptions(merge: true));
      }

      try {
        await batch.commit();

        // Update local
        final now = DateTime.now();
        for (var expense in chunk) {
          final newExpense = ExpenseModel(
            id: expense.id,
            amount: expense.amount,
            date: expense.date,
            categoryId: expense.categoryId,
            note: expense.note,
            isSyncedToFirebase: true,
            lastSyncedAt: now,
          );
          await _expensesBox.put(expense.id, newExpense);
        }
      } catch (e) {
        debugPrint("Error syncing expenses chunk: $e");
      }
    }
  }

  @override
  Future<void> syncCategories() async {
    if (!await _isSyncEnabled()) {
      debugPrint(
        "SyncRepository: Skipping syncCategories - data sync disabled.",
      );
      return;
    }

    final userId = _userId;
    if (userId == null) return;

    final unsynced = _categoriesBox.values
        .where((c) => !c.isSyncedToFirebase)
        .toList();
    if (unsynced.isEmpty) return;

    for (var i = 0; i < unsynced.length; i += 500) {
      final chunk = unsynced.skip(i).take(500).toList();
      final batch = _firestore.batch();

      for (var category in chunk) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('categories')
            .doc(category.id);

        final data = category.toJson();
        data['updatedAt'] = FieldValue.serverTimestamp();
        data['isSyncedToFirebase'] = true;
        data['lastSyncedAt'] = DateTime.now().toIso8601String();

        batch.set(docRef, data, SetOptions(merge: true));
      }

      try {
        await batch.commit();

        final now = DateTime.now();
        for (var category in chunk) {
          final newCategory = CategoryModel(
            id: category.id,
            name: category.name,
            iconCode: category.iconCode,
            color: category.color,
            isSyncedToFirebase: true,
            lastSyncedAt: now,
          );
          await _categoriesBox.put(category.id, newCategory);
        }
      } catch (e) {
        debugPrint("Error syncing categories chunk: $e");
      }
    }
  }

  @override
  Future<void> fetchRemoteData() async {
    if (!await _isSyncEnabled()) {
      debugPrint(
        "SyncRepository: Skipping fetchRemoteData - data sync disabled.",
      );
      return;
    }
    if (!_encryptionService.isReady) {
      debugPrint(
        "SyncRepository: Skipping fetchRemoteData - encryption not ready.",
      );
      return;
    }

    final userId = _userId;
    if (userId == null) return;

    try {
      // 1. Fetch Categories
      final catQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();

      final remoteCategories = catQuery.docs
          .map((doc) => CategoryModel.fromJson(doc.data()))
          .toList();

      for (var remoteCat in remoteCategories) {
        final localCat = _categoriesBox.get(remoteCat.id);
        // Protect local unsynced changes
        if (localCat != null && !localCat.isSyncedToFirebase) {
          continue;
        }
        await _categoriesBox.put(remoteCat.id, remoteCat);
      }

      // 2. Fetch Expenses
      final expQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .get();

      final remoteExpenses = expQuery.docs
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .toList();

      for (var remoteExp in remoteExpenses) {
        final localExp = _expensesBox.get(remoteExp.id);
        // Protect local unsynced changes
        if (localExp != null && !localExp.isSyncedToFirebase) {
          continue;
        }
        await _expensesBox.put(remoteExp.id, remoteExp);
      }

      // 3. Handle Deletions? (Optional but recommended: Remove synched local items not in remote list)
      // This is expensive (comparing lists). For MVP, we skip or do full replacement?
      // Full replacement logic:
      // Clear Synced items from Box. Put Remote items.
      // Keep Unsynced items.
      // This is cleaner than item-by-item check.

      // But clearing box loses unsynced?
      // No, we can filter them out first.

      // Let's implement robust sync strategy:
      // A. Identify obsolete local items (Synced locally, missing remotely).
      // B. Delete them.

      final remoteCatIds = remoteCategories.map((e) => e.id).toSet();
      final localSyncedCatsToDelete = _categoriesBox.values
          .where((c) => c.isSyncedToFirebase && !remoteCatIds.contains(c.id))
          .map((c) => c.id)
          .toList();
      await _categoriesBox.deleteAll(localSyncedCatsToDelete);

      final remoteExpIds = remoteExpenses.map((e) => e.id).toSet();
      final localSyncedExpsToDelete = _expensesBox.values
          .where((e) => e.isSyncedToFirebase && !remoteExpIds.contains(e.id))
          .map((e) => e.id)
          .toList();
      await _expensesBox.deleteAll(localSyncedExpsToDelete);
    } catch (e) {
      debugPrint("Error fetching remote data: $e");
      // Rethrow? No, fail silently (offline or partial).
    }
  }
}
