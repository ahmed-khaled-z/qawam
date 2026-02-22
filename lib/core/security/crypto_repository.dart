import 'package:cloud_firestore/cloud_firestore.dart';

/// Info for a device in the crypto/devices subcollection.
class DeviceCryptoInfo {
  const DeviceCryptoInfo({
    required this.deviceId,
    required this.publicKeyPem,
    this.wrappedMekBase64,
    this.deviceName,
    this.authorized = false,
    this.createdAt,
  });

  final String deviceId;
  final String publicKeyPem;
  final String? wrappedMekBase64;
  final String? deviceName;
  final bool authorized;
  final DateTime? createdAt;

  factory DeviceCryptoInfo.fromFirestore(Map<String, dynamic> data, String deviceId) {
    return DeviceCryptoInfo(
      deviceId: deviceId,
      publicKeyPem: data['publicKey'] as String? ?? '',
      wrappedMekBase64: data['wrappedMEK'] as String?,
      deviceName: data['deviceName'] as String?,
      authorized: data['authorized'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'publicKey': publicKeyPem,
      if (wrappedMekBase64 != null) 'wrappedMEK': wrappedMekBase64,
      if (deviceName != null) 'deviceName': deviceName,
      'authorized': authorized,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}

/// Pending device request (new device waiting for approval).
class PendingDeviceInfo {
  const PendingDeviceInfo({
    required this.deviceId,
    required this.publicKeyPem,
    this.deviceName,
    this.createdAt,
  });

  final String deviceId;
  final String publicKeyPem;
  final String? deviceName;
  final DateTime? createdAt;

  factory PendingDeviceInfo.fromFirestore(Map<String, dynamic> data, String deviceId) {
    return PendingDeviceInfo(
      deviceId: deviceId,
      publicKeyPem: data['publicKey'] as String? ?? '',
      deviceName: data['deviceName'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'publicKey': publicKeyPem,
      if (deviceName != null) 'deviceName': deviceName,
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime.now()),
    };
  }
}

/// Abstracts Firebase reads/writes for users/{uid}/crypto/ subcollection.
abstract class CryptoRepository {
  /// List all authorized devices for the user.
  Future<List<DeviceCryptoInfo>> getDevices(String userId);

  /// Get a single device by id.
  Future<DeviceCryptoInfo?> getDevice(String userId, String deviceId);

  /// Add or update an authorized device (publicKey + wrappedMEK).
  Future<void> setDevice(
    String userId,
    String deviceId, {
    required String publicKeyPem,
    required String wrappedMekBase64,
    String? deviceName,
  });

  /// List pending device requests (new devices awaiting approval).
  Future<List<PendingDeviceInfo>> getPendingDevices(String userId);

  /// Add this device as pending (publicKey only).
  Future<void> addPendingDevice(
    String userId,
    String deviceId, {
    required String publicKeyPem,
    String? deviceName,
  });

  /// Remove a pending device (after approval or timeout).
  Future<void> removePendingDevice(String userId, String deviceId);

  /// Authorize a pending device: write to devices/ with wrappedMEK and delete from pending.
  Future<void> authorizeDevice(
    String userId,
    String deviceId, {
    required String publicKeyPem,
    required String wrappedMekBase64,
    String? deviceName,
  });

  /// Stream a device document (for new device waiting for wrappedMEK).
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDevice(
    String userId,
    String deviceId,
  );

  /// Stream pending devices (for authorized device to show approval list).
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPendingDevices(String userId);
}
