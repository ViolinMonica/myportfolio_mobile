import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/screens/project_form.dart';
import 'package:myportfolio_mobile/screens/menu.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      // Warna latar unik per tombol, diambil dari atribut color pada ItemHomepage.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      // clipBehavior agar efek ripple InkWell ikut terpotong mengikuti sudut melengkung.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () {
          // Tutup SnackBar sebelumnya agar pesan baru langsung muncul,
          // lalu tampilkan SnackBar melayang dengan warna dan ikon tombol terkait.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: item.color,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                content: Row(
                  children: [
                    Icon(item.icon, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text("Kamu telah menekan tombol ${item.name}!"),
                    ),
                  ],
                ),
              ),
            );
          if (item.name == "Tambah Proyek") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProjectFormPage()),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: Colors.white,
                  size: 30.0,
                ),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}