import '../../injection_container.dart';
import 'data/data_sources/remote/more_remote_data_source.dart';
import 'data/repositories/more_repository_impl.dart';
import 'domain/repositories/more_repository.dart';
import 'domain/use_cases/more_use_case.dart';
import 'presentation/cubit/more_cubit.dart';

//call this function in ServiceLocator.setup() function
void injectMore() {
  // cubit
  getIt.registerFactory(() => MoreCubit(moreUseCase: getIt()));

  // Repository
  getIt.registerLazySingleton<MoreRepository>(
          () => MoreRepositoryImpl(remoteDataSource: getIt()));

  // UseCases
  getIt.registerLazySingleton(() => MoreUseCase(getIt()));

  // DataSources
  getIt.registerLazySingleton<MoreRemoteDataSource>(
          () => MoreRemoteDataSourceImpl());
}
      