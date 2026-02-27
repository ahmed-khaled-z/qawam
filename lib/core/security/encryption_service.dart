import 'dart:convert';

import 'package:argon2/argon2.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'crypto_repository.dart';

/// Lifecycle state of the encryption service.
enum EncryptionState { uninitialized, ready, failed }

/// AES-256 encryption service with Firebase-synced MEK.
///
/// **How multi-device works (no device authorization needed):**
/// 1. First login: generate random MEK, derive wrapping key from user UID + salt
///    via Argon2id, wrap MEK, upload wrapped MEK + salt to Firebase.
/// 2. New device login: download wrapped MEK + salt, derive same wrapping key
///    from UID + salt, unwrap MEK, store in secure storage.
/// 3. Returning device: load MEK from secure storage (offline capable).
///
/// The user's UID is available after Google Sign-In and is stable across devices.
/// The wrapping key is never stored — it's derived at runtime.
class EncryptionService {
  EncryptionService({CryptoRepository? cryptoRepository})
    : _cryptoRepository = cryptoRepository;

  final CryptoRepository? _cryptoRepository;
  static const _storageKeyMek = 'qawam_mek';
  static const _storageKeyLegacyKey = 'qawam_encryption_key';

  // Argon2id KDF parameters for wrapping key derivation.
  static const int _argon2Iterations = 3;
  static const int _argon2MemoryPowerOf2 = 16; // 64 MB
  static const int _argon2Lanes = 2;

  final _storage = const FlutterSecureStorage();

  EncryptionState _state = EncryptionState.uninitialized;
  EncryptionState get state => _state;

  /// True when encrypt/decrypt can be used (MEK is loaded).
  bool get isReady => _state == EncryptionState.ready;

  /// Raw MEK bytes (for recovery blob creation). Null if not ready.
  Uint8List? get mekBytes =>
      _state == EncryptionState.ready ? _key.bytes : null;

  /// Legacy key (base64) for migration; only set when old key exists and new MEK not yet.
  String? _legacyKeyBase64;

  late encrypt.Key _key;
  late encrypt.Encrypter _encrypter;

  /// Initialize from secure storage only. Does not touch Firebase.
  /// Call [ensureReady] after login to bootstrap or fetch from Firebase.
  Future<void> init() async {
    try {
      final mek = await _storage.read(key: _storageKeyMek);
      final legacyKey = await _storage.read(key: _storageKeyLegacyKey);

      if (mek != null && mek.isNotEmpty) {
        _key = encrypt.Key(base64Url.decode(mek));
        _encrypter = encrypt.Encrypter(
          encrypt.AES(_key, mode: encrypt.AESMode.cbc),
        );
        _state = EncryptionState.ready;
        debugPrint('EncryptionService: Loaded MEK from storage (Ready).');
        return;
      }

      if (legacyKey != null && legacyKey.isNotEmpty) {
        _legacyKeyBase64 = legacyKey;
        _key = encrypt.Key(base64Url.decode(legacyKey));
        _encrypter = encrypt.Encrypter(
          encrypt.AES(_key, mode: encrypt.AESMode.cbc),
        );
        _state = EncryptionState.ready;
        debugPrint(
          'EncryptionService: Loaded legacy key (Ready, migration available).',
        );
        return;
      }

      _state = EncryptionState.uninitialized;
      debugPrint('EncryptionService: No keys in storage (Uninitialized).');
    } catch (e) {
      debugPrint('EncryptionService: Error in init: $e');
      _state = EncryptionState.failed;
      rethrow;
    }
  }

  /// Returns true if this install has a legacy device-bound key (pre-E2EE).
  bool get hasLegacyKey => _legacyKeyBase64 != null;

  /// Call after login with current user's UID.
  ///
  /// Flow:
  /// 1. If already ready (MEK in secure storage), return immediately.
  /// 2. Try to download wrapped MEK from Firebase → unwrap → store.
  /// 3. If no wrapped MEK exists in Firebase, generate new MEK → wrap → upload.
  Future<void> ensureReady(String userId) async {
    if (_state == EncryptionState.ready) return;
    final repo = _cryptoRepository;
    if (repo == null) {
      debugPrint('EncryptionService: No CryptoRepository, cannot ensureReady.');
      return;
    }

    try {
      // Try to fetch existing wrapped MEK from Firebase
      final blob = await repo.getWrappedMek(userId);

      if (blob != null) {
        // Derive wrapping key from UID + stored salt
        final salt = base64Url.decode(blob.saltBase64);
        final wrappingKey = _deriveWrappingKey(userId, salt);

        // Unwrap MEK
        final wrappedMekBytes = base64Url.decode(blob.wrappedMekBase64);
        final mekBytes = _unwrapMek(wrappedMekBytes, wrappingKey);

        if (mekBytes != null) {
          await _storeMekAndInit(mekBytes);
          debugPrint(
            'EncryptionService: Downloaded and unwrapped MEK from Firebase (Ready).',
          );
          return;
        } else {
          debugPrint(
            'EncryptionService: Failed to unwrap MEK from Firebase. '
            'Generating new MEK.',
          );
        }
      }

      // No wrapped MEK in Firebase — this is the first device. Bootstrap.
      await _bootstrap(userId, repo);
    } catch (e) {
      debugPrint('EncryptionService: ensureReady failed: $e');
      _state = EncryptionState.failed;
      rethrow;
    }
  }

