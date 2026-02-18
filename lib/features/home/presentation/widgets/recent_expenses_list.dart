import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';
import '../../../../features/categories/data/models/category_model.dart';
import '../../../../features/categories/presentation/cubit/categories_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/language/language_manager.dart';
import '../../../../features/categories/presentation/cubit/categories_state.dart';
import '../../../../features/settings/presentation/cubit/settings_cubit.dart';

class RecentExpensesList extends StatelessWidget {
  final List<Expense> expenses;

  const RecentExpensesList({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            context.tr('no_expenses_yet'),
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _ExpenseItem(expense: expense);
      },
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final Expense expense;

  const _ExpenseItem({required this.expense});

  @override
  Widget build(BuildContext context) {
    // Get Locale and Currency Settings
    final locale = AppLocalizations.of(context)?.locale.toString() ?? 'en';
    final currencyCode = context.select<SettingsCubit, String>(
      (cubit) => cubit.state.settings.currency,
    );

    final currencyFormat = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
      decimalDigits: 2,
    );

    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        final category = state.categories.firstWhere(
          (c) => c.id == expense.categoryId,
          orElse: () => CategoryModel(
            id: 'unknown',
            name: 'Unknown',
            iconCode: 0xe000,
            color: 0xFF9E9E9E,
            isSyncedToFirebase: false,
          ),
        );

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(category.color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                  color: Color(category.color),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D2D3A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.MMMd(locale).add_jm().format(expense.date),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "-${currencyFormat.format(expense.amount)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                  if (expense.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        expense.note,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
