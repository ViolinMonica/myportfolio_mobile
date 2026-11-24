import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/screens/menu.dart';
import 'package:myportfolio_mobile/services/api_client.dart';
import 'package:myportfolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp(apiClient: ApiClient()));
}

/// Akar aplikasi MyPortfolio Mobile.
///
/// Tema dibuat sekali di sini dari `seedColor` indigo. Semua halaman mengambil
/// warnanya lewat `Theme.of(context).colorScheme.primary`, jadi kalau warna
/// portofolio ingin diganti cukup ubah satu baris ini.
///
/// [ApiClient] dan [AuthState] disisipkan lewat [MultiProvider] supaya semua
/// layar bisa memakainya dengan `context.read` / `context.watch`.
class MyApp extends StatelessWidget {
  const MyApp({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AuthState(apiClient)),
      ],
      child: MaterialApp(
        title: 'MyPortfolio',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            secondary: Colors.amber[700],
          ),
          useMaterial3: true,
        ),
        home: MyHomePage(),
      ),
    );
  }
}
