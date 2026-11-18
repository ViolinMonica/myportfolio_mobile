import 'package:flutter/material.dart';   
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
      ItemHomepage("Lihat Proyek", Icons.folder, Colors.blue),
      ItemHomepage("Tambah Proyek", Icons.add_circle, Colors.green),
      ItemHomepage("Logout", Icons.logout, Colors.red),
  ];
  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'MyPortfolio',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white)
      ),
      drawer: const LeftDrawer(),
      // Body halaman utama dengan padding di sekelilingnya.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Baris horizontal untuk menampilkan 3 InfoCard secara sejajar.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InfoCard(title: 'NPM', content: npm),
                InfoCard(title: 'Name', content: nama),
                InfoCard(title: 'Class', content: kelas),
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
                        primary: true,
                        padding: const EdgeInsets.all(20),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: layarKecil ? 3 : 1,     // kecil: jejer (row), lebar: numpuk (column)
                        childAspectRatio: layarKecil ? 1 : 5,   // biar kotak mode column nggak kegedean
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
        // Menyesuaikan lebar kartu dengan proporsi layar (dibagi 3.5).
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16.0),
        // Menyusun teks title dan content secara vertikal.
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(content),
          ],
        ),
      ),
    );
  }
}

/// Model data untuk satu tombol aksi di halaman utama.
///
/// Warna disimpan per item ([color]), sehingga [ItemCard] cukup membaca
/// `item.color` tanpa percabangan if-else untuk tiap tombol.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}
