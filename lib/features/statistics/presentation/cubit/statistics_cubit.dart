import 'package:bloc/bloc.dart';
import '../../domain/use_cases/get_statistics_use_case.dart';
import '../../../settings/domain/use_cases/fetch_settings_use_case.dart';
import '../../../expenses/domain/entities/expense_filters.dart';
import 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final GetStatisticsUseCase getStatisticsUseCase;
  final FetchSettingsUseCase fetchSettingsUseCase;

  StatisticsCubit({
    required this.getStatisticsUseCase,
    required this.fetchSettingsUseCase,
  }) : super(const StatisticsState(status: StatisticsStatus.initial));

  void loadStatistics() async {
    emit(state.copyWith(status: StatisticsStatus.loading));

    // 1. Get Settings for month start day
    final settingsResult = await fetchSettingsUseCase.call();
    int startDay = 1;
    settingsResult.fold(
      (l) => startDay = 1, // Default
      (settings) => startDay = settings.monthStartDay,
    );

    // 2. Calculate current month range
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    if (now.day >= startDay) {
      start = DateTime(now.year, now.month, startDay);
      if (startDay == 1) {
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      } else {
        end = DateTime(now.year, now.month + 1, startDay - 1, 23, 59, 59);
      }
    } else {
      start = DateTime(now.year, now.month - 1, startDay);
      end = DateTime(now.year, now.month, startDay - 1, 23, 59, 59);
    }

    // Ensure end is valid (e.g., Feb 30 -> Mar 2 or similar logic? DateTime handles overflow automatically, but day 0 of next month is last day of current)
    // Actually DateTime(y, m+1, 0) gives last day of month m.
    // My logic above for startDay != 1 is slightly complex.
    // Let's refine:
    // If startDay is 1: Jan 1 to Jan 31.
    // If startDay is 25:
    //   If today is Jan 26: Current month is Jan 25 to Feb 24.
    //   If today is Jan 10: Current month is Dec 25 to Jan 24.

    // My logic:
    // now.day (26) >= startDay (25):
    // start = Jan 25.
    // end = Feb 24 (next month, startDay - 1).

    // now.day (10) < startDay (25):
    // start = Dec 25.
    // end = Jan 24.

    // DateTime(y, m, d) handles month overflow correctly.

    final filters = ExpenseFilters(startDate: start, endDate: end);

    updateFilters(filters);
  }

  void updateFilters(ExpenseFilters filters) async {
    emit(state.copyWith(status: StatisticsStatus.loading, filters: filters));

    final result = await getStatisticsUseCase.call(filters);

    result.fold(
      (error) => emit(
        state.copyWith(
          status: StatisticsStatus.error,
          errorMessage: error.toString(),
        ),
      ),
      (data) => emit(
        state.copyWith(status: StatisticsStatus.loaded, statistics: data),
      ),
    );
  }

  void resetFilters() {
    loadStatistics(); // Re-calculate default range from settings
  }
}
