import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense.dart';
import '../../domain/use_cases/add_expense_use_case.dart';
import '../../domain/use_cases/get_dashboard_metrics_use_case.dart';
import '../../domain/use_cases/get_expenses_use_case.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AddExpenseUseCase addExpenseUseCase;
  final GetExpensesUseCase getExpensesUseCase;
  final GetDashboardMetricsUseCase getDashboardMetricsUseCase;

  HomeCubit({
    required this.addExpenseUseCase,
    required this.getExpensesUseCase,
    required this.getDashboardMetricsUseCase,
  }) : super(const HomeState());

  Future<void> loadHomeData() async {
    emit(state.copyWith(status: HomeStatus.loading));

    // Fetch Metrics
    final metricsResult = await getDashboardMetricsUseCase();

    // Fetch Recent (Metrics use case currently fetches all, but we might want separate call or optimized)
    // For now, let's just reuse getExpensesUseCase to get list and take last 5.
    final expensesResult = await getExpensesUseCase();

    expensesResult.fold(
      (error) => emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: error.toString(),
        ),
      ),
      (expenses) {
        // Sort by date desc
        expenses.sort((a, b) => b.date.compareTo(a.date));
        final recent = expenses.take(5).toList();

        metricsResult.fold(
          (metricsError) => emit(
            state.copyWith(
              status: HomeStatus.error,
              errorMessage: metricsError.toString(),
            ),
          ),
          (metrics) {
            emit(
              state.copyWith(
                status: HomeStatus.loaded,
                recentExpenses: recent,
                todayTotal: metrics['today'],
                monthTotal: metrics['month'],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> addExpense(Expense expense) async {
    emit(state.copyWith(status: HomeStatus.adding));
    final result = await addExpenseUseCase(expense);
    result.fold(
      (error) => emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: error.toString(),
        ),
      ),
      (_) {
        // Reload data
        loadHomeData();
      },
    );
  }
}
