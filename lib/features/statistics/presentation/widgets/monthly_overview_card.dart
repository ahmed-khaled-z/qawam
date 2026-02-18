import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qawam/features/settings/presentation/cubit/settings_cubit.dart';
import '../../../../config/language/language_manager.dart';
import '../../domain/entities/statistics_data.dart';
import 'stat_card.dart';

class MonthlyOverviewCard extends StatelessWidget {
  final StatisticsData data;

  const MonthlyOverviewCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)?.locale.toString() ?? 'en';
    final currencyCode = context.select<SettingsCubit, String>(
      (cubit) => cubit.state.settings.currency,
    );

    final currencyFormat = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
      decimalDigits: 0,
    );
    final percentage = data.spendingChangePercentage;
    final isIncrease = percentage > 0;
    // Lower spending is usually better (Green), Higher is worse (Red)
    final color = isIncrease
        ? Colors.redAccent
        : const Color(0xFF0D7377); // Green/Teal
    final icon = isIncrease
        ? Icons.arrow_outward
        : Icons.arrow_downward; // Outward (up-right) for increase

    return StatCard(
      title: context.tr('monthly_overview'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currencyFormat.format(data.totalSpending),
            style: const TextStyle(
              fontSize: 36, // Larger
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D2D3A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20), // Rounded pill
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${NumberFormat.decimalPattern(locale).format(percentage.abs())}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('vs_previous_month'),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('avg_daily'),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  currencyFormat.format(data.averageDailySpending),
                  style: const TextStyle(
                    color: Color(0xFF2D2D3A),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
