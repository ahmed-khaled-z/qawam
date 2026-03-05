import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/feature_request.dart';
import '../models/feature_request_model.dart';

abstract class FeatureRequestRemoteDataSource {
  Future<FeatureRequestModel> submit({
    required String message,
    String? additionalNotes,
  });

  Stream<List<FeatureRequestModel>> streamMyRequests();
}

class FeatureRequestRemoteDataSourceImpl
    implements FeatureRequestRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FeatureRequestRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('feature_requests');

  @override
  Future<FeatureRequestModel> submit({
    required String message,
    String? additionalNotes,
  }) async {
    final user = _currentUser;
    if (user == null) throw Exception('No authenticated user');

    try {
      final ref = _collection.doc();
      final model = FeatureRequestModel(
        id: ref.id,
        userId: user.uid,
        message: message.trim(),
        additionalNotes: additionalNotes?.trim().isEmpty ?? true
            ? null
            : additionalNotes?.trim(),
        createdAt: DateTime.now(),
        status: FeatureRequestStatus.pending,
      );

      await ref.set(model.toFirestore());
      return model;
    } catch (e) {
      debugPrint('[FeatureRequest] Submit failed: $e');
      rethrow;
    }
  }

  @override
  Stream<List<FeatureRequestModel>> streamMyRequests() {
    final user = _currentUser;
    if (user == null) return Stream.value([]);

    // Query by userId only (no orderBy) so no composite index is required.
    // Sort by createdAt descending in Dart.
    return _collection.where('userId', isEqualTo: user.uid).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs
          .map((doc) => FeatureRequestModel.fromFirestore(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
