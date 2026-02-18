import 'package:flutter/material.dart';
import '../../../../config/language/language_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/add_expense_sheet.dart';
import '../../../../features/categories/presentation/cubit/categories_cubit.dart';
import '../../../../features/home/presentation/cubit/home_cubit.dart';
import '../../../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../../../features/profile/presentation/cubit/profile_state.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D7377), Color(0xFF14C6B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D7377).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final profile = state.profile;
          final name = (profile?.name.isNotEmpty ?? false)
              ? profile!.name
              : context.tr('welcome_back');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (profile?.photoUrl != null &&
                      profile!.photoUrl.isNotEmpty) ...[
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(profile.photoUrl),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (profile?.name.isNotEmpty ?? false)
                            ? 'Hello, $name'
                            : context.tr('welcome_back'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('welcome_subtitle'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final homeCubit = context.read<HomeCubit>();
                    final categoriesCubit = context.read<CategoriesCubit>();

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: homeCubit),
                          BlocProvider.value(value: categoriesCubit),
                        ],
                        child: const AddExpenseSheet(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Color(0xFF0D7377)),
                  label: Text(
                    context.tr('add_new_expense'),
                    style: const TextStyle(
                      color: Color(0xFF0D7377),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
