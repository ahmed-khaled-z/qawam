import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/language/language_manager.dart';
import '../../../../injection_container.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../home/domain/entities/expense.dart';
import '../../../home/presentation/widgets/add_expense_sheet.dart';
import '../cubit/expenses_cubit.dart';
import '../cubit/expenses_state.dart';
import '../widgets/filter_expenses_sheet.dart';
import 'package:qawam/features/settings/presentation/cubit/settings_cubit.dart';

class ExpensesScreen extends StatelessWidget {
  static const routeName = "/expenses";
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ExpensesCubit>()..loadExpenses(),
        ),
        BlocProvider(create: (_) => getIt<CategoriesCubit>()..loadCategories()),
      ],
      child: const _ExpensesBody(),
    );
  }
}

class _ExpensesBody extends StatelessWidget {
  const _ExpensesBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          context.tr('all_expenses'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D3A),
          ),
        ),
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showFilterSheet(context),
            icon: const Icon(Icons.filter_list, color: Color(0xFF0D7377)),
            tooltip: context.tr('filter'),
          ),
        ],
      ),
      body: BlocBuilder<ExpensesCubit, ExpensesState>(
        builder: (context, state) {
          if (state.status == ExpensesStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D7377)),
            );
          }

          if (state.status == ExpensesStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? context.tr('error_occurred'),
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ExpensesCubit>().loadExpenses(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D7377),
                    ),
                    child: Text(
                      context.tr('retry'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.filteredExpenses.isEmpty) {
            return _buildEmptyState(context, state.filters.hasFilters);
          }

          return Column(
            children: [
              if (state.filters.hasFilters) _buildFilterSummary(context, state),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<ExpensesCubit>().loadExpenses(),
                  color: const Color(0xFF0D7377),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = state.filteredExpenses[index];
                      return _ExpenseItem(expense: expense);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool hasFilters) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.filter_alt_off : Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? context.tr('no_expenses_match_filters')
                : context.tr('no_expenses_yet'),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (hasFilters)
            TextButton(
              onPressed: () => context.read<ExpensesCubit>().resetFilters(),
              child: Text(
                context.tr('reset_filters'),
                style: const TextStyle(color: Color(0xFF0D7377)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSummary(BuildContext context, ExpensesState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D7377).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 18, color: Color(0xFF0D7377)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${state.filteredExpenses.length} ${context.tr('expenses_found')}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D7377),
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.read<ExpensesCubit>().resetFilters(),
            child: Text(context.tr('reset')),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0D7377),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final currentFilters = context.read<ExpensesCubit>().state.filters;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ExpensesCubit>()),
          BlocProvider.value(value: context.read<CategoriesCubit>()),
        ],
        child: FilterExpensesSheet(
          currentFilters: currentFilters,
          onApply: (filters) =>
              context.read<ExpensesCubit>().updateFilters(filters),
        ),
      ),
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final Expense expense;

  const _ExpenseItem({required this.expense});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)?.locale.toString() ?? 'en';
    final currencyCode = context.select<SettingsCubit, String>(
      (cubit) => cubit.state.settings.currency,
    );
    final currencyFormat = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
      decimalDigits: 2,
    );
    final dateFormat = DateFormat.MMMd(locale).add_jm();

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

        return Dismissible(
          key: Key(expense.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await _showDeleteConfirmation(context);
          },
          onDismissed: (direction) {
            context.read<ExpensesCubit>().deleteExpense(expense.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('expense_deleted')),
                backgroundColor: Colors.red,
              ),
            );
          },
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white, size: 28),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(16),
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
            child: InkWell(
              onTap: () => _showEditExpenseSheet(context, expense),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(category.color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                      color: Color(category.color),
                      size: 24,
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
                          dateFormat.format(expense.date),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        if (expense.note.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
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
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "-${currencyFormat.format(expense.amount)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        expense.isSyncedToFirebase
                            ? Icons.check_circle
                            : Icons.cloud_off,
                        size: 16,
                        color: expense.isSyncedToFirebase
                            ? Colors.green
                            : Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('delete_expense')),
        content: Text(context.tr('delete_expense_confirm')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              context.tr('cancel'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.tr('delete'),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditExpenseSheet(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ExpensesCubit>()),
          BlocProvider.value(value: context.read<CategoriesCubit>()),
        ],
        child: AddExpenseSheet(expenseToEdit: expense),
      ),
    );
  }
}
