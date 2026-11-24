import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportfolio_mobile/main.dart';
import 'package:myportfolio_mobile/screens/login_screen.dart';
import 'package:myportfolio_mobile/screens/project_detail_screen.dart';
import 'package:myportfolio_mobile/screens/project_form.dart';
import 'package:myportfolio_mobile/services/api_client.dart';

/// Alur Tutorial 10 melawan backend palsu (MockClient), tanpa server Django.
void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
  });

  const projectJson = {
    'id': '7a1c0c52-1f1b-4c4e-9a59-2f7a3c0c9b11',
    'title': 'MyPortfolio',
    'description': 'Website portofolio Django',
    'tech_stack': 'Django',
    'project_url': 'https://example.com/',
    'project_image_url': null,
    'star_count': 0,
  };

  /// Backend palsu: token `abc` untuk owner/secret, POST butuh token itu.
  final requests = <http.Request>[];
  ApiClient fakeApi() {
    requests.clear();
    return ApiClient(
      baseUrl: 'http://test',
      client: MockClient((request) async {
        requests.add(request);
        final path = request.url.path;
        if (request.method == 'GET' && path == '/api/v1/projects/') {
          return http.Response(jsonEncode([projectJson]), 200);
        }
        if (path == '/api/v1/auth/token/') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          return body['password'] == 'secret'
              ? http.Response(jsonEncode({'token': 'abc'}), 200)
              : http.Response('{"non_field_errors":["bad"]}', 400);
        }
        if (request.headers['Authorization'] != 'Token abc') {
          return http.Response('{"detail":"no"}', 401);
        }
        if (path == '/api/v1/auth/logout/') return http.Response('', 204);
        if (request.method == 'POST' && path == '/api/v1/projects/') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(jsonEncode({...body, 'id': 'new-id'}), 201);
        }
        return http.Response('', 404);
      }),
    );
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

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

    final post = requests.last;
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

    expect(requests.last.url.path, '/api/v1/auth/logout/');
    expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
  });
}
