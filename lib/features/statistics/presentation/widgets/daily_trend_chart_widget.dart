import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qawam/features/settings/presentation/cubit/settings_cubit.dart';
import 'stat_card.dart';
import '../../domain/entities/statistics_data.dart';
import '../../../../config/language/language_manager.dart';

class DailyTrendChartWidget extends StatelessWidget {
  final List<DailyExpense> data;

  const DailyTrendChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final locale = AppLocalizations.of(context)?.locale.toString() ?? 'en';
    final currencyCode = context.select<SettingsCubit, String>(
      (cubit) => cubit.state.settings.currency,
    );

    final sortedData = List<DailyExpense>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = sortedData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.total);
    }).toList();

    return StatCard(
      title: context.tr('daily_trend'),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1000,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.1),
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
                  reservedSize: 32,
                  interval: (sortedData.length / 5).ceil().toDouble(),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < sortedData.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat(
                            'd',
                            locale,
                          ).format(sortedData[index].date),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
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
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D7377), Color(0xFF4CDEA0)],
                ),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0D7377).withOpacity(0.3),
                      const Color(0xFF0D7377).withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) =>
                    Colors.blueGrey.shade800.withOpacity(0.9),
                fitInsideHorizontally: true,

                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    final index = touchedSpot.x.toInt();
                    if (index >= 0 && index < sortedData.length) {
                      final item = sortedData[index];
                      // Use compact format for tooltip too
                      final formattedAmount =
                          NumberFormat.compactSimpleCurrency(
                            locale: locale,
                            name: currencyCode,
                          ).format(item.total);
                      return LineTooltipItem(
                        '${DateFormat('MMM d', locale).format(item.date)}\n$formattedAmount',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }
                    return null;
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
