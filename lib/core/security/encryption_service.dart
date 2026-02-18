import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class EncryptionService {
  static const _keyStorageKey = 'qawam_encryption_key';
  late final encrypt.Key _key;
  late final encrypt.Encrypter _encrypter;
  final _storage = const FlutterSecureStorage();

  bool _isInitialized = false;

  /// Initialize the service by loading or generating the encryption key.
  /// Must be called before any encryption/decryption operations.
  Future<void> init() async {
    try {
      String? keyString = await _storage.read(key: _keyStorageKey);

      if (keyString == null) {
        // Generate a new 32-byte (256-bit) key
        final key = encrypt.Key.fromSecureRandom(32);
        keyString = base64Url.encode(key.bytes);
        await _storage.write(key: _keyStorageKey, value: keyString);
        debugPrint('EncryptionService: Generated new master key.');
      } else {
        debugPrint('EncryptionService: Loaded existing master key.');
      }

      _key = encrypt.Key(base64Url.decode(keyString));
      // AES Mode: AES-GCM is preferred for authenticated encryption,
      // but AES-CBC with PKCS7 padding is standard and sufficient here.
      // Using AES-CBC for broad compatibility.
      _encrypter = encrypt.Encrypter(
        encrypt.AES(_key, mode: encrypt.AESMode.cbc),
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('EncryptionService: Error initializing: $e');
      rethrow;
    }
  }

  /// Encrypts a double value. returns Base64 encoded string containing IV + Ciphertext.
  String encryptValue(double value) {
    if (!_isInitialized) throw Exception('EncryptionService not initialized');

    final plainText = value.toString();
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(plainText, iv: iv);

    // Combine IV and Ciphertext for storage: IV_BASE64:CIPHERTEXT_BASE64
    // This allows unique IV per record which is critical for security.
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts a string (Format: IV_BASE64:CIPHERTEXT_BASE64) back to double.
  double decryptValue(String encryptedString) {
    if (!_isInitialized) throw Exception('EncryptionService not initialized');

    try {
      final parts = encryptedString.split(':');
      if (parts.length != 2) {
        throw FormatException('Invalid encrypted format');
      }

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

      final decrypted = _encrypter.decrypt(encrypted, iv: iv);
      return double.parse(decrypted);
    } catch (e) {
      debugPrint('EncryptionService: Decryption failed: $e');
      // In a real app, you might want to return null or handle this gracefully.
      // For now, rethrow or return 0.0 to avoid crash logic in UI?
      // Better to throw so we know something is wrong.
      rethrow;
    }
  }

  /// Helper to check if a string looks encrypted (contains colon)
  bool isEncrypted(String value) {
    return value.contains(':');
  }
}
