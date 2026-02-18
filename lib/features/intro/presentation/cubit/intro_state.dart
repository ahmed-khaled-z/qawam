
enum IntroStatus {
  initial,
  loading,
  loaded,
  error,
}

class IntroState {
  final IntroStatus status;
  final String? errorMessage;

  const IntroState({
    required this.status,
    this.errorMessage,
  });

  IntroState copyWith({
    IntroStatus? status,
    String? errorMessage,
  }) {
    return IntroState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
