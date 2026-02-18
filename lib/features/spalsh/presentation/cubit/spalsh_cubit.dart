import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/auth/auth_manager.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../injection_container.dart';
import 'spalsh_state.dart';

class SpalshCubit extends Cubit<SpalshState> {
  SpalshCubit() : super(const SpalshState(status: SpalshStatus.initial));

  Future<void> checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!hasSeenOnboarding) {
      emit(state.copyWith(status: SpalshStatus.needsOnboarding));
      return;
    }

    if (authManager.isLoggedIn) {
      try {
        getIt<SyncService>().syncData();
      } catch (e) {
        // Ignore sync start errors to avoid blocking app launch
      }
      emit(state.copyWith(status: SpalshStatus.authenticated));
    } else {
      emit(state.copyWith(status: SpalshStatus.unauthenticated));
    }
  }
}
