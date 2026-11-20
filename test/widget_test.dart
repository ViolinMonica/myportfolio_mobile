import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportfolio_mobile/main.dart';
import 'package:myportfolio_mobile/screens/education_form.dart';
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

  testWidgets('kartu aksi membuka form Edukasi dan tombol back perangkat kembali ke Home', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Edukasi'));
    await tester.pumpAndSettle();
    expect(find.byType(EducationFormPage), findsOneWidget);

    // Simulasi tombol back bawaan Android (AppBar menampilkan ikon drawer, bukan panah).
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('drawer membuka form Edukasi dan opsi Home kembali ke halaman utama', (tester) async {
    await tester.pumpWidget(const MyApp());
    await openDrawerItem(tester, 'Add Education');
    expect(find.byType(EducationFormPage), findsOneWidget);

    await openDrawerItem(tester, 'Home');
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(EducationFormPage), findsNothing);
  });

  testWidgets('input tidak valid ditolak, input valid tampil di dialog', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
    final simpan = find.text('Simpan');

    // Kosong / hanya spasi ditolak, dialog tidak muncul.
    await tester.enterText(find.widgetWithText(TextFormField, 'Nama Institusi'), '   ');
    await tester.enterText(find.widgetWithText(TextFormField, 'IPK (opsional)'), '4.5');
    await tester.ensureVisible(simpan);
    await tester.tap(simpan);
    await tester.pumpAndSettle();
    expect(find.text('Nama institusi tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Program studi tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);
    expect(find.text('Tanggal selesai wajib dipilih!'), findsOneWidget);
    expect(find.text('IPK harus di antara 0.00 dan 4.00'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    // Lengkapi isian.
    await tester.enterText(find.widgetWithText(TextFormField, 'Nama Institusi'), 'Universitas Indonesia');
    await tester.enterText(find.widgetWithText(TextFormField, 'Program Studi'), 'Ilmu Komputer');
    await tester.enterText(find.widgetWithText(TextFormField, 'IPK (opsional)'), '3.80');
    await tester.tap(find.widgetWithText(TextFormField, 'Tanggal Mulai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // date picker: pakai tanggal awal (hari ini)
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masih berjalan'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(simpan);
    await tester.tap(simpan);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Institusi: Universitas Indonesia'), findsOneWidget);
    expect(find.text('Selesai: Masih berjalan'), findsOneWidget);
    expect(find.text('IPK: 3.80'), findsOneWidget);

    // OK menutup dialog dan kembali ke formulir.
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(EducationFormPage), findsOneWidget);
  });
}
