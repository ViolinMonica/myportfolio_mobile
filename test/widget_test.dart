import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportfolio_mobile/main.dart';
import 'package:myportfolio_mobile/screens/experience_form.dart';
import 'package:myportfolio_mobile/screens/login_screen.dart';
import 'package:myportfolio_mobile/screens/menu.dart';

import 'helpers/fake_backend.dart';

/// Skenario "Petunjuk Pengujian" Tugas 8, diperbarui untuk Tugas 9: form
/// Pengalaman sekarang meminta login dulu, lalu menyimpan ke API.
void main() {
  usePhoneScreen();

  Future<void> openDrawerItem(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'kartu aksi membuka form Pengalaman (setelah login) dan back kembali ke Home',
    (tester) async {
      await tester.pumpWidget(MyApp(apiClient: FakeBackend().client()));
      await tapText(tester, 'Tambah Pengalaman');
      expect(find.byType(LoginScreen), findsOneWidget);
      await logIn(tester);
      expect(find.byType(ExperienceFormPage), findsOneWidget);

      // Simulasi tombol back bawaan Android (AppBar menampilkan ikon drawer, bukan panah).
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    },
  );

  testWidgets(
    'drawer membuka form Pengalaman dan opsi Home kembali ke halaman utama',
    (tester) async {
      await tester.pumpWidget(MyApp(apiClient: FakeBackend().client()));
      await openDrawerItem(tester, 'Add Experience');
      await logIn(tester);
      expect(find.byType(ExperienceFormPage), findsOneWidget);

      await openDrawerItem(tester, 'Home');
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);
    },
  );

  testWidgets('batal login tidak membuka form Pengalaman', (tester) async {
    await tester.pumpWidget(MyApp(apiClient: FakeBackend().client()));
    await tapText(tester, 'Tambah Pengalaman');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ExperienceFormPage), findsNothing);
  });

  testWidgets('input tidak valid ditolak, input valid tersimpan ke API', (
    tester,
  ) async {
    final backend = FakeBackend(experiences: []);
    await tester.pumpWidget(MyApp(apiClient: backend.client()));
    await tapText(tester, 'Tambah Pengalaman');
    await logIn(tester);

    final judul = find.widgetWithText(TextFormField, 'Judul');
    final deskripsi = find.widgetWithText(TextFormField, 'Deskripsi');

    // Judul hanya spasi, deskripsi kosong, sudah selesai tapi tanggal belum dipilih.
    await tester.enterText(judul, '   ');
    await tapText(tester, 'Masih berjalan');
    await tapText(tester, 'Simpan');
    expect(find.text('Judul tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
    expect(
      find.text('Pilih tanggal selesai, atau centang "Masih berjalan"'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(backend.experiences, isEmpty);

    // Lengkapi isian dan pilih tanggal selesai (default date picker: hari ini).
    await tester.enterText(judul, 'Asisten Dosen PBP');
    await tester.enterText(deskripsi, 'Membimbing lab Flutter.');
    await tester.tap(find.widgetWithText(TextFormField, 'Tanggal Selesai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tapText(tester, 'Simpan');
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Judul: Asisten Dosen PBP'), findsOneWidget);
    expect(find.text('Kategori: Full-Time'), findsOneWidget);
    expect(find.textContaining('Selesai: '), findsOneWidget);
    final today = DateTime.now();
    expect(
      backend.experiences.single['ended_at'],
      startsWith(
        DateTime.utc(today.year, today.month, today.day).toIso8601String(),
      ),
    );

    // OK menutup dialog dan form, kembali ke halaman utama.
    await tapText(tester, 'OK');
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
  });
}
