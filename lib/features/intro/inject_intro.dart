import '../../injection_container.dart';
import 'data/data_sources/remote/intro_remote_data_source.dart';
import 'data/repositories/intro_repository_impl.dart';
import 'domain/repositories/intro_repository.dart';
import 'domain/use_cases/intro_use_case.dart';
import 'presentation/cubit/intro_cubit.dart';

//call this function in ServiceLocator.setup() function
injectIntro() {
  // cubit
  getIt.registerFactory(() => IntroCubit(introUseCase: getIt()));

  // Repository
  getIt.registerLazySingleton<IntroRepository>(
          () => IntroRepositoryImpl(remoteDataSource: getIt()));

  // UseCases
  getIt.registerLazySingleton(() => IntroUseCase(getIt()));

  // DataSources
  getIt.registerLazySingleton<IntroRemoteDataSource>(
          () => IntroRemoteDataSourceImpl());
}
      