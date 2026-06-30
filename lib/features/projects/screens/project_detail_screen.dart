import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int id;
  const ProjectDetailScreen({super.key, required this.id});
  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  Map<String, dynamic>? _project;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.projectById(widget.id));
      if (mounted) setState(() { _project = res.data['data']; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _evaluate() async {
    setState(() => _loading = true);
    try {
      await ApiClient().dio.post(ApiConstants.evaluateProject(widget.id));
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Değerlendirme tamamlandı!'), backgroundColor: AppTheme.success));
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Color _scoreColor(num score) => score >= 70 ? AppTheme.success : (score >= 40 ? AppTheme.warning : AppTheme.error);

  @override
  Widget build(BuildContext context) {
    final eval = _project?['evaluation'];
    final score = (eval?['score'] ?? 0) as num;

    return Scaffold(
      appBar: AppBar(
        title: Text(_project?['title'] ?? 'Proje Detayı'),
        actions: [
          if (_project != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Düzenle',
              onPressed: () => context
                  .push('/projects/${widget.id}/edit', extra: _project)
                  .then((ok) { if (ok == true) _load(); }),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_project?['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 10),
                        Text(_project?['description'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, height: 1.6)),
                        const SizedBox(height: 16),
                        if (_project?['repositoryUrl'] != null && _project!['repositoryUrl'].toString().isNotEmpty)
                          _LinkRow(icon: Icons.code, label: 'Kaynak Kod', url: _project!['repositoryUrl']),
                        if (_project?['demoUrl'] != null && _project!['demoUrl'].toString().isNotEmpty)
                          _LinkRow(icon: Icons.play_circle_outline, label: 'Demo', url: _project!['demoUrl']),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Evaluation
                  if (eval == null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(children: [
                          const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 40),
                          const SizedBox(height: 12),
                          const Text('Bu proje henüz değerlendirilmedi.', style: TextStyle(color: AppTheme.textSecondary)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('AI ile Değerlendir'),
                            onPressed: _evaluate,
                          ),
                        ]),
                      ),
                    )
                  else ...[
                    // Score ring
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(children: [
                          CircularPercentIndicator(
                            radius: 48, lineWidth: 8,
                            percent: score.toDouble() / 100,
                            center: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('$score', style: TextStyle(color: _scoreColor(score), fontSize: 20, fontWeight: FontWeight.w800)),
                              Text('/100', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                            ]),
                            progressColor: _scoreColor(score),
                            backgroundColor: _scoreColor(score).withValues(alpha: 0.15),
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                          const SizedBox(width: 20),
                          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('AI Değerlendirme Skoru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                            SizedBox(height: 4),
                            Text('100 puan üzerinden hesaplanmıştır.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ])),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _EvalSection(title: 'Güçlü Yönler', content: eval['strengthPoints'] ?? '', color: AppTheme.success, icon: Icons.check_circle_outline),
                    const SizedBox(height: 10),
                    _EvalSection(title: 'Zayıf Yönler', content: eval['weaknessPoints'] ?? '', color: AppTheme.error, icon: Icons.warning_amber_outlined),
                    const SizedBox(height: 10),
                    _EvalSection(title: 'Geliştirme Önerileri', content: eval['improvementSuggestions'] ?? '', color: AppTheme.warning, icon: Icons.lightbulb_outline),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Yeniden Değerlendir'),
                      onPressed: _evaluate,
                    ),
                  ],
                ]),
              ),
            ),
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
      Expanded(child: Text(url, style: const TextStyle(color: AppTheme.info, fontSize: 13), overflow: TextOverflow.ellipsis)),
    ]),
  );
}

class _EvalSection extends StatelessWidget {
  final String title, content;
  final Color color;
  final IconData icon;
  const _EvalSection({required this.title, required this.content, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
      const SizedBox(height: 8),
      Text(content, style: const TextStyle(color: AppTheme.textSecondary, height: 1.6, fontSize: 13)),
    ]),
  );
}
