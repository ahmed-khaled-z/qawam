import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:qawam/features/bottom_nav/inject_bottom_nav.dart';
import 'package:qawam/features/categories/inject_categories.dart';
import 'package:qawam/features/home/inject_home.dart';
import 'package:qawam/features/expenses/inject_expenses.dart';
import 'package:qawam/features/login/inject_login.dart';
import 'package:qawam/features/settings/inject_settings.dart';
import 'package:qawam/features/profile/inject_profile.dart';
import 'package:qawam/features/spalsh/inject_spalsh.dart';
import 'package:qawam/features/statistics/inject_statistics.dart';
import 'package:qawam/features/feature_request/inject_feature_request.dart';
import 'package:qawam/features/intro/inject_intro.dart';

import 'core/network/api_provider.dart';
import 'core/security/encryption_service.dart';
import 'package:qawam/features/categories/data/adapters/category_adapter.dart';
import 'package:qawam/features/categories/data/models/category_model.dart';
import 'features/home/data/adapters/expense_adapter.dart';
import 'features/home/data/models/expense_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/sync/models/sync_item.dart';
import 'core/sync/sync_repository.dart';
import 'core/sync/sync_service.dart';

final GetIt getIt = GetIt.instance;

// how to use
// ignore: slash_for_doc_comments
/**
 * Future.wait([
    ServiceLocator().setup(),
    ]).then((value) {
    runApp(const App());
    });
 * **/
class ServiceLocator {
  Future<void> setup() async {
    // Hive Init
    await Hive.initFlutter();

    // Security (Must be before Adapters/Boxes)
    getIt.registerLazySingleton(() => EncryptionService());
    await getIt<EncryptionService>().init();

    Hive.registerAdapter(CategoryAdapter()); // Id: 0
    Hive.registerAdapter(ExpenseAdapter()); // Id: 1
    Hive.registerAdapter(SyncItemAdapter()); // Id: 2
    await Hive.openBox<CategoryModel>('categories');
    await Hive.openBox<ExpenseModel>('expenses');
    await Hive.openBox<SyncItem>('pending_deletions');

    // External
    getIt.registerLazySingleton(() => FirebaseFirestore.instance);

    getIt.registerFactory(() => Dio());
    getIt.registerFactory(() => ApiProvider(getIt()));

    injectSettings();

    // Sync
    getIt.registerLazySingleton<SyncRepository>(
      () => SyncRepositoryImpl(getIt(), getIt()),
    );
    getIt.registerLazySingleton(() => SyncService(getIt()));

    injectIntro();
    injectLogin();
    injectSpalsh();
    injectBottomNav();
    injectProfile();
    injectCategories();
    injectHome();
    injectExpenses();
    injectStatistics();
    injectFeatureRequest();
  }
}
