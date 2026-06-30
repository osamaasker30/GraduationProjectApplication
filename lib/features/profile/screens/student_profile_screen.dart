import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});
  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.studentProfile);
      if (mounted) setState(() { _profile = res.data['data']; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Düzenle',
            onPressed: _profile == null
                ? null
                : () => context
                    .push('/profile/student/edit', extra: _profile)
                    .then((_) => _load()),
          ),
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
                    // Avatar
                    Center(
                      child: Column(children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                          child: Text(
                            (_profile?['fullName'] ?? '?').toString().substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: AppTheme.primary, fontSize: 32, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(_profile?['fullName'] ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(_profile?['email'] ?? '',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ]),
                    ),
                    const SizedBox(height: 24),

                    // Stats
                    Row(children: [
                      _Mini(label: 'Proje', value: '${_profile?['projectsCount'] ?? 0}', color: AppTheme.primary),
                      const SizedBox(width: 12),
                      _Mini(label: 'Başvuru', value: '${_profile?['applicationsCount'] ?? 0}', color: AppTheme.info),
                    ]),
                    const SizedBox(height: 20),

                    // Info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          _InfoRow(label: 'Üniversite', value: _profile?['university']),
                          _InfoRow(label: 'Fakülte', value: _profile?['faculty']),
                          _InfoRow(label: 'Bölüm', value: _profile?['major']),
                          _InfoRow(label: 'Sınıf', value: _profile?['academicYear']?.toString()),
                          _InfoRow(label: 'Telefon', value: _profile?['phone']),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if ((_profile?['bio'] ?? '').toString().isNotEmpty) ...[
                      const Text('Hakkımda',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(_profile!['bio'],
                              style: const TextStyle(color: AppTheme.textSecondary, height: 1.6)),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Skills
                    if (_profile?['skills'] != null &&
                        (_profile!['skills'] as List).isNotEmpty) ...[
                      const Text('Yetenekler',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          for (final s in (_profile!['skills'] as List))
                            Chip(label: Text(s.toString(), style: const TextStyle(fontSize: 12))),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Links
                    if ([_profile?['linkedInUrl'], _profile?['gitHubUrl'], _profile?['portfolioUrl']]
                        .any((v) => v != null && v.toString().isNotEmpty))
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Bağlantılar',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                              const SizedBox(height: 10),
                              if ((_profile?['linkedInUrl'] ?? '').toString().isNotEmpty)
                                _LinkRow(icon: Icons.link, label: 'LinkedIn', url: _profile!['linkedInUrl']),
                              if ((_profile?['gitHubUrl'] ?? '').toString().isNotEmpty)
                                _LinkRow(icon: Icons.code, label: 'GitHub', url: _profile!['gitHubUrl']),
                              if ((_profile?['portfolioUrl'] ?? '').toString().isNotEmpty)
                                _LinkRow(icon: Icons.language, label: 'Portfolyo', url: _profile!['portfolioUrl']),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Mini({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(children: [
            Text(value,
                style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final dynamic value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
        Expanded(child: Text(value.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13))),
      ]),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label, url;
  const _LinkRow({required this.icon, required this.label, required this.url});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(icon, color: AppTheme.info, size: 18),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Expanded(
              child: Text(url,
                  style: const TextStyle(color: AppTheme.info, fontSize: 13),
                  overflow: TextOverflow.ellipsis)),
        ]),
      );
}
