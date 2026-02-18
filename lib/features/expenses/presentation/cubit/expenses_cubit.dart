import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/entities/expense.dart';
import '../../../home/domain/use_cases/add_expense_use_case.dart';
import '../../../home/domain/use_cases/delete_expense_use_case.dart';
import '../../../home/domain/use_cases/get_expenses_use_case.dart';
import '../../../settings/domain/use_cases/fetch_settings_use_case.dart';
import '../../domain/entities/expense_filters.dart';
import 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  final GetExpensesUseCase getExpensesUseCase;
  final AddExpenseUseCase addExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final FetchSettingsUseCase fetchSettingsUseCase;

  ExpensesCubit({
    required this.getExpensesUseCase,
    required this.addExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.fetchSettingsUseCase,
  }) : super(const ExpensesState());

  /// Load all expenses and apply default filter (current month)
  Future<void> loadExpenses() async {
    emit(state.copyWith(status: ExpensesStatus.loading));

    try {
      final result = await getExpensesUseCase.call();

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: ExpensesStatus.error,
            errorMessage: failure.toString(),
          ),
        ),
        (expenses) async {
          // Sort by date descending (most recent first)
          final sortedExpenses = List<Expense>.from(expenses)
            ..sort((a, b) => b.date.compareTo(a.date));

          // Get month boundaries based on user's month start day
          final monthBoundaries = await _getCurrentMonthBoundaries();

          // Apply default filter (current month)
          final defaultFilters = ExpenseFilters(
            startDate: monthBoundaries.$1,
            endDate: monthBoundaries.$2,
          );

          final filtered = _applyFilters(sortedExpenses, defaultFilters);

          emit(
            state.copyWith(
              status: ExpensesStatus.loaded,
              allExpenses: sortedExpenses,
              filteredExpenses: filtered,
              filters: defaultFilters,
              errorMessage: null,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ExpensesStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Update filters and reapply
  void updateFilters(ExpenseFilters newFilters) {
    emit(state.copyWith(status: ExpensesStatus.filtering));

    final filtered = _applyFilters(state.allExpenses, newFilters);

    emit(
      state.copyWith(
        status: ExpensesStatus.loaded,
        filteredExpenses: filtered,
        filters: newFilters,
      ),
    );
  }

  /// Reset filters to current month
  Future<void> resetFilters() async {
    final monthBoundaries = await _getCurrentMonthBoundaries();
    final defaultFilters = ExpenseFilters(
      startDate: monthBoundaries.$1,
      endDate: monthBoundaries.$2,
    );
    updateFilters(defaultFilters);
  }

  /// Clear all filters
  void clearFilters() {
    emit(state.copyWith(status: ExpensesStatus.filtering));

    emit(
      state.copyWith(
        status: ExpensesStatus.loaded,
        filteredExpenses: state.allExpenses,
        filters: const ExpenseFilters(),
      ),
    );
  }

  /// Delete expense
  Future<void> deleteExpense(String id) async {
    final result = await deleteExpenseUseCase.call(id);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ExpensesStatus.error,
          errorMessage: failure.toString(),
        ),
      ),
      (_) {
        // Remove from cached lists
        final updatedAll = state.allExpenses.where((e) => e.id != id).toList();
        final updatedFiltered = state.filteredExpenses
            .where((e) => e.id != id)
            .toList();

        emit(
          state.copyWith(
            allExpenses: updatedAll,
            filteredExpenses: updatedFiltered,
            status: ExpensesStatus.loaded,
          ),
        );
      },
    );
  }

  /// Add/Update expense and refresh
  Future<void> addExpense(Expense expense) async {
    final result = await addExpenseUseCase.call(expense);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ExpensesStatus.error,
          errorMessage: failure.toString(),
        ),
      ),
      (_) => loadExpenses(), // Reload to update both lists
    );
  }

  /// Apply filters in optimal order: Date → Category → Amount
  List<Expense> _applyFilters(List<Expense> expenses, ExpenseFilters filters) {
    var result = expenses;

    // 1. Date range filter (most selective)
    if (filters.startDate != null || filters.endDate != null) {
      result = result.where((expense) {
        final date = expense.date;
        if (filters.startDate != null && date.isBefore(filters.startDate!)) {
          return false;
        }
        if (filters.endDate != null && date.isAfter(filters.endDate!)) {
          return false;
        }
        return true;
      }).toList();
    }

    // 2. Category filter
    if (filters.categoryIds.isNotEmpty) {
      result = result
          .where((expense) => filters.categoryIds.contains(expense.categoryId))
          .toList();
    }

    // 3. Amount filter
    if (filters.minAmount != null || filters.maxAmount != null) {
      result = result.where((expense) {
        if (filters.minAmount != null && expense.amount < filters.minAmount!) {
          return false;
        }
        if (filters.maxAmount != null && expense.amount > filters.maxAmount!) {
          return false;
        }
        return true;
      }).toList();
    }

    return result;
  }

  /// Get current month boundaries based on user's month start day
  Future<(DateTime, DateTime)> _getCurrentMonthBoundaries() async {
    final settingsResult = await fetchSettingsUseCase.call();

    final monthStartDay = settingsResult.fold(
      (_) => 1, // Default to 1 if settings can't be loaded
      (settings) => settings.monthStartDay,
    );

    final now = DateTime.now();
    final currentDay = now.day;

    DateTime monthStart;
    DateTime monthEnd;

    if (currentDay >= monthStartDay) {
      // We're in current month's period
      monthStart = DateTime(now.year, now.month, monthStartDay);
      // End is day before next month's start day
      final nextMonth = now.month == 12
          ? DateTime(now.year + 1, 1, monthStartDay)
          : DateTime(now.year, now.month + 1, monthStartDay);
      monthEnd = nextMonth.subtract(
        const Duration(days: 1, hours: 23, minutes: 59),
      );
    } else {
      // We're in previous month's period
      final prevMonth = now.month == 1
          ? DateTime(now.year - 1, 12, monthStartDay)
          : DateTime(now.year, now.month - 1, monthStartDay);
      monthStart = prevMonth;
      monthEnd = DateTime(
        now.year,
        now.month,
        monthStartDay - 1,
        23,
        59,
        59,
        999,
      );
    }

    return (monthStart, monthEnd);
  }
}
