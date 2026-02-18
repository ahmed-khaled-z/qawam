import 'package:dartz/dartz.dart';
import 'package:collection/collection.dart';
import '../../../home/domain/entities/expense.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../home/domain/use_cases/get_expenses_use_case.dart';
import '../../../categories/domain/use_cases/get_categories_use_case.dart';
import '../../../expenses/domain/entities/expense_filters.dart';
import '../entities/statistics_data.dart';

class GetStatisticsUseCase {
  final GetExpensesUseCase getExpensesUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  GetStatisticsUseCase(this.getExpensesUseCase, this.getCategoriesUseCase);

  Future<Either<Exception, StatisticsData>> call(ExpenseFilters filters) async {
    // 1. Fetch ALL data via UseCases
    final expensesResult = await getExpensesUseCase.call();
    final categoriesResult = await getCategoriesUseCase.call();

    return expensesResult.fold((error) => Left(error), (allExpenses) {
      return categoriesResult.fold((error) => Left(error), (categories) {
        // 2. Filter expenses for current period
        final filteredExpenses = _filterExpenses(allExpenses, filters);

        // 3. Filter expenses for previous period (for comparison)
        final previousFilters = _getPreviousPeriodFilters(filters);
        final previousExpenses = _filterExpenses(allExpenses, previousFilters);

        // 4. Calculate
        final totalSpending = _calculateTotal(filteredExpenses);
        final previousTotal = _calculateTotal(previousExpenses);
        final changePercentage = _calculateChangePercentage(
          totalSpending,
          previousTotal,
        );

        final categoryMap = {for (var c in categories) c.id: c};
        final categoryDistribution = _calculateCategoryDistribution(
          filteredExpenses,
          categoryMap,
        );
        final topCategory = categoryDistribution.isNotEmpty
            ? categoryDistribution.first
            : null;

        return Right(
          StatisticsData(
            totalSpending: totalSpending,
            previousPeriodSpending: previousTotal,
            spendingChangePercentage: changePercentage,
            dailyTrend: _calculateDailyTrend(filteredExpenses),
            categoryDistribution: categoryDistribution,
            topCategory: topCategory,
            averageDailySpending: _calculateAverageDailySpending(
              filteredExpenses,
              filters,
            ),
            last6MonthsTrend: _calculateLast6MonthsTrend(allExpenses),
            highestSingleExpense: _getHighestSingleExpense(filteredExpenses),
            spendingHeatmap: _calculateHeatmap(filteredExpenses),
            categoryGrowth: _calculateCategoryGrowth(
              filteredExpenses,
              previousExpenses,
              categoryMap,
            ),
            spendingFrequency: _calculateSpendingFrequency(
              filteredExpenses,
              categoryMap,
            ),
            weekendVsWeekday: _calculateWeekendVsWeekday(filteredExpenses),
            timeOfDayAnalysis: _calculateTimeOfDayAnalysis(filteredExpenses),
          ),
        );
      });
    });
  }

  // ... (Calculations logic unchanged, relying on internal methods I defined before)
  List<Expense> _filterExpenses(
    List<Expense> expenses,
    ExpenseFilters filters,
  ) {
    return expenses.where((expense) {
      if (filters.startDate != null &&
          expense.date.isBefore(filters.startDate!))
        return false;
      if (filters.endDate != null &&
          expense.date.isAfter(
            filters.endDate!
                .add(const Duration(days: 1))
                .subtract(const Duration(milliseconds: 1)),
          ))
        return false;
      if (filters.categoryIds.isNotEmpty &&
          !filters.categoryIds.contains(expense.categoryId))
        return false;
      return true;
    }).toList();
  }

