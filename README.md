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
| Tutorial 09 | Pisahkan halaman ke `lib/screens/` dan widget ke `lib/widgets/`, `LeftDrawer`, form Tambah Proyek dengan validasi dan dialog |
| Tugas 8 | Form Tambah Pengalaman (`experience_form.dart`, sesuai model `Experience` di web) dibuka dari kartu aksi dan drawer, validasi per field, dialog ringkasan, widget test |

## Fitur Tambahan (di luar checklist Tugas 7)

- **SnackBar mengikuti tombol yang ditekan:** warna latar SnackBar sama dengan warna tombol, dan ikon tombol ikut tampil di sebelah pesan. Pengguna langsung tahu tombol mana yang barusan ditekan.
- **SnackBar melayang (floating)** dengan sudut melengkung dan durasi 2 detik. SnackBar lama ditutup dulu (`hideCurrentSnackBar`) supaya pesan tidak menumpuk kalau tombol ditekan berkali-kali.
- **Efek ripple rapi:** `clipBehavior: Clip.antiAlias` pada `Material` membuat efek sentuh `InkWell` ikut terpotong mengikuti sudut kartu yang melengkung.
- **Docstring (`///`)** di setiap class pada `menu.dart` untuk menjelaskan peran masing-masing widget dan model.

## Struktur Kode

- `lib/main.dart`: bootstrap aplikasi (`main()` dan `MyApp` berisi `MaterialApp` serta tema).
- `lib/screens/menu.dart`: halaman utama (`MyHomePage`), kartu identitas (`InfoCard`), dan model tombol (`ItemHomepage`, dengan atribut `name`, `icon`, `color`).
- `lib/screens/project_form.dart`: form Tambah Proyek (Tutorial 09).
- `lib/screens/experience_form.dart`: form Tambah Pengalaman (Tugas 8).
- `lib/widgets/left_drawer.dart`: drawer yang sama untuk semua halaman (Home, Add Project, Add Experience).
- `lib/widgets/project_card.dart`: kartu tombol aksi (`ItemCard`) beserta navigasinya.
- `test/widget_test.dart`: widget test untuk skenario pengujian Tugas 8.

## Fitur Tambahan Tugas 8 (di luar checklist)

- **Field dan aturan validasi mengikuti model Django `Experience`** (`main/models.py` di repo `portfolio`):

  | Field model | Input | Validasi |
  |---|---|---|
  | `title` (`CharField(max_length=255)`) | `TextFormField` | wajib, bukan spasi saja, maks. 255 karakter |
  | `description` (`TextField`) | `TextFormField` multi-baris | wajib, bukan spasi saja |
  | `category` (`EXPERIENCE_CHOICES`, default `full-time`) | `DropdownButtonFormField` | hanya 6 pilihan dari model |
  | `ended_at` (boleh kosong = masih berjalan) | `showDatePicker()` + centang "Masih berjalan" | kalau tidak berjalan, tanggal wajib dan tidak boleh sebelum `started_at` |

  `started_at` memakai `auto_now_add` (terisi otomatis saat disimpan), jadi tidak ada di form dan dianggap hari ini. `thumbnail` (upload gambar) belum dimasukkan karena materi minggu ini belum mencakup upload file.
- **Penghitung karakter** (`maxLength: 255`) di field Judul, sesuai batas di model.
- **Widget test** (`flutter test`) di layar 390 × 844 untuk semua langkah di Petunjuk Pengujian: buka dari kartu dan drawer, kembali ke Home, judul spasi saja / deskripsi kosong / tanggal selesai belum dipilih ditolak, input valid tampil di dialog, OK kembali ke form.
- **Perbaikan overflow di layar ponsel.** Saat dites di lebar 390 px, baris `InfoCard` dan label kartu 2 baris ternyata overflow. Sekarang `InfoCard` dibagi rata dengan `Expanded`, label kartu dibatasi 2 baris, dan halaman utama bisa digulir.
- **Navigasi kartu dipisah ke model.** Halaman tujuan tiap kartu disimpan di `ItemHomepage.page`, bukan dipilih dari teks label lewat `switch`. Mengganti label tombol tidak merusak navigasi, dan menambah kartu baru cukup satu baris di `menu.dart`.
- **Satu sumber warna.** AppBar, tombol Simpan, dan header drawer di semua halaman memakai `Theme.of(context).colorScheme.primary` dari `seedColor` di `main.dart`, bukan `Colors.indigo` yang ditulis langsung.
- **Docstring (`///`) di semua class**, termasuk alasan desainnya (mis. kenapa Home di drawer memakai `pushReplacement` sedangkan opsi form memakai `push`).

