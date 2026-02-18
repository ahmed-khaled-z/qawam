import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qawam/features/home/presentation/screens/home_screen.dart';

import '../../../../config/language/language_manager.dart';
import '../../../../injection_container.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../more/presentation/screens/more_screen.dart';
import '../cubit/bottom_nav_cubit.dart';
import '../cubit/bottom_nav_state.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../home/presentation/widgets/add_expense_sheet.dart';
import '../../../statistics/presentation/screens/statistics_screen.dart';

class BottomNavScreen extends StatelessWidget {
  static const routeName = "/home";
  const BottomNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<BottomNavCubit>()),
        BlocProvider(create: (_) => getIt<HomeCubit>()..loadHomeData()),
        BlocProvider(create: (_) => getIt<CategoriesCubit>()..loadCategories()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()..loadProfile()),
      ],
      child: const _BottomNavBody(),
    );
  }
}

class _BottomNavBody extends StatelessWidget {
  const _BottomNavBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavCubit, BottomNavState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(index: state.currentIndex, children: _pages),
          bottomNavigationBar: _buildBottomNavBar(context, state),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddExpenseSheet(context),
            backgroundColor: const Color(0xFF0D7377),
            heroTag: 'main_fab_add_expense',
            child: const Icon(Icons.add, color: Colors.white),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  /// Tab pages — MoreScreen replaces placeholder
  List<Widget> get _pages => const [
    HomeScreen(),
    StatisticsScreen(),
    CategoriesScreen(),
    MoreScreen(),
  ];

  Widget _buildBottomNavBar(BuildContext context, BottomNavState state) {
    const activeColor = Color(0xFF0D7377);
    final inactiveColor = Colors.grey.shade400;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              final isSelected =
                  state.currentIndex == (index < 2 ? index : index - 1);
              final icons = [
                Icons.home_rounded,
                Icons.bar_chart_rounded,
                Icons.category_rounded,
                Icons.more_horiz_rounded,
              ];
              final labels = [
                context.tr('nav_home'),
                context.tr('nav_statistics'),
                context.tr('nav_categories'),
                context.tr('nav_more'),
              ];

              // Add spacing for FAB
              if (index == 2) {
                return const SizedBox(width: 48);
              }

              // Adjust index for items after FAB
              final itemIndex = index < 2 ? index : index - 1;

              return _NavBarItem(
                icon: icons[itemIndex],
                label: labels[itemIndex],
                isSelected: isSelected,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () =>
                    context.read<BottomNavCubit>().changeTab(itemIndex),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showAddExpenseSheet(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();
    final categoriesCubit = context.read<CategoriesCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: homeCubit),
          BlocProvider.value(value: categoriesCubit),
        ],
        child: const AddExpenseSheet(),
      ),
    );
  }
}

/// Individual nav bar item with smooth animation
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
