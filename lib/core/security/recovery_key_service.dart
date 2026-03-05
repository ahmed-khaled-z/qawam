import 'dart:convert';

import 'package:argon2/argon2.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

import 'crypto_repository.dart';
import 'encryption_service.dart';

/// KDF parameters for Argon2id (stored with recovery blob for verification).
const int kArgon2Iterations = 3;
const int kArgon2MemoryPowerOf2 = 16; // 64 MB
const int kArgon2Lanes = 2;

/// Service for recovery key setup and recovery using passphrase-derived encryption.
/// Uses Argon2id for KDF and AES-256-CBC for encrypting the MEK.
class RecoveryKeyService {
  RecoveryKeyService(this._cryptoRepository, this._encryptionService);

  final CryptoRepository _cryptoRepository;
  final EncryptionService _encryptionService;

  /// Whether a recovery blob exists for this user.
  Future<bool> hasRecoveryBlob(String userId) async {
    return _cryptoRepository.hasRecoveryBlob(userId);
  }

  /// Create recovery blob from current MEK and store in Firestore.
  /// Call when encryption is ready. Passphrase is never stored or sent.
  Future<void> setupRecovery(String userId, String passphrase) async {
    if (!_encryptionService.isReady) {
      throw StateError('Encryption not ready: cannot create recovery blob');
    }

    final salt = _generateSalt();
    final derivedKey = _deriveKey(passphrase, salt);
    final mekBytes = _encryptionService.mekBytes;
    if (mekBytes == null) throw StateError('MEK not available');

    final encrypted = _encryptWithKey(mekBytes, derivedKey);
    final kdfParams = {
      'iterations': kArgon2Iterations,
      'memoryPowerOf2': kArgon2MemoryPowerOf2,
      'lanes': kArgon2Lanes,
      'type': 'argon2id',
    };

    await _cryptoRepository.setRecoveryBlob(
      userId,
      recoveryBlobBase64: base64Url.encode(encrypted),
      saltBase64: base64Url.encode(salt),
      kdfParams: kdfParams,
    );
    debugPrint('RecoveryKeyService: Recovery blob created for user $userId');
  }

  /// Recover MEK from passphrase and store in secure storage.
  /// Returns true on success, false if passphrase is wrong.
  Future<bool> recoverWithPassphrase(String userId, String passphrase) async {
    final blob = await _cryptoRepository.getRecoveryBlob(userId);
    if (blob == null) return false;

    try {
      final salt = base64Url.decode(blob.saltBase64);
      final derivedKey = _deriveKeyFromParams(passphrase, salt, blob.kdfParams);
      final encrypted = base64Url.decode(blob.recoveryBlobBase64);
      final mekBytes = _decryptWithKey(encrypted, derivedKey);
      if (mekBytes == null) return false;

      await _encryptionService.importMekFromRecovery(userId, mekBytes);
      return true;
    } catch (e) {
      debugPrint('RecoveryKeyService: Recovery failed: $e');
      return false;
    }
  }

  /// Remove recovery blob (user disables recovery).
  Future<void> removeRecovery(String userId) async {
    await _cryptoRepository.deleteRecoveryBlob(userId);
    debugPrint('RecoveryKeyService: Recovery blob removed for user $userId');
  }

  Uint8List _generateSalt() {
    return encrypt.Key.fromSecureRandom(32).bytes;
  }

  Uint8List _deriveKey(String passphrase, Uint8List salt) {
    return _deriveKeyFromParams(passphrase, salt, {
      'iterations': kArgon2Iterations,
      'memoryPowerOf2': kArgon2MemoryPowerOf2,
      'lanes': kArgon2Lanes,
    });
  }

  Uint8List _deriveKeyFromParams(
    String passphrase,
    Uint8List salt,
    Map<String, dynamic> params,
  ) {
    final iterations = params['iterations'] as int? ?? kArgon2Iterations;
    final memoryPowerOf2 =
        params['memoryPowerOf2'] as int? ?? kArgon2MemoryPowerOf2;
    final lanes = params['lanes'] as int? ?? kArgon2Lanes;

    final argon2Params = Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      salt,
      iterations: iterations,
      memoryPowerOf2: memoryPowerOf2,
      lanes: lanes,
      version: Argon2Parameters.ARGON2_VERSION_13,
    );

    final generator = Argon2BytesGenerator();
    generator.init(argon2Params);

    final passwordBytes = Uint8List.fromList(utf8.encode(passphrase));
    final result = Uint8List(32);
    generator.generateBytes(passwordBytes, result, 0, result.length);

    return result;
  }

  Uint8List _encryptWithKey(Uint8List plainBytes, Uint8List keyBytes) {
    final key = encrypt.Key(keyBytes);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);
    // Format: IV (16) + ciphertext
    return Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
  }

  Uint8List? _decryptWithKey(Uint8List encryptedBytes, Uint8List keyBytes) {
    if (encryptedBytes.length < 32) return null; // IV(16) + at least 16 bytes
    final iv = encrypt.IV(Uint8List.sublistView(encryptedBytes, 0, 16));
    final cipherBytes = Uint8List.sublistView(encryptedBytes, 16);
    final key = encrypt.Key(keyBytes);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    try {
      final encrypted = encrypt.Encrypted(Uint8List.fromList(cipherBytes));
      return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
    } catch (_) {
      return null;
    }
  }
}
