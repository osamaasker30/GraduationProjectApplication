import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

class EditProjectScreen extends StatefulWidget {
  final int projectId;
  final Map<String, dynamic> project;
  const EditProjectScreen({
    super.key,
    required this.projectId,
    required this.project,
  });

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _repoUrl;
  late final TextEditingController _demoUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.project['title'] ?? '');
    _description = TextEditingController(text: widget.project['description'] ?? '');
    _repoUrl = TextEditingController(text: widget.project['repositoryUrl'] ?? '');
    _demoUrl = TextEditingController(text: widget.project['demoUrl'] ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _repoUrl.dispose();
    _demoUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await ApiClient().dio.put(
        ApiConstants.projectById(widget.projectId),
        data: {
          'id': widget.projectId,
          'title': _title.text.trim(),
          'description': _description.text.trim(),
          'repositoryUrl': _repoUrl.text.trim().isEmpty ? null : _repoUrl.text.trim(),
          'demoUrl': _demoUrl.text.trim().isEmpty ? null : _demoUrl.text.trim(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proje güncellendi. AI yeniden değerlendirecek.'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.pop(true); // true = refresh parent
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Güncelleme başarısız.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projeyi Düzenle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Proje Başlığı *',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v!.isEmpty ? 'Başlık zorunludur' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _description,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Açıklama *',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'Açıklama zorunludur' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _repoUrl,
                decoration: const InputDecoration(
                  labelText: 'Depo Bağlantısı (GitHub...)',
                  prefixIcon: Icon(Icons.code),
                  hintText: 'https://github.com/...',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _demoUrl,
                decoration: const InputDecoration(
                  labelText: 'Demo Bağlantısı',
                  prefixIcon: Icon(Icons.play_circle_outline),
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                ),
                child: const Row(children: [
                  Icon(Icons.auto_awesome, color: AppTheme.primary, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Proje güncellendikten sonra AI otomatik olarak yeniden değerlendirecektir.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  icon: _loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined),
                  label: Text(_loading ? 'Kaydediliyor...' : 'Değişiklikleri Kaydet'),
                  onPressed: _loading ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
