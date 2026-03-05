import 'package:equatable/equatable.dart';

/// Status of a feature suggestion for admin workflow.
enum FeatureRequestStatus { pending, approved, rejected, implemented }

extension FeatureRequestStatusX on FeatureRequestStatus {
  String get value {
    switch (this) {
      case FeatureRequestStatus.pending:
        return 'pending';
      case FeatureRequestStatus.approved:
        return 'approved';
      case FeatureRequestStatus.rejected:
        return 'rejected';
      case FeatureRequestStatus.implemented:
        return 'implemented';
    }
  }

  static FeatureRequestStatus fromString(String? v) {
    switch (v) {
      case 'approved':
        return FeatureRequestStatus.approved;
      case 'rejected':
        return FeatureRequestStatus.rejected;
      case 'implemented':
        return FeatureRequestStatus.implemented;
      default:
        return FeatureRequestStatus.pending;
    }
  }
}

class FeatureRequest extends Equatable {
  final String id;
  final String userId;
  final String message;
  final String? additionalNotes;
  final DateTime createdAt;
  final FeatureRequestStatus status;

  const FeatureRequest({
    required this.id,
    required this.userId,
    required this.message,
    this.additionalNotes,
    required this.createdAt,
    this.status = FeatureRequestStatus.pending,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    message,
    additionalNotes,
    createdAt,
    status,
  ];
}
