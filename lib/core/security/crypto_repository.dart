/// Wrapped MEK blob stored in Firebase.
class WrappedMekBlob {
  const WrappedMekBlob({
    required this.wrappedMekBase64,
    required this.saltBase64,
  });

  final String wrappedMekBase64;
  final String saltBase64;
}

/// Recovery blob stored in Firestore (encrypted MEK with passphrase-derived key).
class RecoveryBlob {
  const RecoveryBlob({
    required this.recoveryBlobBase64,
    required this.saltBase64,
    required this.kdfParams,
  });

  final String recoveryBlobBase64;
  final String saltBase64;
  final Map<String, dynamic> kdfParams;
}

/// Abstracts Firebase reads/writes for encryption key storage.
///
/// Stores:
/// - Wrapped MEK (AES-wrapped with UID-derived key) at users/{uid}/crypto/mek
/// - Recovery blob (AES-wrapped with passphrase-derived key) at users/{uid}/crypto_recovery/recovery
abstract class CryptoRepository {
  /// Get the wrapped MEK blob for this user (or null if not set).
  Future<WrappedMekBlob?> getWrappedMek(String userId);

  /// Store the wrapped MEK blob for this user.
  Future<void> setWrappedMek(
    String userId, {
    required String wrappedMekBase64,
    required String saltBase64,
  });

  // --- Recovery key (optional fallback for lost passphrase, etc.) ---

  /// Whether a recovery blob exists for this user.
  Future<bool> hasRecoveryBlob(String userId);

  /// Get the recovery blob (encrypted MEK) and salt for passphrase decryption.
  Future<RecoveryBlob?> getRecoveryBlob(String userId);

  /// Store the recovery blob (encrypted MEK with passphrase-derived key).
  Future<void> setRecoveryBlob(
    String userId, {
    required String recoveryBlobBase64,
    required String saltBase64,
    required Map<String, dynamic> kdfParams,
  });

  /// Remove the recovery blob (user disables recovery).
  Future<void> deleteRecoveryBlob(String userId);
}
