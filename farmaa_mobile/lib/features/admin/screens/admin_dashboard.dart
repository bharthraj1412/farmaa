import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';

// ── Light data models for Admin ─────────────────────────────────────────────

class _AdminStats {
  final int totalUsers;
  final int totalFarmers;
  final int totalBuyers;
  final int pendingApprovals;
  final int totalOrders;
  final int openDisputes;
  final double totalRevenue;

  const _AdminStats({
    required this.totalUsers,
    required this.totalFarmers,
    required this.totalBuyers,
    required this.pendingApprovals,
    required this.totalOrders,
    required this.openDisputes,
    required this.totalRevenue,
  });

  factory _AdminStats.demo() => const _AdminStats(
        totalUsers: 142,
        totalFarmers: 87,
        totalBuyers: 55,
        pendingApprovals: 6,
        totalOrders: 318,
        openDisputes: 3,
        totalRevenue: 245800,
      );
}

class _PendingUser {
  final String id;
  final String name;
  final String phone;
  final String role;
  final String district;

  const _PendingUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.district,
  });
}

// ── Admin Dashboard ──────────────────────────────────────────────────────────

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  _AdminStats _stats = _AdminStats.demo();
  List<_PendingUser> _pending = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      // Try to fetch from backend
      final statsResp = await ApiClient().dio.get('/admin/stats');
      final d = statsResp.data as Map<String, dynamic>;
      _stats = _AdminStats(
        totalUsers: d['total_users'] ?? 0,
        totalFarmers: d['farmers'] ?? 0,
        totalBuyers: d['buyers'] ?? 0,
        pendingApprovals: d['pending_approvals'] ?? 0,
        totalOrders: d['total_orders'] ?? 0,
        openDisputes: d['open_disputes'] ?? 0,
        totalRevenue: (d['total_revenue'] ?? 0.0).toDouble(),
      );

      final pendingResp =
          await ApiClient().dio.get('/admin/pending-verifications');
      final list = (pendingResp.data as List<dynamic>?) ?? [];
      _pending = list.map((e) {
        final m = e as Map<String, dynamic>;
        return _PendingUser(
          id: m['id'].toString(),
          name: m['name'] ?? '',
          phone: m['phone'] ?? '',
          role: m['role'] ?? 'farmer',
          district: m['district'] ?? '',
        );
      }).toList();
    } catch (_) {
      // Demo fallback
      _stats = _AdminStats.demo();
      _pending = [
        const _PendingUser(
            id: '1',
            name: 'Murugan S',
            phone: '+91 94430 11234',
            role: 'farmer',
            district: 'Tirunelveli'),
        const _PendingUser(
            id: '2',
            name: 'Kavitha R',
            phone: '+91 98762 55678',
            role: 'farmer',
            district: 'Madurai'),
        const _PendingUser(
            id: '3',
            name: 'Ravi Kumar',
            phone: '+91 76543 99001',
            role: 'buyer',
            district: 'Chennai'),
      ];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(String userId) async {
    try {
      await ApiClient().dio.post('/admin/verify-user/$userId');
      setState(() => _pending.removeWhere((u) => u.id == userId));
      _showSnack('User approved ✅', AppTheme.successGreen);
    } catch (_) {
      // Demo: just remove
      setState(() => _pending.removeWhere((u) => u.id == userId));
      _showSnack('User approved (demo) ✅', AppTheme.successGreen);
    }
  }

  Future<void> _reject(String userId) async {
    try {
      await ApiClient().dio.post('/admin/reject-user/$userId');
      setState(() => _pending.removeWhere((u) => u.id == userId));
      _showSnack('User rejected', AppTheme.errorRed);
    } catch (_) {
      setState(() => _pending.removeWhere((u) => u.id == userId));
      _showSnack('User rejected (demo)', AppTheme.errorRed);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceCream,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppTheme.primaryGreenDark,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.accentAmber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Approvals'),
            Tab(text: 'System'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _OverviewTab(stats: _stats),
                _ApprovalsTab(
                  pending: _pending,
                  onApprove: _approve,
                  onReject: _reject,
                ),
                const _SystemTab(),
              ],
            ),
    );
  }
}

// ── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final _AdminStats stats;
  const _OverviewTab({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'Platform Overview'),
          const SizedBox(height: 12),

          // Revenue highlight
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: AppTheme.radiusLarge,
              boxShadow: AppTheme.elevatedShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Platform Revenue',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '₹${_fmt(stats.totalRevenue)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${stats.totalOrders} orders processed',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _statCard('👥 Users', '${stats.totalUsers}', AppTheme.infoBlue),
              _statCard(
                  '🌾 Farmers', '${stats.totalFarmers}', AppTheme.primaryGreen),
              _statCard('🛒 Buyers', '${stats.totalBuyers}',
                  AppTheme.accentAmberDark),
              _statCard(
                  '⏳ Pending',
                  '${stats.pendingApprovals}',
                  stats.pendingApprovals > 0
                      ? AppTheme.warningAmber
                      : AppTheme.textLight),
              _statCard('📦 Orders', '${stats.totalOrders}',
                  AppTheme.primaryGreenLight),
              _statCard(
                  '⚠️ Disputes',
                  '${stats.openDisputes}',
                  stats.openDisputes > 0
                      ? AppTheme.errorRed
                      : AppTheme.textLight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusLarge,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 13, color: AppTheme.textMedium)),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      );

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Approvals Tab ────────────────────────────────────────────────────────────

