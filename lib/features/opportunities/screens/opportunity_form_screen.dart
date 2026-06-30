import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

class OpportunityFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existing; // null = create, non-null = edit
  const OpportunityFormScreen({super.key, this.existing});

  @override
  State<OpportunityFormScreen> createState() => _OpportunityFormScreenState();
}

class _OpportunityFormScreenState extends State<OpportunityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _skills;
  late final TextEditingController _requirements;
  String _type = 'Job';
  DateTime? _deadline;
  bool _loading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?['title'] ?? '');
    _description = TextEditingController(text: e?['description'] ?? '');
    _skills = TextEditingController(text: e?['requiredSkills'] ?? '');
    _requirements = TextEditingController(text: e?['requirements'] ?? '');
    _type = e?['type'] ?? 'Job';
    if (e?['deadline'] != null) {
      _deadline = DateTime.tryParse(e!['deadline']);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _skills.dispose();
    _requirements.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.surfaceVariant,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen son başvuru tarihi seçin.'), backgroundColor: AppTheme.warning),
      );
      return;
    }

    setState(() => _loading = true);

    final body = {
      'title': _title.text.trim(),
      'description': _description.text.trim(),
      'type': _type,
      'requiredSkills': _skills.text.trim(),
      'requirements': _requirements.text.trim(),
      'deadline': _deadline!.toIso8601String(),
      'isActive': true,
    };

    try {
      if (_isEdit) {
        final id = widget.existing!['id'];
        await ApiClient().dio.put(ApiConstants.companyOpportunityById(id), data: body);
      } else {
        await ApiClient().dio.post(ApiConstants.companyOpportunities, data: body);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'İlan güncellendi.' : 'İlan oluşturuldu.'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İşlem başarısız.'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'İlanı Düzenle' : 'Yeni İlan Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                controller: _title,
                label: 'İlan Başlığı *',
                icon: Icons.title,
                validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _description,
                label: 'Açıklama *',
                icon: Icons.description_outlined,
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 14),

              // Type dropdown
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: 'Fırsat Türü *',
                  prefixIcon: const Icon(Icons.category_outlined),
                  filled: true,
                  fillColor: AppTheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                dropdownColor: AppTheme.surfaceVariant,
                items: const [
                  DropdownMenuItem(value: 'Job', child: Text('İş İlanı')),
                  DropdownMenuItem(value: 'InternshipShort', child: Text('Kısa Süreli Staj')),
                  DropdownMenuItem(value: 'InternshipLong', child: Text('Uzun Süreli Staj')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'Job'),
              ),
              const SizedBox(height: 14),

              _field(
                controller: _skills,
                label: 'Gerekli Yetenekler *',
                icon: Icons.star_outline,
                hint: 'C#, SQL, Flutter (virgülle ayırın)',
                validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _requirements,
                label: 'Koşullar / Gereksinimler',
                icon: Icons.checklist_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 14),

              // Deadline picker
              InkWell(
                onTap: _pickDeadline,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Son Başvuru Tarihi *',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    filled: true,
                    fillColor: AppTheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _deadline != null
                        ? '${_deadline!.day}.${_deadline!.month}.${_deadline!.year}'
                        : 'Tarih seçin...',
                    style: TextStyle(
                      color: _deadline != null ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(_isEdit ? Icons.save_outlined : Icons.rocket_launch_outlined),
                  label: Text(_loading
                      ? 'Kaydediliyor...'
                      : (_isEdit ? 'Değişiklikleri Kaydet' : 'İlanı Yayınla')),
                  onPressed: _loading ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}
