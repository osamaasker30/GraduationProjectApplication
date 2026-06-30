import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final int id;
  const OpportunityDetailScreen({super.key, required this.id});
  @override
  State<OpportunityDetailScreen> createState() => _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  Map<String, dynamic>? _opp;
  bool _loading = true;
  bool _applying = false;
  bool _blindApplication = false;
  PlatformFile? _cvFile;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.opportunityById(widget.id));
      if (mounted) setState(() { _opp = res.data['data']; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _pickCv() async {
    // withData: true → loads bytes into memory (works on real Android devices)
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _cvFile = result.files.first);
    }
  }

  Future<void> _apply() async {
    if (_cvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen CV dosyası seçin.'), backgroundColor: AppTheme.warning),
      );
      return;
    }

    final bytes = _cvFile!.bytes;
    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dosya okunamadı. Lütfen tekrar deneyin.'), backgroundColor: AppTheme.error),
      );
      return;
    }

    setState(() => _applying = true);
    try {
      // Use bytes (not path) — safe on all Android versions
      final formData = FormData.fromMap({
        'opportunityId': widget.id.toString(),
        'isBlindApplication': _blindApplication.toString(),
        'cvFile': MultipartFile.fromBytes(bytes, filename: _cvFile!.name),
      });

      await ApiClient().dio.post(
        ApiConstants.apply,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Başvurunuz alındı! AI eşleşme analizi tamamlandı.'),
          backgroundColor: AppTheme.success,
        ));
        if (context.mounted) Navigator.of(context).pop();
      }
    } on DioException catch (e) {
      if (mounted) {
        final msg = e.response?.statusCode == 409
            ? 'Bu pozisyona zaten başvurdunuz.'
            : (e.response?.data?['message'] ?? 'Başvuru gönderilemedi.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  String _typeLabel(String t) => switch (t) {
    'Job' => 'İş İlanı', 'InternshipShort' => 'Kısa Staj', 'InternshipLong' => 'Uzun Staj', _ => t,
  };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final deadline = DateTime.tryParse(_opp?['deadline'] ?? '');
    final expired = deadline != null && deadline.isBefore(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text(_opp?['title'] ?? 'Fırsat Detayı')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Header
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Text(_opp?['title'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white))),
                  const SizedBox(width: 8),
                  _Badge(label: _typeLabel(_opp?['type'] ?? ''), color: AppTheme.primary),
                ]),
                const SizedBox(height: 6),
                if (_opp?['company']?['companyName'] != null)
                  Text(_opp!['company']['companyName'], style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 16),

                // Description
                _InfoCard(title: 'Açıklama', content: _opp?['description'] ?? ''),
                const SizedBox(height: 12),

                // Skills
                if ((_opp?['requiredSkills'] ?? '').toString().isNotEmpty) ...[
                  const Text('Gerekli Yetenekler', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 6,
                    children: (_opp!['requiredSkills'] as String).split(',').map((s) => Chip(label: Text(s.trim()))).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                if ((_opp?['requirements'] ?? '').toString().isNotEmpty) ...[
                  _InfoCard(title: 'Gereksinimler', content: _opp!['requirements']),
                  const SizedBox(height: 12),
                ],

                Row(children: [
                  Icon(expired ? Icons.event_busy : Icons.calendar_today, color: expired ? AppTheme.error : AppTheme.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    deadline != null ? 'Son Başvuru: ${deadline.day}.${deadline.month}.${deadline.year}' : '',
                    style: TextStyle(color: expired ? AppTheme.error : AppTheme.textSecondary, fontSize: 13),
                  ),
                ]),
                const SizedBox(height: 28),

                // Apply section (student only)
                if (auth.isStudent && !expired) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Başvur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _pickCv,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                      ),
                      child: Row(children: [
                        Icon(_cvFile != null ? Icons.check_circle : Icons.upload_file, color: AppTheme.primary, size: 26),
                        const SizedBox(width: 12),
                        Text(_cvFile != null ? _cvFile!.name : 'CV Seç (PDF veya TXT)',
                            style: TextStyle(color: _cvFile != null ? Colors.white : AppTheme.textSecondary)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _blindApplication,
                    onChanged: (v) => setState(() => _blindApplication = v),
                    title: const Text('Gizli Başvuru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Kişisel bilgileriniz şirket tarafından görülmez.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    activeThumbColor: AppTheme.primary,
                    activeTrackColor: AppTheme.primary.withValues(alpha: 0.4),
                    contentPadding: EdgeInsets.zero,
                    tileColor: Colors.transparent,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: _applying
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_outlined),
                      label: Text(_applying ? 'Gönderiliyor...' : 'Başvuruyu Gönder'),
                      onPressed: _applying ? null : _apply,
                    ),
                  ),
                ] else if (auth.isStudent && expired)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.error.withValues(alpha: 0.3))),
                    child: const Row(children: [
                      Icon(Icons.event_busy, color: AppTheme.error),
                      SizedBox(width: 10),
                      Text('Bu ilanın başvuru süresi sona erdi.', style: TextStyle(color: AppTheme.error)),
                    ]),
                  ),
              ]),
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title, content;
  const _InfoCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
    const SizedBox(height: 6),
    Text(content, style: const TextStyle(color: AppTheme.textSecondary, height: 1.6)),
  ]);
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.4))),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}
