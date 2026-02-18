import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../../config/language/language_manager.dart';
import '../../presentation/cubit/statistics_cubit.dart';
import '../../presentation/cubit/statistics_state.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../widgets/monthly_overview_card.dart';
import '../widgets/daily_trend_chart_widget.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/last_six_months_chart.dart';
import '../widgets/highest_single_expense_widget.dart';
import '../../../expenses/presentation/widgets/filter_expenses_sheet.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';

class StatisticsScreen extends StatelessWidget {
  static const String routeName = '/statistics';

  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StatisticsCubit>()..loadStatistics(),
      child: const _StatisticsScreenContent(),
    );
  }
}

class _StatisticsScreenContent extends StatelessWidget {
  const _StatisticsScreenContent();

  void _showFilterSheet(BuildContext context) {
    final cubit = context.read<StatisticsCubit>();
    final currentFilters = cubit.state.filters;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<CategoriesCubit>()..loadCategories(),
          ),
        ],
        child: FilterExpensesSheet(
          currentFilters: currentFilters,
          onApply: (filters) => cubit.updateFilters(filters),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          previous.settings.monthStartDay != current.settings.monthStartDay ||
          previous.settings.currency !=
              current
                  .settings
                  .currency, // Reload if currency changes just in case stats depend on it (though UI handles formatting)
      listener: (context, state) {
        context.read<StatisticsCubit>().loadStatistics();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('statistics')),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterSheet(context),
              tooltip: context.tr('filter'),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<StatisticsCubit>().loadStatistics();
              },
            ),
          ],
        ),
        body: BlocBuilder<StatisticsCubit, StatisticsState>(
          builder: (context, state) {
            if (state.status == StatisticsStatus.loading &&
                state.statistics == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == StatisticsStatus.error &&
                state.statistics == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.errorMessage ?? context.tr('error_occurred')),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<StatisticsCubit>().loadStatistics(),
                      child: Text(context.tr('retry')),
                    ),
                  ],
                ),
              );
            }

            if (state.statistics == null) {
              return Center(child: Text(context.tr('no_data')));
            }

            final data = state.statistics!;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<StatisticsCubit>().loadStatistics();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.filters.hasFilters)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.filter_alt,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('apply_filters'),
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => context
                                  .read<StatisticsCubit>()
                                  .resetFilters(),
                              child: Text(context.tr('reset_filters')),
                            ),
                          ],
                        ),
                      ),
                    MonthlyOverviewCard(data: data),
                    DailyTrendChartWidget(data: data.dailyTrend),
                    CategoryPieChartWidget(data: data.categoryDistribution),
                    LastSixMonthsChart(data: data.last6MonthsTrend),
                    HighestSingleExpenseWidget(data: data),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
