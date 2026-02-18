import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qawam/features/settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/statistics_data.dart';
import 'stat_card.dart';
import '../../../../config/language/language_manager.dart';

class LastSixMonthsChart extends StatelessWidget {
  final List<MonthlySpending> data;

  const LastSixMonthsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final locale = AppLocalizations.of(context)?.locale.toString() ?? 'en';
    final currencyCode = context.select<SettingsCubit, String>(
      (cubit) => cubit.state.settings.currency,
    );
    final currencyFormat = NumberFormat.compactSimpleCurrency(
      locale: locale,
      name: currencyCode,
    );

    // Sort chronologically
    final sorted = List<MonthlySpending>.from(data)
      ..sort((a, b) => a.month.compareTo(b.month));

    return StatCard(
      title: context.tr('last_6_months'),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1000,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.05),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < sorted.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat('MMM', locale).format(sorted[index].month),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: sorted.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.total,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D7377), Color(0xFF4CDEA0)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: 18,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ],
              );
            }).toList(),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) =>
                    Colors.blueGrey.shade800.withOpacity(0.9),
                fitInsideHorizontally: true,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${DateFormat('MMMM y', locale).format(sorted[group.x.toInt()].month)}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: currencyFormat.format(rod.toY),
                        style: const TextStyle(
                          color: Color(0xFF4CDEA0), // Highlight color
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
