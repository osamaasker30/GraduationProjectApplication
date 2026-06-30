import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});
  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<dynamic> _projects = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.projects);
      if (mounted) setState(() { _projects = res.data['data'] ?? []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _evaluate(int id) async {
    try {
      await ApiClient().dio.post(ApiConstants.evaluateProject(id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Değerlendirme tamamlandı!'), backgroundColor: AppTheme.success));
        _load();
      }
    } catch (_) {}
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: const Text('Projeyi Sil', style: TextStyle(color: Colors.white)),
        content: const Text('Bu projeyi silmek istediğinize emin misiniz?', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (ok == true) {
      await ApiClient().dio.delete(ApiConstants.projectById(id));
      _load();
    }
  }

  Color _scoreColor(num score) {
    if (score >= 70) return AppTheme.success;
    if (score >= 40) return AppTheme.warning;
    return AppTheme.error;
  }

  String _statusLabel(String s) => switch (s) {
    'Evaluated' => 'Değerlendirildi',
    'Pending' => 'Beklemede',
    'InProgress' => 'Devam Ediyor',
    'Failed' => 'Başarısız',
    _ => s,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projelerim'),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline), tooltip: 'Yeni Proje', onPressed: () => context.push('/projects/create').then((_) => _load())),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _projects.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.folder_open, size: 72, color: AppTheme.textSecondary),
                      const SizedBox(height: 16),
                      const Text('Henüz proje eklenmedi.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('İlk Projeyi Ekle'), onPressed: () => context.push('/projects/create').then((_) => _load())),
                    ]),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _projects.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final p = _projects[i];
                      final eval = p['evaluation'];
                      final score = eval?['score'] ?? 0;
                      final status = p['evaluationStatus'] ?? 'Pending';

                      return Card(
                        child: InkWell(
                          onTap: () => context.push('/projects/${p['id']}').then((_) => _load()),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Expanded(child: Text(p['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white))),
                                if (eval != null) CircularPercentIndicator(
                                  radius: 28, lineWidth: 5,
                                  percent: (score as num).toDouble() / 100,
                                  center: Text('$score', style: TextStyle(color: _scoreColor(score), fontWeight: FontWeight.w700, fontSize: 11)),
                                  progressColor: _scoreColor(score),
                                  backgroundColor: _scoreColor(score).withValues(alpha: 0.15),
                                ),
                              ]),
                              const SizedBox(height: 8),
                              Text(p['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              const SizedBox(height: 12),
                              Row(children: [
                                _StatusChip(label: _statusLabel(status), color: status == 'Evaluated' ? AppTheme.success : (status == 'Pending' ? AppTheme.warning : AppTheme.info)),
                                const Spacer(),
                                // Edit button
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppTheme.warning, size: 20),
                                  tooltip: 'Düzenle',
                                  onPressed: () => context.push('/projects/${p['id']}/edit', extra: p).then((ok) { if (ok == true) _load(); }),
                                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 4),
                                if (status != 'InProgress') IconButton(
                                  icon: const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 20),
                                  tooltip: 'Değerlendir',
                                  onPressed: () => _evaluate(p['id']),
                                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                                  onPressed: () => _delete(p['id']),
                                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                ),
                              ]),
                            ]),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.4))),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}
