import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _priceAlertsEnabled = true;
  bool _orderUpdatesEnabled = true;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _appVersion = 'v${info.version} (${info.buildNumber})');
    } catch (_) {
      setState(() => _appVersion = 'v1.0.0');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final locale = ref.watch(localeProvider);
    final isTamil = locale.languageCode == 'ta';
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceCream,
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // ── Account Section ─────────────────────────────────────
          _sectionHeader(l.account),
          _settingsTile(
            icon: Icons.person_outline,
            title: l.profile,
            subtitle: user?.name ?? '',
            onTap: () {
              final isF = user?.isFarmer ?? false;
              context
                  .go(isF ? AppRoutes.farmerProfile : AppRoutes.buyerProfile);
            },
          ),
          _settingsTile(
            icon: Icons.phone_outlined,
            title: l.phone,
            subtitle: user?.phone ?? '-',
            trailing: const SizedBox.shrink(),
          ),
          _settingsTile(
            icon: Icons.badge_outlined,
            title: l.role,
            subtitle: (user?.role ?? '').toUpperCase(),
            trailing: const SizedBox.shrink(),
          ),

          // ── Language ────────────────────────────────────────────
          _sectionHeader(l.language),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.radiusMedium,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            AppTheme.primaryGreen.withValues(alpha: 0.1),
                        child: const Icon(Icons.language,
                            size: 18, color: AppTheme.primaryGreen),
                      ),
                      const SizedBox(width: 12),
                      Text(l.selectLanguage,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _langButton(
                          label: l.english,
                          flag: '🇬🇧',
                          isSelected: !isTamil,
                          onTap: () => ref
                              .read(localeProvider.notifier)
                              .setLocale(const Locale('en')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _langButton(
                          label: l.tamil,
                          flag: '🇮🇳',
                          isSelected: isTamil,
                          onTap: () => ref
                              .read(localeProvider.notifier)
                              .setLocale(const Locale('ta')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Notifications ────────────────────────────────────────
          _sectionHeader(l.notifications),
          _switchTile(
            icon: Icons.notifications_outlined,
            title: l.pushNotifications,
            subtitle: l.pushNotificationsSubtitle,
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          _switchTile(
            icon: Icons.trending_up,
            title: l.priceAlerts,
            subtitle: l.priceAlertsSubtitle,
            value: _priceAlertsEnabled,
            onChanged: (v) => setState(() => _priceAlertsEnabled = v),
          ),
          _switchTile(
            icon: Icons.shopping_bag_outlined,
            title: l.orderUpdates,
            subtitle: l.orderUpdatesSubtitle,
            value: _orderUpdatesEnabled,
            onChanged: (v) => setState(() => _orderUpdatesEnabled = v),
          ),

          // ── About ────────────────────────────────────────────────
          _sectionHeader(l.about),
          _settingsTile(
            icon: Icons.info_outline,
            title: l.appVersion,
            subtitle: _appVersion,
            trailing: const SizedBox.shrink(),
          ),
          _settingsTile(
            icon: Icons.policy_outlined,
            title: l.privacyPolicy,
            onTap: () =>
                launchUrl(Uri.parse('${AppConstants.baseUrl}/privacy')),
          ),
          _settingsTile(
            icon: Icons.description_outlined,
            title: l.termsOfService,
            onTap: () => launchUrl(Uri.parse('${AppConstants.baseUrl}/tos')),
          ),
          _settingsTile(
            icon: Icons.help_outline,
            title: l.helpSupport,
            onTap: () =>
                launchUrl(Uri.parse('mailto:bharathraj1412p@gmail.com')),
          ),

          // ── Danger Zone ─────────────────────────────────────────
          _sectionHeader(l.accountActions),
          _settingsTile(
            icon: Icons.logout,
            title: l.logout,
            titleColor: AppTheme.errorRed,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(l.logout),
                  content: Text(l.logoutConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorRed),
                      child: Text(l.logout),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref.read(authProvider.notifier).logout();
              }
            },
          ),

          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Text(
                  '🌾 ${l.appName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.tagline,
                  style:
                      const TextStyle(color: AppTheme.textLight, fontSize: 12),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _langButton({
    required String label,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen
              : AppTheme.primaryGreen.withValues(alpha: 0.06),
          borderRadius: AppTheme.radiusMedium,
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.borderLight,
          ),
        ),
        child: Column(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isSelected ? Colors.white : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Builder Helpers ──────────────────────────────────────────────

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textLight,
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.cardShadow,
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor:
              (titleColor ?? AppTheme.primaryGreen).withValues(alpha: 0.1),
          child:
              Icon(icon, size: 18, color: titleColor ?? AppTheme.primaryGreen),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: titleColor ?? AppTheme.textDark,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ??
            const Icon(Icons.chevron_right, color: AppTheme.textLight),
        onTap: onTap,
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.cardShadow,
      ),
      child: SwitchListTile(
        secondary: CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
          child: Icon(icon, size: 18, color: AppTheme.primaryGreen),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        activeThumbColor: AppTheme.primaryGreen,
        onChanged: onChanged,
      ),
    );
  }
}
