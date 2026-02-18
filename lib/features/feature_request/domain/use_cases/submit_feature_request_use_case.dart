import 'package:dartz/dartz.dart';

import '../entities/feature_request.dart';
import '../repositories/feature_request_repository.dart';

class SubmitFeatureRequestUseCase {
  final FeatureRequestRepository _repository;

  SubmitFeatureRequestUseCase(this._repository);

  Future<Either<Exception, FeatureRequest>> call({
    required String message,
    String? additionalNotes,
  }) =>
      _repository.submit(message: message, additionalNotes: additionalNotes);
}