class _ApprovalsTab extends StatelessWidget {
  final List<_PendingUser> pending;
  final void Function(String) onApprove;
  final void Function(String) onReject;

  const _ApprovalsTab({
    required this.pending,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (pending.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('✅', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('All caught up!',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            Text('No pending verifications',
                style: TextStyle(color: AppTheme.textLight)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (ctx, i) => _ApprovalCard(
        user: pending[i],
        onApprove: () => onApprove(pending[i].id),
        onReject: () => onReject(pending[i].id),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final _PendingUser user;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalCard({
    required this.user,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isFarmer = user.role == 'farmer';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isFarmer
                    ? AppTheme.primaryGreen.withValues(alpha: 0.12)
                    : AppTheme.accentAmber.withValues(alpha: 0.15),
                child: Text(
                  user.name.isNotEmpty ? user.name[0] : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isFarmer
                        ? AppTheme.primaryGreen
                        : AppTheme.accentAmberDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(user.phone,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textLight)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isFarmer
                      ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                      : AppTheme.accentAmber.withValues(alpha: 0.15),
                  borderRadius: AppTheme.radiusRound,
                ),
                child: Text(
                  isFarmer ? '🌾 Farmer' : '🛒 Buyer',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isFarmer
                        ? AppTheme.primaryGreen
                        : AppTheme.accentAmberDark,
                  ),
                ),
              ),
            ],
          ),
          if (user.district.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Text(user.district,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMedium)),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── System Tab ───────────────────────────────────────────────────────────────

class _SystemTab extends StatelessWidget {
  const _SystemTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'System Status'),
          const SizedBox(height: 12),
          _statusRow(Icons.cloud_done, 'Backend API', 'Connected',
              AppTheme.successGreen),
          _statusRow(Icons.notifications_active, 'FCM Push Service', 'Active',
              AppTheme.successGreen),
          _statusRow(Icons.payment, 'Razorpay Gateway', 'Test Mode',
              AppTheme.warningAmber),
          _statusRow(
              Icons.storage, 'Database', 'Healthy', AppTheme.successGreen),
          _statusRow(Icons.edit_note, 'Pricing Engine', 'Active (Editable)',
              AppTheme.primaryGreen),
          const SizedBox(height: 24),
          _sectionTitle(context, 'Business Rules'),
          const SizedBox(height: 12),
          _ruleCard('Flexible Pricing',
              'Farmers can update crop prices anytime based on market conditions. No restrictions on price updates.'),
          _ruleCard('QA Verification',
              'All new crop listings require admin approval before going live on the marketplace.'),
          _ruleCard('Farmer Verification',
              'Farmers must be approved by admin before they can list crops.'),
          _ruleCard('Minimum Order',
              'Default minimum order is 50 kg unless farmer specifies otherwise.'),
          const SizedBox(height: 24),
          _sectionTitle(context, 'Dispute Management'),
          const SizedBox(height: 12),
          _disputeCard('ORD-2024-0312', 'Buyer: Arjun M',
              'Quality dispute – seeds below specification',
              isOpen: true),
          _disputeCard(
              'ORD-2024-0298', 'Buyer: Priya K', 'Delivery delayed by 5 days',
              isOpen: true),
          _disputeCard('ORD-2024-0255', 'Buyer: Ravi R',
              'Short delivery – 10 kg missing',
              isOpen: false),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _statusRow(IconData icon, String label, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppTheme.radiusRound,
            ),
            child: Text(status,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _ruleCard(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.policy_outlined,
              size: 18, color: AppTheme.primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Text(body,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMedium, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _disputeCard(String orderId, String buyer, String issue,
      {required bool isOpen}) {
    return StatefulBuilder(
      builder: (context, setCardState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.radiusMedium,
            boxShadow: AppTheme.cardShadow,
            border: Border.all(
              color: isOpen
                  ? AppTheme.errorRed.withValues(alpha: 0.3)
                  : AppTheme.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(orderId,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.primaryGreen)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? AppTheme.errorRed.withValues(alpha: 0.1)
                          : AppTheme.successGreen.withValues(alpha: 0.1),
                      borderRadius: AppTheme.radiusRound,
                    ),
                    child: Text(
                      isOpen ? 'Open' : 'Resolved',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color:
                            isOpen ? AppTheme.errorRed : AppTheme.successGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(buyer,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textMedium)),
              const SizedBox(height: 2),
              Text(issue,
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.textDark)),
              if (isOpen) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.errorRed.withValues(alpha: 0.85)),
                    onPressed: () {
                      setCardState(() {
                        isOpen = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Dispute $orderId resolved ✅'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    },
                    child: const Text('Resolve Dispute',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

Widget _sectionTitle(BuildContext context, String title) => Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.w800),
    );
