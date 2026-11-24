import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/models/experience.dart';
import 'package:myportfolio_mobile/services/api_client.dart';
import 'package:myportfolio_mobile/services/auth_state.dart';
import 'package:myportfolio_mobile/widgets/api_error.dart';
import 'package:myportfolio_mobile/widgets/auth_guard.dart';
import 'package:myportfolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Formulir Tambah/Edit Pengalaman, mengikuti `ExperienceSerializer` Django.
///
/// | Field API     | Input di form                           |
/// |---------------|-----------------------------------------|
/// | `title`       | TextFormField, wajib, maks. 255         |
/// | `description` | TextFormField multi-baris, wajib        |
/// | `category`    | Dropdown dari `EXPERIENCE_CHOICES`      |
/// | `ended_at`    | showDatePicker, kosong = masih berjalan |
///
/// Tanpa [initial], Simpan mengirim `POST /api/v1/experiences/`. Dengan
/// [initial], form terisi data lama dan Simpan mengirim `PATCH` ke entri itu.
/// Keduanya butuh token, jadi [ensureLoggedIn] membuka layar login dulu kalau
/// belum masuk. Setelah berhasil, tombol OK menutup form dan mengembalikan
/// [Experience] hasil simpan ke halaman pemanggil.
///
/// `started_at` diisi server saat dibuat, jadi tanggal selesai tidak boleh
/// sebelum tanggal mulai (hari ini untuk entri baru).
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({this.initial, super.key});

  /// Entri yang sedang diedit, atau `null` untuk entri baru.
  final Experience? initial;

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  late String _title = widget.initial?.title ?? '';
  late String _description = widget.initial?.description ?? '';
  late String _category =
      widget.initial?.category ?? Experience.defaultCategory;

  /// Tanggal selesai sebagai tanggal kalender lokal (tanpa jam).
  late DateTime? _endedAt = _dateOnly(widget.initial?.endedAt);
  late bool _ongoing = widget.initial?.isOngoing ?? true;
  bool _isSubmitting = false;

  // Controller hanya untuk menampilkan tanggal terpilih di field read-only.
  late final _endedController = TextEditingController(
    text: _endedAt == null ? '' : formatDate(_endedAt!),
  );

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _endedController.dispose();
    super.dispose();
  }

  static DateTime? _dateOnly(DateTime? d) =>
      d == null ? null : DateTime(d.year, d.month, d.day);

  /// Tanggal mulai: dari server saat edit, atau hari ini untuk entri baru.
  DateTime get _startDate =>
      _dateOnly(widget.initial?.startedAt?.toLocal()) ??
      _dateOnly(DateTime.now())!;

  /// Validator teks wajib: tolak kosong / hanya spasi, dan batasi panjang bila ada.
  String? _requiredText(String? value, String label, {int? maxLength}) {
    if (value == null || value.trim().isEmpty) {
      return '$label tidak boleh kosong!';
    }
    if (maxLength != null && value.trim().length > maxLength) {
      return '$label maksimal $maxLength karakter!';
    }
    return null;
  }

  /// `ended_at` boleh kosong (masih berjalan). Kalau diisi, tidak boleh
  /// sebelum `started_at`. Server memeriksa aturan yang sama.
  String? _validateEndedAt(String? _) {
    if (_ongoing) return null;
    if (_endedAt == null) {
      return 'Pilih tanggal selesai, atau centang "Masih berjalan"';
    }
    if (_endedAt!.isBefore(_startDate)) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai '
          '(${formatDate(_startDate)})!';
    }
    return null;
  }

  Future<void> _pickEndedAt() async {
    final today = _dateOnly(DateTime.now())!;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _endedAt ?? (today.isBefore(_startDate) ? _startDate : today),
      firstDate: _startDate,
      lastDate: DateTime(today.year + 10),
    );
    if (picked == null) return;
    setState(() {
      _endedAt = picked;
      _endedController.text = formatDate(picked);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await ensureLoggedIn(context) || !mounted) return;

    final ended = _ongoing ? null : _endedAt!;
    final experience = Experience(
      title: _title.trim(),
      description: _description.trim(),
      category: _category,
      // Tengah malam UTC dari tanggal yang dipilih: tanggalnya tidak bergeser
      // saat disimpan Django (USE_TZ = True, TIME_ZONE = 'UTC').
      endedAt: ended == null
          ? null
          : DateTime.utc(ended.year, ended.month, ended.day),
    );
    final api = context.read<ApiClient>();
    final token = context.read<AuthState>().token!;

    setState(() => _isSubmitting = true);
    Experience? saved;
    try {
      saved = _isEditing
          ? await api.updateExperience(
              widget.initial!.id!,
              experience,
              token: token,
            )
          : await api.createExperience(experience, token: token);
    } on ApiException catch (e) {
      if (mounted) {
        await handleApiError(context, e, action: 'menyimpan pengalaman');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
    // Spinner sudah berhenti sebelum dialog muncul.
    if (saved != null && mounted) await _showSuccess(saved);
  }

  Future<void> _showSuccess(Experience saved) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          _isEditing
              ? 'Pengalaman berhasil diperbarui!'
              : 'Pengalaman berhasil disimpan!',
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Judul: ${saved.title}'),
              Text('Deskripsi: ${saved.description}'),
              Text('Kategori: ${saved.categoryLabel}'),
              if (saved.startedAt != null)
                Text('Mulai: ${formatDate(saved.startedAt!.toLocal())}'),
              Text(
                'Selesai: ${saved.isOngoing ? 'Masih berjalan' : formatDate(saved.endedAt!)}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    // Kembali ke halaman sebelumnya (daftar/detail) dengan data hasil simpan.
    if (mounted) Navigator.pop(context, saved);
  }

  InputDecoration _decoration(
    String label, {
    String? hint,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffixIcon,
    alignLabelWithHint: true,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
  );

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Pengalaman' : 'Tambah Pengalaman',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // Warna sama dengan AppBar halaman utama (warna primer tema).
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      // Saat edit, tombol back lebih jelas daripada drawer.
      drawer: _isEditing ? null : const LeftDrawer(),
      body: Form(
        key: _formKey,
        // SafeArea + SingleChildScrollView supaya semua field dan tombol Simpan
        // tetap bisa digulir saat layar sempit atau papan ketik muncul.
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _title,
                  decoration: _decoration(
                    'Judul',
                    hint: 'Contoh: Asisten Dosen PBP',
                  ),
                  textInputAction: TextInputAction.next,
                  maxLength: Experience.titleMaxLength,
                  onChanged: (value) => _title = value,
                  validator: (value) => _requiredText(
                    value,
                    'Judul',
                    maxLength: Experience.titleMaxLength,
                  ),
                ),
                gap,
                TextFormField(
                  initialValue: _description,
                  decoration: _decoration(
                    'Deskripsi',
                    hint: 'Apa yang kamu kerjakan dan pelajari?',
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: 6,
                  onChanged: (value) => _description = value,
                  validator: (value) => _requiredText(value, 'Deskripsi'),
                ),
                gap,
                DropdownButtonFormField<String>(
                  decoration: _decoration('Kategori'),
                  initialValue: _category,
                  items: Experience.categories.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
                gap,
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Masih berjalan'),
                  subtitle: Text(
                    _isEditing
                        ? 'Mulai ${formatDate(_startDate)}'
                        : 'Tanggal mulai terisi otomatis saat disimpan',
                  ),
                  value: _ongoing,
                  onChanged: (value) => setState(() => _ongoing = value!),
                ),
                if (!_ongoing)
                  TextFormField(
                    controller: _endedController,
                    readOnly: true,
                    decoration: _decoration(
                      'Tanggal Selesai',
                      hint: 'Pilih tanggal',
                      suffixIcon: const Icon(Icons.event_available),
                    ),
                    onTap: _pickEndedAt,
                    validator: _validateEndedAt,
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isSubmitting ? null : _save,
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
