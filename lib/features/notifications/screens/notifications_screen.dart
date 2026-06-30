import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.notifications);
      if (mounted) setState(() { _items = res.data['data'] ?? []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _markRead(int id) async {
    await ApiClient().dio.post(ApiConstants.markRead(id));
    _load();
  }

  IconData _icon(String type) => switch (type) {
    'ApplicationUpdate' => Icons.work_outline,
    'Interview' => Icons.calendar_month_outlined,
    'Opportunity' => Icons.campaign_outlined,
    _ => Icons.notifications_outlined,
  };

  Color _color(String type) => switch (type) {
    'ApplicationUpdate' => AppTheme.primary,
    'Interview' => AppTheme.success,
    'Opportunity' => AppTheme.warning,
    _ => AppTheme.info,
  };

  @override
  Widget build(BuildContext context) {
    final unread = _items.where((n) => !(n['isRead'] ?? false)).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('Bildirimler'),
          if (unread > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppTheme.error, borderRadius: BorderRadius.circular(12)),
              child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.notifications_off_outlined, size: 64, color: AppTheme.textSecondary),
                    SizedBox(height: 12),
                    Text('Bildirim yok.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                  ]))
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 1),
                    itemBuilder: (context, i) {
                      final n = _items[i];
                      final isRead = n['isRead'] ?? false;
                      final type = n['type'] ?? 'General';
                      final color = _color(type);
                      final createdAt = DateTime.tryParse(n['createdAt'] ?? '');

                      return Container(
                        color: isRead ? Colors.transparent : AppTheme.primary.withValues(alpha: 0.04),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          leading: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                            child: Icon(_icon(type), color: color, size: 22),
                          ),
                          title: Row(children: [
                            Expanded(child: Text(n['title'] ?? '', style: TextStyle(color: Colors.white, fontWeight: isRead ? FontWeight.w500 : FontWeight.w700, fontSize: 14))),
                            if (!isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                          ]),
                          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const SizedBox(height: 3),
                            Text(n['message'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
                            if (createdAt != null) ...[
                              const SizedBox(height: 4),
                              Text(timeago.format(createdAt, locale: 'tr'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                            ],
                          ]),
                          trailing: isRead ? null : IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: AppTheme.primary, size: 22),
                            onPressed: () => _markRead(n['id']),
                            tooltip: 'Okundu',
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
