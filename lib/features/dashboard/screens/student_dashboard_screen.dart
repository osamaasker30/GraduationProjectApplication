import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.studentDashboard);
      if (mounted) setState(() { _data = res.data['data']; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Paneli'),
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
                    // Welcome card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.waving_hand, color: Colors.white70, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            'Merhaba, ${_data?['fullName'] ?? auth.fullName ?? ''}!',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_data?['university'] ?? ''} · ${_data?['major'] ?? ''}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats row
                    Row(
                      children: [
                        _StatCard(label: 'Proje', value: '${_data?['projectsCount'] ?? 0}', icon: Icons.folder, color: AppTheme.primary),
                        const SizedBox(width: 12),
                        _StatCard(label: 'Başvuru', value: '${_data?['applicationsCount'] ?? 0}', icon: Icons.send, color: AppTheme.info),
                        const SizedBox(width: 12),
                        _StatCard(label: 'Bildirim', value: '${_data?['notificationsCount'] ?? 0}', icon: Icons.notifications, color: AppTheme.warning),
                      ],
                    ),
                    const SizedBox(height: 28),

                    Text('Hızlı Erişim', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 14),

                    _QuickAction(icon: Icons.folder_outlined, label: 'Projelerim', sub: 'AI değerlendirme sonuçları', color: AppTheme.primary, onTap: () => context.push('/projects')),
                    const SizedBox(height: 10),
                    _QuickAction(icon: Icons.add_circle_outline, label: 'Yeni Proje Ekle', sub: 'AI ile otomatik değerlendirilir', color: AppTheme.info, onTap: () => context.push('/projects/create')),
                    const SizedBox(height: 10),
                    _QuickAction(icon: Icons.work_outline, label: 'Fırsatlara Göz At', sub: 'Staj ve iş ilanları', color: AppTheme.success, onTap: () => context.go('/opportunities')),
                    const SizedBox(height: 10),
                    _QuickAction(icon: Icons.chat_bubble_outline, label: 'Mesajlar', sub: 'Şirketlerle iletişim', color: AppTheme.warning, onTap: () => context.go('/messages')),
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
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha:0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.sub, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceVariant,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha:0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: color.withValues(alpha:0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
                    Text(sub, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
