import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});
  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.companyProfile);
      if (mounted) setState(() { _profile = res.data['data']; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final approved = _profile?['isApproved'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Şirket Profili'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Düzenle',
            onPressed: _profile == null
                ? null
                : () => context.push('/profile/company/edit', extra: _profile).then((_) => _load()),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.error),
            tooltip: 'Çıkış',
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
                    // Header card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: Text(
                                (_profile?['companyName'] ?? 'Ş').substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(_profile?['companyName'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                              Text(_profile?['industry'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ])),
                          ]),
                          const SizedBox(height: 12),
                          Row(children: [
                            Icon(approved ? Icons.verified : Icons.pending_outlined,
                                color: approved ? Colors.greenAccent : Colors.orangeAccent, size: 16),
                            const SizedBox(width: 6),
                            Text(approved ? 'Onaylı Hesap' : 'Onay Bekleniyor',
                                style: TextStyle(color: approved ? Colors.greenAccent : Colors.orangeAccent, fontSize: 13)),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          _Row(label: 'Yetkili', value: _profile?['fullName']),
                          _Row(label: 'E-posta', value: _profile?['email']),
                          _Row(label: 'Telefon', value: _profile?['phone']),
                          _Row(label: 'Web Sitesi', value: _profile?['websiteUrl']),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if ((_profile?['description'] ?? '').toString().isNotEmpty) ...[
                      const Text('Hakkında', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(_profile!['description'], style: const TextStyle(color: AppTheme.textSecondary, height: 1.6)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final dynamic value;
  const _Row({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
        Expanded(child: Text(value.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13))),
      ]),
    );
  }
}
