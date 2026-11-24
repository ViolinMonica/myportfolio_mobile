# MyPortfolio Mobile

[![CI](https://github.com/ViolinMonica/myportfolio_mobile/actions/workflows/main.yaml/badge.svg)](https://github.com/ViolinMonica/myportfolio_mobile/actions/workflows/main.yaml)

Aplikasi mobile Flutter untuk portofolio pribadi saya. Proyek ini lanjutan dari website portofolio Django di mata kuliah Pemrograman Berbasis Platform (PBP).

- **Nama:** Violin Monica
- **NPM:** 2506551794
- **Kelas:** PBP B

## Setup

### 1. Backend Django (sumber data)

Aplikasi ini membaca dan menulis data lewat API di repo backend
[ViolinMonica/portfolio](https://github.com/ViolinMonica/portfolio)
(versi deploy: <https://violin-monica-portofolio.pws.cs.ui.ac.id/>). Endpoint yang dipakai:

| Method | URL | Akses |
|---|---|---|
| POST | `/api/v1/auth/token/` | publik, tukar username + password jadi token |
| POST | `/api/v1/auth/logout/` | token, cabut token (204) |
| GET | `/api/v1/projects/`, `/api/v1/experiences/` (+ `<uuid>/`) | publik |
| POST | `/api/v1/projects/`, `/api/v1/experiences/` | token superuser |
| PATCH, DELETE | `/api/v1/experiences/<uuid>/` | token superuser |

```bash
git clone https://github.com/ViolinMonica/portfolio.git
cd portfolio
python -m venv env
env\Scripts\activate              # macOS/Linux: source env/bin/activate
pip install -r requirements.txt
python manage.py migrate          # termasuk tabel authtoken_token
python manage.py createsuperuser  # akun untuk login di aplikasi
python manage.py runserver        # http://localhost:8000
```

Cek token: kirim `POST http://localhost:8000/api/v1/auth/token/` dengan body JSON `{"username": "...", "password": "..."}` (curl/Postman), balasannya harus `{"token": "..."}`.

### 2. Aplikasi Flutter

1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install), lalu cek dengan `flutter doctor`.
2. Clone repositori ini dan install dependensi:
   ```bash
   git clone https://github.com/ViolinMonica/myportfolio_mobile.git
   cd myportfolio_mobile
   flutter pub get
   ```
3. **Generate kode model JSON.** File `*.g.dart` tidak di-commit, jadi perintah ini wajib setelah clone dan setiap kali model di `lib/models/` berubah:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Jalankan aplikasi. URL backend diatur lewat `--dart-define=API_BASE_URL` (default `http://10.0.2.2:8000`, yaitu alamat komputer host dilihat dari emulator Android):
   ```bash
   # Emulator Android, backend lokal
   flutter run
   # Chrome, backend lokal
   flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
   # Backend yang sudah di-deploy
   flutter run --dart-define=API_BASE_URL=https://violin-monica-portofolio.pws.cs.ui.ac.id
   ```
5. Cek kualitas kode (sama seperti CI):
   ```bash
   dart format --output=none --set-exit-if-changed .
   flutter analyze
   flutter test --coverage
   ```

### 3. CI/CD

`.github/workflows/main.yaml` berjalan pada setiap push ke `main` dan setiap pull request:

- **build** (`VeryGoodOpenSource/very_good_workflows` `flutter_package.yml@v2`): `build_runner`, cek format, `flutter analyze`, `flutter test --coverage`.
- **build_apk** (hanya setelah `build` hijau): `flutter build apk --release`, lalu mengunggah artefak **`app-release-apk`** yang bisa diunduh dari halaman run di tab Actions.

## Progres Mingguan

| Minggu | Isi |
|---|---|
| Tutorial 08 | Setup proyek Flutter, pisahkan `menu.dart` dari `main.dart`, buat `InfoCard` dan `ItemCard` |
| Tugas 7 | Identitas sendiri di `InfoCard`, 3 tombol aksi (Lihat Proyek, Tambah Proyek, Logout) dengan warna berbeda, SnackBar saat tombol ditekan |
| Tutorial 09 | Pisahkan halaman ke `lib/screens/` dan widget ke `lib/widgets/`, `LeftDrawer`, form Tambah Proyek dengan validasi dan dialog |
| Tugas 8 | Form Tambah Pengalaman (`experience_form.dart`, sesuai model `Experience` di web) dibuka dari kartu aksi dan drawer, validasi per field, dialog ringkasan, widget test |
| Tutorial 10 | Model `Project` `@JsonSerializable`, `ApiClient`, daftar dan detail proyek dari API, `AuthState` + `MultiProvider`, `LoginScreen`, `ensureLoggedIn`, POST proyek dengan token, GitHub Actions CI/CD |
| Tugas 9 | Integrasi **Experience**: endpoint DRF baru di backend, model `Experience`, GET daftar + detail publik, POST/PATCH/DELETE dengan token, penanganan 401, unit + widget test MockClient, badge CI |

## Fitur Tambahan (di luar checklist Tugas 7)

- **SnackBar mengikuti tombol yang ditekan:** warna latar SnackBar sama dengan warna tombol, dan ikon tombol ikut tampil di sebelah pesan. Pengguna langsung tahu tombol mana yang barusan ditekan.
- **SnackBar melayang (floating)** dengan sudut melengkung dan durasi 2 detik. SnackBar lama ditutup dulu (`hideCurrentSnackBar`) supaya pesan tidak menumpuk kalau tombol ditekan berkali-kali.
- **Efek ripple rapi:** `clipBehavior: Clip.antiAlias` pada `Material` membuat efek sentuh `InkWell` ikut terpotong mengikuti sudut kartu yang melengkung.
- **Docstring (`///`)** di setiap class pada `menu.dart` untuk menjelaskan peran masing-masing widget dan model.

## Struktur Kode

```
lib/
├── main.dart                  # MyApp: MultiProvider (ApiClient, AuthState) + MaterialApp
├── config.dart                # apiBaseUrl dari --dart-define=API_BASE_URL
├── models/                    # kelas @JsonSerializable (+ *.g.dart hasil build_runner)
│   ├── project.dart
│   └── experience.dart
├── services/
│   ├── api_client.dart        # semua request HTTP + ApiException
│   └── auth_state.dart        # token sesi (ChangeNotifier)
├── screens/
│   ├── menu.dart              # halaman utama, InfoCard, ItemHomepage
│   ├── login_screen.dart
│   ├── project_list_screen.dart, project_detail_screen.dart, project_form.dart
│   └── experience_list_screen.dart, experience_detail_screen.dart, experience_form.dart
└── widgets/
    ├── left_drawer.dart       # drawer bersama, Login/Logout reaktif
    ├── project_card.dart      # ItemCard (kartu aksi)
    ├── auth_guard.dart        # ensureLoggedIn()
    ├── api_list_view.dart     # FutureBuilder: loading / error + Retry / kosong / refresh
    └── api_error.dart         # handleApiError(): 401, 403, 400, jaringan putus
test/
├── helpers/fake_backend.dart  # backend palsu in-memory lewat MockClient
├── api_client_test.dart       # unit test model JSON + ApiClient
├── api_flow_test.dart         # alur Tutorial 10 (Project)
├── experience_flow_test.dart  # alur Tugas 9 (Experience)
└── widget_test.dart           # skenario Tugas 8, diperbarui dengan login
```

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

## Tugas 9: Integrasi Experience dengan Backend

### Kenapa Experience

Form Tugas 8 saya adalah **Tambah Pengalaman**, sedangkan API Tugas 6 baru mencakup Skill. Supaya form Tugas 8 benar-benar bisa di-refactor menjadi POST sesuai checklist, saya menambahkan endpoint Experience di backend (`ExperienceSerializer`, `experience_list`, `experience_detail`, beserta test-nya di `main/tests_api.py`). Aturan aksesnya sama dengan Project: GET publik, tulis hanya superuser dengan token.

### Checklist

- [x] `lib/models/experience.dart`: `@JsonSerializable(fieldRename: FieldRename.snake)`, `@JsonKey(includeToJson: false)` untuk `id` dan `started_at` (diisi server), `@JsonKey(defaultValue: 'full-time')` untuk `category`, `ended_at` nullable (= masih berjalan).
- [x] `*.g.dart` di-generate `build_runner`, diabaikan di `.gitignore` dan `analysis_options.yaml`.
- [x] `ApiClient.getExperiences()` (publik) dan `createExperience()` (`Authorization: Token <key>`).
- [x] `ExperienceListScreen`: `FutureBuilder` dengan Future dibuat di `initState()`, `RefreshIndicator`, state loading, error + Retry, dan kosong.
- [x] `ExperienceDetailScreen`: semua field (judul, kategori, status, deskripsi, tanggal mulai, tanggal selesai).
- [x] Daftar terhubung ke kartu **Lihat Pengalaman** di halaman utama dan **View Experiences** di drawer.
- [x] Form Tugas 8 meminta login lewat `ensureLoggedIn(context)` saat dibuka (kartu, drawer, tombol Tambah) dan saat Simpan.
- [x] Simpan mengirim POST dengan token dari `AuthState`. `ApiException` ditangani: 401 menghapus sesi dan membuka login lagi, 403/400/jaringan putus tampil di SnackBar. Setelah berhasil, dialog konfirmasi menutup form dan daftar dimuat ulang sehingga entri baru langsung muncul.
- [x] Workflow GitHub Actions dengan artefak `app-release-apk`, dan badge CI di atas README.

### Fitur tambahan (di luar checklist)

- **PATCH dan DELETE terautentikasi.** Di halaman detail ada tombol **Edit** (form yang sama, terisi data lama, mengirim `PATCH`) dan **Hapus** (dialog konfirmasi, lalu `DELETE`). Keduanya meminta login dan memakai penanganan 401 yang sama.
- **Pengujian otomatis (25 test Flutter, coverage ±92%).**
  - `test/api_client_test.dart`: unit test `MockClient` untuk setiap method (URL, method HTTP, header `Authorization`, body JSON yang dikirim), mapping snake_case, `ended_at: null` tetap terkirim, error non-2xx dilempar sebagai `ApiException`, dan server mati menjadi `ApiException(0)`.
  - `test/experience_flow_test.dart`: widget test melawan backend palsu (`test/helpers/fake_backend.dart`) untuk skenario Petunjuk Pengujian: lihat tanpa login, tambah meminta login, **token dicabut lalu submit (401) menghapus sesi dan meminta login ulang**, edit, hapus, error validasi server, daftar kosong, serta Retry setelah jaringan putus.
  - Backend: 6 test baru untuk Experience API (baca publik, 401/403, create/patch/delete dengan token, validasi). Total 69 test backend lulus.
- **Penanganan error di satu tempat.** `handleApiError()` (`lib/widgets/api_error.dart`) dipakai form Project, form Experience, dan aksi hapus, sehingga aturan 401/403/400 tidak ditulis ulang di setiap layar. `ApiException.readableMessage` mengubah body error DRF (misalnya `{"ended_at": ["..."]}`) menjadi kalimat pendek untuk SnackBar.
- **Jaringan putus tidak membuat aplikasi crash.** `ApiClient` membungkus `http.ClientException` menjadi `ApiException(0)`, jadi daftar menampilkan "Tidak bisa terhubung ke server" dengan tombol Retry, bukan exception yang tidak tertangkap.
- **`ApiListView<T>` generik** untuk FutureBuilder + RefreshIndicator, dipakai daftar Project dan Experience. Logika loading/error/kosong tidak tersalin dua kali.
- **Tanggal selesai tidak bergeser zona waktu.** `ended_at` dikirim sebagai tengah malam UTC dari tanggal yang dipilih (`DateTime.utc(y, m, d)`) karena Django menyimpan dalam UTC. Kalau dikirim sebagai waktu lokal, 1 Desember 00.00 WIB akan tersimpan sebagai 30 November 17.00 UTC.
- **Validasi tanggal di dua sisi.** Form menolak tanggal selesai sebelum tanggal mulai, dan `ExperienceSerializer.validate_ended_at` di Django memeriksa aturan yang sama, jadi request langsung (tanpa aplikasi) tetap ditolak.
- **`10.0.2.2` ditambahkan ke `ALLOWED_HOSTS`** di backend. Tanpa itu, request dari emulator Android ke `runserver` dibalas 400 Bad Request oleh Django.

### Cara menguji Tugas 9

```bash
flutter test   # 25 test, tanpa server
# End-to-end: jalankan backend (lihat Setup), lalu
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

1. Buka **Lihat Pengalaman** tanpa login. Daftar dari Django tampil, dan item bisa diketuk untuk melihat detail.
2. Tekan **Tambah** (atau kartu **Tambah Pengalaman**). Aplikasi membuka layar Login. Login dengan superuser, isi form, lalu **Simpan**. Refresh `http://localhost:8000/api/v1/experiences/` atau halaman Experience di web, entri baru ada di sana.
3. Uji 401: setelah login di aplikasi, hapus token di Django Admin (**Auth Token › Tokens**), lalu Simpan lagi. Aplikasi menampilkan "Sesi berakhir, silakan login lagi." dan membuka layar Login.
4. Di detail, coba **Edit** dan **Hapus**, lalu **Logout** dari drawer atau kartu Logout.

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

### Assignment 9

1. **`@JsonSerializable(fieldRename: FieldRename.snake)` dan `@JsonKey(includeToJson: false)` dibanding `Map<String, dynamic>` mentah**

   Dengan `Map` mentah, setiap widget menulis sendiri kunci JSON sebagai string (`'ended_at'`, `'category'`) dan membaca nilainya sebagai `dynamic`. Salah ketik nama kunci atau salah tipe tidak terdeteksi analyzer. Error baru muncul saat runtime, atau lebih parah, tidak muncul sama sekali karena Django diam-diam mengabaikan kunci yang tidak dikenalnya. Dengan kelas `Experience`, nama field dan tipenya diperiksa compiler. `FieldRename.snake` membuat penamaan `endedAt` (Dart) ↔ `ended_at` (DRF) ditulis sekali di generator, bukan di setiap pemanggil. `fromJson` hasil generate juga langsung mengubah string ISO menjadi `DateTime`, jadi layar tidak perlu mem-parse tanggal sendiri.

   `@JsonKey(includeToJson: false)` memisahkan field yang **dibaca** dari server dan yang **dikirim** ke server. Di model saya, `id` dan `started_at` hanya dibaca. Keduanya diisi Django (`UUIDField(default=uuid4)` dan `auto_now_add`), jadi tidak boleh ikut di body POST/PATCH.

   Bug yang dicegah: saat edit, form membuat objek `Experience` baru. Kalau body dibangun manual dari objek lama (`{...old, 'title': baru}`), `started_at` dan `is_ongoing` lama ikut terkirim, dan klien bisa tanpa sengaja mencoba menimpa tanggal mulai. Contoh lain yang benar-benar saya temui: `ended_at` harus **tetap dikirim sebagai `null`** saat pengguna mencentang lagi "Masih berjalan", supaya PATCH mengosongkannya. Dengan `Map` mentah, pola umum `if (endedAt != null) map['ended_at'] = ...` akan membuang kuncinya. Akibatnya PATCH tidak mengubah apa pun, dan pengalaman tetap tercatat "Selesai". `toJson()` hasil generate selalu menyertakan `ended_at`, dan perilaku ini dikunci oleh test di `test/api_client_test.dart`. Kalau ada kesalahan nama field, cukup diperbaiki di satu kelas, lalu `build_runner` dijalankan ulang.

2. **Future di `initState()` dan `ApiException` alih-alih `null`**

   `build()` bisa dipanggil berkali-kali: setiap `setState`, perubahan tema atau ukuran layar, keyboard muncul, atau `context.watch` di drawer memberi tahu perubahan login. Kalau `getExperiences()` dipanggil di dalam `build()`, setiap rebuild membuat Future baru. Akibatnya request HTTP dikirim ulang, `FutureBuilder` kembali ke `ConnectionState.waiting` (spinner berkedip), dan data yang sudah tampil hilang sesaat. Ini bisa menjadi loop kalau hasilnya memicu rebuild lagi. Dengan membuat Future sekali di `initState()` dan menyimpannya di field `State`, rebuild memakai Future yang sama. Request baru hanya dikirim saat memang diminta, yaitu `_reload()` dari pull-to-refresh, Retry, atau kembali dari form/detail.

   `ApiClient` melempar `ApiException` karena `null` tidak membawa informasi apa pun: apakah datanya memang kosong, token kedaluwarsa (401), akun bukan pemilik (403), input ditolak (400), atau server mati? Masing-masing butuh reaksi berbeda. 401 harus menghapus sesi dan membuka login, sedangkan 400 menampilkan pesan validasi dari DRF. Dengan exception, `FutureBuilder` otomatis masuk ke cabang `snapshot.hasError` (menampilkan tombol Retry), dan form cukup punya satu `on ApiException catch (e)` lalu memilih reaksi dari `e.statusCode` (`handleApiError`). Kalau mengembalikan `null`, setiap pemanggil wajib ingat mengecek `null`. Kalau lupa, hasilnya null-check crash di tempat lain, atau kegagalan diam-diam yang terlihat seperti "daftar kosong". Di aplikasi ini, server yang tidak bisa dihubungi pun dibungkus jadi `ApiException(0)`, jadi semua jenis kegagalan lewat satu jalur.

3. **`SessionAuthentication` vs `TokenAuthentication`**

   `SessionAuthentication` (Tutorial 04/07) menyimpan sesi di server dan mengirim `sessionid` lewat cookie. Browser menyimpan dan mengirim cookie itu otomatis ke setiap request. Karena otomatis, request tulis juga harus membawa token CSRF, supaya situs lain tidak bisa "menumpang" cookie pengguna. Ini cocok untuk halaman web Django dan Browsable API.

   `TokenAuthentication` (Tutorial 10) memakai kunci acak yang disimpan di tabel `authtoken_token`. Klien mengirimnya sendiri di header `Authorization: Token <key>` pada setiap request. Aplikasi Flutter bukan browser: `http.Client` tidak mengelola cookie dan alur CSRF seperti browser (butuh GET halaman dulu untuk mengambil `csrftoken`, lalu mengirim header `X-CSRFToken` dan `Referer`). Di Flutter Web, cookie lintas origin dari `localhost:xxxx` ke `localhost:8000` juga diblokir kecuali CORS dan `SameSite` diatur khusus. Token lebih sederhana dan stateless dari sisi klien. Karena header tidak dikirim otomatis oleh browser, request dengan token juga tidak rentan CSRF, sehingga DRF tidak memeriksa CSRF untuk token. Logout cukup menghapus baris token di server (`/api/v1/auth/logout/`), dan menghapusnya lewat Django Admin langsung membuat aplikasi menerima 401.

   `SessionAuthentication` tetap aktif karena backend yang sama juga melayani **website** portofolio dan Browsable API. Halaman Skill (Tugas 6) memanggil API lewat `fetch` dengan cookie sesi, dan admin login lewat form web. Kalau hanya token yang diaktifkan, fitur web itu akan berhenti bekerja. Kedua kelas dipasang berdampingan di `DEFAULT_AUTHENTICATION_CLASSES`: DRF mencoba token dulu, lalu sesi. Satu API melayani dua jenis klien, masing-masing dengan mekanisme yang paling cocok. `TokenAuthentication` sengaja diletakkan pertama supaya permintaan tanpa kredensial dibalas **401** dengan header `WWW-Authenticate` (bukan 403). Aplikasi memakai kode 401 itu untuk membedakan "perlu login ulang" dari "login tapi tidak berhak" (403).

4. **Job `build` dan `build_apk`, dan kenapa `*.g.dart` di-`.gitignore`**

   - **`build`** memanggil reusable workflow `very_good_workflows/flutter_package.yml@v2`. Di balik layar, workflow ini: checkout kode, memasang Flutter, `flutter pub get`, menjalankan perintah `setup` dari saya (`dart run build_runner build --delete-conflicting-outputs`), cek format (`dart format --set-exit-if-changed`), static analysis (`flutter analyze`), lalu `flutter test --coverage` (juga dengan urutan test acak). Setelah itu ia memeriksa coverage terhadap `min_coverage` (saya set 0 dan mengecualikan `**/*.g.dart` lewat `coverage_excludes`), dengan batas waktu `timeout_minutes: 15`. Job ini menjawab pertanyaan "apakah kodenya rapi, lolos analyzer, dan test-nya hijau?" pada setiap push ke `main` dan setiap pull request.
   - **`build_apk`** punya `needs: build`, jadi hanya jalan kalau `build` hijau. APK tidak pernah dibuat dari kode yang gagal test. Job ini memasang Flutter stable, `flutter pub get`, menjalankan `build_runner` lagi (setiap job berjalan di mesin baru yang bersih), `flutter build apk --release`, lalu mengunggah `build/app/outputs/flutter-apk/app-release.apk` sebagai artefak `app-release-apk` dengan `actions/upload-artifact@v4`. Asisten dosen atau penguji bisa mengunduh APK dari halaman run tanpa memasang Flutter. Ini bagian CD (delivery).
   - **`*.g.dart` di-`.gitignore`** karena file ini adalah **hasil turunan** dari `lib/models/*.dart`, bukan sumber. Kalau ikut di-commit, ia bisa basi. Misalnya field baru ditambah di `experience.dart` tapi `build_runner` lupa dijalankan: kode yang di-commit tidak sinkron, dan error hanya muncul di mesin orang lain. Diff commit juga jadi penuh kode generator yang tidak di-review siapa pun, dan rawan konflik merge. CI tetap butuh file itu untuk analyze dan build, jadi CI **membuatnya ulang sendiri** lewat `build_runner` di kedua job. Satu-satunya sumber kebenaran tetap kelas model, dan hasil generate di CI selalu sesuai dengan kode yang sedang diuji. Ini juga alasan `**/*.g.dart` dikecualikan dari analyzer dan coverage: yang dinilai hanya kode yang saya tulis.

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

### AI Disclosure Tugas 9

- **Tools:** Claude Code (Claude Opus 5.5) di VS Code, dengan akses ke repo `myportfolio_mobile`, repo backend `portfolio`, terminal (Flutter, Python), dan browser untuk membaca halaman soal.
- **Bagian yang dibantu AI:**
  - Membaca soal Tutorial 10 dan Tugas 9, mengecek status pengerjaan Tutorial 10, lalu menyusun rencana per checklist.
  - Backend: `ExperienceSerializer`, view `experience_list`/`experience_detail`, URL, 6 test API, `10.0.2.2` di `ALLOWED_HOSTS`, dan dokumentasi endpoint di README backend.
  - Flutter: model `Experience`, perluasan `ApiClient` (GET/POST/PATCH/DELETE, error jaringan), `ApiListView`, `handleApiError`, layar daftar/detail Experience, refactor form Tugas 8 menjadi POST/PATCH, wiring kartu dan drawer.
  - Test: unit test `MockClient`, widget test dengan backend palsu, dan penyesuaian test Tugas 8 yang sekarang butuh login.
  - Verifikasi: `dart format`, `flutter analyze`, `flutter test --coverage`, `manage.py test`, serta uji end-to-end `ApiClient` sungguhan melawan `runserver` lokal (GET publik, 401 token salah, POST/PATCH/DELETE, 400 validasi tanggal, 401 setelah logout, header CORS, host `10.0.2.2`).
  - Draf README ini, termasuk jawaban reflektif.
- **Strategi prompting:** memberi link halaman soal (bukan ringkasan) supaya AI membaca checklist dan rubrik aslinya, meminta AI mengecek dulu apa yang sudah ada di kedua repo sebelum menulis kode, meminta commit kecil dengan conventional commits per fitur di branch terpisah, dan meminta setiap klaim diverifikasi dengan menjalankan test atau server sungguhan.

#### Keterbatasan AI dan perbaikan

- **Asumsi "backend sudah siap" ternyata salah.** Checklist mengandaikan endpoint DRF section dari Tugas 6 sudah ada. Saat repo backend dibaca, API Tugas 6 saya ternyata Skill, sedangkan form Tugas 8 adalah Experience. Perubahan Tutorial 10 (token, CORS, logout) juga masih di branch `feat/tutorial-10`, belum di `main`. Endpoint Experience perlu dibuat dulu, dan keputusan memakai Experience (bukan Skill) diambil supaya form Tugas 8 benar-benar terpakai.
- **Detail lingkungan yang tidak terlihat dari kode Flutter.** `ALLOWED_HOSTS` backend belum memuat `10.0.2.2`, jadi emulator Android akan menerima 400 Bad Request walaupun kode Flutter benar. Ini baru ketahuan saat request diuji dengan header `Host: 10.0.2.2`.
- **Zona waktu.** Draf pertama mengirim tanggal selesai sebagai waktu lokal. Karena Django menyimpan dalam UTC, tanggal bisa mundur satu hari untuk pengguna WIB. Diperbaiki dengan `DateTime.utc(y, m, d)` dan memformat tanggal tanpa konversi zona.
- **Kode tutorial yang ikut disalin punya celah kecil.** `_reload()` dari tutorial melakukan `await future`. Kalau refresh gagal, error dilempar ulang ke `RefreshIndicator` dan menjadi exception yang tidak tertangkap, padahal `FutureBuilder` sudah menampilkannya. Sekarang error ditelan di `_reload()`.
- **Test AI sendiri sempat salah.** Satu test hapus mengharapkan request terakhir adalah `DELETE`, padahal aplikasi (dengan benar) memuat ulang daftar dengan `GET` setelahnya. Satu test "error validasi server" juga awalnya tidak pernah sampai ke server karena ditolak validator form lebih dulu. Keduanya diperbaiki supaya benar-benar menguji perilaku yang dimaksud. Test yang hijau belum tentu menguji hal yang benar, jadi tiap test perlu dibaca ulang.
- **AI tidak bisa menjalankan emulator Android atau melihat tampilan.** Verifikasi AI terbatas pada test otomatis dan request HTTP sungguhan. Pengecekan tampilan di emulator, alur hapus token lewat Django Admin, dan versi deploy PWS tetap perlu saya lakukan sendiri.

log chat AI: _(tautan menyusul)_
