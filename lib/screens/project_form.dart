import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/models/project.dart';
import 'package:myportfolio_mobile/services/api_client.dart';
import 'package:myportfolio_mobile/services/auth_state.dart';
import 'package:myportfolio_mobile/widgets/api_error.dart';
import 'package:myportfolio_mobile/widgets/auth_guard.dart';
import 'package:myportfolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Formulir Tambah Proyek yang mengirim `POST /api/v1/projects/`.
///
/// Field mengikuti `ProjectSerializer` Django: title, description, tech_stack,
/// project_url, dan project_image_url (opsional). Pengiriman butuh token,
/// jadi [ensureLoggedIn] membuka layar login dulu kalau belum masuk.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  String _techStack = '';
  String _projectUrl = '';
  String _projectImageUrl = '';
  bool _isSubmitting = false;

  /// Batas panjang `CharField(max_length=255)` di model Django.
  static const int maxLength = 255;

  static String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label tidak boleh kosong!';
    }
    if (value.trim().length > maxLength) {
      return '$label maksimal $maxLength karakter!';
    }
    return null;
  }

  /// Sama seperti `URLField` Django: harus http(s) dan punya host.
  static bool isValidUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;

    final auth = context.read<AuthState>();
    final newProject = Project(
      title: _title.trim(),
      description: _description.trim(),
      techStack: _techStack.trim(),
      projectUrl: _projectUrl.trim(),
      projectImageUrl: _projectImageUrl.trim(),
    );

    setState(() => _isSubmitting = true);
    Project? created;
    try {
      created = await context.read<ApiClient>().createProject(
        newProject,
        token: auth.token!,
      );
    } on ApiException catch (e) {
      // 401: sesi dihapus lalu diminta login ulang (lihat handleApiError).
      if (mounted) await handleApiError(context, e, action: 'menambah proyek');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
    // Spinner sudah berhenti sebelum dialog muncul.
    if (created != null && mounted) await _showSuccess(created);
  }

  Future<void> _showSuccess(Project project) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Proyek berhasil ditambahkan!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Title: ${project.title}'),
              Text('Description: ${project.description}'),
              Text('Tech Stack: ${project.techStack}'),
              Text('Project URL: ${project.projectUrl}'),
              if (project.projectImageUrl.isNotEmpty)
                Text('Image URL: ${project.projectImageUrl}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _formKey.currentState!.reset();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    alignLabelWithHint: true,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
  );

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Form'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: _decoration('Title', hint: 'Nama proyek'),
                textInputAction: TextInputAction.next,
                onChanged: (value) => _title = value,
                validator: (value) => _required(value, 'Title'),
              ),
              gap,
              TextFormField(
                decoration: _decoration('Description'),
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: 6,
                onChanged: (value) => _description = value,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description tidak boleh kosong!';
                  }
                  return null;
                },
              ),
              gap,
              TextFormField(
                decoration: _decoration(
                  'Tech Stack',
                  hint: 'Contoh: Flutter, Django',
                ),
                textInputAction: TextInputAction.next,
                onChanged: (value) => _techStack = value,
                validator: (value) => _required(value, 'Tech Stack'),
              ),
              gap,
              TextFormField(
                decoration: _decoration(
                  'Project URL',
                  hint: 'https://github.com/...',
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                onChanged: (value) => _projectUrl = value,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Project URL tidak boleh kosong!';
                  }
                  if (!isValidUrl(value)) {
                    return 'Masukkan URL yang valid (http/https)!';
                  }
                  return null;
                },
              ),
              gap,
              TextFormField(
                decoration: _decoration('Project Image URL (Optional)'),
                keyboardType: TextInputType.url,
                onChanged: (value) => _projectImageUrl = value,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  if (!isValidUrl(value)) {
                    return 'Masukkan URL yang valid (http/https)!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
