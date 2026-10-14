import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/connectivity_provider.dart';
import '../theme/app_colors.dart';

/// Wraps the whole app (via `MaterialApp.builder`) and shows a "No internet
/// connection" popup whenever the device is offline. It closes by itself as
/// soon as the connection is back.
class NoInternetOverlay extends StatelessWidget {
  final Widget child;

  const NoInternetOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityProvider>();

    return Stack(
      children: [
        child,
        if (connectivity.showOfflinePopup)
          Positioned.fill(
            child: Material(
              color: Colors.black54,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _NoInternetCard(connectivity: connectivity),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NoInternetCard extends StatelessWidget {
  final ConnectivityProvider connectivity;

  const _NoInternetCard({required this.connectivity});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: appColors.redLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              color: appColors.red,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No internet connection',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please connect to the internet and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appColors.textSecondary,
              fontSize: 13,
              height: 1.5,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: connectivity.isChecking ? null : connectivity.checkNow,
              icon: connectivity.isChecking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(connectivity.isChecking ? 'Checking...' : 'Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: appColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: connectivity.dismiss,
            child: Text(
              'Close',
              style: TextStyle(color: appColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
