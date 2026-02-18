enum SpalshStatus { initial, authenticated, unauthenticated, needsOnboarding }

class SpalshState {
  final SpalshStatus status;

  const SpalshState({required this.status});

  SpalshState copyWith({SpalshStatus? status}) {
    return SpalshState(status: status ?? this.status);
  }
}