## Cara Menguji Tugas 8

```bash
flutter analyze   # harus "No issues found!"
flutter test      # menjalankan skenario pengujian di atas
flutter run -d chrome
```

Di Chrome: buka **Tambah Pengalaman** dari kartu aksi dan dari drawer, tekan **Simpan** dengan field kosong, lalu lengkapi isian dan tekan **Simpan** lagi. Pakai opsi **Home** di drawer untuk kembali ke halaman utama.

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

### Tugas 8

1. **`Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()`**

   Navigator menyimpan halaman dalam bentuk tumpukan (stack).
   - `push()` menaruh halaman baru di atas tumpukan. Halaman lama tetap ada di bawahnya, jadi pengguna bisa kembali dengan tombol back.
   - `pushReplacement()` mengganti halaman paling atas dengan halaman baru. Halaman lama dibuang, jadi tombol back tidak akan kembali ke sana.
   - `pop()` membuang halaman paling atas dan kembali ke halaman di bawahnya. Ini juga dipakai untuk menutup dialog.

   Kartu aksi **Tambah Pengalaman** membuka form dengan `Navigator.push()` (di `ItemCard`), supaya tombol back perangkat membawa pengguna kembali ke halaman utama. Opsi **Home** di drawer memakai `Navigator.pushReplacement()` ke `MyHomePage`. Halaman yang sedang terbuka (misalnya form) diganti dengan halaman utama, sehingga form tidak tertinggal di tumpukan sebagai halaman yang bisa di-back.

2. **Struktur `Scaffold`, `AppBar`, dan `Drawer`**

   `Scaffold` adalah kerangka setiap halaman: `appBar` di atas, `drawer` di samping, dan `body` di tengah. Karena halaman utama, form proyek, dan form pengalaman sama-sama memakai `Scaffold` dengan `AppBar` dan `LeftDrawer` yang sama, pengguna selalu menemukan judul dan menu navigasi di tempat yang sama. `LeftDrawer` cukup ditulis sekali di `lib/widgets/`, lalu dipakai di semua halaman. Kalau ada opsi baru, cukup ditambah di satu file.

   Contoh warna tema: `AppBar` di halaman utama dan di form Tambah Pengalaman sama-sama memakai `Theme.of(context).colorScheme.primary` (dari `seedColor: Colors.indigo` di `main.dart`). Tombol **Simpan** di form pengalaman juga memakai warna yang sama. Kalau seed color diganti, ketiganya ikut berubah.

3. **Tata letak form**

   Form disusun satu kolom (`Column` dengan `crossAxisAlignment.stretch`), satu field per baris dari atas ke bawah, dengan tombol **Simpan** selebar layar di paling bawah. Susunan ini paling mudah dibaca dan diisi di layar ponsel yang sempit, dan urutannya mengikuti urutan pengisian (judul, deskripsi, kategori, lalu status dan tanggal selesai).
   - **Widget pengatur jarak:** `Padding` di `SingleChildScrollView` memberi jarak 16 px dari tepi layar, dan `SizedBox(height: 16)` memberi jarak antar-field, jadi field tidak menempel satu sama lain dan pesan error punya ruang.
   - **Widget penggulir:** `SingleChildScrollView` membuat seluruh isi form bisa digulir. Saat papan ketik muncul, tinggi layar yang tersisa mengecil. Tanpa penggulir, field di bawah dan tombol Simpan akan tertutup atau overflow. `SafeArea` menjaga isi form tidak tertutup notch atau status bar.

