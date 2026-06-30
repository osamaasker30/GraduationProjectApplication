import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});
  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.companyDashboard);
      if (mounted) setState(() { _data = res.data['data']; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final approved = _data?['isApproved'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Şirket Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.error),
            tooltip: 'Çıkış Yap',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.business, color: Colors.white70, size: 28),
                        const SizedBox(height: 8),
                        Text('${_data?['companyName'] ?? auth.fullName ?? ''}',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(approved ? Icons.verified : Icons.pending_outlined,
                              color: approved ? Colors.greenAccent : Colors.orangeAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(approved ? 'Onaylı Hesap' : 'Onay Bekleniyor',
                              style: TextStyle(color: approved ? Colors.greenAccent : Colors.orangeAccent, fontSize: 13)),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 24),

                    Row(children: [
                      _StatCard(label: 'İlan', value: '${_data?['opportunitiesCount'] ?? 0}', icon: Icons.work, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      _StatCard(label: 'Başvuran', value: '${_data?['applicantsCount'] ?? 0}', icon: Icons.people, color: AppTheme.info),
                    ]),
                    const SizedBox(height: 28),

                    Text('İşlemler', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 14),

                    _ActionTile(icon: Icons.work_outline, label: 'Fırsat Listesi', sub: 'İlanları ve başvuruları yönet', color: AppTheme.primary, onTap: () => context.go('/opportunities')),
                    const SizedBox(height: 10),
                    _ActionTile(icon: Icons.chat_bubble_outline, label: 'Mesajlar', sub: 'Adaylarla iletişim', color: AppTheme.info, onTap: () => context.go('/messages')),
                    const SizedBox(height: 10),
                    _ActionTile(icon: Icons.notifications_outlined, label: 'Bildirimler', sub: 'Sistem bildirimleri', color: AppTheme.warning, onTap: () => context.go('/notifications')),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ]),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.sub, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: AppTheme.surfaceVariant,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
            Text(sub, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ])),
          const Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary, size: 14),
        ]),
      ),
    ),
  );
}
