import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportfolio_mobile/main.dart';
import 'package:myportfolio_mobile/screens/experience_form.dart';
import 'package:myportfolio_mobile/screens/menu.dart';

/// Skenario dari "Petunjuk Pengujian" Tugas 8, dijalankan di layar selebar ponsel.
void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
  });

  Future<void> openDrawerItem(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('kartu aksi membuka form Pengalaman dan tombol back perangkat kembali ke Home', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Pengalaman'));
    await tester.pumpAndSettle();
    expect(find.byType(ExperienceFormPage), findsOneWidget);

    // Simulasi tombol back bawaan Android (AppBar menampilkan ikon drawer, bukan panah).
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('drawer membuka form Pengalaman dan opsi Home kembali ke halaman utama', (tester) async {
    await tester.pumpWidget(const MyApp());
    await openDrawerItem(tester, 'Add Experience');
    expect(find.byType(ExperienceFormPage), findsOneWidget);

    await openDrawerItem(tester, 'Home');
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ExperienceFormPage), findsNothing);
  });

  testWidgets('input tidak valid ditolak, input valid tampil di dialog', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
    final simpan = find.text('Simpan');
    final judul = find.widgetWithText(TextFormField, 'Judul');
    final deskripsi = find.widgetWithText(TextFormField, 'Deskripsi');

    // Judul hanya spasi, deskripsi kosong, sudah selesai tapi tanggal belum dipilih.
    await tester.enterText(judul, '   ');
    await tester.tap(find.text('Masih berjalan'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(simpan);
    await tester.tap(simpan);
    await tester.pumpAndSettle();
    expect(find.text('Judul tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Pilih tanggal selesai, atau centang "Masih berjalan"'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    // Lengkapi isian dan pilih tanggal selesai (default date picker: hari ini).
    await tester.enterText(judul, 'Asisten Dosen PBP');
    await tester.enterText(deskripsi, 'Membimbing lab Flutter.');
    await tester.tap(find.widgetWithText(TextFormField, 'Tanggal Selesai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(simpan);
    await tester.tap(simpan);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Judul: Asisten Dosen PBP'), findsOneWidget);
    expect(find.text('Kategori: Full-Time'), findsOneWidget);
    expect(find.textContaining('Selesai: '), findsOneWidget);

    // OK menutup dialog dan kembali ke formulir.
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(ExperienceFormPage), findsOneWidget);
  });
}
