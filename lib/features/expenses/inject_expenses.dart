import '../../injection_container.dart';
import 'presentation/cubit/expenses_cubit.dart';

/// Call this function in ServiceLocator.setup() function
void injectExpenses() {
  // Cubit
  getIt.registerFactory(
    () => ExpensesCubit(
      getExpensesUseCase: getIt(),
      addExpenseUseCase: getIt(),
      deleteExpenseUseCase: getIt(),
      fetchSettingsUseCase: getIt(),
    ),
  );

  // Note: All use cases and repositories are already registered in inject_home.dart and inject_settings.dart
  // We're only registering the Cubit here since it depends on existing use cases
}
