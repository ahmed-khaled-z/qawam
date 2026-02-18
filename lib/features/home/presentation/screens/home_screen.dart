import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qawam/config/router/app_router.dart';
import 'package:qawam/features/expenses/presentation/screens/expenses_screen.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../../../config/language/language_manager.dart';
import '../widgets/recent_expenses_list.dart';
import '../widgets/spending_summary_card.dart';
import '../widgets/welcome_card.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = "/home";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: BlocConsumer<HomeCubit, HomeState>(
          listener: (context, state) {
            if (state.errorMessage != null &&
                state.status == HomeStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == HomeStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0D7377)),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().loadHomeData(),
              color: const Color(0xFF0D7377),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const WelcomeCard(),
                          const SizedBox(height: 24),
                          SpendingSummaryCard(
                            todayTotal: state.todayTotal,
                            monthTotal: state.monthTotal,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('recent_expenses'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D3A),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  AppRouter.to(ExpensesScreen.routeName);
                                },
                                child: Text(
                                  context.tr('view_more'),
                                  style: const TextStyle(
                                    color: Color(0xFF0D7377),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          RecentExpensesList(expenses: state.recentExpenses),
                          const SizedBox(height: 80), // Padding for bottom nav
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
