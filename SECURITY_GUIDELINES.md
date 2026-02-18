# Qawam Security Guidelines

## Encryption

All user data stored locally **must** be encrypted using `EncryptionService`. This ensures that even with device access or a database dump, the data remains unreadable.

### Usage

```dart
import 'package:qawam/core/security/encryption_service.dart';

final encryption = EncryptionService();
await encryption.init();

// Encrypt
final encrypted = encryption.encryptData('sensitive data');

// Decrypt
final decrypted = encryption.decryptData(encrypted);

// JSON
final encryptedJson = encryption.encryptJson({'amount': 150, 'note': 'Groceries'});
final data = encryption.decryptJson(encryptedJson);
```

### Key Storage
- **Android**: EncryptedSharedPreferences (AES-256)
- **iOS**: Keychain Services
- Key is auto-generated on first launch and never leaves the device

## Authentication
- Firebase Authentication handles all session management
- Tokens are managed by the Firebase SDK — never stored manually
- `AuthManager` persists only non-sensitive user profile info (name, email, photo URL)

## Development Rules

1. **Never log PII** (names, emails, financial data) — not even in debug mode
2. **Always use `EncryptionService`** for any data written to disk
3. **Use `flutter_secure_storage`** for tokens, API keys, and secrets
4. **Never hardcode** credentials, API keys, or secrets in source code
5. **Validate all inputs** before processing or storing
6. **Use HTTPS** exclusively for all network requests
7. **Handle errors gracefully** — never expose stack traces or internal details to users
