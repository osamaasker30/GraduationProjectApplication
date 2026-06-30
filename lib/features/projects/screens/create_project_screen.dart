import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});
  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _repoCtrl = TextEditingController();
  final _demoCtrl = TextEditingController();
  PlatformFile? _pickedFile;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _repoCtrl.dispose();
    _demoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'zip', 'txt', 'docx'],
    );
    if (result != null) setState(() => _pickedFile = result.files.first);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final formData = FormData.fromMap({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'repositoryUrl': _repoCtrl.text.trim(),
        'demoUrl': _demoCtrl.text.trim(),
        if (_pickedFile != null)
          'projectFile': await MultipartFile.fromFile(
            _pickedFile!.path!,
            filename: _pickedFile!.name,
          ),
      });

      await ApiClient().dio.post(
        ApiConstants.projects,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Proje eklendi ve AI değerlendirmesi başlatıldı!'),
          backgroundColor: AppTheme.success,
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Proje eklenemedi.'),
          backgroundColor: AppTheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Proje Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const _SectionHeader(title: 'Proje Bilgileri', icon: Icons.folder_outlined),
            const SizedBox(height: 14),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Proje Başlığı *', prefixIcon: Icon(Icons.title)),
              validator: (v) => v!.isEmpty ? 'Başlık zorunludur' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Açıklama *', prefixIcon: Icon(Icons.description_outlined)),
              validator: (v) => v!.isEmpty ? 'Açıklama zorunludur' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _repoCtrl,
              decoration: const InputDecoration(labelText: 'Depo Bağlantısı (GitHub...)', prefixIcon: Icon(Icons.code)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _demoCtrl,
              decoration: const InputDecoration(labelText: 'Demo Bağlantısı', prefixIcon: Icon(Icons.play_circle_outline)),
            ),
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Proje Dosyası', icon: Icons.attach_file),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), style: BorderStyle.solid),
                ),
                child: Row(children: [
                  Icon(_pickedFile != null ? Icons.check_circle : Icons.upload_file, color: AppTheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_pickedFile != null ? _pickedFile!.name : 'Dosya Seç (PDF, ZIP, TXT...)',
                        style: TextStyle(color: _pickedFile != null ? Colors.white : AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                    if (_pickedFile != null)
                      Text('${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ])),
                ]),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.rocket_launch_outlined),
                label: Text(_loading ? 'Ekleniyor...' : 'Projeyi Kaydet'),
                onPressed: _loading ? null : _submit,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Proje kaydedildikten sonra AI otomatik olarak değerlendirecektir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: AppTheme.primary, size: 20),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
  ]);
}
