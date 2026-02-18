import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qawam/features/settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/statistics_data.dart';
import 'stat_card.dart';
import '../../../../config/language/language_manager.dart';

class CategoryPieChartWidget extends StatefulWidget {
  final List<CategorySpending> data;

  const CategoryPieChartWidget({super.key, required this.data});

  @override
  State<CategoryPieChartWidget> createState() => _CategoryPieChartWidgetState();
}

class _CategoryPieChartWidgetState extends State<CategoryPieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox.shrink();
    }

    final locale = AppLocalizations.of(context)?.locale.toString() ?? 'en';
    final currencyCode = context.select<SettingsCubit, String>(
      (cubit) => cubit.state.settings.currency,
    );

    final currencyFormat = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
      decimalDigits: 0,
    );
    final percentFormat = NumberFormat.decimalPattern(locale);

    final sortedData = List<CategorySpending>.from(widget.data)
      ..sort((a, b) => b.total.compareTo(a.total));

    return StatCard(
      title: context.tr('spending_by_category'),
      child: Column(
        children: [
          SizedBox(
            height: 280,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: List.generate(sortedData.length, (i) {
                  final item = sortedData[i];
                  final isTouched = i == touchedIndex;
                  final fontSize = isTouched ? 16.0 : 12.0;
                  final radius = isTouched ? 110.0 : 100.0;
                  final color = Color(item.color);
                  final percentage = item.percentage;

                  return PieChartSectionData(
                    color: color,
                    value: item.total,
                    title: isTouched
                        ? '${percentFormat.format(percentage)}%\n${currencyFormat.format(item.total)}'
                        : '${percentFormat.format(percentage)}%',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffffffff),
                      shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                    ),
                    badgeWidget: isTouched
                        ? _Badge(
                            item.categoryName,
                            size: 40,
                            borderColor: color,
                          )
                        : null,
                    badgePositionPercentageOffset: .98,
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLegend(sortedData, percentFormat),
        ],
      ),
    );
  }

  Widget _buildLegend(List<CategorySpending> data, NumberFormat percentFormat) {
    // Show max 6 items in legend to avoid clutter, rest usage is in chart
    final displayItems = data.length > 8 ? data.sublist(0, 8) : data;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: displayItems.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Color(item.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.categoryName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${percentFormat.format(item.percentage)}%)',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final double size;
  final Color borderColor;

  const _Badge(this.label, {required this.size, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .1),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
