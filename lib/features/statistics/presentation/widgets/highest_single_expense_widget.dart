import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qawam/features/settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/statistics_data.dart';
import 'stat_card.dart';
import '../../../../config/language/language_manager.dart';

class HighestSingleExpenseWidget extends StatelessWidget {
  final StatisticsData data;

  const HighestSingleExpenseWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.highestSingleExpense == null) return const SizedBox.shrink();

    final expense = data.highestSingleExpense!;

    // Find category info
    final categorySpending = data.categoryDistribution.firstWhere(
      (c) => c.categoryId == expense.categoryId,
      orElse: () => const CategorySpending(
        categoryId: 'unknown',
        categoryName: 'Unknown',
        color: 0xFF9E9E9E,
        total: 0.0,
        percentage: 0.0,
        transactionCount: 0,
      ),
    );

    final locale = AppLocalizations.of(context)?.locale.toString() ?? 'en';
    final currencyCode = context.select<SettingsCubit, String>(
      (cubit) => cubit.state.settings.currency,
    );

    final currencyFormat = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
      decimalDigits: 0,
    );

    return StatCard(
      title: context.tr('highest_single_expense'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(categorySpending.color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons
                    .local_offer_outlined, // Generic icon as we don't store icon code in Expense easily
                color: Color(categorySpending.color),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categorySpending.categoryName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF2D2D3A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd(locale).format(expense.date),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (expense.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        expense.note,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              currencyFormat.format(expense.amount),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
