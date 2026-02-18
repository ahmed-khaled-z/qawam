import '../../domain/entities/profile.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  error,
  saving,
  saved,
  deleting,
  deleted,
  deleteError,
}

class ProfileState {
  final ProfileStatus status;
  final Profile? profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }
}
