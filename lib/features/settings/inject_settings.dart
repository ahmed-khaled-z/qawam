import 'package:get_it/get_it.dart';

import 'data/data_sources/local/settings_local_data_source.dart';
import 'data/data_sources/remote/settings_remote_data_source.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/use_cases/fetch_settings_use_case.dart';
import 'domain/use_cases/save_settings_use_case.dart';
import 'domain/use_cases/fetch_currencies_use_case.dart';
import 'presentation/cubit/settings_cubit.dart';

void injectSettings() {
  final getIt = GetIt.instance;

  // ==================== PRESENTATION LAYER ====================
  // Cubit (Factory)
  getIt.registerFactory(
    () => SettingsCubit(
      fetchSettingsUseCase: getIt(),
      saveSettingsUseCase: getIt(),
      fetchCurrenciesUseCase: getIt(),
    ),
  );

  // ==================== DOMAIN LAYER ====================
  // Use Cases (LazySingleton)
  getIt.registerLazySingleton(() => FetchSettingsUseCase(getIt()));
  getIt.registerLazySingleton(() => SaveSettingsUseCase(getIt()));
  getIt.registerLazySingleton(() => FetchCurrenciesUseCase(getIt()));

  // Repository Interface (LazySingleton)
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // ==================== DATA LAYER ====================
  // Data Sources (LazySingleton)
  getIt.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(),
  );
}
