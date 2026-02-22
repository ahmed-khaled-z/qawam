import '../../injection_container.dart';
import 'data/data_sources/remote/login_remote_data_source.dart';
import 'data/repositories/login_repository_impl.dart';
import 'domain/repositories/login_repository.dart';
import 'domain/use_cases/login_use_case.dart';
import 'presentation/cubit/login_cubit.dart';

/// Call this function in ServiceLocator.setup() function
void injectLogin() {
  // cubit
  getIt.registerFactory(
    () => LoginCubit(
      loginUseCase: getIt(),
      encryptionService: getIt(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<LoginRepository>(
    () => LoginRepositoryImpl(remoteDataSource: getIt()),
  );

  // UseCases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));

  // DataSources
  getIt.registerLazySingleton<LoginRemoteDataSource>(
    () => LoginRemoteDataSourceImpl(),
  );
}
