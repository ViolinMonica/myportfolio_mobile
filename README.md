# MyPortfolio Mobile

Aplikasi mobile Flutter untuk portofolio pribadi saya. Proyek ini lanjutan dari website portofolio Django di mata kuliah Pemrograman Berbasis Platform (PBP).

- **Nama:** Violin Monica
- **NPM:** 2506551794
- **Kelas:** PBP B

## Setup

1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install), lalu cek dengan `flutter doctor`.
2. Clone repositori ini:
   ```bash
   git clone https://github.com/ViolinMonica/myportfolio_mobile.git
   cd myportfolio_mobile
   ```
3. Install dependensi: `flutter pub get`
4. Jalankan aplikasi: `flutter run` (pilih emulator, device, atau Chrome)
5. Cek kualitas kode: `flutter analyze`

## Progres Mingguan

| Minggu | Isi |
|---|---|
| Tutorial 08 | Setup proyek Flutter, pisahkan `menu.dart` dari `main.dart`, buat `InfoCard` dan `ItemCard` |
| Tugas 7 | Identitas sendiri di `InfoCard`, 3 tombol aksi (Lihat Proyek, Tambah Proyek, Logout) dengan warna berbeda, SnackBar saat tombol ditekan |

## Fitur Tambahan (di luar checklist Tugas 7)

- **SnackBar mengikuti tombol yang ditekan:** warna latar SnackBar sama dengan warna tombol, dan ikon tombol ikut tampil di sebelah pesan. Pengguna langsung tahu tombol mana yang barusan ditekan.
- **SnackBar melayang (floating)** dengan sudut melengkung dan durasi 2 detik. SnackBar lama ditutup dulu (`hideCurrentSnackBar`) supaya pesan tidak menumpuk kalau tombol ditekan berkali-kali.
- **Efek ripple rapi:** `clipBehavior: Clip.antiAlias` pada `Material` membuat efek sentuh `InkWell` ikut terpotong mengikuti sudut kartu yang melengkung.
- **Docstring (`///`)** di setiap class pada `menu.dart` untuk menjelaskan peran masing-masing widget dan model.

## Struktur Kode

- `lib/main.dart`: bootstrap aplikasi (`main()` dan `MyApp` berisi `MaterialApp` serta tema).
- `lib/menu.dart`: halaman utama (`MyHomePage`), kartu identitas (`InfoCard`), model tombol (`ItemHomepage`, dengan atribut `name`, `icon`, `color`), dan kartu tombol (`ItemCard`).

---

### Tugas 7

1. **Widget tree dan hubungan parent-child**

   Di Flutter, seluruh tampilan disusun dari widget, dan widget-widget itu membentuk struktur pohon yang disebut *widget tree*. Widget paling atas (root) punya satu atau beberapa anak, dan setiap anak bisa punya anak lagi. Di aplikasi ini, `MaterialApp` adalah induk dari `MyHomePage`. `MyHomePage` membangun `Scaffold`, yang punya anak `AppBar` dan `Padding`, dan seterusnya sampai `Text` dan `Icon` di paling bawah.

   Hubungan parent-child bekerja seperti ini:
   - Parent menentukan **posisi dan batas ukuran** (constraints) anaknya. Contohnya, `Padding` memberi jarak, lalu `Column` menyusun anak-anaknya secara vertikal.
   - Data dan konfigurasi mengalir **dari atas ke bawah**. Contohnya, tema dari `MaterialApp` bisa diakses widget di bawahnya lewat `Theme.of(context)`.
   - Widget yang hanya punya satu anak memakai properti `child` (misalnya `Padding`, `Center`, `Container`). Widget yang punya banyak anak memakai `children` (misalnya `Row`, `Column`, `GridView`).

