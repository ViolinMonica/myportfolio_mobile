import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/models/experience.dart';
import 'package:myportfolio_mobile/screens/experience_detail_screen.dart';
import 'package:myportfolio_mobile/screens/experience_form.dart';
import 'package:myportfolio_mobile/services/api_client.dart';
import 'package:myportfolio_mobile/widgets/api_list_view.dart';
import 'package:myportfolio_mobile/widgets/auth_guard.dart';
import 'package:myportfolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Daftar pengalaman dari `GET /api/v1/experiences/` (publik, tanpa login).
///
/// Daftar dimuat ulang setiap kali kembali dari detail atau form, supaya
/// entri yang baru ditambah, diubah, atau dihapus langsung terlihat.
class ExperienceListScreen extends StatefulWidget {
  const ExperienceListScreen({super.key});

  @override
  State<ExperienceListScreen> createState() => _ExperienceListScreenState();
}

class _ExperienceListScreenState extends State<ExperienceListScreen> {
  // Dibuat di initState, bukan build, supaya rebuild tidak mengirim ulang request.
  late Future<List<Experience>> _experiencesFuture;

  @override
  void initState() {
    super.initState();
    _experiencesFuture = context.read<ApiClient>().getExperiences();
  }

  Future<void> _reload() async {
    final future = context.read<ApiClient>().getExperiences();
    setState(() {
      _experiencesFuture = future;
    });
    // Error sudah ditampilkan FutureBuilder; jangan dilempar ulang ke RefreshIndicator.
    await future.then<void>((_) {}, onError: (_) {});
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) await _reload();
  }

  Future<void> _add() async {
    if (!await ensureLoggedIn(context) || !mounted) return;
    await _open(const ExperienceFormPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements: Experiences'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: ApiListView<Experience>(
        future: _experiencesFuture,
        onRefresh: _reload,
        itemName: 'experiences',
        itemBuilder: (context, experience) => Card(
          child: ListTile(
            title: Text(
              experience.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${experience.categoryLabel} · '
              '${experience.isOngoing ? 'Masih berjalan' : 'Selesai ${formatDate(experience.endedAt!)}'}'
              '\n${experience.description}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(ExperienceDetailScreen(experience: experience)),
          ),
        ),
      ),
    );
  }
}
