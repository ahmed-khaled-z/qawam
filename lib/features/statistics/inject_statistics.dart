import '../../injection_container.dart';
import 'domain/use_cases/get_statistics_use_case.dart';
import 'presentation/cubit/statistics_cubit.dart';

void injectStatistics() {
  // Use Cases
  getIt.registerLazySingleton(() => GetStatisticsUseCase(getIt(), getIt()));

  // Cubit
  getIt.registerFactory(
    () => StatisticsCubit(
      getStatisticsUseCase: getIt(),
      fetchSettingsUseCase: getIt(),
    ),
  );
}
