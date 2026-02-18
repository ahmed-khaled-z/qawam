import 'package:equatable/equatable.dart';
import '../../domain/entities/statistics_data.dart';
import '../../../expenses/domain/entities/expense_filters.dart';

enum StatisticsStatus { initial, loading, loaded, error }

class StatisticsState extends Equatable {
  final StatisticsStatus status;
  final StatisticsData? statistics;
  final ExpenseFilters filters;
  final String? errorMessage;

  const StatisticsState({
    required this.status,
    this.statistics,
    this.filters = const ExpenseFilters(),
    this.errorMessage,
  });

  StatisticsState copyWith({
    StatisticsStatus? status,
    StatisticsData? statistics,
    ExpenseFilters? filters,
    String? errorMessage,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      statistics: statistics ?? this.statistics,
      filters: filters ?? this.filters,
      errorMessage: errorMessage, // Reset error on state change if not provided
    );
  }

  @override
  List<Object?> get props => [status, statistics, filters, errorMessage];
}
