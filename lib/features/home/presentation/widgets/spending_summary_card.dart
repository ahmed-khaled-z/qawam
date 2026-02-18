import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/language/language_manager.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';

class SpendingSummaryCard extends StatelessWidget {
  final double todayTotal;
  final double monthTotal;

  const SpendingSummaryCard({
    super.key,
    required this.todayTotal,
    required this.monthTotal,
  });

  @override
  Widget build(BuildContext context) {
    // We can access settings here
    final locale = AppLocalizations.of(context)?.locale.toString() ?? 'en';
    final currencyCode = context.select<SettingsCubit, String>(
      (cubit) => cubit.state.settings.currency,
    );

    final currencyFormat = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
      decimalDigits: 0,
    );

    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            context,
            title: context.tr('spent_today'),
            amount: todayTotal,
            icon: Icons.today,
            color: const Color(0xFF0D7377),
            formatter: currencyFormat,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            context,
            title: context.tr('spent_month'),
            amount: monthTotal,
            icon: Icons.calendar_month,
            color: const Color(0xFF14C6B8),
            formatter: currencyFormat,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required NumberFormat formatter,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatter.format(amount),
            style: const TextStyle(
              color: Color(0xFF2D2D3A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
