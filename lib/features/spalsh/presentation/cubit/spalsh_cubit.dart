import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/auth/auth_manager.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../injection_container.dart';
import 'spalsh_state.dart';

class SpalshCubit extends Cubit<SpalshState> {
  SpalshCubit() : super(const SpalshState(status: SpalshStatus.initial));

  /// Check auth status after a short splash delay
  Future<void> checkAuthStatus() async {
    // Brief delay for splash branding
    await Future.delayed(const Duration(milliseconds: 2000));

    if (authManager.isLoggedIn) {
      // Trigger background sync
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
