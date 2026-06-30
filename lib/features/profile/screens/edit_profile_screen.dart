import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

/// Universal edit screen for both Student and Company profiles
class EditProfileScreen extends StatefulWidget {
  final bool isCompany;
  final Map<String, dynamic>? existing;
  const EditProfileScreen({super.key, required this.isCompany, this.existing});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _ctrl = {};
  bool _loading = false;

  List<Map<String, dynamic>> get _fields => widget.isCompany
      ? [
          {'key': 'fullName', 'label': 'Yetkili Ad Soyad', 'icon': Icons.person_outline},
          {'key': 'companyName', 'label': 'Şirket Adı', 'icon': Icons.business_outlined},
          {'key': 'industry', 'label': 'Sektör', 'icon': Icons.category_outlined},
          {'key': 'description', 'label': 'Şirket Hakkında', 'icon': Icons.info_outline, 'lines': 4},
          {'key': 'websiteUrl', 'label': 'Web Sitesi', 'icon': Icons.language_outlined},
          {'key': 'phoneNumber', 'label': 'Telefon', 'icon': Icons.phone_outlined, 'optional': true},
        ]
      : [
          {'key': 'fullName', 'label': 'Ad Soyad', 'icon': Icons.person_outline},
          {'key': 'phoneNumber', 'label': 'Telefon', 'icon': Icons.phone_outlined, 'optional': true},
          {'key': 'university', 'label': 'Üniversite', 'icon': Icons.school_outlined},
          {'key': 'faculty', 'label': 'Fakülte', 'icon': Icons.account_balance_outlined},
          {'key': 'major', 'label': 'Bölüm', 'icon': Icons.book_outlined},
          {'key': 'academicYear', 'label': 'Sınıf (1-4)', 'icon': Icons.calendar_today_outlined,
           'type': TextInputType.number},
          {'key': 'bio', 'label': 'Hakkımda', 'icon': Icons.notes_outlined, 'lines': 3, 'optional': true},
          {'key': 'skillsText', 'label': 'Yetenekler', 'icon': Icons.star_outline, 'optional': true,
           'hint': 'C#, Flutter, SQL (virgülle)'},
          {'key': 'linkedInUrl', 'label': 'LinkedIn', 'icon': Icons.link, 'optional': true},
          {'key': 'gitHubUrl', 'label': 'GitHub', 'icon': Icons.code, 'optional': true},
          {'key': 'portfolioUrl', 'label': 'Portfolyo', 'icon': Icons.language_outlined, 'optional': true},
        ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing ?? {};
    for (final f in _fields) {
      final key = f['key'] as String;
      _ctrl[key] = TextEditingController(text: e[key]?.toString() ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final body = <String, dynamic>{};
    for (final f in _fields) {
      final key = f['key'] as String;
      final isOptional = f['optional'] == true;
      final val = _ctrl[key]!.text.trim();
      // Send null for empty optional fields (avoids [Url]/[Phone] validation errors)
      body[key] = (isOptional && val.isEmpty) ? null : val;
    }
    if (!widget.isCompany) {
      body['academicYear'] = int.tryParse(_ctrl['academicYear']?.text ?? '1') ?? 1;
    }

    try {
      final url = widget.isCompany ? ApiConstants.companyProfile : ApiConstants.studentProfile;
      await ApiClient().dio.put(url, data: body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellendi.'), backgroundColor: AppTheme.success),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Güncelleme başarısız.'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isCompany ? 'Şirket Profilini Düzenle' : 'Profili Düzenle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._fields.map((f) {
                final key = f['key'] as String;
                final optional = f['optional'] == true;
                final lines = f['lines'] as int? ?? 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TextFormField(
                    controller: _ctrl[key],
                    maxLines: lines,
                    keyboardType: f['type'] as TextInputType? ?? TextInputType.text,
                    decoration: InputDecoration(
                      labelText: f['label'] as String,
                      hintText: f['hint'] as String?,
                      prefixIcon: Icon(f['icon'] as IconData),
                    ),
                    validator: optional
                        ? null
                        : (v) => v == null || v.isEmpty ? '${f['label']} zorunludur' : null,
                  ),
                );
              }),
              const SizedBox(height: 8),
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
