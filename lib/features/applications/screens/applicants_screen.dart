import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

class ApplicantsScreen extends StatefulWidget {
  final int opportunityId;
  const ApplicantsScreen({super.key, required this.opportunityId});
  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.applicants(widget.opportunityId));
      if (mounted) setState(() { _items = res.data['data'] ?? []; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _updateStatus(int applicationId, String status) async {
    try {
      await ApiClient().dio.put(ApiConstants.updateStatus(applicationId), data: {'status': status});
      _load();
    } catch (_) {}
  }

  Color _matchColor(num pct) => pct >= 70 ? AppTheme.success : (pct >= 40 ? AppTheme.warning : AppTheme.error);

  String _statusLabel(String s) => switch (s) {
    'Pending' => 'Beklemede',
    'UnderReview' => 'İncelemede',
    'Shortlisted' => 'Ön Eleme',
    'InterviewScheduled' => 'Mülakat',
    'Accepted' => 'Kabul',
    'Rejected' => 'Red',
    _ => s,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Başvuranlar')),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? const Center(child: Text('Henüz başvuru yok.', style: TextStyle(color: AppTheme.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final a = _items[i];
                      final match = (a['matchPercentage'] ?? 0) as num;
                      final isBlind = a['isBlindApplication'] ?? false;
                      final status = a['status'] ?? 'Pending';

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                                child: Icon(isBlind ? Icons.person_off_outlined : Icons.person_outline, color: AppTheme.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(a['studentName'] ?? 'Bilinmiyor', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                                if (isBlind) const Text('Anonim Başvuru', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              ])),
                              _StatusPill(label: _statusLabel(status), status: status),
                            ]),
                            const SizedBox(height: 14),

                            // Match bar
                            Row(children: [
                              Text('Eşleşme: ', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              Text('${match.toInt()}%', style: TextStyle(color: _matchColor(match), fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: LinearPercentIndicator(
                                  percent: match.toDouble() / 100,
                                  lineHeight: 8,
                                  barRadius: const Radius.circular(4),
                                  progressColor: _matchColor(match),
                                  backgroundColor: _matchColor(match).withValues(alpha: 0.15),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ]),

                            if ((a['matchSummary'] ?? '').toString().isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(a['matchSummary'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5)),
                            ],

                            const SizedBox(height: 14),
                            // Status update
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: [
                                _ActionBtn(label: 'İncele', color: AppTheme.info, onTap: () => _updateStatus(a['id'], 'UnderReview')),
                                const SizedBox(width: 6),
                                _ActionBtn(label: 'Ön Eleme', color: AppTheme.primary, onTap: () => _updateStatus(a['id'], 'Shortlisted')),
                                const SizedBox(width: 6),
                                _ActionBtn(label: 'Kabul', color: AppTheme.success, onTap: () => _updateStatus(a['id'], 'Accepted')),
                                const SizedBox(width: 6),
                                _ActionBtn(label: 'Red', color: AppTheme.error, onTap: () => _updateStatus(a['id'], 'Rejected')),
                              ]),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label, status;
  const _StatusPill({required this.label, required this.status});

  Color get color => switch (status) {
    'Accepted' => AppTheme.success,
    'Rejected' => AppTheme.error,
    'Shortlisted' || 'InterviewScheduled' => AppTheme.primary,
    'UnderReview' => AppTheme.info,
    _ => AppTheme.warning,
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.4))),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      foregroundColor: color, side: BorderSide(color: color),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
    child: Text(label),
  );
}
