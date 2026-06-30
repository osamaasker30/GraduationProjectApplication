import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
class ChatScreen extends StatefulWidget {
  final int applicationId;
  const ChatScreen({super.key, required this.applicationId});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _msgs = [];
  bool _loading = true;
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.messages(widget.applicationId));
      if (mounted) {
        setState(() { _msgs = res.data['data'] ?? []; _loading = false; });
        _scrollBottom();
      }
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() => _sending = true);
    try {
      await ApiClient().dio.post(ApiConstants.sendMessage, data: {'applicationId': widget.applicationId, 'content': text});
      await _load();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesaj gönderilemedi.'), backgroundColor: AppTheme.error));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mesajlaşma'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ]),
      body: Column(children: [
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _msgs.isEmpty
                  ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.chat_outlined, size: 56, color: AppTheme.textSecondary),
                      SizedBox(height: 12),
                      Text('Henüz mesaj yok.\nİlk mesajı gönderin!', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
                    ]))
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _msgs.length,
                      itemBuilder: (context, i) {
                        final m = _msgs[i];
                        final isMine = m['isMine'] ?? false;
                        final time = DateTime.tryParse(m['createdAt'] ?? '');

                        return Align(
                          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            child: Column(
                              crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                if (!isMine) Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                                  child: Text(m['senderName'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: isMine ? const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]) : null,
                                    color: isMine ? null : AppTheme.surfaceVariant,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isMine ? 16 : 4),
                                      bottomRight: Radius.circular(isMine ? 4 : 16),
                                    ),
                                    border: isMine ? null : Border.all(color: Colors.white.withValues(alpha: 0.07)),
                                  ),
                                  child: Column(crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                                    Text(m['content'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
                                    if (time != null) ...[
                                      const SizedBox(height: 4),
                                      Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 10)),
                                    ],
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),

        // Input
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
          ),
          child: SafeArea(
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Mesajınızı yazın...', contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: _sending ? null : _send,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 48, height: 48,
                    alignment: Alignment.center,
                    child: _sending
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
