import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/screens/menu.dart';

void main() {
  runApp(const MyApp());
}

/// Akar aplikasi MyPortfolio Mobile.
///
/// Tema dibuat sekali di sini dari `seedColor` indigo. Semua halaman mengambil
/// warnanya lewat `Theme.of(context).colorScheme.primary`, jadi kalau warna
/// portofolio ingin diganti cukup ubah satu baris ini.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPortfolio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          secondary: Colors.amber[700],
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}