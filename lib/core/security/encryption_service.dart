import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uuid/uuid.dart';

import 'crypto_repository.dart';
import 'rsa_key_utils.dart';

/// Lifecycle state of the encryption service.
enum EncryptionState {
  uninitialized,
  bootstrap,
  awaitingAuthorization,
  ready,
  failed,
  needsMigration,
}

/// E2EE encryption service with multi-device key wrapping.
/// - Bootstrap: first device generates RSA + MEK, uploads to Firebase.
/// - New device: creates pending request, waits for authorized device to wrap MEK.
/// - Returning device: loads MEK from secure storage (no Firebase).
class EncryptionService {
  EncryptionService({CryptoRepository? cryptoRepository})
      : _cryptoRepository = cryptoRepository;

  final CryptoRepository? _cryptoRepository;
  static const _storageKeyMek = 'qawam_mek';
  static const _storageKeyPrivateKey = 'qawam_private_key';
  static const _storageKeyDeviceId = 'qawam_device_id';
  static const _storageKeyLegacyKey = 'qawam_encryption_key';

  final _storage = const FlutterSecureStorage();

  EncryptionState _state = EncryptionState.uninitialized;
  EncryptionState get state => _state;

  /// True when encrypt/decrypt can be used (MEK is loaded).
  bool get isReady => _state == EncryptionState.ready;

  /// Legacy key (base64) for migration; only set when old key exists and new MEK not yet.
  String? _legacyKeyBase64;

  late encrypt.Key _key;
  late encrypt.Encrypter _encrypter;

  /// Initialize from secure storage only. Does not touch Firebase.
  /// Call [ensureReady] after login to bootstrap or join as new device.
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
        debugPrint('EncryptionService: Loaded legacy key (Ready, migration available).');
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

  /// Call after login with current user id. Bootstraps first device, or starts new-device flow.
  /// Requires [CryptoRepository] to be registered.
  Future<void> ensureReady(String userId) async {
    if (_state == EncryptionState.ready) return;
    final repo = _cryptoRepository;
    if (repo == null) {
      debugPrint('EncryptionService: No CryptoRepository, cannot ensureReady.');
      return;
    }

    try {
      final deviceId = await _storage.read(key: _storageKeyDeviceId);
      final devices = await repo.getDevices(userId);

      if (deviceId != null && devices.any((d) => d.deviceId == deviceId)) {
        final device = await repo.getDevice(userId, deviceId);
        if (device?.wrappedMekBase64 != null) {
          await _unwrapMekAndStore(device!.wrappedMekBase64!);
          _state = EncryptionState.ready;
          debugPrint('EncryptionService: Unwrapped MEK for returning device (Ready).');
          return;
        }
      }

      if (devices.isEmpty) {
        await _bootstrap(userId, repo);
        return;
      }

      _state = EncryptionState.awaitingAuthorization;
      debugPrint('EncryptionService: New device, awaiting authorization.');
    } catch (e) {
      debugPrint('EncryptionService: ensureReady failed: $e');
      _state = EncryptionState.failed;
      rethrow;
    }
  }

  Future<void> _bootstrap(String userId, CryptoRepository repo) async {
    _state = EncryptionState.bootstrap;
    try {
      final keyPair = generateRsaKeyPair();
      final mekBytes = encrypt.Key.fromSecureRandom(32).bytes;
      final mekBase64 = base64Url.encode(mekBytes);
      final deviceId = const Uuid().v4();

      final publicKeyPem = encodePublicKeyToPem(keyPair.publicKey);
      final privateKeyPem = encodePrivateKeyToPem(
        keyPair.privateKey,
        BigInt.from(65537),
      );

      final wrappedMek = _wrapMekWithPublicKey(mekBytes, keyPair.publicKey);

      await _storage.write(key: _storageKeyDeviceId, value: deviceId);
      await _storage.write(key: _storageKeyPrivateKey, value: privateKeyPem);
      await _storage.write(key: _storageKeyMek, value: mekBase64);

      await repo.setDevice(
        userId,
        deviceId,
        publicKeyPem: publicKeyPem,
        wrappedMekBase64: wrappedMek,
        deviceName: _defaultDeviceName(),
      );

      _key = encrypt.Key(Uint8List.fromList(mekBytes));
      _encrypter = encrypt.Encrypter(
        encrypt.AES(_key, mode: encrypt.AESMode.cbc),
      );
      _state = EncryptionState.ready;
      debugPrint('EncryptionService: Bootstrap done (Ready).');
    } catch (e) {
      debugPrint('EncryptionService: Bootstrap failed: $e');
      _state = EncryptionState.failed;
      rethrow;
    }
  }

  /// Start new-device flow: generate keypair, add pending device, return verification code.
  /// [onApproved] is called when this device receives wrapped MEK and becomes ready.
  Future<String> startNewDeviceAuthorization(String userId) async {
    final repo = _cryptoRepository;
    if (repo == null) throw StateError('CryptoRepository not set');

    final keyPair = generateRsaKeyPair();
    final deviceId = const Uuid().v4();
    final publicKeyPem = encodePublicKeyToPem(keyPair.publicKey);
    final privateKeyPem = encodePrivateKeyToPem(
      keyPair.privateKey,
      BigInt.from(65537),
    );

    await _storage.write(key: _storageKeyDeviceId, value: deviceId);
    await _storage.write(key: _storageKeyPrivateKey, value: privateKeyPem);

    await repo.addPendingDevice(
      userId,
      deviceId,
      publicKeyPem: publicKeyPem,
      deviceName: _defaultDeviceName(),
    );

    _pendingPrivateKeyPem = privateKeyPem;
    _pendingDeviceId = deviceId;
    return _verificationCodeFromPublicKey(publicKeyPem);
  }

