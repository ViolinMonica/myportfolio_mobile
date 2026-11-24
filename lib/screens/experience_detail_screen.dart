import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/models/experience.dart';
import 'package:myportfolio_mobile/screens/experience_form.dart';
import 'package:myportfolio_mobile/services/api_client.dart';
import 'package:myportfolio_mobile/services/auth_state.dart';
import 'package:myportfolio_mobile/widgets/api_error.dart';
import 'package:myportfolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Detail satu pengalaman, menampilkan semua field dari API.
///
/// Membaca publik. Tombol Edit (`PATCH`) dan Hapus (`DELETE`) di AppBar
/// meminta login dulu lewat [ensureLoggedIn].
class ExperienceDetailScreen extends StatefulWidget {
  const ExperienceDetailScreen({required this.experience, super.key});

  final Experience experience;

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  late Experience _experience = widget.experience;
  bool _isDeleting = false;

  Future<void> _edit() async {
    if (!await ensureLoggedIn(context) || !mounted) return;
    final updated = await Navigator.push<Experience>(
      context,
      MaterialPageRoute(
        builder: (_) => ExperienceFormPage(initial: _experience),
      ),
    );
    if (updated != null && mounted) setState(() => _experience = updated);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus pengalaman?'),
        content: Text('"${_experience.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (!await ensureLoggedIn(context) || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await context.read<ApiClient>().deleteExperience(
        _experience.id!,
        token: context.read<AuthState>().token!,
      );
      if (!mounted) return;
      showSnack(context, 'Pengalaman "${_experience.title}" dihapus.');
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) {
        await handleApiError(context, e, action: 'menghapus pengalaman');
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final experience = _experience;
    final startedAt = experience.startedAt;
    return Scaffold(
      appBar: AppBar(
        title: Text(experience.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: _isDeleting ? null : _edit,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Hapus',
            onPressed: _isDeleting ? null : _delete,
            icon: _isDeleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(experience.title, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(experience.categoryLabel)),
                Chip(
                  avatar: Icon(
                    experience.isOngoing ? Icons.timelapse : Icons.check,
                    size: 18,
                  ),
                  label: Text(
                    experience.isOngoing ? 'Masih berjalan' : 'Selesai',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(experience.description, style: textTheme.bodyLarge),
            const SizedBox(height: 16),
            _field(
              'Mulai',
              startedAt == null ? '-' : formatDate(startedAt.toLocal()),
            ),
            _field(
              'Selesai',
              experience.isOngoing ? '-' : formatDate(experience.endedAt!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
