import '../../domain/entities/feature_request.dart';

enum FeatureRequestSubmitStatus { initial, loading, success, failure }

class FeatureRequestState {
  final List<FeatureRequest> requests;
  final FeatureRequestSubmitStatus submitStatus;
  final String? submitError;
  final bool canSubmit; // cooldown / prevent rapid submit

  const FeatureRequestState({
    this.requests = const [],
    this.submitStatus = FeatureRequestSubmitStatus.initial,
    this.submitError,
    this.canSubmit = true,
  });

  FeatureRequestState copyWith({
    List<FeatureRequest>? requests,
    FeatureRequestSubmitStatus? submitStatus,
    String? submitError,
    bool? canSubmit,
  }) {
    return FeatureRequestState(
      requests: requests ?? this.requests,
      submitStatus: submitStatus ?? this.submitStatus,
      submitError: submitError,
      canSubmit: canSubmit ?? this.canSubmit,
    );
  }
}
