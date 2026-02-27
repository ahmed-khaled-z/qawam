import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import '../../domain/entities/feature_request.dart';

class FeatureRequestModel {
  final String id;
  final String userId;
  final String message;
  final String? additionalNotes;
  final DateTime createdAt;
  final FeatureRequestStatus status;

  const FeatureRequestModel({
    required this.id,
    required this.userId,
    required this.message,
    this.additionalNotes,
    required this.createdAt,
    this.status = FeatureRequestStatus.pending,
  });

  factory FeatureRequestModel.fromEntity(FeatureRequest entity) {
    return FeatureRequestModel(
      id: entity.id,
      userId: entity.userId,
      message: entity.message,
      additionalNotes: entity.additionalNotes,
      createdAt: entity.createdAt,
      status: entity.status,
    );
  }

  FeatureRequest toEntity() => FeatureRequest(
    id: id,
    userId: userId,
    message: message,
    additionalNotes: additionalNotes,
    createdAt: createdAt,
    status: status,
  );

  factory FeatureRequestModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    final createdAt = data['createdAt'];
    return FeatureRequestModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      message: data['message'] as String? ?? '',
      additionalNotes: data['additionalNotes'] as String?,
      createdAt: createdAt is Timestamp
          ? (createdAt).toDate()
          : (createdAt is DateTime ? createdAt : DateTime.now()),
      status: FeatureRequestStatusX.fromString(data['status'] as String?),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'message': message,
    'additionalNotes': additionalNotes,
    'createdAt': Timestamp.fromDate(createdAt),
    'status': status.value,
  };
}
