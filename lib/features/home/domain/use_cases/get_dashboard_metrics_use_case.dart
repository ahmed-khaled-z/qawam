import 'package:dartz/dartz.dart';
import '../repositories/expenses_repository.dart';

class GetDashboardMetricsUseCase {
  final ExpensesRepository repository;

  GetDashboardMetricsUseCase(this.repository);

  Future<Either<Exception, Map<String, double>>> call() async {
    final result = await repository.getExpenses();
    return result.fold((error) => Left(error), (expenses) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Today's total
      double todayTotal = 0;
      for (var expense in expenses) {
        final expenseDate = DateTime(
          expense.date.year,
          expense.date.month,
          expense.date.day,
        );
        if (expenseDate.isAtSameMomentAs(today)) {
          todayTotal += expense.amount;
        }
      }

      // Monthly total (Simplified for now, assumes month starts on 1st)
      // TODO: Respect Month Start Day from settings
      double monthTotal = 0;
      for (var expense in expenses) {
        if (expense.date.year == now.year && expense.date.month == now.month) {
          monthTotal += expense.amount;
        }
      }

      return Right({'today': todayTotal, 'month': monthTotal});
    });
  }
}
