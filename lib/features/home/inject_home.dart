import '../../injection_container.dart';
import 'data/data_sources/local/expenses_local_data_source.dart';
import 'data/data_sources/local/expenses_local_data_source_impl.dart';
import 'data/repositories/expenses_repository_impl.dart';
import 'domain/repositories/expenses_repository.dart';
import 'domain/use_cases/add_expense_use_case.dart';
import 'domain/use_cases/delete_expense_use_case.dart';
import 'domain/use_cases/get_dashboard_metrics_use_case.dart';
import 'domain/use_cases/get_expenses_use_case.dart';
import 'presentation/cubit/home_cubit.dart';

void injectHome() {
  // DataSources
  getIt.registerLazySingleton<ExpensesLocalDataSource>(
    () => ExpensesLocalDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<ExpensesRepository>(
    () => ExpensesRepositoryImpl(
      localDataSource: getIt(),
      syncRepository: getIt(),
    ),
  );

  // UseCases
  getIt.registerLazySingleton(() => AddExpenseUseCase(getIt()));
  getIt.registerLazySingleton(() => GetExpensesUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteExpenseUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDashboardMetricsUseCase(getIt()));

  // Cubit
  getIt.registerFactory(
    () => HomeCubit(
      addExpenseUseCase: getIt(),
      getExpensesUseCase: getIt(),
      getDashboardMetricsUseCase: getIt(),
    ),
  );
}