  ExpenseFilters _getPreviousPeriodFilters(ExpenseFilters current) {
    if (current.startDate == null || current.endDate == null) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month - 1, 1);
      final end = DateTime(now.year, now.month, 0);
      return ExpenseFilters(startDate: start, endDate: end);
    }

    final duration =
        current.endDate!.difference(current.startDate!) +
        const Duration(days: 1);
    final previousStart = current.startDate!.subtract(duration);
    final previousEnd = current.endDate!.subtract(duration);

    return ExpenseFilters(
      startDate: previousStart,
      endDate: previousEnd,
      categoryIds: current.categoryIds,
    );
  }

  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  double _calculateChangePercentage(double current, double previous) {
    if (previous == 0) return current == 0 ? 0 : 100;
    return ((current - previous) / previous) * 100;
  }

  List<DailyExpense> _calculateDailyTrend(List<Expense> expenses) {
    final grouped = groupBy(
      expenses,
      (Expense e) => DateTime(e.date.year, e.date.month, e.date.day),
    );
    final sortedKeys = grouped.keys.toList()..sort();

    return sortedKeys.map((date) {
      final total = grouped[date]!.fold(0.0, (sum, e) => sum + e.amount);
      return DailyExpense(date: date, total: total);
    }).toList();
  }

  List<CategorySpending> _calculateCategoryDistribution(
    List<Expense> expenses,
    Map<String, Category> categoryMap,
  ) {
    if (expenses.isEmpty) return [];
    final total = _calculateTotal(expenses);
    final grouped = groupBy(expenses, (Expense e) => e.categoryId);

    final list = grouped.entries.map((entry) {
      final catId = entry.key;
      final catTotal = entry.value.fold(0.0, (sum, e) => sum + e.amount);
      final category = categoryMap[catId];

      return CategorySpending(
        categoryId: catId,
        categoryName: category?.name ?? 'Unknown',
        color: category?.color ?? 0xFF9E9E9E,
        total: catTotal,
        percentage: total == 0 ? 0 : (catTotal / total) * 100,
        transactionCount: entry.value.length,
      );
    }).toList();

    list.sort((a, b) => b.total.compareTo(a.total));
    return list;
  }

  double _calculateAverageDailySpending(
    List<Expense> expenses,
    ExpenseFilters filters,
  ) {
    if (expenses.isEmpty) return 0.0;

    int days;
    if (filters.startDate != null && filters.endDate != null) {
      days = filters.endDate!.difference(filters.startDate!).inDays + 1;
    } else {
      final sorted = expenses.map((e) => e.date).toList()..sort();
      days = sorted.last.difference(sorted.first).inDays + 1;
    }

    if (days <= 0) days = 1;
    return _calculateTotal(expenses) / days;
  }

  List<MonthlySpending> _calculateLast6MonthsTrend(List<Expense> allExpenses) {
    final now = DateTime.now();
    final List<MonthlySpending> result = [];

    for (int i = 5; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);

      final monthlyExpenses = allExpenses
          .where(
            (e) =>
                e.date.isAfter(
                  monthStart.subtract(const Duration(milliseconds: 1)),
                ) &&
                e.date.isBefore(monthEnd.add(const Duration(days: 1))),
          )
          .toList();

      result.add(
        MonthlySpending(
          month: monthStart,
          total: _calculateTotal(monthlyExpenses),
        ),
      );
    }
    return result;
  }

  Expense? _getHighestSingleExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.fold<Expense>(
      expenses.first,
      (max, e) => e.amount > max.amount ? e : max,
    );
  }

  List<Map<String, dynamic>> _calculateHeatmap(List<Expense> expenses) {
    final grouped = groupBy(
      expenses,
      (Expense e) => DateTime(e.date.year, e.date.month, e.date.day),
    );

    return grouped.entries.map((entry) {
      return {
        'date': entry.key,
        'count': entry.value.length,
        'total': entry.value.fold(0.0, (s, e) => s + e.amount),
      };
    }).toList();
  }

  List<CategoryGrowth> _calculateCategoryGrowth(
    List<Expense> current,
    List<Expense> previous,
    Map<String, Category> categoryMap,
  ) {
    final currentMap = groupBy(current, (Expense e) => e.categoryId);
    final previousMap = groupBy(previous, (Expense e) => e.categoryId);

    final allKeys = {...currentMap.keys, ...previousMap.keys};
    final results = <CategoryGrowth>[];

    for (var catId in allKeys) {
      final currTotal = (currentMap[catId] ?? []).fold(
        0.0,
        (s, e) => s + e.amount,
      );
      final prevTotal = (previousMap[catId] ?? []).fold(
        0.0,
        (s, e) => s + e.amount,
      );

      double growth = 0.0;
      if (prevTotal > 0) {
        growth = ((currTotal - prevTotal) / prevTotal) * 100;
      } else if (currTotal > 0) {
        growth = 100.0;
      }

      results.add(
        CategoryGrowth(
          categoryId: catId,
          categoryName: categoryMap[catId]?.name ?? 'Unknown',
          growthPercentage: growth,
        ),
      );
    }

    results.sort(
      (a, b) => b.growthPercentage.abs().compareTo(a.growthPercentage.abs()),
    );
    return results;
  }

  List<CategoryFrequency> _calculateSpendingFrequency(
    List<Expense> expenses,
    Map<String, Category> categoryMap,
  ) {
    final grouped = groupBy(expenses, (Expense e) => e.categoryId);

    final list = grouped.entries.map((entry) {
      return CategoryFrequency(
        categoryId: entry.key,
        categoryName: categoryMap[entry.key]?.name ?? 'Unknown',
        count: entry.value.length,
      );
    }).toList();

    list.sort((a, b) => b.count.compareTo(a.count));
    return list;
  }

  WeekendVsWeekday _calculateWeekendVsWeekday(List<Expense> expenses) {
    double weekend = 0.0;
    double weekday = 0.0;

    for (var expense in expenses) {
      if (expense.date.weekday == DateTime.friday ||
          expense.date.weekday == DateTime.saturday) {
        weekend += expense.amount;
      } else {
        weekday += expense.amount;
      }
    }
    return WeekendVsWeekday(weekend: weekend, weekday: weekday);
  }

  List<TimeOfDaySpending> _calculateTimeOfDayAnalysis(List<Expense> expenses) {
    double morning = 0, afternoon = 0, evening = 0, night = 0;

    for (var expense in expenses) {
      final hour = expense.date.hour;
      if (hour >= 5 && hour < 12)
        morning += expense.amount;
      else if (hour >= 12 && hour < 17)
        afternoon += expense.amount;
      else if (hour >= 17 && hour < 21)
        evening += expense.amount;
      else
        night += expense.amount;
    }

    return [
      TimeOfDaySpending(periodName: 'Morning', total: morning),
      TimeOfDaySpending(periodName: 'Afternoon', total: afternoon),
      TimeOfDaySpending(periodName: 'Evening', total: evening),
      TimeOfDaySpending(periodName: 'Night', total: night),
    ];
  }
}
