import '../../domain/entities/expense.dart';

enum HomeStatus { initial, loading, loaded, error, adding }

class HomeState {
  final HomeStatus status;
  final List<Expense> recentExpenses;
  final double todayTotal;
  final double monthTotal;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.recentExpenses = const [],
    this.todayTotal = 0.0,
    this.monthTotal = 0.0,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<Expense>? recentExpenses,
    double? todayTotal,
    double? monthTotal,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      recentExpenses: recentExpenses ?? this.recentExpenses,
      todayTotal: todayTotal ?? this.todayTotal,
      monthTotal: monthTotal ?? this.monthTotal,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
