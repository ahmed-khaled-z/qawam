import '../../injection_container.dart';
import 'data/repositories/intro_repository_impl.dart';
import 'domain/repositories/intro_repository.dart';
import 'presentation/cubit/intro_cubit.dart';

void injectIntro() {
  getIt.registerLazySingleton<IntroRepository>(() => IntroRepositoryImpl());

  getIt.registerFactory(() => IntroCubit(repository: getIt()));
}
