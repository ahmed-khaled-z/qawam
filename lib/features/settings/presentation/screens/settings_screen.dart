import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/language/language_manager.dart';

import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = "/settings";
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsBody();
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  static const _teal = Color(0xFF0D7377);
  static const _bg = Color(0xFFF7F8FA);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state.status == SettingsStatus.loading) {
          return Scaffold(
            backgroundColor: _bg,
            body: const Center(child: CircularProgressIndicator(color: _teal)),
          );
        }

        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Currency
                      _buildSectionCard(
                        context,
                        children: [_buildCurrencyTile(context, state)],
                      ),
                      const SizedBox(height: 16),

                      // Language
                      _buildSectionCard(
                        context,
                        children: [_buildLanguageTile(context, state)],
                      ),
                      const SizedBox(height: 16),

                      // Toggles
                      _buildSectionCard(
                        context,
                        children: [
                          _buildSwitchTile(
                            context,
                            icon: Icons.cloud_sync_outlined,
                            color: const Color(0xFF42A5F5),
                            label: context.tr('settings_data_sync'),
                            subtitle: context.tr('settings_data_sync_desc'),
                            value: state.settings.dataSyncEnabled,
                            onChanged: (v) =>
                                context.read<SettingsCubit>().setDataSync(v),
                          ),
                          _divider(),
                          _buildSwitchTile(
                            context,
                            icon: Icons.notifications_outlined,
                            color: const Color(0xFFFFA726),
                            label: context.tr('settings_notifications'),
                            subtitle: context.tr('settings_notifications_desc'),
                            value: state.settings.notificationsEnabled,
                            onChanged: (v) => context
                                .read<SettingsCubit>()
                                .setNotifications(v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Month start day
                      _buildSectionCard(
                        context,
                        children: [_buildMonthStartTile(context, state)],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Color(0xFF2D2D3A),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('more_settings'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('settings_subtitle'),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  Widget _buildCurrencyTile(BuildContext context, SettingsState state) {
    final currencies = state.currencies;

    // Ensure we have a valid selection even if the list is still loading
    final currentCurrencyCode = state.settings.currency;

    // Find if current currency exists in list, if not we might want to add it nicely
    // or just rely on the list having it.

    return _SettingsTile(
      icon: Icons.attach_money_rounded,
      color: const Color(0xFF66BB6A),
      label: context.tr('settings_currency'),
      trailing: DropdownButton<String>(
        value: currentCurrencyCode,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(14),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D2D3A),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        items: currencies.map((c) {
          return DropdownMenuItem(value: c.code, child: Text(c.displayName));
        }).toList(),
        onChanged: (v) {
          if (v != null) context.read<SettingsCubit>().setCurrency(v);
        },
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, SettingsState state) {
    final isArabic = state.settings.language == 'ar';
    return _SettingsTile(
      icon: Icons.language_rounded,
      color: const Color(0xFF5C6BC0),
      label: context.tr('settings_language'),
      trailing: Container(
        decoration: BoxDecoration(
          color: _teal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _langChip('EN', !isArabic, () {
              context.read<SettingsCubit>().setLanguage('en');
            }),
            _langChip('عربي', isArabic, () {
              context.read<SettingsCubit>().setLanguage('ar');
            }),
          ],
        ),
      ),
    );
  }

  Widget _langChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _teal : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : _teal,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _SettingsTile(
      icon: icon,
      color: color,
      label: label,
      subtitle: subtitle,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: _teal,
      ),
    );
  }

  Widget _buildMonthStartTile(BuildContext context, SettingsState state) {
    return _SettingsTile(
      icon: Icons.calendar_month_rounded,
      color: const Color(0xFFEF5350),
      label: context.tr('settings_month_start'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<int>(
          value: state.settings.monthStartDay,
          underline: const SizedBox(),
          borderRadius: BorderRadius.circular(14),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D3A),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          items: List.generate(28, (i) {
            final day = i + 1;
            return DropdownMenuItem(value: day, child: Text('  $day  '));
          }),
          onChanged: (v) {
            if (v != null) context.read<SettingsCubit>().setMonthStartDay(v);
          },
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }
}

/// Reusable settings row with icon badge and trailing widget
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D3A),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
