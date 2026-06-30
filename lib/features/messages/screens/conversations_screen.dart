import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});
  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<dynamic> _convs = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.conversations);
      if (mounted) setState(() { _convs = res.data['data'] ?? []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mesajlar')),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _convs.isEmpty
                ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textSecondary),
                    SizedBox(height: 12),
                    Text('Henüz mesaj yok.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                  ]))
                : ListView.separated(
                    itemCount: _convs.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final c = _convs[i];
                      final unread = (c['unreadCount'] ?? 0) as int;
                      final lastAt = DateTime.tryParse(c['lastMessageAt'] ?? '');

                      return ListTile(
                        onTap: () => context.push('/messages/${c['applicationId']}'),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                          child: Text(
                            (c['otherUserName'] ?? '?').toString().substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                        ),
                        title: Row(children: [
                          Expanded(child: Text(c['otherUserName'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
                          if (lastAt != null) Text(timeago.format(lastAt, locale: 'tr'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ]),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const SizedBox(height: 2),
                          Text(c['opportunityTitle'] ?? '', style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(c['lastMessage'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: unread > 0 ? Colors.white : AppTheme.textSecondary, fontSize: 13, fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal)),
                        ]),
                        trailing: unread > 0
                            ? Container(
                                width: 22, height: 22,
                                decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                                child: Center(child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                              )
                            : null,
                      );
                    },
                  ),
      ),
    );
  }
}
