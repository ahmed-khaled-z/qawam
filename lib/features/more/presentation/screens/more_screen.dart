import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/auth/auth_manager.dart';
import '../../../../config/language/language_manager.dart';
import '../../../../config/router/app_router.dart';

import '../../../login/presentation/screens/login_screen.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../../../../core/sync/sync_service.dart';
import '../../../../../../injection_container.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> with TickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final List<Animation<double>> _itemAnimations;

  static const _itemCount = 7;
  static const _teal = Color(0xFF0D7377);

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _itemAnimations = List.generate(_itemCount, (i) {
      final start = (i / _itemCount) * 0.6;
      final end = start + 0.4;
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      );
    });

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ProfileCubit is provided in BottomNavScreen
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Main actions card
                  _buildSectionCard(
                    context,
                    children: [
                      _buildAnimatedItem(
                        index: 0,
                        icon: Icons.info_outline_rounded,
                        color: const Color(0xFF5C6BC0),
                        label: context.tr('more_about'),
                        onTap: () => _showComingSoon(context),
                      ),
                      _divider(),
                      _buildAnimatedItem(
                        index: 1,
                        icon: Icons.mail_outline_rounded,
                        color: const Color(0xFF26A69A),
                        label: context.tr('more_contact'),
                        onTap: () => _showComingSoon(context),
                      ),
                      _divider(),
                      _buildAnimatedItem(
                        index: 2,
                        icon: Icons.lightbulb_outline_rounded,
                        color: const Color(0xFFFFA726),
                        label: context.tr('more_suggest'),
                        onTap: () => _showComingSoon(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Legal card
                  _buildSectionCard(
                    context,
                    children: [
                      _buildAnimatedItem(
                        index: 3,
                        icon: Icons.description_outlined,
                        color: const Color(0xFF78909C),
                        label: context.tr('more_terms'),
                        onTap: () => _showComingSoon(context),
                      ),
                      _divider(),
                      _buildAnimatedItem(
                        index: 4,
                        icon: Icons.shield_outlined,
                        color: const Color(0xFF8D6E63),
                        label: context.tr('more_privacy'),
                        onTap: () => _showComingSoon(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Settings card
                  _buildSectionCard(
                    context,
                    children: [
                      _buildAnimatedItem(
                        index: 5,
                        icon: Icons.settings_outlined,
                        color: const Color(0xFF607D8B),
                        label: context.tr('more_settings'),
                        onTap: () => AppRouter.to(SettingsScreen.routeName),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Logout card
                  _buildSectionCard(
                    context,
                    children: [
                      _buildAnimatedItem(
                        index: 6,
                        icon: Icons.logout_rounded,
                        color: const Color(0xFFE53935),
                        label: context.tr('more_logout'),
                        isDestructive: true,
                        onTap: () => _handleLogout(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // App version footer
                  Center(
                    child: Text(
                      '${context.tr('app_name')} v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        final name = (profile?.name.isNotEmpty ?? false)
            ? profile!.name
            : context.tr('nav_more');
        final email = (profile?.email.isNotEmpty ?? false)
            ? profile!.email
            : context.tr('more_subtitle');
        final photoUrl = profile?.photoUrl;

        return GestureDetector(
          onTap: () => AppRouter.to(ProfileScreen.routeName)?.then((_) {
            if (context.mounted) {
              context.read<ProfileCubit>().loadProfile();
            }
          }),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: (photoUrl == null || photoUrl.isEmpty)
                        ? const LinearGradient(
                            colors: [Color(0xFF0D7377), Color(0xFF14919B)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    image: (photoUrl != null && photoUrl.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(photoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 26,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _buildAnimatedItem({
    required int index,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return AnimatedBuilder(
      animation: _itemAnimations[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _itemAnimations[index].value)),
          child: Opacity(opacity: _itemAnimations[index].value, child: child),
        );
      },
      child: _MoreMenuItem(
        icon: icon,
        color: color,
        label: label,
        isDestructive: isDestructive,
        onTap: onTap,
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('coming_soon')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _teal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final syncService = getIt<SyncService>();
    final hasUnsynced = await syncService.hasUnsyncedData();

    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          // Use default text if key not found (simple fallback logic or ensure keys exist)
          // For now, hardcoding fallback English if translation logic is complex to update
          hasUnsynced ? "Warning: Unsynced Data" : context.tr('more_logout'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
        content: Text(
          hasUnsynced
              ? "You have changes that haven't been synced to the cloud yet. Logging out will delete them permanently. Are you sure?"
              : context.tr('logout_confirm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              context.tr('cancel'),
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              hasUnsynced ? "Delete & Logout" : context.tr('more_logout'),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Clear all local data before logout
      await syncService.clearLocalData();

      await FirebaseAuth.instance.signOut();
      await authManager.logout();
      AppRouter.toAndRemoveUntil(LoginScreen.routeName);
    }
  }
}

/// Individual menu item with icon badge, label, and chevron
class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _MoreMenuItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              // Icon badge
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
              // Label
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDestructive
                        ? const Color(0xFFE53935)
                        : const Color(0xFF2D2D3A),
                  ),
                ),
              ),
              // Chevron
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade300,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
