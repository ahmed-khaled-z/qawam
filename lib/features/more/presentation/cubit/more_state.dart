
enum MoreStatus {
  initial,
  loading,
  loaded,
  error,
}

class MoreState {
  final MoreStatus status;
  final String? errorMessage;

  const MoreState({
    required this.status,
    this.errorMessage,
  });

  MoreState copyWith({
    MoreStatus? status,
    String? errorMessage,
  }) {
    return MoreState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
