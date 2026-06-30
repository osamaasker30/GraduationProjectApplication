import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});
  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.opportunities);
      if (mounted) setState(() { _items = res.data['data'] ?? []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  List<dynamic> get _filtered => _search.isEmpty
      ? _items
      : _items.where((o) =>
          o['title'].toString().toLowerCase().contains(_search.toLowerCase()) ||
          (o['requiredSkills'] ?? '').toString().toLowerCase().contains(_search.toLowerCase())).toList();

  String _typeLabel(String t) => switch (t) {
    'Job' => 'İş İlanı',
    'InternshipShort' => 'Kısa Staj',
    'InternshipLong' => 'Uzun Staj',
    _ => t,
  };

  Color _typeColor(String t) => switch (t) {
    'Job' => AppTheme.success,
    'InternshipShort' => AppTheme.info,
    _ => AppTheme.warning,
  };

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('Fırsatlar')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Fırsat veya yetenek ara...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            color: AppTheme.primary,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('Fırsat bulunamadı.', style: TextStyle(color: AppTheme.textSecondary)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final o = filtered[i];
                          final type = o['type'] ?? '';
                          final deadline = DateTime.tryParse(o['deadline'] ?? '');
                          final expired = deadline != null && deadline.isBefore(DateTime.now());

                          return Card(
                            child: InkWell(
                              onTap: () => context.push('/opportunities/${o['id']}'),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    Expanded(child: Text(o['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white))),
                                    _TypeBadge(label: _typeLabel(type), color: _typeColor(type)),
                                  ]),
                                  if ((o['company'] ?? '') != null && o['company'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(o['company'].toString(), style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(o['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                  const SizedBox(height: 10),
                                  if ((o['requiredSkills'] ?? '').toString().isNotEmpty) ...[
                                    Wrap(
                                      spacing: 6, runSpacing: 4,
                                      children: (o['requiredSkills'] as String).split(',').take(4).map((s) => Chip(label: Text(s.trim(), style: const TextStyle(fontSize: 11)))).toList(),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  Row(children: [
                                    Icon(expired ? Icons.event_busy : Icons.calendar_today, size: 14, color: expired ? AppTheme.error : AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      deadline != null ? '${deadline.day}.${deadline.month}.${deadline.year}' : '',
                                      style: TextStyle(color: expired ? AppTheme.error : AppTheme.textSecondary, fontSize: 12),
                                    ),
                                    if (expired) ...[const SizedBox(width: 6), const Text('Süresi doldu', style: TextStyle(color: AppTheme.error, fontSize: 11))],
                                    const Spacer(),
                                    const Icon(Icons.arrow_forward_ios, size: 13, color: AppTheme.textSecondary),
                                  ]),
                                ]),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ]),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}
