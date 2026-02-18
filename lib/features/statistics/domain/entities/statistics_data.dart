import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/expense.dart';

class StatisticsData extends Equatable {
  final double totalSpending;
  final double previousPeriodSpending; // For comparison
  final double spendingChangePercentage;
  final List<DailyExpense> dailyTrend;
  final List<CategorySpending> categoryDistribution;
  final CategorySpending? topCategory;
  final double averageDailySpending;
  final List<MonthlySpending> last6MonthsTrend;
  final Expense? highestSingleExpense;
  final List<Map<String, dynamic>>
  spendingHeatmap; // {date: DateTime, intensity: int}
  final List<CategoryGrowth> categoryGrowth;
  final List<CategoryFrequency> spendingFrequency;
  final WeekendVsWeekday weekendVsWeekday;
  final List<TimeOfDaySpending> timeOfDayAnalysis;
  final double projectedSavings; // Placeholder

  const StatisticsData({
    this.totalSpending = 0.0,
    this.previousPeriodSpending = 0.0,
    this.spendingChangePercentage = 0.0,
    this.dailyTrend = const [],
    this.categoryDistribution = const [],
    this.topCategory,
    this.averageDailySpending = 0.0,
    this.last6MonthsTrend = const [],
    this.highestSingleExpense,
    this.spendingHeatmap = const [],
    this.categoryGrowth = const [],
    this.spendingFrequency = const [],
    this.weekendVsWeekday = const WeekendVsWeekday(weekend: 0, weekday: 0),
    this.timeOfDayAnalysis = const [],
    this.projectedSavings = 0.0,
  });

  @override
  List<Object?> get props => [
    totalSpending,
    previousPeriodSpending,
    spendingChangePercentage,
    dailyTrend,
    categoryDistribution,
    topCategory,
    averageDailySpending,
    last6MonthsTrend,
    highestSingleExpense,
    spendingHeatmap,
    categoryGrowth,
    spendingFrequency,
    weekendVsWeekday,
    timeOfDayAnalysis,
    projectedSavings,
  ];
}

class DailyExpense extends Equatable {
  final DateTime date;
  final double total;

  const DailyExpense({required this.date, required this.total});

  @override
  List<Object?> get props => [date, total];
}

class CategorySpending extends Equatable {
  final String categoryId;
  final String categoryName;
  final int color;
  final double total;
  final double percentage;
  final int transactionCount;

  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.color,
    required this.total,
    required this.percentage,
    this.transactionCount = 0,
  });

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    color,
    total,
    percentage,
    transactionCount,
  ];
}

class MonthlySpending extends Equatable {
  final DateTime month;
  final double total;

  const MonthlySpending({required this.month, required this.total});

  @override
  List<Object?> get props => [month, total];
}

class CategoryGrowth extends Equatable {
  final String categoryId;
  final String categoryName;
  final double growthPercentage;

  const CategoryGrowth({
    required this.categoryId,
    required this.categoryName,
    required this.growthPercentage,
  });

  @override
  List<Object?> get props => [categoryId, categoryName, growthPercentage];
}

class CategoryFrequency extends Equatable {
  final String categoryId;
  final String categoryName;
  final int count;

  const CategoryFrequency({
    required this.categoryId,
    required this.categoryName,
    required this.count,
  });

  @override
  List<Object?> get props => [categoryId, categoryName, count];
}

class WeekendVsWeekday extends Equatable {
  final double weekend;
  final double weekday;

  const WeekendVsWeekday({required this.weekend, required this.weekday});

  double get total => weekend + weekday;
  double get weekendPercentage => total == 0 ? 0 : (weekend / total) * 100;
  double get weekdayPercentage => total == 0 ? 0 : (weekday / total) * 100;

  @override
  List<Object?> get props => [weekend, weekday];
}

class TimeOfDaySpending extends Equatable {
  final String periodName; // Morning, Afternoon, Evening, Night
  final double total;

  const TimeOfDaySpending({required this.periodName, required this.total});

  @override
  List<Object?> get props => [periodName, total];
}