2. **Widget yang digunakan dan fungsinya**

   | Widget | Fungsi |
   |---|---|
   | `MaterialApp` | Root aplikasi, mengatur judul, tema, dan halaman awal (`home`) |
   | `MyApp` | Widget custom (Stateless) yang membungkus `MaterialApp` |
   | `MyHomePage` | Widget custom (Stateless) untuk halaman utama |
   | `Scaffold` | Kerangka halaman Material (tempat AppBar, body, dan SnackBar) |
   | `AppBar` | Bar di bagian atas berisi judul "MyPortfolio" |
   | `Text` | Menampilkan teks (judul, NPM, nama, kelas, nama tombol) |
   | `Padding` | Memberi jarak di sekeliling child |
   | `Column` | Menyusun anak-anaknya secara vertikal |
   | `Row` | Menyusun 3 `InfoCard` secara horizontal |
   | `SizedBox` | Memberi jarak kosong dengan ukuran tetap |
   | `Center` | Menaruh child di tengah |
   | `GridView.count` | Menyusun tombol `ItemCard` dalam grid 3 kolom |
   | `InfoCard` | Widget custom: kartu berisi judul dan isi (NPM, Name, Class) |
   | `Card` | Kartu bergaya Material dengan bayangan (elevation) |
   | `Container` | Mengatur lebar dan padding isi kartu |
   | `ItemCard` | Widget custom: tombol berbentuk kartu dengan ikon, teks, dan warna |
   | `Material` | Memberi warna latar dan sudut melengkung pada `ItemCard` |
   | `InkWell` | Membuat kartu bisa ditekan (`onTap`) dengan efek ripple |
   | `Icon` | Menampilkan ikon tombol (folder, add_circle, logout) |
   | `SnackBar` | Pesan singkat di bawah layar saat tombol ditekan, ditampilkan lewat `ScaffoldMessenger` |

3. **Fungsi `MaterialApp` dan alasannya dipakai sebagai root**

   `MaterialApp` adalah widget pembungkus yang menyediakan semua yang dibutuhkan aplikasi bergaya Material Design: tema (`ThemeData`, `ColorScheme`), navigasi (`Navigator` dan routes), judul aplikasi, localization, dan `ScaffoldMessenger` untuk SnackBar.

   Widget ini biasanya dipakai sebagai root karena banyak widget Material, seperti `Scaffold`, `AppBar`, dan `SnackBar`, bergantung pada data yang disediakan `MaterialApp` di atasnya, misalnya tema dan arah teks. Dengan menaruhnya di paling atas, semua widget di bawahnya bisa mengakses tema dan navigasi yang sama. Hasilnya, tampilan aplikasi jadi konsisten.

4. **`StatelessWidget` vs `StatefulWidget`**

   - **`StatelessWidget`** tidak punya state yang bisa berubah. Tampilannya hanya ditentukan oleh data yang diberikan saat dibuat. Kalau ingin berubah, widget-nya harus dibuat ulang oleh parent.
   - **`StatefulWidget`** punya objek `State` terpisah yang bisa menyimpan data yang berubah selama aplikasi berjalan. Kalau `setState()` dipanggil, Flutter akan memanggil `build()` lagi untuk memperbarui tampilan.

   Pakai `StatelessWidget` kalau tampilannya statis atau cuma bergantung pada input, misalnya `InfoCard`, `ItemCard`, dan `MyHomePage` di tugas ini. Pakai `StatefulWidget` kalau ada data yang berubah karena interaksi atau waktu, misalnya counter, form input, checkbox, animasi, atau data yang diambil dari API.

5. **`BuildContext`**

   `BuildContext` adalah penanda posisi sebuah widget di dalam widget tree. Lewat `context`, widget bisa "melihat ke atas" dan mengakses data dari widget leluhurnya.

   Di dalam metode `build(BuildContext context)`, `context` dipakai untuk:
   - `Theme.of(context).colorScheme.primary` untuk mengambil warna tema dari `MaterialApp` (dipakai di `AppBar`).
   - `MediaQuery.of(context).size.width` untuk mengambil lebar layar (dipakai untuk lebar `InfoCard`).
   - `ScaffoldMessenger.of(context)` untuk menampilkan `SnackBar` saat `ItemCard` ditekan.

   `BuildContext` penting karena tanpa itu widget tidak tahu posisinya di dalam tree, sehingga tidak bisa mengakses tema, ukuran layar, navigasi, atau Scaffold terdekat.

