import 'package:cloud_firestore/cloud_firestore.dart';

import 'crypto_repository.dart';

/// Firebase implementation of [CryptoRepository].
/// Uses Firestore: users/{userId}/crypto_devices/{deviceId}, users/{userId}/crypto_pending/{deviceId}.
class CryptoRepositoryImpl implements CryptoRepository {
  CryptoRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  static const String _devicesCollection = 'crypto_devices';
  static const String _pendingCollection = 'crypto_pending';

  CollectionReference<Map<String, dynamic>> _devices(String userId) =>
      _firestore.collection('users').doc(userId).collection(_devicesCollection);

  CollectionReference<Map<String, dynamic>> _pending(String userId) =>
      _firestore.collection('users').doc(userId).collection(_pendingCollection);

  @override
  Future<List<DeviceCryptoInfo>> getDevices(String userId) async {
    final snapshot = await _devices(userId).get();
    return snapshot.docs
        .map((d) => DeviceCryptoInfo.fromFirestore(d.data(), d.id))
        .toList();
  }

  @override
  Future<DeviceCryptoInfo?> getDevice(String userId, String deviceId) async {
    final doc = await _devices(userId).doc(deviceId).get();
    if (!doc.exists || doc.data() == null) return null;
    return DeviceCryptoInfo.fromFirestore(doc.data()!, doc.id);
  }

  @override
  Future<void> setDevice(
    String userId,
    String deviceId, {
    required String publicKeyPem,
    required String wrappedMekBase64,
    String? deviceName,
  }) async {
    final data = {
      'publicKey': publicKeyPem,
      'wrappedMEK': wrappedMekBase64,
      'deviceName': ?deviceName,
      'authorized': true,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _devices(userId).doc(deviceId).set(data);
  }

  @override
  Future<List<PendingDeviceInfo>> getPendingDevices(String userId) async {
    final snapshot = await _pending(userId).get();
    return snapshot.docs
        .map((d) => PendingDeviceInfo.fromFirestore(d.data(), d.id))
        .toList();
  }

  @override
  Future<void> addPendingDevice(
    String userId,
    String deviceId, {
    required String publicKeyPem,
    String? deviceName,
  }) async {
    final data = {
      'publicKey': publicKeyPem,
      'deviceName': ?deviceName,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _pending(userId).doc(deviceId).set(data);
  }

  @override
  Future<void> removePendingDevice(String userId, String deviceId) async {
    await _pending(userId).doc(deviceId).delete();
  }

  @override
  Future<void> authorizeDevice(
    String userId,
    String deviceId, {
    required String publicKeyPem,
    required String wrappedMekBase64,
    String? deviceName,
  }) async {
    await setDevice(
      userId,
      deviceId,
      publicKeyPem: publicKeyPem,
      wrappedMekBase64: wrappedMekBase64,
      deviceName: deviceName,
    );
    await removePendingDevice(userId, deviceId);
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDevice(
    String userId,
    String deviceId,
  ) {
    return _devices(userId).doc(deviceId).snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPendingDevices(
    String userId,
  ) {
    return _pending(userId).snapshots();
  }
}
