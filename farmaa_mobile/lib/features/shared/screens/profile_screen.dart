import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';
import '../../../generated/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final l = AppLocalizations.of(context);

    // Handle loading state
    if (authState.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceCream,
        appBar: AppBar(title: Text(l.profile)),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    // Handle unauthenticated state
    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceCream,
        appBar: AppBar(title: Text(l.profile)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  size: 64, color: AppTheme.textLight),
              const SizedBox(height: 16),
              Text(
                'Please login to view your profile',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceCream,
      appBar: AppBar(
        title: Text(l.profile),
        actions: [
          if (user.isAdmin == true)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () => context.push(AppRoutes.admin),
              tooltip: 'Admin Panel',
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
            tooltip: l.settings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(authProvider.notifier).refreshProfile(),
        color: AppTheme.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty == true
                        ? user.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
              Text(user.phone ?? '-',
                  style: const TextStyle(color: AppTheme.textMedium)),
              const SizedBox(height: 8),

              // Verification badge
              GestureDetector(
                onTap: user.isVerified == false
                    ? () => _showKYCDialog(context, l)
                    : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: user.isVerified == true
                        ? AppTheme.successGreen.withValues(alpha: 0.1)
                        : AppTheme.warningAmber.withValues(alpha: 0.1),
                    borderRadius: AppTheme.radiusRound,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user.isVerified == true
                            ? Icons.verified
                            : Icons.pending,
                        size: 14,
                        color: user.isVerified == true
                            ? AppTheme.successGreen
                            : AppTheme.warningAmber,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.isVerified == true
                            ? l.verifiedAccount
                            : l.verificationPending,
                        style: TextStyle(
                          fontSize: 13,
                          color: user.isVerified == true
                              ? AppTheme.successGreen
                              : AppTheme.warningAmber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showEditDialog(context, user, l),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(l.editProfile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryGreen,
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Details card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.radiusLarge,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Builder(
                  builder: (context) {
                    final u = user;
                    return Column(
                      children: [
                        _tile(Icons.person_outline, l.name, u.name),
                        _divider(),
                        _tile(Icons.phone_outlined, l.phone, u.phone ?? '-'),
                        _divider(),
                        if (u.isFarmer) ...[
                          if (u.village != null)
                            _tile(Icons.location_city, l.village, u.village!),
                          _divider(),
                          if (u.district != null)
                            _tile(Icons.map_outlined, l.district, u.district!),
                          _divider(),
                        ],
                        if (u.isBuyer && u.organization != null) ...[
                          _tile(Icons.business_outlined, l.organization,
                              u.organization!),
                          _divider(),
                        ],
                        _tile(
                            Icons.badge_outlined, l.role, u.role.toUpperCase()),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(l.logout),
                        content: Text(l.logoutConfirm),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: Text(l.cancel)),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorRed),
                            child: Text(l.logout),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      await ref.read(authProvider.notifier).logout();
                      if (mounted) {
                        context.go(AppRoutes.login);
                      }
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.errorRed),
                  label: Text(l.logout,
                      style: const TextStyle(color: AppTheme.errorRed)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.errorRed)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, UserModel? user, AppLocalizations l) {
    if (user == null) return;
    final nameCtrl = TextEditingController(text: user.name);
    final villageCtrl = TextEditingController(text: user.village ?? '');
    final districtCtrl = TextEditingController(text: user.district ?? '');
    final orgCtrl = TextEditingController(text: user.organization ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.editProfile),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l.fullName)),
              const SizedBox(height: 12),
              if (user.isFarmer) ...[
                TextField(
                    controller: villageCtrl,
                    decoration: InputDecoration(labelText: l.village)),
                const SizedBox(height: 12),
                TextField(
                    controller: districtCtrl,
                    decoration: InputDecoration(labelText: l.district)),
              ],
              if (user.isBuyer)
                TextField(
                    controller: orgCtrl,
                    decoration: InputDecoration(labelText: l.organization)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(authProvider.notifier).updateProfile(
                      name: nameCtrl.text,
                      village: user.isFarmer ? villageCtrl.text : null,
                      district: user.isFarmer ? districtCtrl.text : null,
                      organization: user.isBuyer ? orgCtrl.text : null,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(l.profileUpdated),
                        backgroundColor: AppTheme.successGreen),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${l.updateFailed}: $e'),
                        backgroundColor: AppTheme.errorRed),
                  );
                }
              }
            },
            child: Text(l.saveChangesBtn),
          ),
        ],
      ),
    );
  }

  void _showKYCDialog(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.verifyIdentity),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.kycDesc, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            const Icon(Icons.cloud_upload_outlined,
                size: 48, color: AppTheme.primaryGreen),
            Text(l.simulatedUploadReady,
                style:
                    const TextStyle(fontSize: 11, color: AppTheme.textLight)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(l.documentsSubmitted),
                    backgroundColor: AppTheme.successGreen),
              );
            },
            child: Text(l.submitDocuments),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textLight)),
                  Text(value,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _divider() => const Divider(height: 1, indent: 48);
}
