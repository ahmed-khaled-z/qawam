# Qawam: Encryption Key Management Architecture Proposal

## Executive Summary

This document analyzes the current device-approval model in Qawam, explains why it creates usability and lockout risks, and proposes alternative key management architectures that balance security with practical recovery.

---

## Part 1: Why the Current Device-Approval Model Is Problematic

### Current Architecture (Summary)

Your implementation uses a **device-centric key wrapping** model:

1. **First device (bootstrap)**: Generates RSA keypair + MEK (Master Encryption Key), stores MEK in `FlutterSecureStorage`, uploads `wrappedMEK` (MEK encrypted with device's RSA public key) to Firestore.
2. **Returning device**: If `deviceId` in secure storage matches a device in Firestore, unwraps MEK from Firestore and proceeds.
3. **New device**: Creates pending request with public key, waits for an *authorized* device to wrap the MEK with the new device's public key and write it to `crypto_devices`.

### Critical Problems

| Problem | Impact |
|---------|--------|
| **Single point of failure** | The MEK exists only in devices that have been approved. If all approved devices are lost, the MEK is unrecoverable. |
| **Reinstall = new device** | `deviceId` is stored in secure storage. On reinstall, secure storage is wiped → new UUID → treated as new device → requires approval. |
| **Original device dependency** | Approval *must* come from a device that already has the MEK. No alternative path exists. |
| **Permanent lockout** | Lost device + no other approved device = user can never decrypt their data again. |
| **Poor UX for common flows** | Same user, same Google account, same physical device after reinstall is blocked until they find another device. |

### Root Cause

The design assumes **at least one authorized device is always available**. This is a strong assumption that fails in many real-world scenarios.

---

## Part 2: Alternative Recovery Mechanisms

### Option A: **Cloud-Backed Recovery Key (Recommended)**

**Idea**: Store a copy of the MEK encrypted with a **recovery key** derived from a user-chosen secret (e.g., passphrase or PIN). The encrypted blob is stored in Firestore. Only the user knows the secret; the server never sees the plain MEK.

**Flow**:
1. On bootstrap or first setup, user optionally creates a recovery passphrase.
2. Derive a key from passphrase (e.g., Argon2id) → encrypt MEK → store `recoveryBlob` in Firestore.
3. New device / reinstall: User enters passphrase → derive key → decrypt MEK from `recoveryBlob` → store locally.

**Pros**:
- No dependency on another device
- Survives reinstall, device loss, multi-device
- Server never sees MEK or passphrase
- User-controlled recovery

**Cons**:
- User must remember a passphrase (or store it in a password manager)
- If user forgets passphrase and loses all devices, still locked out (but by user choice)
- Requires UI for setup and recovery

**Security tradeoff**: Slightly weaker than device-only (passphrase can be phished or guessed if weak), but much better usability. Mitigate with strong KDF (Argon2id) and optional rate limiting.

---

### Option B: **Account-Based Key Derivation (No Device Approval)**

**Idea**: Derive the MEK from something tied to the authenticated account, so any device that can sign in gets the same MEK without approval.

**Flow**:
1. Use a **key derivation** approach: `MEK = KDF(serverSecret, userId, salt)` where `serverSecret` is stored in Firebase (or a separate backend) and only accessible after auth.
2. Or: `MEK = KDF(GoogleIdToken + userId + salt)` — but then MEK changes when tokens rotate, so this is tricky.
3. Simpler variant: Store `encryptedMEK` in Firestore, encrypted with a key derived from `userId + userPassword` or from a **hardware-backed credential** (e.g., Android Keystore / iOS Secure Enclave) that survives reinstall when possible.

**Pros**:
- No device approval flow
- Works across reinstalls if the derivation inputs are available

**Cons**:
- If derivation uses server-side secret: developer/backend can theoretically access the key (breaks "developer cannot decrypt" requirement).
- If derivation uses only client-side inputs: need something that survives reinstall (e.g., Google Sign-In + a user secret), which brings you back to Option A.
- Pure account-based without user secret often means the server holds a key-encryption key, which weakens E2EE.

**Security tradeoff**: True E2EE with zero server knowledge is hard with pure account-based derivation. You either need a user secret (Option A) or accept that the server could help recover (weaker model).

---

### Option C: **Hybrid: Device Wrapping + Optional Recovery Key**

**Idea**: Keep your current device-approval flow for devices that *can* approve, but add an **optional** recovery key as a fallback. Best of both worlds.

**Flow**:
1. Bootstrap: Same as now (RSA + MEK, upload wrapped MEK).
2. New device: First try device approval (current flow). If user has no other device, offer: "Set up recovery" or "Recover with passphrase."
3. Recovery setup (one-time): User sets passphrase → `recoveryBlob = Enc(MEK, KDF(passphrase))` → store in Firestore.
4. Recovery use: New device → user enters passphrase → decrypt MEK from `recoveryBlob`.

**Pros**:
- Keeps strong device-bound model when possible
- Adds recovery path for lost-device / reinstall scenarios
- User can choose not to set recovery (maximum security, higher lockout risk) or set it (better UX)

**Cons**:
- More code paths and UI
- Recovery passphrase is a new secret to manage

**Security tradeoff**: Same as Option A for the recovery path. The device path remains as strong as today.

---

### Option D: **Backup to Trusted Cloud (e.g., iCloud Keychain / Android Backup)**

**Idea**: Use platform backup (iCloud Keychain, Android Auto Backup) to back up the MEK or device keys. On reinstall, restore from backup.

**Flow**:
1. Store MEK (or device private key) in `FlutterSecureStorage` with `iOSOptions(accessibility: KeychainAccessibility.whenUnlockedThisDeviceOnly)` or equivalent.
2. On iOS: Use `kSecAttrAccessibleWhenUnlocked` and ensure app participates in Keychain backup (or use `kSecAttrAccessibleAfterFirstUnlock` for backup).
3. On Android: Use `EncryptedSharedPreferences` with Android Backup — keys may be included in backup if configured.

**Pros**:
- No extra user action
- Survives reinstall on same device (and sometimes across devices with same Apple ID / Google account)

**Cons**:
- Platform-dependent, not always reliable
- Android backup of keystore/encrypted prefs is device-specific and may not restore to a new device
- User may disable backup
- Less control over recovery UX

**Security tradeoff**: Relies on platform security. Generally good, but backup could be restored to a compromised device.

---

## Part 3: Security Tradeoffs Summary

| Approach | Developer Access to Data | Lost Device Recovery | Reinstall Recovery | User Friction |
|----------|--------------------------|----------------------|--------------------|---------------|
| **Current (device approval)** | None | ❌ No | ❌ No | High (must have other device) |
| **A: Recovery passphrase** | None | ✅ Yes | ✅ Yes | Medium (remember passphrase) |
| **B: Account-based** | Possible* | ✅ Yes | ✅ Yes | Low |
| **C: Hybrid (device + recovery)** | None | ✅ Yes | ✅ Yes | Medium (optional setup) |
| **D: Platform backup** | None | Partial | Partial | Low |

\*Depends on implementation; pure client-side derivation preserves E2EE.

---

## Part 4: Recommended Revised Architecture

### Recommendation: **Option C — Hybrid Model**

1. **Keep** the existing device-approval flow for users who have another device.
2. **Add** an optional recovery key (Option A) as a fallback.
3. **Improve** reinstall detection where possible (e.g., consider Android Backup / iOS Keychain for same-device restore).

### Proposed Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         KEY MANAGEMENT LAYERS                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Layer 1: Device-bound (current)                                             │
│  ├── Bootstrap: RSA + MEK, wrapped MEK in Firestore                          │
│  ├── Returning device: deviceId match → unwrap from Firestore                │
│  └── New device: Pending → authorized device wraps MEK                        │
│                                                                              │
│  Layer 2: Recovery key (NEW)                                                 │
│  ├── Setup: User sets passphrase → recoveryBlob = Enc(MEK, KDF(passphrase))  │
│  │          Store recoveryBlob in Firestore (users/{uid}/crypto/recovery)     │
│  └── Recover: User enters passphrase → decrypt MEK from recoveryBlob          │
│                                                                              │
│  Layer 3: Same-device reinstall (OPTIONAL)                                   │
│  └── Use FlutterSecureStorage with platform backup where supported           │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Flow: New Device / Reinstall

```
1. User signs in with Google
2. ensureReady() runs
3. Check: deviceId in storage + exists in Firestore? → YES → unwrap, ready
4. Check: devices empty? → YES → bootstrap, ready
5. Check: recoveryBlob exists? → YES → show "Recover with passphrase" UI
6. Else: Show device approval flow (current) + "Or recover with passphrase if you set it up"
7. If user has no other device AND no recovery: Show "Set up recovery" (one-time) after first successful auth on any device
```

### Implementation Outline

1. **Recovery blob storage**
   - Firestore: `users/{userId}/crypto/recovery` document with `recoveryBlob` (base64), `salt`, `kdfParams` (Argon2id params).

2. **Key derivation**
   - Use `argon2` or similar: `key = Argon2id(passphrase, salt, ...)`.
   - Encrypt MEK with AES-256-GCM using derived key.

3. **Recovery setup**
   - After bootstrap or when ready: optional "Set up recovery" in settings.
   - User enters passphrase (with confirmation), derive key, encrypt MEK, write to Firestore.

4. **Recovery path**
   - In `ensureReady`, when `awaitingAuthorization`: check for `recoveryBlob`.
   - If exists: show recovery screen; on success, decrypt MEK, store in secure storage, set ready.

5. **Clean architecture**
   - New `RecoveryKeyService` (or extend `EncryptionService`) for recovery operations.
   - New `CryptoRepository` methods: `getRecoveryBlob`, `setRecoveryBlob`, `deleteRecoveryBlob`.
   - UI: Recovery setup screen, recovery entry screen (when awaiting auth).

### Security Properties Preserved

- **E2E encryption**: MEK never leaves the client in plain form; recovery blob is encrypted.
- **No developer access**: Server only stores ciphertext; passphrase never sent.
- **Strong crypto**: Argon2id for KDF, AES-256-GCM for encryption.

---

## Part 5: Handling "No Recovery Set" Scenario

For users who never set up recovery and lose all devices:

1. **Clear messaging**: During onboarding or first device setup, explain: "Set up a recovery passphrase to recover your data if you lose this device. You can do this later in Settings."
2. **Periodic prompts**: After N logins or when adding a new device, remind: "Have you set up recovery? It helps if you lose your device."
3. **Data loss warning**: When user dismisses recovery setup, show: "Without recovery, if you lose all your devices, your data cannot be recovered."

This keeps the choice with the user while avoiding permanent lockout for users who opt in.

---

## Next Steps

1. Decide on Option C (hybrid) vs. Option A only (recovery key always required).
2. Add `recoveryBlob` storage and `RecoveryKeyService`.
3. Implement recovery setup UI (settings) and recovery entry UI (login/awaiting-auth flow).
4. Optionally: explore platform backup for same-device reinstall.
5. Migrate existing users: recovery is optional; they can set it up when they next open the app.

---

## References

- [Signal's Secure Value Recovery](https://signal.org/blog/secure-value-recovery/) — similar concepts for key recovery
- [Argon2](https://github.com/p-h-c/phc-winner-argon2) — memory-hard KDF for passphrase
- [OWASP Key Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Key_Storage_Cheat_Sheet.html)
