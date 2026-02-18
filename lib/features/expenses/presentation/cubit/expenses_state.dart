import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/expense.dart';
import '../../domain/entities/expense_filters.dart';

enum ExpensesStatus { initial, loading, loaded, filtering, error }

class ExpensesState extends Equatable {
  final ExpensesStatus status;
  final List<Expense> allExpenses; // Cache all expenses
  final List<Expense> filteredExpenses; // Current filtered view
  final ExpenseFilters filters;
  final String? errorMessage;

  const ExpensesState({
    this.status = ExpensesStatus.initial,
    this.allExpenses = const [],
    this.filteredExpenses = const [],
    this.filters = const ExpenseFilters(),
    this.errorMessage,
  });

  ExpensesState copyWith({
    ExpensesStatus? status,
    List<Expense>? allExpenses,
    List<Expense>? filteredExpenses,
    ExpenseFilters? filters,
    String? errorMessage,
  }) {
    return ExpensesState(
      status: status ?? this.status,
      allExpenses: allExpenses ?? this.allExpenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      filters: filters ?? this.filters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allExpenses,
    filteredExpenses,
    filters,
    errorMessage,
  ];
}
