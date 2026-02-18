import 'package:dartz/dartz.dart';

import '../entities/feature_request.dart';

abstract class FeatureRequestRepository {
  /// Submit a new feature suggestion.
  Future<Either<Exception, FeatureRequest>> submit({
    required String message,
    String? additionalNotes,
  });

  /// Stream the current user's suggestions (real-time).
  Stream<List<FeatureRequest>> streamMyRequests();
}
