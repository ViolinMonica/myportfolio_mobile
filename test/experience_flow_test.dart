import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportfolio_mobile/main.dart';
import 'package:myportfolio_mobile/screens/experience_detail_screen.dart';
import 'package:myportfolio_mobile/screens/experience_form.dart';
import 'package:myportfolio_mobile/screens/experience_list_screen.dart';
import 'package:myportfolio_mobile/screens/login_screen.dart';

import 'helpers/fake_backend.dart';

/// Alur Tugas 9 (Experience) melawan backend palsu, sesuai Petunjuk Pengujian:
/// baca tanpa login, tambah butuh login, 401 menghapus sesi, edit, hapus.
void main() {
  usePhoneScreen();

  Future<void> openList(WidgetTester tester, FakeBackend backend) async {
    await tester.pumpWidget(MyApp(apiClient: backend.client()));
    await tapText(tester, 'Lihat Pengalaman');
    expect(find.byType(ExperienceListScreen), findsOneWidget);
  }

  testWidgets('daftar publik dan detail menampilkan semua field', (
    tester,
  ) async {
    final backend = FakeBackend(
      experiences: [
        FakeBackend.sampleExperience(),
        FakeBackend.sampleExperience(
          id: 'exp-2',
          title: 'Magang Backend',
          endedAt: '2026-12-31T00:00:00Z',
        ),
      ],
    );
    await openList(tester, backend);
    expect(find.text('Asisten Dosen PBP'), findsOneWidget);
    expect(find.textContaining('Selesai 31/12/2026'), findsOneWidget);
    expect(backend.requests.single.headers['Authorization'], isNull);

    await tapText(tester, 'Magang Backend');
    expect(find.byType(ExperienceDetailScreen), findsOneWidget);
    expect(find.text('Part-Time'), findsOneWidget);
    expect(find.text('Membimbing lab Flutter.'), findsOneWidget);
    expect(find.text('01/09/2026'), findsOneWidget);
    expect(find.text('31/12/2026'), findsOneWidget);
    expect(find.text('Selesai'), findsWidgets);
  });

  testWidgets('daftar kosong dan error jaringan dengan tombol Retry', (
    tester,
  ) async {
    final backend = FakeBackend(experiences: [])..offline = true;
    await openList(tester, backend);
    expect(
      find.textContaining('Tidak bisa terhubung ke server'),
      findsOneWidget,
    );

    backend.offline = false;
    await tapText(tester, 'Retry');
    expect(find.text('No experiences found.'), findsOneWidget);
  });

  testWidgets('Tambah dari daftar meminta login, POST, lalu daftar segar', (
    tester,
  ) async {
    final backend = FakeBackend();
    await openList(tester, backend);

    await tapText(tester, 'Tambah');
    expect(find.byType(LoginScreen), findsOneWidget);
    await logIn(tester);
    expect(find.byType(ExperienceFormPage), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul'),
      'Volunteer COMPFEST',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi'),
      'Divisi acara',
    );
    await tapText(tester, 'Full-Time');
    await tapText(tester, 'Volunteer');
    await tapText(tester, 'Simpan');

    expect(find.text('Pengalaman berhasil disimpan!'), findsOneWidget);
    final post = backend.requests.last;
    expect(post.method, 'POST');
    expect(post.headers['Authorization'], 'Token abc');
    expect(jsonDecode(post.body), {
      'title': 'Volunteer COMPFEST',
      'description': 'Divisi acara',
      'category': 'volunteer',
      'ended_at': null,
    });

    await tapText(tester, 'OK');
    expect(find.byType(ExperienceListScreen), findsOneWidget);
    expect(find.text('Volunteer COMPFEST'), findsOneWidget);
  });

  testWidgets('token dicabut: 401 menghapus sesi dan meminta login lagi', (
    tester,
  ) async {
    final backend = FakeBackend();
    await tester.pumpWidget(MyApp(apiClient: backend.client()));
    await tapText(tester, 'Tambah Pengalaman');
    await logIn(tester);
    expect(find.byType(ExperienceFormPage), findsOneWidget);

    // Sama seperti menghapus token di Django Admin.
    backend.revokeToken();
    await tester.enterText(find.widgetWithText(TextFormField, 'Judul'), 'X');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi'),
      'Y',
    );
    await tapText(tester, 'Simpan');

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Sesi berakhir, silakan login lagi.'), findsOneWidget);
    expect(backend.experiences, hasLength(1));

    // Login ulang lalu kirim lagi: berhasil.
    await logIn(tester);
    await tapText(tester, 'Simpan');
    expect(find.text('Pengalaman berhasil disimpan!'), findsOneWidget);
    expect(backend.experiences, hasLength(2));
  });

  testWidgets('edit lewat PATCH memperbarui detail dan daftar', (tester) async {
    final backend = FakeBackend();
    await openList(tester, backend);
    await tapText(tester, 'Asisten Dosen PBP');

    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    await logIn(tester);
    expect(find.text('Edit Pengalaman'), findsOneWidget);
    // Form terisi data lama.
    expect(find.text('Membimbing lab Flutter.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul'),
      'Asisten Dosen PBP 2026',
    );
    await tapText(tester, 'Simpan');
    expect(find.text('Pengalaman berhasil diperbarui!'), findsOneWidget);
    expect(backend.requests.last.method, 'PATCH');
    expect(backend.requests.last.url.path, '/api/v1/experiences/exp-1/');

    await tapText(tester, 'OK');
    expect(find.byType(ExperienceDetailScreen), findsOneWidget);
    expect(find.text('Asisten Dosen PBP 2026'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Asisten Dosen PBP 2026'), findsOneWidget);
  });

  testWidgets('hapus butuh konfirmasi, lalu DELETE dan hilang dari daftar', (
    tester,
  ) async {
    final backend = FakeBackend();
    await openList(tester, backend);
    await tapText(tester, 'Asisten Dosen PBP');

    await tester.tap(find.byTooltip('Hapus'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Batal');
    expect(find.byType(ExperienceDetailScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Hapus');
    await logIn(tester);

    // DELETE terkirim, lalu daftar dimuat ulang (GET) saat kembali.
    final methods = backend.requests.map((r) => r.method).toList();
    expect(methods.sublist(methods.length - 2), ['DELETE', 'GET']);
    expect(backend.experiences, isEmpty);
    expect(find.byType(ExperienceListScreen), findsOneWidget);
    expect(find.text('No experiences found.'), findsOneWidget);
  });

  testWidgets('error validasi server tampil di SnackBar', (tester) async {
    final backend = FakeBackend();
    await tester.pumpWidget(MyApp(apiClient: backend.client()));
    await tapText(tester, 'Tambah Pengalaman');
    await logIn(tester);

    // Lolos validasi form, tapi server membuang tag HTML lalu menolak judul kosong.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul'),
      '<b></b>',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi'),
      'Y',
    );
    await tapText(tester, 'Simpan');
    expect(
      find.text('Data ditolak server: title: Title cannot be empty.'),
      findsOneWidget,
    );
    expect(find.byType(ExperienceFormPage), findsOneWidget);
    expect(backend.experiences, hasLength(1));
  });
}