4. **`GlobalKey<FormState>`, `validator`, dan `validate()`**

   - `GlobalKey<FormState>` (`_formKey`) adalah "pegangan" ke widget `Form`, sehingga kode di luar field bisa mengakses state form lewat `_formKey.currentState`.
   - `validator` adalah fungsi di tiap `TextFormField` yang mengembalikan pesan error (String) kalau input salah, atau `null` kalau benar.
   - Saat tombol **Simpan** ditekan, `_formKey.currentState!.validate()` menjalankan semua validator sekaligus. Field yang salah langsung menampilkan pesan error di bawahnya, dan `validate()` mengembalikan `false`, jadi dialog tidak ditampilkan. Dialog ringkasan hanya muncul kalau semua validator mengembalikan `null`.

   Contoh nilai yang ditolak: Judul berisi spasi saja (`"   "`). Secara teknis field-nya tidak kosong, dan papan ketik teks biasa tetap mengizinkan spasi, tapi judul seperti itu tidak bermakna. Validator memakai `value.trim().isEmpty`, jadi spasi dihapus dulu sebelum dicek, dan isian ini ditolak dengan pesan "Judul tidak boleh kosong!".

   Memilih jenis input saja belum cukup karena input hanya membatasi *cara* mengisi, bukan *aturan data* di model. Papan ketik tidak bisa mencegah spasi kosong, teks yang ditempel lewat clipboard, atau ketikan dari papan ketik fisik di Chrome. Date picker juga hanya menjamin formatnya tanggal, bukan urutannya. Aturan seperti "deskripsi wajib" atau "`ended_at` tidak boleh sebelum `started_at`" tetap harus diperiksa validator (`_validateEndedAt`), dan nantinya juga oleh Django saat data dikirim ke server.

---

## AI Disclosure Tugas 7

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

### AI Disclosure Tugas 8

- **Tools:** Claude Code (Claude Opus 5.5) di VS Code.
- **Bagian yang dibantu AI:**
  - Membaca halaman soal Tugas 8 dan menyusun checklist pengerjaan.
  - Menyelesaikan TODO Tutorial 09 yang tertinggal (routing Add Project di drawer, drawer di form proyek).
  - Membuat `experience_form.dart` (field, validator, date picker, dialog ringkasan), kartu aksi, dan opsi drawer baru.
  - Menulis widget test di `test/widget_test.dart` dan menjalankan `flutter analyze` serta `flutter test`.
  - Menyusun draf jawaban reflektif Tugas 8 dan bagian README di atas.
- **Strategi prompting:** memberi link soal langsung supaya AI membaca checklist dan rubrik aslinya, lalu meminta AI menguji hasilnya (widget test dan tampilan di Chrome selebar ponsel), bukan hanya menulis kode.

log chat AI: https://drive.google.com/file/d/1bZrYR2nBua0wzANNJHX7jilCes05f7gX/view?usp=sharing

#### Keterbatasan AI dan perbaikan

- **Bug layout lama baru ketahuan saat dites di lebar ponsel.** Widget test di 390 × 844 menunjukkan baris `InfoCard` overflow 0.3 px (lebar `MediaQuery / 3.5` ditambah margin kartu) dan label kartu 2 baris overflow. Ini sudah ada sejak Tugas 7 dan tidak terlihat di jendela lebar. Diperbaiki dengan `Expanded` dan batas baris, sehingga jawaban Tugas 7 nomor 5 tentang `MediaQuery` untuk lebar `InfoCard` sudah tidak sesuai dengan kode terbaru.
- **Test bawaan Flutter (counter) sudah lama gagal** karena aplikasinya bukan counter lagi. AI menggantinya dengan test yang sesuai aplikasi.
- **Asumsi tombol back.** Karena form punya drawer, `AppBar` menampilkan ikon menu, bukan panah back. Kembali ke halaman utama dilakukan lewat tombol back perangkat (`Navigator.push`) atau opsi Home di drawer, sesuai soal.
- **AI awalnya menebak model.** Karena belum diberi lokasi proyek Django, AI sempat membuat form *Edukasi* dengan field karangan sendiri (institusi, jenjang, IPK), padahal model `Education` tidak ada di web saya. Setelah saya tunjukkan folder proyek `portfolio`, form diganti menjadi *Pengalaman* yang field dan validasinya diambil langsung dari model `Experience`.
- **Konsekuensi `auto_now_add` di model.** `started_at` terisi otomatis saat data disimpan, jadi tanggal selesai di form tidak boleh sebelum hari ini. Ini mengikuti model apa adanya. Kalau nanti ingin mencatat pengalaman lama yang sudah selesai, model web-nya yang perlu diubah (`started_at` jadi field yang bisa diisi).
