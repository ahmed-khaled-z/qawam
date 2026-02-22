import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/auth/auth_manager.dart';
import '../../../../core/security/encryption_service.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../features/home/data/data_sources/local/expenses_local_data_source.dart';
import '../../../../features/home/data/models/expense_model.dart';
import '../../../../features/home/domain/entities/expense.dart';
import '../../../../features/home/domain/repositories/expenses_repository.dart';
import '../../../../injection_container.dart';
import '../../data/models/login_model.dart';
import '../../domain/use_cases/login_use_case.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;
  final EncryptionService encryptionService;

  LoginCubit({
    required this.loginUseCase,
    required this.encryptionService,
  }) : super(const LoginState(status: LoginStatus.initial));

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
        final userModel = UserModel(
          uid: user.uid,
          displayName: user.displayName,
          email: user.email,
          photoUrl: user.photoUrl,
        );
        await authManager.login(userModel.toJson());

        await encryptionService.ensureReady(user.uid);

        if (encryptionService.isReady) {
          if (encryptionService.hasLegacyKey) {
            try {
              await _runMigration(user.uid);
            } catch (e) {
              emit(state.copyWith(
                status: LoginStatus.error,
                user: user,
                errorMessage: 'Migration failed. Please try again.',
              ));
              return;
            }
          }
          try {
            await getIt<SyncService>().syncData();
          } catch (e) {
            // Fail silently during login sync attempt
          }
          emit(state.copyWith(status: LoginStatus.success, user: user));
          return;
        }

        if (encryptionService.state == EncryptionState.awaitingAuthorization) {
          emit(state.copyWith(
            status: LoginStatus.needsDeviceAuthorization,
            user: user,
          ));
          return;
        }

        if (encryptionService.state == EncryptionState.failed) {
          emit(state.copyWith(
            status: LoginStatus.error,
            user: user,
            errorMessage: 'Could not set up encryption. Please try again.',
          ));
          return;
        }

        emit(state.copyWith(status: LoginStatus.success, user: user));
      },
    );
  }

  /// Migrate from legacy device-bound key: re-encrypt all expenses with new MEK.
  Future<void> _runMigration(String userId) async {
    final repo = getIt<ExpensesRepository>();
    final local = getIt<ExpensesLocalDataSource>();
    final sync = getIt<SyncService>();

    final result = await repo.getExpenses();
    final expenses = result.fold((_) => <Expense>[], (list) => list);

    await encryptionService.runMigrationFromLegacyKey(userId);

    for (final e in expenses) {
      await local.addExpense(ExpenseModel.fromEntity(e));
    }

    await sync.syncData();
  }
}
