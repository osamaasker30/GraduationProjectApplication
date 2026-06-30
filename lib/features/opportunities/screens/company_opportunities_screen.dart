import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

class CompanyOpportunitiesScreen extends StatefulWidget {
  const CompanyOpportunitiesScreen({super.key});
  @override
  State<CompanyOpportunitiesScreen> createState() =>
      _CompanyOpportunitiesScreenState();
}

class _CompanyOpportunitiesScreenState
    extends State<CompanyOpportunitiesScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res =
          await ApiClient().dio.get(ApiConstants.companyOpportunities);
      if (mounted) {
        setState(() {
          _items = res.data['data'] ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(int id, String title) async {
    final confirm = await _showConfirm(
      title: 'İlanı Sil',
      content: '"$title" ilanını silmek istediğinize emin misiniz?',
      confirmLabel: 'Sil',
      confirmColor: AppTheme.error,
    );
    if (confirm != true) return;

    try {
      await ApiClient().dio.delete(ApiConstants.companyOpportunityById(id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('İlan silindi.'),
              backgroundColor: AppTheme.success),
        );
        _load();
      }
    } catch (_) {}
  }

  Future<void> _toggle(int id, bool current) async {
    try {
      await ApiClient().dio.patch(ApiConstants.toggleOpportunity(id));
      _load();
    } catch (_) {}
  }

  Future<bool?> _showConfirm({
    required String title,
    required String content,
    required String confirmLabel,
    Color confirmColor = AppTheme.primary,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(content,
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlanlarım'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Yeni İlan',
            onPressed: () =>
                context.push('/company/opportunities/create').then((_) => _load()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.work_off_outlined,
                            size: 72, color: AppTheme.textSecondary),
                        const SizedBox(height: 16),
                        const Text('Henüz ilan eklenmedi.',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 16)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('İlk İlanı Ekle'),
                          onPressed: () => context
                              .push('/company/opportunities/create')
                              .then((_) => _load()),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, idx) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final o = _items[i];
                      final type = o['type'] ?? '';
                      final isActive = o['isActive'] ?? true;
                      final deadline =
                          DateTime.tryParse(o['deadline'] ?? '');
                      final expired = deadline != null &&
                          deadline.isBefore(DateTime.now());

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(
                                    o['title'] ?? '',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15),
                                  ),
                                ),
                                _Badge(
                                    label: _typeLabel(type),
                                    color: _typeColor(type)),
                              ]),
                              const SizedBox(height: 6),
                              Text(
                                o['description'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              Row(children: [
                                Icon(
                                  expired
                                      ? Icons.event_busy
                                      : Icons.calendar_today,
                                  size: 13,
                                  color: expired
                                      ? AppTheme.error
                                      : AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  deadline != null
                                      ? '${deadline.day}.${deadline.month}.${deadline.year}'
                                      : '',
                                  style: TextStyle(
                                      color: expired
                                          ? AppTheme.error
                                          : AppTheme.textSecondary,
                                      fontSize: 12),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppTheme.success
                                            .withValues(alpha: 0.15)
                                        : AppTheme.textSecondary
                                            .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isActive ? 'Aktif' : 'Pasif',
                                    style: TextStyle(
                                        color: isActive
                                            ? AppTheme.success
                                            : AppTheme.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ]),
                              const Divider(height: 20),
                              Row(
                                children: [
                                  // View applicants
                                  _ActionBtn(
                                    label: 'Başvuranlar',
                                    icon: Icons.people_outline,
                                    color: AppTheme.info,
                                    onTap: () => context
                                        .push('/applicants/${o['id']}'),
                                  ),
                                  const SizedBox(width: 8),
                                  // Edit
                                  _ActionBtn(
                                    label: 'Düzenle',
                                    icon: Icons.edit_outlined,
                                    color: AppTheme.warning,
                                    onTap: () => context
                                        .push(
                                            '/company/opportunities/edit/${o['id']}',
                                            extra: o)
                                        .then((_) => _load()),
                                  ),
                                  const SizedBox(width: 8),
                                  // Toggle active
                                  _ActionBtn(
                                    label: isActive ? 'Pasifle' : 'Aktifle',
                                    icon: isActive
                                        ? Icons.pause_circle_outline
                                        : Icons.play_circle_outline,
                                    color: isActive
                                        ? AppTheme.textSecondary
                                        : AppTheme.success,
                                    onTap: () =>
                                        _toggle(o['id'], isActive),
                                  ),
                                  const Spacer(),
                                  // Delete
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppTheme.error),
                                    onPressed: () =>
                                        _delete(o['id'], o['title'] ?? ''),
                                    tooltip: 'Sil',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        icon: Icon(icon, size: 14),
        label: Text(label),
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
}
