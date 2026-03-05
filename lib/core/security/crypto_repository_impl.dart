import 'package:cloud_firestore/cloud_firestore.dart';

import 'crypto_repository.dart';

/// Firebase implementation of [CryptoRepository].
/// Uses Firestore: users/{userId}/crypto/mek for wrapped MEK,
/// users/{userId}/crypto_recovery/recovery for recovery blob.
class CryptoRepositoryImpl implements CryptoRepository {
  CryptoRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  static const String _cryptoCollection = 'crypto';
  static const String _mekDoc = 'mek';
  static const String _recoveryCollection = 'crypto_recovery';
  static const String _recoveryDoc = 'recovery';

  DocumentReference<Map<String, dynamic>> _mekRef(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection(_cryptoCollection)
      .doc(_mekDoc);

  DocumentReference<Map<String, dynamic>> _recoveryRef(String userId) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection(_recoveryCollection)
          .doc(_recoveryDoc);

  @override
  Future<WrappedMekBlob?> getWrappedMek(String userId) async {
    final doc = await _mekRef(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    final wrapped = data['wrappedMek'] as String?;
    final salt = data['salt'] as String?;
    if (wrapped == null || salt == null) return null;
    return WrappedMekBlob(wrappedMekBase64: wrapped, saltBase64: salt);
  }

  @override
  Future<void> setWrappedMek(
    String userId, {
    required String wrappedMekBase64,
    required String saltBase64,
  }) async {
    await _mekRef(userId).set({
      'wrappedMek': wrappedMekBase64,
      'salt': saltBase64,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<bool> hasRecoveryBlob(String userId) async {
    final doc = await _recoveryRef(userId).get();
    return doc.exists && doc.data()?['recoveryBlob'] != null;
  }

  @override
  Future<RecoveryBlob?> getRecoveryBlob(String userId) async {
    final doc = await _recoveryRef(userId).get();
    if (!doc.exists) return null;
    return _parseRecoveryBlob(doc.data());
  }

  RecoveryBlob? _parseRecoveryBlob(Map<String, dynamic>? data) {
    if (data == null) return null;
    final blob = data['recoveryBlob'] as String?;
    final salt = data['salt'] as String?;
    final params = data['kdfParams'] as Map<String, dynamic>?;
    if (blob == null || salt == null || params == null) return null;
    return RecoveryBlob(
      recoveryBlobBase64: blob,
      saltBase64: salt,
      kdfParams: params,
    );
  }

  @override
  Future<void> setRecoveryBlob(
    String userId, {
    required String recoveryBlobBase64,
    required String saltBase64,
    required Map<String, dynamic> kdfParams,
  }) async {
    await _recoveryRef(userId).set({
      'recoveryBlob': recoveryBlobBase64,
      'salt': saltBase64,
      'kdfParams': kdfParams,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteRecoveryBlob(String userId) async {
    await _recoveryRef(userId).delete();
  }
}
