import '../entities/feature_request.dart';
import '../repositories/feature_request_repository.dart';

class StreamMyFeatureRequestsUseCase {
  final FeatureRequestRepository _repository;

  StreamMyFeatureRequestsUseCase(this._repository);

  Stream<List<FeatureRequest>> call() => _repository.streamMyRequests();
}
