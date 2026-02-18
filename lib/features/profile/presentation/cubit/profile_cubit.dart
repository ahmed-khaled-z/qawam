import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/delete_account_use_case.dart';
import '../../domain/use_cases/get_profile_use_case.dart';
import '../../domain/use_cases/save_profile_use_case.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final SaveProfileUseCase _saveProfileUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  ProfileCubit({
    required GetProfileUseCase getProfileUseCase,
    required SaveProfileUseCase saveProfileUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
  }) : _getProfileUseCase = getProfileUseCase,
       _saveProfileUseCase = saveProfileUseCase,
       _deleteAccountUseCase = deleteAccountUseCase,
       super(const ProfileState());

  /// Load profile initially
  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await _getProfileUseCase.call();

    result.fold(
      (error) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: error.toString(),
        ),
      ),
      (profile) =>
          emit(state.copyWith(status: ProfileStatus.loaded, profile: profile)),
    );
  }

  /// Update local state field
  void updateField({String? name, String? phoneNumber, DateTime? dob}) {
    if (state.profile == null) return;

    final updated = state.profile!.copyWith(
      name: name,
      phoneNumber: phoneNumber,
      dateOfBirth: dob,
    );
    emit(state.copyWith(profile: updated, status: ProfileStatus.loaded));
  }

  /// Save changes to repository
  Future<void> saveProfile() async {
    final profile = state.profile;
    if (profile == null) return;

    emit(state.copyWith(status: ProfileStatus.saving));

    final result = await _saveProfileUseCase.call(profile);

    result.fold(
      (error) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: error.toString(),
        ),
      ),
      (saved) =>
          emit(state.copyWith(status: ProfileStatus.saved, profile: saved)),
    );
  }

  /// Delete account
  Future<void> deleteAccount() async {
    emit(state.copyWith(status: ProfileStatus.deleting));

    final result = await _deleteAccountUseCase.call();

    result.fold(
      (error) => emit(
        state.copyWith(
          status: ProfileStatus.deleteError,
          errorMessage: error.toString(),
        ),
      ),
      (_) => emit(state.copyWith(status: ProfileStatus.deleted)),
    );
  }
}