  String? _pendingPrivateKeyPem;
  String? _pendingDeviceId;

  /// Derive 6-digit verification code from public key fingerprint.
  String _verificationCodeFromPublicKey(String publicKeyPem) {
    final bytes = utf8.encode(publicKeyPem);
    final digest = sha256.convert(bytes).bytes;
    final hex = digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final num = BigInt.parse(hex.substring(0, 12), radix: 16);
    return (num % BigInt.from(1000000)).toString().padLeft(6, '0');
  }

  /// Watch for this device to be authorized; when wrappedMEK appears, unwrap and set ready.
  Stream<EncryptionState> watchAuthorization(String userId) async* {
    final repo = _cryptoRepository;
    final deviceId = _pendingDeviceId;
    final privateKeyPem = _pendingPrivateKeyPem;
    if (repo == null || deviceId == null || privateKeyPem == null) {
      yield _state;
      return;
    }

    await for (final snapshot in repo.watchDevice(userId, deviceId)) {
      if (!snapshot.exists) continue;
      final data = snapshot.data();
      final wrapped = data?['wrappedMEK'] as String?;
      if (wrapped == null || wrapped.isEmpty) continue;

      try {
        await _unwrapMekWithPrivateKey(wrapped, privateKeyPem);
        _state = EncryptionState.ready;
        _pendingPrivateKeyPem = null;
        _pendingDeviceId = null;
        yield _state;
        return;
      } catch (e) {
        debugPrint('EncryptionService: Unwrap on approval failed: $e');
      }
    }
  }

  Future<void> _unwrapMekAndStore(String wrappedMekBase64) async {
    final privateKeyPem = await _storage.read(key: _storageKeyPrivateKey);
    if (privateKeyPem == null) throw StateError('No private key in storage');
    await _unwrapMekWithPrivateKey(wrappedMekBase64, privateKeyPem);
  }

  Future<void> _unwrapMekWithPrivateKey(String wrappedMekBase64, String privateKeyPem) async {
    final key = parseKeyFromPem(privateKeyPem);
    if (key is! RSAPrivateKey) throw StateError('Expected private key');
    final enc = encrypt.Encrypter(encrypt.RSA(
      privateKey: key,
      encoding: encrypt.RSAEncoding.OAEP,
      digest: encrypt.RSADigest.SHA256,
    ));
    final encrypted = encrypt.Encrypted.fromBase64(wrappedMekBase64);
    final mekBytes = Uint8List.fromList(enc.decryptBytes(encrypted));
    final mekBase64 = base64Url.encode(mekBytes);
    await _storage.write(key: _storageKeyMek, value: mekBase64);
    _key = encrypt.Key(mekBytes);
    _encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
  }

  String _wrapMekWithPublicKey(Uint8List mekBytes, RSAPublicKey publicKey) {
    final enc = encrypt.Encrypter(encrypt.RSA(
      publicKey: publicKey,
      encoding: encrypt.RSAEncoding.OAEP,
      digest: encrypt.RSADigest.SHA256,
    ));
    final encrypted = enc.encryptBytes(mekBytes);
    return base64.encode(encrypted.bytes);
  }

  String _defaultDeviceName() {
    return 'Device ${DateTime.now().toIso8601String().substring(0, 10)}';
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

  /// Cancel pending authorization and clear pending state.
  void cancelAuthorization() {
    _pendingPrivateKeyPem = null;
    _pendingDeviceId = null;
    if (_state == EncryptionState.awaitingAuthorization) {
      _state = EncryptionState.failed;
    }
  }

  /// Wrap the current MEK with the given RSA public key (PEM). Used by an authorized device to approve a new device.
  /// Throws if not ready or key cannot be parsed.
  String wrapMekForPublicKey(String publicKeyPem) {
    if (!isReady) throw StateError('EncryptionService not ready');
    final key = parseKeyFromPem(publicKeyPem);
    if (key is! RSAPublicKey) throw StateError('Expected public key');
    return _wrapMekWithPublicKey(_key.bytes, key);
  }

  /// Migrate from legacy device-bound key to E2EE: generate new RSA+MEK, upload to Firebase, switch to new key, delete legacy key.
  /// Call when [hasLegacyKey] is true. Caller must re-write all expenses to Hive after this so they are re-encrypted with the new MEK.
  Future<void> runMigrationFromLegacyKey(String userId) async {
    final repo = _cryptoRepository;
    if (!hasLegacyKey || repo == null) {
      throw StateError('Migration only when hasLegacyKey and CryptoRepository set');
    }
    await _bootstrap(userId, repo);
    await _storage.delete(key: _storageKeyLegacyKey);
    _legacyKeyBase64 = null;
    debugPrint('EncryptionService: Migration from legacy key completed.');
  }
}
