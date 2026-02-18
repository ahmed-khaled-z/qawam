import 'package:dartz/dartz.dart';

import '../../domain/entities/feature_request.dart';
import '../../domain/repositories/feature_request_repository.dart';
import '../data_sources/feature_request_remote_data_source.dart';

class FeatureRequestRepositoryImpl implements FeatureRequestRepository {
  final FeatureRequestRemoteDataSource _remote;

  FeatureRequestRepositoryImpl({required FeatureRequestRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<Either<Exception, FeatureRequest>> submit({
    required String message,
    String? additionalNotes,
  }) async {
    try {
      final model = await _remote.submit(
        message: message,
        additionalNotes: additionalNotes,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Stream<List<FeatureRequest>> streamMyRequests() {
    return _remote.streamMyRequests().map(
        (models) => models.map<FeatureRequest>((m) => m.toEntity()).toList());
  }
}
