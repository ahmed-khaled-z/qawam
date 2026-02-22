import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../config/app_helper/app_padding.dart';
import '../../../../config/router/app_router.dart';
import '../../../../injection_container.dart';
import '../../../../core/security/device_authorization_service.dart';
import '../../../../core/security/encryption_service.dart';
import '../../../../core/sync/sync_service.dart';

/// Shown on a new device after login while waiting for an authorized device to approve.
class DeviceAuthorizationWaitingScreen extends StatefulWidget {
  static const routeName = '/device-authorization-waiting';

  final String userId;

  const DeviceAuthorizationWaitingScreen({
    super.key,
    required this.userId,
  });

  @override
  State<DeviceAuthorizationWaitingScreen> createState() =>
      _DeviceAuthorizationWaitingScreenState();
}

class _DeviceAuthorizationWaitingScreenState
    extends State<DeviceAuthorizationWaitingScreen> {
  final DeviceAuthorizationService _deviceAuth =
      getIt<DeviceAuthorizationService>();

  String? _verificationCode;
  String? _error;
  StreamSubscription<EncryptionState>? _subscription;

  @override
  void initState() {
    super.initState();
    _startAuthorization();
  }

  Future<void> _startAuthorization() async {
    setState(() {
      _error = null;
      _verificationCode = null;
    });
    try {
      final code = await _deviceAuth.startNewDeviceAuthorization(widget.userId);
      if (!mounted) return;
      setState(() => _verificationCode = code);

      _subscription = _deviceAuth.watchAuthorization(widget.userId).listen(
        (state) async {
          if (state == EncryptionState.ready && mounted) {
            await _onApproved();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _onApproved() async {
    _subscription?.cancel();
    try {
      await getIt<SyncService>().syncData();
    } catch (_) {}
    if (!mounted) return;
    AppRouter.toAndRemoveUntil('/home');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _cancel() {
    _deviceAuth.cancelAuthorization();
    AppRouter.toAndRemoveUntil('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.phone_android,
                size: 64,
                color: Color(0xFF0D7377),
              ),
              const SizedBox(height: 24),
              Text(
                'Authorize this device',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Open Qawam on another device where you\'re already signed in, and approve this device using the code below.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_verificationCode != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D7377).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _verificationCode!,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          color: const Color(0xFF0D7377),
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter this code on your other device',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ] else if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _startAuthorization,
                  child: const Text('Retry'),
                ),
              ] else ...[
                const CircularProgressIndicator(),
              ],
              const Spacer(),
              TextButton(
                onPressed: _verificationCode != null ? _cancel : null,
                child: const Text('Cancel and sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

