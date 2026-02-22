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
import 'package:qawam/features/settings/data/data_sources/local/settings_local_data_source.dart';

import 'core/network/api_provider.dart';
import 'core/security/crypto_repository.dart';
import 'core/security/crypto_repository_impl.dart';
import 'core/security/device_authorization_service.dart';
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

    // External (Firestore needed for CryptoRepository)
    getIt.registerLazySingleton(() => FirebaseFirestore.instance);

    // Crypto and encryption (before Adapters/Boxes)
    getIt.registerLazySingleton<CryptoRepository>(
      () => CryptoRepositoryImpl(getIt()),
    );
    getIt.registerLazySingleton(
      () => EncryptionService(cryptoRepository: getIt()),
    );
    await getIt<EncryptionService>().init();

    getIt.registerLazySingleton(
      () => DeviceAuthorizationService(
        getIt<CryptoRepository>(),
        getIt<EncryptionService>(),
      ),
    );

    Hive.registerAdapter(CategoryAdapter()); // Id: 0
    Hive.registerAdapter(ExpenseAdapter()); // Id: 1
    Hive.registerAdapter(SyncItemAdapter()); // Id: 2
    await Hive.openBox<CategoryModel>('categories');
    await Hive.openBox<ExpenseModel>('expenses');
    await Hive.openBox<SyncItem>('pending_deletions');

    getIt.registerFactory(() => Dio());
    getIt.registerFactory(() => ApiProvider(getIt()));

    injectSettings();

    // Sync
    getIt.registerLazySingleton<SyncRepository>(
      () => SyncRepositoryImpl(
        getIt<FirebaseFirestore>(),
        getIt<SettingsLocalDataSource>(),
        getIt<EncryptionService>(),
      ),
    );
    getIt.registerLazySingleton(
      () => SyncService(getIt<SyncRepository>(), getIt<EncryptionService>()),
    );

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
