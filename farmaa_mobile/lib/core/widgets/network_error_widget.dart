import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shown when a data load fails. Never shows a black screen.
class NetworkErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isCompact;

  const NetworkErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withValues(alpha: 0.06),
          borderRadius: AppTheme.radiusLarge,
          border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppTheme.errorRed, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 40, color: AppTheme.errorRed),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: AppTheme.textMedium,
                height: 1.5,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape:
                    RoundedRectangleBorder(borderRadius: AppTheme.radiusRound),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
