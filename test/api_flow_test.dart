import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportfolio_mobile/main.dart';
import 'package:myportfolio_mobile/screens/login_screen.dart';
import 'package:myportfolio_mobile/screens/project_detail_screen.dart';
import 'package:myportfolio_mobile/screens/project_form.dart';
import 'package:myportfolio_mobile/services/api_client.dart';

import 'helpers/fake_backend.dart';

/// Alur Tutorial 10 melawan backend palsu (MockClient), tanpa server Django.
void main() {
  usePhoneScreen();
  late FakeBackend backend;
  ApiClient fakeApi() => (backend = FakeBackend()).client();

  testWidgets('daftar proyek publik dimuat dari API dan membuka detail', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApi()));
    await tapText(tester, 'Lihat Proyek');

    expect(find.text('MyPortfolio'), findsOneWidget);
    await tapText(tester, 'MyPortfolio');
    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    // project_image_url null -> tidak ada widget gambar.
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('Tambah Proyek meminta login, lalu POST memakai token', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApi()));
    await tapText(tester, 'Tambah Proyek');
    expect(find.byType(LoginScreen), findsOneWidget);

    // Password salah ditolak dan tetap di layar login.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'owner',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'x');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Username atau password salah.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);

    // URL tidak valid ditolak sebelum request dikirim.
    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'App');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Desc',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tech Stack'),
      'Flutter',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Project URL'),
      'bukan-url',
    );
    await tapText(tester, 'Save');
    expect(find.text('Masukkan URL yang valid (http/https)!'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Project URL'),
      'https://github.com/x/app',
    );
    await tapText(tester, 'Save');
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);

    final post = backend.requests.last;
    expect(post.headers['Authorization'], 'Token abc');
    expect(jsonDecode(post.body), {
      'title': 'App',
      'description': 'Desc',
      'tech_stack': 'Flutter',
      'project_url': 'https://github.com/x/app',
      'project_image_url': '',
    });
  });

  testWidgets('drawer menukar Login dan Logout sesuai status sesi', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApi()));
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Login'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'owner',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Kembali dari LoginScreen, drawer masih terbuka dan sudah berganti menu.
    expect(find.widgetWithText(ListTile, 'Logout'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Logout'));
    await tester.pumpAndSettle();

    expect(backend.requests.last.url.path, '/api/v1/auth/logout/');
    expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
  });
}
