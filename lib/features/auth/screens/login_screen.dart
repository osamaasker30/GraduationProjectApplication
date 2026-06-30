import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      context.go(auth.isStudent ? '/dashboard' : '/company-dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Giriş başarısız.'), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Logo area
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.work_outline, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 24),
              Text(
                'Kariyer Köprüsü',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text('Hesabınıza giriş yapın', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) => v!.isEmpty ? 'E-posta gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'Şifre gerekli' : null,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _login,
                        child: auth.isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Giriş Yap'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Row(children: [
                Expanded(child: Divider()),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('veya', style: TextStyle(color: AppTheme.textSecondary))),
                Expanded(child: Divider()),
              ]),
              const SizedBox(height: 24),

              OutlinedButton(
                onPressed: () => context.push('/register/student'),
                child: const Text('Öğrenci Olarak Kaydol'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/register/company'),
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.secondary, side: const BorderSide(color: AppTheme.secondary)),
                child: const Text('Şirket Olarak Kaydol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