  /// Generate new MEK, wrap with UID-derived key, upload to Firebase.
  Future<void> _bootstrap(String userId, CryptoRepository repo) async {
    try {
      // Generate random 256-bit MEK
      final mekBytes = encrypt.Key.fromSecureRandom(32).bytes;

      // Generate random salt for KDF
      final salt = encrypt.Key.fromSecureRandom(32).bytes;

      // Derive wrapping key
      final wrappingKey = _deriveWrappingKey(userId, salt);

      // Wrap MEK
      final wrappedMek = _wrapMek(mekBytes, wrappingKey);

      // Upload to Firebase
      await repo.setWrappedMek(
        userId,
        wrappedMekBase64: base64Url.encode(wrappedMek),
        saltBase64: base64Url.encode(salt),
      );

      // Store MEK locally
      await _storeMekAndInit(Uint8List.fromList(mekBytes));
      debugPrint('EncryptionService: Bootstrap done (Ready).');
    } catch (e) {
      debugPrint('EncryptionService: Bootstrap failed: $e');
      _state = EncryptionState.failed;
      rethrow;
    }
  }

  /// Derive a 256-bit wrapping key from user UID and salt using Argon2id.
  Uint8List _deriveWrappingKey(String userId, Uint8List salt) {
    final argon2Params = Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      salt,
      iterations: _argon2Iterations,
      memoryPowerOf2: _argon2MemoryPowerOf2,
      lanes: _argon2Lanes,
      version: Argon2Parameters.ARGON2_VERSION_13,
    );

    final generator = Argon2BytesGenerator();
    generator.init(argon2Params);

    final inputBytes = Uint8List.fromList(utf8.encode(userId));
    final result = Uint8List(32);
    generator.generateBytes(inputBytes, result, 0, result.length);

    return result;
  }

  /// AES-wrap (AES-CBC encrypt) the MEK with the wrapping key.
  /// Format: IV (16 bytes) + ciphertext.
  Uint8List _wrapMek(Uint8List mekBytes, Uint8List wrappingKey) {
    final key = encrypt.Key(wrappingKey);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = encrypter.encryptBytes(mekBytes, iv: iv);
    return Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
  }

  /// AES-unwrap the MEK with the wrapping key. Returns null on failure.
  Uint8List? _unwrapMek(Uint8List wrappedBytes, Uint8List wrappingKey) {
    if (wrappedBytes.length < 32) return null; // IV(16) + at least 16 bytes
    try {
      final iv = encrypt.IV(Uint8List.sublistView(wrappedBytes, 0, 16));
      final cipherBytes = Uint8List.sublistView(wrappedBytes, 16);
      final key = encrypt.Key(wrappingKey);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      final encrypted = encrypt.Encrypted(Uint8List.fromList(cipherBytes));
      return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
    } catch (e) {
      debugPrint('EncryptionService: _unwrapMek failed: $e');
      return null;
    }
  }

  /// Store MEK in secure storage and initialize the AES encrypter.
  Future<void> _storeMekAndInit(Uint8List mekBytes) async {
    final mekBase64 = base64Url.encode(mekBytes);
    await _storage.write(key: _storageKeyMek, value: mekBase64);
    _key = encrypt.Key(mekBytes);
    _encrypter = encrypt.Encrypter(
      encrypt.AES(_key, mode: encrypt.AESMode.cbc),
    );
    _state = EncryptionState.ready;
  }

  /// Encrypts a double value. Returns Base64 string: IV:CIPHERTEXT.
  String encryptValue(double value) {
    if (!isReady) throw StateError('EncryptionService not ready');
    final plainText = value.toString();
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts IV:CIPHERTEXT back to double.
  double decryptValue(String encryptedString) {
    if (!isReady) throw StateError('EncryptionService not ready');
    try {
      final parts = encryptedString.split(':');
      if (parts.length != 2) throw FormatException('Invalid encrypted format');
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      final decrypted = _encrypter.decrypt(encrypted, iv: iv);
      return double.parse(decrypted);
    } catch (e) {
      debugPrint('EncryptionService: Decryption failed: $e');
      rethrow;
    }
  }

  bool isEncrypted(String value) => value.contains(':');

  /// Import MEK from recovery (passphrase decryption). Call after successful recovery.
  /// Stores MEK in secure storage and sets state to ready.
  Future<void> importMekFromRecovery(String userId, Uint8List mekBytes) async {
    await _storeMekAndInit(mekBytes);
    debugPrint('EncryptionService: MEK imported from recovery (Ready).');

    // Re-upload wrapped MEK to Firebase so future devices can access it
    final repo = _cryptoRepository;
    if (repo != null) {
      try {
        final salt = encrypt.Key.fromSecureRandom(32).bytes;
        final wrappingKey = _deriveWrappingKey(userId, salt);
        final wrappedMek = _wrapMek(mekBytes, wrappingKey);
        await repo.setWrappedMek(
          userId,
          wrappedMekBase64: base64Url.encode(wrappedMek),
          saltBase64: base64Url.encode(salt),
        );
        debugPrint(
          'EncryptionService: Re-uploaded wrapped MEK after recovery.',
        );
      } catch (e) {
        debugPrint(
          'EncryptionService: Failed to re-upload MEK after recovery: $e',
        );
      }
    }
  }

  /// Migrate from legacy device-bound key to new MEK system.
  /// Generates new MEK, uploads to Firebase, deletes legacy key.
  /// Caller must re-write all expenses to Hive after this so they are
  /// re-encrypted with the new MEK.
  Future<void> runMigrationFromLegacyKey(String userId) async {
    final repo = _cryptoRepository;
    if (!hasLegacyKey || repo == null) {
      throw StateError(
        'Migration only when hasLegacyKey and CryptoRepository set',
      );
    }
    await _bootstrap(userId, repo);
    await _storage.delete(key: _storageKeyLegacyKey);
    _legacyKeyBase64 = null;
    debugPrint('EncryptionService: Migration from legacy key completed.');
  }
}
