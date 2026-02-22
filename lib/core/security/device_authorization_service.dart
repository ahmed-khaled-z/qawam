import 'dart:async';

import 'package:flutter/foundation.dart';

import 'crypto_repository.dart';
import 'encryption_service.dart';

/// Handles the device authorization flow: pending requests, approval, and timeout.
class DeviceAuthorizationService {
  DeviceAuthorizationService(
    this._cryptoRepository,
    this._encryptionService,
  );

  final CryptoRepository _cryptoRepository;
  final EncryptionService _encryptionService;

  /// Pending request timeout (10 minutes).
  static const Duration pendingTimeout = Duration(minutes: 10);

  /// Start the new-device flow: register as pending, return verification code.
  /// Caller should then listen to [watchAuthorization] until state is [EncryptionState.ready].
  Future<String> startNewDeviceAuthorization(String userId) async {
    return _encryptionService.startNewDeviceAuthorization(userId);
  }

  /// Stream of encryption state while waiting for approval (e.g. ready when approved).
  Stream<EncryptionState> watchAuthorization(String userId) {
    return _encryptionService.watchAuthorization(userId);
  }

  /// Cancel the current pending authorization on this device.
  void cancelAuthorization() {
    _encryptionService.cancelAuthorization();
  }

  /// Stream of pending device requests (for the authorized device to show approval UI).
  Stream<List<PendingDeviceInfo>> watchPendingDevices(String userId) {
    return _cryptoRepository.watchPendingDevices(userId).map((snapshot) {
      final list = snapshot.docs
          .map((d) => PendingDeviceInfo.fromFirestore(d.data(), d.id))
          .toList();
      return list;
    });
  }

  /// Approve a pending device: wrap MEK with its public key and write to devices, remove from pending.
  Future<void> approveDevice(
    String userId,
    String deviceId, {
    required String publicKeyPem,
    String? deviceName,
  }) async {
    if (!_encryptionService.isReady) {
      throw StateError('Cannot approve: encryption not ready (no MEK)');
    }
    final wrappedMek = _encryptionService.wrapMekForPublicKey(publicKeyPem);
    await _cryptoRepository.authorizeDevice(
      userId,
      deviceId,
      publicKeyPem: publicKeyPem,
      wrappedMekBase64: wrappedMek,
      deviceName: deviceName,
    );
    debugPrint('DeviceAuthorizationService: Approved device $deviceId');
  }

  /// Reject (remove) a pending device request.
  Future<void> rejectPendingDevice(String userId, String deviceId) async {
    await _cryptoRepository.removePendingDevice(userId, deviceId);
  }

  /// Whether a pending request has expired (older than [pendingTimeout]).
  static bool isPendingExpired(PendingDeviceInfo pending) {
    final createdAt = pending.createdAt;
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt) > pendingTimeout;
  }

  /// Remove expired pending requests (call periodically or when listing).
  Future<void> removeExpiredPending(String userId) async {
    final pending = await _cryptoRepository.getPendingDevices(userId);
    for (final p in pending) {
      if (isPendingExpired(p)) {
        await _cryptoRepository.removePendingDevice(userId, p.deviceId);
      }
    }
  }
}
