import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/l10n/app_localizations.dart';

/// A record of a past in-app notification.
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime receivedAt;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.receivedAt,
    this.isRead = false,
  });
}

enum NotificationType { order, price, kyc, general }

/// Screen showing the notification history for the user.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Demo notifications — replace with a NotificationsProvider backed by
  // SharedPreferences or a backend endpoint in production.
  final List<NotificationItem> _items = [
    NotificationItem(
      id: '1',
      title: 'Order Confirmed ✅',
      body:
          'Your order for Pearl Millet Seeds (200 kg) has been confirmed by the farmer.',
      type: NotificationType.order,
      receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: '📈 Price Update Available',
      body:
          'Market prices for Pearl Millet have changed. Consider reviewing your listing price.',
      type: NotificationType.price,
      receivedAt: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'New Order Received 📦',
      body:
          'Arjun Mehta placed an order for 150 kg of Kodo Millet. Review and accept.',
      type: NotificationType.order,
      receivedAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Account Verified ✅',
      body:
          'Your farmer account has been verified by the Farmaa team. You can now list crops.',
      type: NotificationType.kyc,
      receivedAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: '📈 Millet Prices Rising',
      body:
          'District market data shows millet prices up 6% this week. Consider updating your listing.',
      type: NotificationType.price,
      receivedAt: DateTime.now().subtract(const Duration(days: 5)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _items.where((n) => !n.isRead).length;
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceCream,
      appBar: AppBar(
        title: Text(l.notifications),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (int i = 0; i < _items.length; i++) {
                    _items[i] = NotificationItem(
                      id: _items[i].id,
                      title: _items[i].title,
                      body: _items[i].body,
                      type: _items[i].type,
                      receivedAt: _items[i].receivedAt,
                      isRead: true,
                    );
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
              child: Text(
                l.markAllRead,
                style:
                    const TextStyle(color: AppTheme.primaryGreen, fontSize: 12),
              ),
            ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔔', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(l.noNotificationsYet,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(l.youreAllCaughtUp,
                      style: const TextStyle(color: AppTheme.textLight)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _items.length,
              itemBuilder: (ctx, i) => _NotificationTile(
                item: _items[i],
                onTap: () {
                  setState(() {
                    _items[i] = NotificationItem(
                      id: _items[i].id,
                      title: _items[i].title,
                      body: _items[i].body,
                      type: _items[i].type,
                      receivedAt: _items[i].receivedAt,
                      isRead: true,
                    );
                  });
                },
              ),
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(item.type);
    final icon = _typeIcon(item.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : color.withValues(alpha: 0.05),
          borderRadius: AppTheme.radiusLarge,
          boxShadow: AppTheme.cardShadow,
          border: Border.all(
            color: item.isRead
                ? AppTheme.borderLight
                : color.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight:
                                item.isRead ? FontWeight.w600 : FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMedium, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(item.receivedAt, context),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return AppTheme.primaryGreen;
      case NotificationType.price:
        return AppTheme.accentAmberDark;
      case NotificationType.kyc:
        return AppTheme.infoBlue;
      case NotificationType.general:
        return AppTheme.textMedium;
    }
  }

  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_bag_outlined;
      case NotificationType.price:
        return Icons.trending_up;
      case NotificationType.kyc:
        return Icons.verified_outlined;
      case NotificationType.general:
        return Icons.notifications_outlined;
    }
  }

  String _timeAgo(DateTime dt, BuildContext context) {
    final diff = DateTime.now().difference(dt);
    final l = AppLocalizations.of(context);
    if (diff.inMinutes < 60) return l.timeAgoM(diff.inMinutes);
    if (diff.inHours < 24) return l.timeAgoH(diff.inHours);
    return l.timeAgoD(diff.inDays);
  }
}
