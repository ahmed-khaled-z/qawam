import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../config/app_helper/app_padding.dart';
import '../../../../core/security/crypto_repository.dart';
import '../../../../core/security/device_authorization_service.dart';
import '../../../../injection_container.dart';

/// Screen for an authorized device to approve or reject pending device requests.
class DeviceAuthorizationApproveScreen extends StatelessWidget {
  static const routeName = '/device-authorization-approve';

  const DeviceAuthorizationApproveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Authorize devices')),
        body: const Center(child: Text('Not signed in')),
      );
    }

    final deviceAuth = getIt<DeviceAuthorizationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authorize devices'),
      ),
      body: StreamBuilder<List<PendingDeviceInfo>>(
        stream: deviceAuth.watchPendingDevices(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final pending = snapshot.data ?? [];
          if (pending.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppPadding.defaultPadding),
                child: Text(
                  'No devices waiting for approval. When someone signs in on a new device, they will appear here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppPadding.defaultPadding),
            itemCount: pending.length,
            itemBuilder: (context, index) {
              final p = pending[index];
              final expired =
                  DeviceAuthorizationService.isPendingExpired(p);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    p.deviceName ?? 'Device ${p.deviceId.substring(0, 8)}...',
                  ),
                  subtitle: expired
                      ? const Text(
                          'Expired',
                          style: TextStyle(color: Colors.orange),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!expired) ...[
                        TextButton(
                          onPressed: () => _reject(context, userId, p.deviceId),
                          child: const Text('Reject'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              _approve(context, userId, p, deviceAuth),
                          child: const Text('Approve'),
                        ),
                      ] else
                        TextButton(
                          onPressed: () =>
                              _reject(context, userId, p.deviceId),
                          child: const Text('Remove'),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _approve(
    BuildContext context,
    String userId,
    PendingDeviceInfo pending,
    DeviceAuthorizationService deviceAuth,
  ) async {
    try {
      await deviceAuth.approveDevice(
        userId,
        pending.deviceId,
        publicKeyPem: pending.publicKeyPem,
        deviceName: pending.deviceName,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device approved')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reject(
    BuildContext context,
    String userId,
    String deviceId,
  ) async {
    try {
      await getIt<DeviceAuthorizationService>().rejectPendingDevice(
        userId,
        deviceId,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device rejected')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
