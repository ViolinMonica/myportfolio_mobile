import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/widgets/left_drawer.dart';

/// Halaman formulir Tambah Pengalaman, mengikuti model Django `Experience`
/// di proyek web portofolio (`main/models.py`).
///
/// | Field model   | Input di form                           |
/// |---------------|-----------------------------------------|
/// | `title`       | TextFormField, wajib, maks. 255         |
/// | `description` | TextFormField multi-baris, wajib        |
/// | `category`    | Dropdown dari `EXPERIENCE_CHOICES`      |
/// | `ended_at`    | showDatePicker, kosong = masih berjalan |
///
/// `started_at` memakai `auto_now_add` (terisi otomatis saat disimpan), jadi
/// tidak ada di form. Akibatnya tanggal selesai tidak boleh sebelum hari ini.
/// Saat Simpan ditekan, [FormState.validate] menjalankan semua validator;
/// ringkasan isian hanya muncul di dialog kalau semuanya lolos.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  /// `title = models.CharField(max_length=255)`
  static const int titleMaxLength = 255;

  /// `EXPERIENCE_CHOICES`: nilai yang disimpan → label yang ditampilkan.
  static const Map<String, String> categories = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  String _title = '';
  String _description = '';
  String _category = 'full-time'; // default di model
  DateTime? _endedAt;
  bool _ongoing = true; // ended_at kosong = masih berjalan

  // Controller hanya untuk menampilkan tanggal terpilih di field read-only.
  final _endedController = TextEditingController();

  @override
  void dispose() {
    _endedController.dispose();
    super.dispose();
  }

  /// Format tanggal dd/mm/yyyy tanpa package tambahan.
  static String formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

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

  /// `ended_at` boleh kosong (masih berjalan). Kalau diisi, tidak boleh sebelum
  /// `started_at`, yaitu hari ini karena `started_at` terisi otomatis saat disimpan.
  String? _validateEndedAt(String? _) {
    if (_ongoing) return null;
    if (_endedAt == null) return 'Pilih tanggal selesai, atau centang "Masih berjalan"';
    if (_endedAt!.isBefore(_today)) return 'Tanggal selesai tidak boleh sebelum tanggal mulai (hari ini)!';
    return null;
  }

  Future<void> _pickEndedAt() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endedAt ?? _today,
      firstDate: _today,
      lastDate: DateTime(_today.year + 10),
    );
    if (picked == null) return;
    setState(() {
      _endedAt = picked;
      _endedController.text = formatDate(picked);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengalaman berhasil disimpan!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Judul: ${_title.trim()}'),
              Text('Deskripsi: ${_description.trim()}'),
              Text('Kategori: ${categories[_category]}'),
              Text('Mulai: ${formatDate(_today)}'),
              Text('Selesai: ${_ongoing ? 'Masih berjalan' : formatDate(_endedAt!)}'),
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
  }

  InputDecoration _decoration(String label, {String? hint, Widget? suffixIcon}) => InputDecoration(
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
        title: const Text(
          'Tambah Pengalaman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Warna sama dengan AppBar halaman utama (warna primer tema).
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
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
                  decoration: _decoration('Judul', hint: 'Contoh: Asisten Dosen PBP'),
                  textInputAction: TextInputAction.next,
                  maxLength: titleMaxLength,
                  onChanged: (value) => setState(() => _title = value),
                  validator: (value) => _requiredText(value, 'Judul', maxLength: titleMaxLength),
                ),
                gap,
                TextFormField(
                  decoration: _decoration('Deskripsi', hint: 'Apa yang kamu kerjakan dan pelajari?'),
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: 6,
                  onChanged: (value) => setState(() => _description = value),
                  validator: (value) => _requiredText(value, 'Deskripsi'),
                ),
                gap,
                DropdownButtonFormField<String>(
                  decoration: _decoration('Kategori'),
                  initialValue: _category,
                  items: categories.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
                gap,
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Masih berjalan'),
                  subtitle: const Text('Tanggal mulai terisi otomatis saat disimpan'),
                  value: _ongoing,
                  onChanged: (value) => setState(() => _ongoing = value!),
                ),
                if (!_ongoing)
                  TextFormField(
                    controller: _endedController,
                    readOnly: true,
                    decoration: _decoration('Tanggal Selesai',
                        hint: 'Pilih tanggal', suffixIcon: const Icon(Icons.event_available)),
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
                  onPressed: _save,
                  icon: const Icon(Icons.save),
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
