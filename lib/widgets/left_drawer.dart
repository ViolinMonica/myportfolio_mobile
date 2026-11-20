import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/screens/experience_form.dart';
import 'package:myportfolio_mobile/screens/menu.dart';
import 'package:myportfolio_mobile/screens/project_form.dart';

/// Drawer navigasi yang dipakai bersama oleh semua halaman
/// (halaman utama, form Proyek, dan form Pengalaman).
///
/// Karena satu widget dipakai di semua `Scaffold`, opsi menu cukup ditambah
/// di satu tempat dan langsung muncul di setiap halaman.
///
/// - **Home** memakai [Navigator.pushReplacement]: halaman saat ini diganti
///   dengan halaman utama, sehingga form tidak tertinggal di tumpukan dan
///   tombol back tidak membuka form lama lagi.
/// - **Add Project** dan **Add Experience** memakai [Navigator.push]: form
///   ditumpuk di atas halaman saat ini, jadi tombol back kembali ke halaman
///   sebelumnya.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            // Warna primer tema, supaya header drawer serasi dengan AppBar.
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Portfolio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Explore personal projects and experiences!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            // Navigasi ke halaman utama portofolio
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            // Navigasi ke halaman tambah proyek
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectFormPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Add Experience'),
            // Navigasi ke halaman tambah pengalaman
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExperienceFormPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}