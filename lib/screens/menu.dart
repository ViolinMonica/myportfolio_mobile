import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/screens/experience_form.dart';
import 'package:myportfolio_mobile/screens/project_form.dart';
import 'package:myportfolio_mobile/screens/project_list_screen.dart';
import 'package:myportfolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:myportfolio_mobile/widgets/left_drawer.dart';
import 'package:myportfolio_mobile/widgets/project_card.dart';

/// Halaman utama MyPortfolio: kartu identitas pemilik di atas
/// dan kisi tombol aksi portofolio di bawahnya.
class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});
  final String npm = "2506551794";
  final String nama = "Violin Monica";
  final String kelas = "PBP B";

  final List<ItemHomepage> items = [
    ItemHomepage(
      "Lihat Proyek",
      Icons.folder,
      Colors.blue,
      page: () => const ProjectListScreen(),
    ),
    ItemHomepage(
      "Tambah Proyek",
      Icons.add_circle,
      Colors.green,
      page: () => const ProjectFormPage(),
      requiresLogin: true,
    ),
    ItemHomepage(
      "Tambah Pengalaman",
      Icons.work,
      Colors.orange,
      page: () => const ExperienceFormPage(),
    ),
    ItemHomepage("Logout", Icons.logout, Colors.red, onTap: _logout),
  ];
  static Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthState>();
    final wasLoggedIn = auth.isLoggedIn;
    await auth.logout();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(wasLoggedIn ? 'Berhasil logout.' : 'Kamu belum login.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      // Body halaman utama dengan padding di sekelilingnya. Bisa digulir supaya
      // kartu aksi tidak overflow di layar pendek atau jendela Chrome yang lebar.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Baris horizontal untuk menampilkan 3 InfoCard secara sejajar.
            // Expanded membagi lebar sama rata, jadi tidak overflow di layar 390 px.
            Row(
              children: [
                Expanded(
                  child: InfoCard(title: 'NPM', content: npm),
                ),
                Expanded(
                  child: InfoCard(title: 'Name', content: nama),
                ),
                Expanded(
                  child: InfoCard(title: 'Class', content: kelas),
                ),
              ],
            ),

            const SizedBox(height: 16.0),

            // Bagian tengah: pesan sambutan dan kisi tombol menu portofolio.
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),

                  // GridView menampilkan kartu tombol dalam tata letak kisi 3 kolom.
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // constraints.maxWidth = lebar ruang yang tersedia buat widget ini
                      final bool layarKecil = constraints.maxWidth < 600;

                      return GridView.count(
                        // Scroll diurus SingleChildScrollView di atas.
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: layarKecil
                            ? 3
                            : 1, // kecil: jejer (row), lebar: numpuk (column)
                        childAspectRatio: layarKecil ? 0.85 : 5, // kecil: sedikit lebih tinggi agar label 2 baris muat
                        shrinkWrap: true,
                        children: items.map((ItemHomepage item) {
                          return ItemCard(item);
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu informasi profil yang menampilkan judul ([title]) dan isinya ([content]),
/// misalnya NPM, nama, atau kelas.
class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      child: Container(
        // Lebar diatur Expanded di MyHomePage; padding kecil agar teks muat di ponsel.
        padding: const EdgeInsets.all(12.0),
        // Menyusun teks title dan content secara vertikal.
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Model data untuk satu tombol aksi di halaman utama.
///
/// Semua yang membedakan satu tombol dengan tombol lain disimpan di sini:
/// label ([name]), ikon ([icon]), warna ([color]), dan halaman tujuan ([page]).
/// Dengan begitu [ItemCard] cukup membaca atribut item, tanpa percabangan
/// if-else atau `switch` berdasarkan teks label. Mengganti label tombol tidak
/// akan merusak navigasi, dan menambah tombol baru cukup menambah satu baris
/// di daftar `items` pada [MyHomePage].
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  /// Pembuat halaman yang dibuka saat kartu ditekan, atau `null` kalau tombol
  /// tidak membuka halaman. Berupa fungsi, bukan widget jadi, supaya halaman baru dibuat
  /// saat kartu ditekan dan form selalu mulai dalam keadaan kosong.
  final Widget Function()? page;

  /// Kalau `true`, [page] baru dibuka setelah `ensureLoggedIn` berhasil.
  final bool requiresLogin;

  /// Aksi khusus pengganti navigasi (mis. Logout). Kalau diisi, [page]
  /// diabaikan.
  final Future<void> Function(BuildContext context)? onTap;

  ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.page,
    this.requiresLogin = false,
    this.onTap,
  });
}
