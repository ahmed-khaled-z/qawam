import 'package:get_it/get_it.dart';

import 'data/data_sources/profile_remote_data_source.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/use_cases/delete_account_use_case.dart';
import 'domain/use_cases/get_profile_use_case.dart';
import 'domain/use_cases/save_profile_use_case.dart';
import 'presentation/cubit/profile_cubit.dart';

void injectProfile() {
  final getIt = GetIt.instance;

  // Cubit
  getIt.registerFactory(
    () => ProfileCubit(
      getProfileUseCase: getIt(),
      saveProfileUseCase: getIt(),
      deleteAccountUseCase: getIt(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => SaveProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteAccountUseCase(getIt()));

  // Repository
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: getIt()),
  );

  // Data Source
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(),
  );
}
