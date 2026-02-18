import 'package:equatable/equatable.dart';

/// Filter parameters for expenses
class ExpenseFilters extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> categoryIds;
  final double? minAmount;
  final double? maxAmount;

  const ExpenseFilters({
    this.startDate,
    this.endDate,
    this.categoryIds = const [],
    this.minAmount,
    this.maxAmount,
  });

  bool get hasFilters =>
      startDate != null ||
      endDate != null ||
      categoryIds.isNotEmpty ||
      minAmount != null ||
      maxAmount != null;

  ExpenseFilters clear() {
    return const ExpenseFilters();
  }

  ExpenseFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    double? minAmount,
    double? maxAmount,
    bool clearDates = false,
    bool clearCategories = false,
    bool clearAmounts = false,
  }) {
    return ExpenseFilters(
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      categoryIds: clearCategories ? [] : (categoryIds ?? this.categoryIds),
      minAmount: clearAmounts ? null : (minAmount ?? this.minAmount),
      maxAmount: clearAmounts ? null : (maxAmount ?? this.maxAmount),
    );
  }

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    categoryIds,
    minAmount,
    maxAmount,
  ];
}
