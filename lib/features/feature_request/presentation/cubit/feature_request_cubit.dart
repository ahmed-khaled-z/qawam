import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/feature_request.dart';
import '../../domain/use_cases/submit_feature_request_use_case.dart';
import '../../domain/use_cases/stream_my_feature_requests_use_case.dart';
import 'feature_request_state.dart';

class FeatureRequestCubit extends Cubit<FeatureRequestState> {
  final SubmitFeatureRequestUseCase _submitUseCase;
  final StreamMyFeatureRequestsUseCase _streamUseCase;
  StreamSubscription<List<FeatureRequest>>? _subscription;

  FeatureRequestCubit({
    required SubmitFeatureRequestUseCase submitUseCase,
    required StreamMyFeatureRequestsUseCase streamUseCase,
  }) : _submitUseCase = submitUseCase,
       _streamUseCase = streamUseCase,
       super(const FeatureRequestState()) {
    _subscribeToMyRequests();
  }

  void _subscribeToMyRequests() {
    _subscription?.cancel();
    _subscription = _streamUseCase().listen(
      (requests) => emit(state.copyWith(requests: requests)),
      onError: (e, st) {
        debugPrint('[FeatureRequestCubit] stream error: $e');
        if (kDebugMode && st != null) debugPrintStack(stackTrace: st);
        emit(state.copyWith(requests: []));
      },
    );
  }

  Future<void> submit({
    required String message,
    String? additionalNotes,
  }) async {
    if (!state.canSubmit) return;

    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      emit(
        state.copyWith(
          submitStatus: FeatureRequestSubmitStatus.failure,
          submitError: 'Message is required',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        submitStatus: FeatureRequestSubmitStatus.loading,
        submitError: null,
        canSubmit: false,
      ),
    );

    final result = await _submitUseCase(
      message: trimmedMessage,
      additionalNotes: additionalNotes?.trim().isEmpty ?? true
          ? null
          : additionalNotes?.trim(),
    );

    result.fold(
      (e) => emit(
        state.copyWith(
          submitStatus: FeatureRequestSubmitStatus.failure,
          submitError: e.toString(),
          canSubmit: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          submitStatus: FeatureRequestSubmitStatus.success,
          submitError: null,
          canSubmit: true,
        ),
      ),
    );

    // Cooldown: allow submit again after 3 seconds even if success
    Future.delayed(const Duration(seconds: 3), () {
      if (state.submitStatus == FeatureRequestSubmitStatus.success) {
        emit(state.copyWith(submitStatus: FeatureRequestSubmitStatus.initial));
      }
    });
  }

  void clearSubmitState() {
    emit(
      state.copyWith(
        submitStatus: FeatureRequestSubmitStatus.initial,
        submitError: null,
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
