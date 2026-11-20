import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/widgets/left_drawer.dart';

/// Halaman formulir Tambah Edukasi untuk bagian riwayat pendidikan portofolio.
///
/// Field mengikuti model Edukasi: institusi, jenjang, program studi,
/// tanggal mulai, tanggal selesai (atau masih berjalan), dan IPK (opsional).
/// Saat Simpan ditekan, [FormState.validate] menjalankan semua validator;
/// ringkasan isian hanya muncul di dialog kalau semuanya lolos.
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();

  static const int maxTextLength = 100;
  static const List<String> degrees = ['SMA/SMK', 'D3', 'D4', 'S1', 'S2', 'S3'];

  String _institution = '';
  String _degree = 'S1';
  String _major = '';
  String _gpa = '';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _ongoing = false;

  // Controller hanya untuk menampilkan tanggal terpilih di field read-only.
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  /// Format tanggal dd/mm/yyyy tanpa package tambahan.
  static String formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  /// Validator teks wajib: tolak kosong / hanya spasi dan batasi panjang.
  String? _requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label tidak boleh kosong!';
    }
    if (value.trim().length > maxTextLength) {
      return '$label maksimal $maxTextLength karakter!';
    }
    return null;
  }

  /// IPK opsional, tapi kalau diisi harus angka 0.00 sampai 4.00.
  String? _validateGpa(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final gpa = double.tryParse(value.trim().replaceAll(',', '.'));
    if (gpa == null) return 'IPK harus berupa angka, contoh 3.75';
    if (gpa < 0 || gpa > 4) return 'IPK harus di antara 0.00 dan 4.00';
    return null;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? _startDate ?? now,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        _startController.text = formatDate(picked);
      } else {
        _endDate = picked;
        _endController.text = formatDate(picked);
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edukasi berhasil disimpan!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Institusi: ${_institution.trim()}'),
              Text('Jenjang: $_degree'),
              Text('Program Studi: ${_major.trim()}'),
              Text('Mulai: ${formatDate(_startDate!)}'),
              Text('Selesai: ${_ongoing ? 'Masih berjalan' : formatDate(_endDate!)}'),
              Text('IPK: ${_gpa.trim().isEmpty ? '-' : _gpa.trim()}'),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      );

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Edukasi',
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
                  decoration: _decoration('Nama Institusi', hint: 'Contoh: Universitas Indonesia'),
                  textInputAction: TextInputAction.next,
                  maxLength: maxTextLength,
                  onChanged: (value) => setState(() => _institution = value),
                  validator: (value) => _requiredText(value, 'Nama institusi'),
                ),
                gap,
                DropdownButtonFormField<String>(
                  decoration: _decoration('Jenjang'),
                  initialValue: _degree,
                  items: degrees.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (value) => setState(() => _degree = value!),
                ),
                gap,
                TextFormField(
                  decoration: _decoration('Program Studi', hint: 'Contoh: Ilmu Komputer'),
                  textInputAction: TextInputAction.next,
                  maxLength: maxTextLength,
                  onChanged: (value) => setState(() => _major = value),
                  validator: (value) => _requiredText(value, 'Program studi'),
                ),
                gap,
                TextFormField(
                  controller: _startController,
                  readOnly: true,
                  decoration: _decoration('Tanggal Mulai',
                      hint: 'Pilih tanggal', suffixIcon: const Icon(Icons.calendar_today)),
                  onTap: () => _pickDate(isStart: true),
                  validator: (_) => _startDate == null ? 'Tanggal mulai wajib dipilih!' : null,
                ),
                gap,
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Masih berjalan'),
                  value: _ongoing,
                  onChanged: (value) => setState(() => _ongoing = value!),
                ),
                if (!_ongoing) ...[
                  TextFormField(
                    controller: _endController,
                    readOnly: true,
                    decoration: _decoration('Tanggal Selesai',
                        hint: 'Pilih tanggal', suffixIcon: const Icon(Icons.event_available)),
                    onTap: () => _pickDate(isStart: false),
                    validator: (_) {
                      if (_endDate == null) return 'Tanggal selesai wajib dipilih!';
                      if (_startDate != null && _endDate!.isBefore(_startDate!)) {
                        return 'Tanggal selesai tidak boleh sebelum tanggal mulai!';
                      }
                      return null;
                    },
                  ),
                  gap,
                ],
                TextFormField(
                  decoration: _decoration('IPK (opsional)', hint: 'Contoh: 3.75'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  onChanged: (value) => setState(() => _gpa = value),
                  validator: _validateGpa,
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
