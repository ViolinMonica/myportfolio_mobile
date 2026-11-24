import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/screens/experience_form.dart';
import 'package:myportfolio_mobile/screens/experience_list_screen.dart';
import 'package:myportfolio_mobile/screens/menu.dart';
import 'package:myportfolio_mobile/screens/login_screen.dart';
import 'package:myportfolio_mobile/screens/project_form.dart';
import 'package:myportfolio_mobile/screens/project_list_screen.dart';
import 'package:myportfolio_mobile/services/auth_state.dart';
import 'package:myportfolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Drawer navigasi yang dipakai bersama oleh semua halaman
/// (halaman utama, form Proyek, dan form Pengalaman).
///
/// Karena satu widget dipakai di semua `Scaffold`, opsi menu cukup ditambah
/// di satu tempat dan langsung muncul di setiap halaman.
///
/// - **Home** memakai [Navigator.pushReplacement]: halaman saat ini diganti
///   dengan halaman utama, sehingga form tidak tertinggal di tumpukan dan
///   tombol back tidak membuka form lama lagi.
/// - **View Projects** / **View Experiences** membuka daftar dari API
///   (publik, tanpa login).
/// - **Add Project** dan **Add Experience** memakai [Navigator.push]: form
///   ditumpuk di atas halaman saat ini, jadi tombol back kembali ke halaman
///   sebelumnya. Keduanya dijaga [ensureLoggedIn], jadi pengguna yang belum
///   login dibawa ke [LoginScreen] dulu.
/// - **Login** / **Logout** bergantian sesuai [AuthState.isLoggedIn]; drawer
///   ikut dibangun ulang karena memakai `context.watch`.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
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
                  style: TextStyle(fontSize: 15, color: Colors.white),
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
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('View Projects'),
            // Daftar proyek dari API, publik tanpa login.
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            // Navigasi ke halaman tambah proyek, setelah memastikan sudah login.
            onTap: () async {
              if (!await ensureLoggedIn(context) || !context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectFormPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.work_history_outlined),
            title: const Text('View Experiences'),
            // Daftar pengalaman dari API, publik tanpa login.
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExperienceListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Add Experience'),
            // Navigasi ke halaman tambah pengalaman, setelah memastikan sudah login.
            onTap: () async {
              if (!await ensureLoggedIn(context) || !context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExperienceFormPage(),
                ),
              );
            },
          ),
          const Divider(),
          if (!isLoggedIn)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => context.read<AuthState>().logout(),
            ),
        ],
      ),
    );
  }
}