6. **Hot reload vs hot restart**

   - **Hot reload** memasukkan perubahan kode ke aplikasi yang sedang berjalan lalu membangun ulang widget tree **tanpa menghapus state**. Prosesnya sangat cepat dan cocok untuk mengubah tampilan, misalnya warna, teks, atau layout.
   - **Hot restart** menjalankan ulang aplikasi dari awal (`main()`) dan **menghapus semua state**, tapi tidak meng-compile ulang seluruh aplikasi native.

   Hot reload tidak cukup, sehingga perlu hot restart atau full restart, ketika:
   - Mengubah isi `main()` atau inisialisasi variabel global atau static.
   - Mengubah nilai awal state di `initState()` (perubahannya tidak terlihat karena state lama dipertahankan).
   - Mengubah struktur class, misalnya StatelessWidget diubah jadi StatefulWidget, atau mengubah enum dan generic type.
   - **Full restart** (stop lalu `flutter run` lagi) diperlukan saat menambah package baru di `pubspec.yaml`, mengubah kode native (Android/iOS), atau menambah asset baru.

---

## AI Disclosure

- **Tools:** Claude Code (Claude Opus 5.5) di VS Code.
- **Bagian yang dibantu AI:**
  - Menjelaskan maksud checklist tugas (pemisahan `menu.dart` dari `main.dart`, `InfoCard`, `ItemCard`) dan mengecek kode terhadap checklist.
  - Menemukan dan menghapus anotasi `@override` ganda di `menu.dart`.
  - Menjalankan `flutter analyze` untuk verifikasi.
  - Menyusun draf README ini, termasuk jawaban pertanyaan reflektif.
  - Menambahkan fitur ekstra SnackBar (warna dan ikon mengikuti tombol), `clipBehavior`, serta docstring dan komentar kode.
- **Yang saya kerjakan sendiri:** mengisi data identitas, menambahkan atribut `color` pada `ItemHomepage` dan warna tiap tombol, lalu membaca ulang dan menyesuaikan jawaban README.
- **Strategi prompting:** bertanya per poin checklist ("ini maksudnya apa", "ini bener ga"), meminta AI membaca langsung halaman tugas supaya acuannya sesuai soal, lalu memverifikasi jawaban AI dengan membaca kodenya sendiri dan menjalankan aplikasinya.

### Keterbatasan AI dan perbaikan manual

- **AI tidak tahu data pribadi saya.** Di awal, nama di `InfoCard` hanya "Violin". AI hanya bisa mengingatkan bahwa soal meminta nama lengkap, dan saya sendiri yang menggantinya jadi "Violin Monica".
- **AI tidak melihat konteks yang tidak saya berikan.** Saat saya menempel sebagian checklist saja, AI tidak tahu ada syarat warna berbeda per tombol sampai saya memberi link halaman tugas. Jadi jawaban AI hanya seakurat konteks yang diberikan.
- **AI tidak menjalankan aplikasi secara visual.** AI hanya memverifikasi lewat `flutter analyze` (statis). Hasil tampilannya (warna tombol, SnackBar) saya cek sendiri dengan menjalankan aplikasi.
- **Komentar kode bisa basi.** Setelah warna diganti ke `item.color`, komentar lama "Menggunakan warna sekunder dari skema tema aplikasi" masih tertinggal dan jadi menyesatkan. Ini ditemukan saat review, lalu diperbaiki.
- **Jawaban reflektif dari AI tetap harus dipahami.** Saya membaca ulang tiap jawaban dan mencocokkannya dengan kode saya (misalnya contoh `Theme.of(context)` dan `MediaQuery.of(context)`), bukan sekadar menyalin.

log chat AI: https://drive.google.com/file/d/1QEMrrWYWgrUNR6VqchNJBVp8bKHDEykD/view?usp=sharing
