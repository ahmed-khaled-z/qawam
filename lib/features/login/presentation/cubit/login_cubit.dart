import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../injection_container.dart';

import '../../../../config/auth/auth_manager.dart';
import '../../data/models/login_model.dart';
import '../../domain/use_cases/login_use_case.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;

  LoginCubit({required this.loginUseCase})
    : super(const LoginState(status: LoginStatus.initial));

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: LoginStatus.loading));

    final result = await loginUseCase.call();

    result.fold(
      (exception) => emit(
        state.copyWith(
          status: LoginStatus.error,
          errorMessage: exception.toString().replaceAll('Exception: ', ''),
        ),
      ),
      (user) async {
        // Save user to AuthManager for session persistence
        final userModel = UserModel(
          uid: user.uid,
          displayName: user.displayName,
          email: user.email,
          photoUrl: user.photoUrl,
        );

        await authManager.login(userModel.toJson());

        // Trigger synchronization to fetch user data from Firebase
        // We await it here to ensure data is available when the user lands on the Home screen
        try {
          await getIt<SyncService>().syncData();
        } catch (e) {
          // Fail silently during login sync attempt
        }

        emit(state.copyWith(status: LoginStatus.success, user: user));
      },
    );
  }
}
