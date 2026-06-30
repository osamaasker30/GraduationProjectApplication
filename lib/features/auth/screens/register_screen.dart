import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  final bool isStudent;
  const RegisterScreen({super.key, required this.isStudent});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _ctrl = {};
  bool _obscure = true;

  final List<Map<String, dynamic>> _studentFields = [
    {'key': 'fullName', 'label': 'Ad Soyad', 'icon': Icons.person_outline},
    {'key': 'email', 'label': 'E-posta', 'icon': Icons.email_outlined, 'type': TextInputType.emailAddress},
    {'key': 'password', 'label': 'Şifre', 'icon': Icons.lock_outline, 'isPass': true},
    {'key': 'confirmPassword', 'label': 'Şifre Tekrar', 'icon': Icons.lock_outline, 'isPass': true},
    {'key': 'university', 'label': 'Üniversite', 'icon': Icons.school_outlined},
    {'key': 'faculty', 'label': 'Fakülte', 'icon': Icons.account_balance_outlined},
    {'key': 'major', 'label': 'Bölüm', 'icon': Icons.book_outlined},
    {'key': 'academicYear', 'label': 'Sınıf (1-4)', 'icon': Icons.calendar_today_outlined, 'type': TextInputType.number},
    {'key': 'phoneNumber', 'label': 'Telefon', 'icon': Icons.phone_outlined, 'type': TextInputType.phone},
  ];

  final List<Map<String, dynamic>> _companyFields = [
    {'key': 'fullName', 'label': 'Yetkili Ad Soyad', 'icon': Icons.person_outline},
    {'key': 'email', 'label': 'Kurumsal E-posta', 'icon': Icons.email_outlined, 'type': TextInputType.emailAddress},
    {'key': 'password', 'label': 'Şifre', 'icon': Icons.lock_outline, 'isPass': true},
    {'key': 'confirmPassword', 'label': 'Şifre Tekrar', 'icon': Icons.lock_outline, 'isPass': true},
    {'key': 'companyName', 'label': 'Şirket Adı', 'icon': Icons.business_outlined},
    {'key': 'industry', 'label': 'Sektör', 'icon': Icons.category_outlined},
    {'key': 'description', 'label': 'Şirket Hakkında', 'icon': Icons.info_outline, 'lines': 3},
    {'key': 'websiteUrl', 'label': 'Web Sitesi', 'icon': Icons.language_outlined},
    {'key': 'phoneNumber', 'label': 'Telefon', 'icon': Icons.phone_outlined, 'type': TextInputType.phone},
  ];

  @override
  void initState() {
    super.initState();
    final fields = widget.isStudent ? _studentFields : _companyFields;
    for (final f in fields) {
      _ctrl[f['key'] as String] = TextEditingController();
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

    final data = Map<String, dynamic>.fromEntries(
      _ctrl.entries.map((e) => MapEntry(e.key, e.value.text.trim())),
    );
    if (data['academicYear'] != null) {
      data['academicYear'] = int.tryParse(data['academicYear'].toString()) ?? 1;
    }

    final auth = context.read<AuthProvider>();
    final ok = widget.isStudent
        ? await auth.registerStudent(data)
        : await auth.registerCompany(data);

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isStudent
              ? 'Kayıt başarılı! Giriş yapabilirsiniz.'
              : 'Kayıt başarılı! Admin onayı bekleniyor.'),
          backgroundColor: AppTheme.success,
        ),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Kayıt başarısız.'), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fields = widget.isStudent ? _studentFields : _companyFields;
    final title = widget.isStudent ? 'Öğrenci Kaydı' : 'Şirket Kaydı';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...fields.map((f) {
                final key = f['key'] as String;
                final isPass = f['isPass'] == true;
                final lines = f['lines'] as int?;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TextFormField(
                    controller: _ctrl[key],
                    obscureText: isPass && _obscure,
                    keyboardType: f['type'] as TextInputType? ?? TextInputType.text,
                    maxLines: lines ?? 1,
                    decoration: InputDecoration(
                      labelText: f['label'] as String,
                      prefixIcon: Icon(f['icon'] as IconData),
                      suffixIcon: isPass
                          ? IconButton(
                              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            )
                          : null,
                    ),
                    validator: (v) {
                      if (key == 'phoneNumber' || key == 'websiteUrl' || key == 'description') {
                        return null;
                      }
                      if (v == null || v.isEmpty) return '${f['label']} zorunludur';
                      if (key == 'confirmPassword' && v != _ctrl['password']?.text) {
                        return 'Şifreler eşleşmiyor';
                      }
                      return null;
                    },
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isStudent ? AppTheme.primary : AppTheme.secondary,
                  ),
                  child: auth.isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(widget.isStudent ? 'Öğrenci Olarak Kaydol' : 'Şirket Olarak Kaydol'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Zaten hesabın var mı? Giriş yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
