# Product Requirements Document (PRD)

# Barakah: Jadwal Sholat, Kiblat & Donasi

## Versi 2.0 (Lengkap, Memenuhi Kriteria Tugas Akhir)

| Atribut | Keterangan |
|---|---|
| Nama Produk | Barakah |
| Platform | Android dan iOS (Flutter) |
| Jenis Dokumen | PRD, Tugas Akhir Pemrograman Aplikasi Mobile |
| Versi | 2.0 (Draf) |
| Tanggal | 15 Oktober 2026 |
| Penyusun |  |
| Dosen Pengampu | |
| Pengganti | PRD_Barakah.md versi 1.0 |

Tabel 1. Informasi dokumen

## Riwayat Revisi

| Versi | Tanggal | Perubahan |
|---|---|---|
| 1.0 | 11 Oktober 2026 | PRD awal: jadwal sholat, kiblat, tasbih, zakat dan donasi, ledger hash chain, AI fikih, kuis, notifikasi |
| 2.0 | 15 Oktober 2026 | Menambah login terenkripsi dan session, login biometrik, basis data lokal dan online (Supabase), web service, bottom navigation baru (Profil, Saran dan Kesan, Logout), sensor gyroscope, AI non-LLM, mini game sensor, sinkronisasi, modul IoT opsional, dan matriks kepatuhan kriteria |

Tabel 2. Riwayat revisi

---

## 1. Ringkasan Eksekutif

Barakah adalah aplikasi mobile bagi umat Muslim yang menggabungkan ibadah harian dan kegiatan sosial dalam satu aplikasi. Pengguna masuk dengan akun yang terlindungi (kata sandi di-hash, sesi bertoken, dan login biometrik), lalu mengakses jadwal sholat sesuai lokasi, arah kiblat berbasis sensor, tasbih digital, pencarian masjid terdekat, kalkulator zakat, dan pencatatan donasi pada buku catatan berantai hash.

Aplikasi ini bekerja dengan prinsip offline first. Data disimpan di SQLite lokal yang dienkripsi dan disinkronkan ke basis data online (Supabase PostgreSQL) lewat web service REST. Aplikasi juga memuat fitur LLM untuk tanya jawab fikih dasar, fitur AI ringan untuk rekomendasi, dua mini game, konversi waktu dan mata uang yang terpadu dengan alur ibadah, serta notifikasi pengingat adzan.

Dokumen ini dirancang agar setiap kriteria penilaian tugas akhir memiliki fitur, kebutuhan, dan kriteria penerimaan yang jelas. Pemetaannya ada pada Bagian 6.

## 2. Latar Belakang dan Masalah

1. Pengguna memakai beberapa aplikasi terpisah untuk jadwal sholat, kompas kiblat, tasbih, dan donasi, sehingga pengalamannya terpecah.
2. Pelancong dan pekerja lintas zona waktu kesulitan membandingkan waktu sholat di kota asal dan kota tujuan.
3. Donatur sering tidak yakin catatan donasinya tetap utuh dan tidak diubah pengelola.
4. Pengguna yang bertransaksi lintas negara membutuhkan perhitungan zakat dan donasi dalam beberapa mata uang.
5. Data ibadah dan donasi bersifat pribadi, sehingga membutuhkan akun, sesi yang aman, dan penguncian cepat lewat biometrik.
6. Pertanyaan fikih dasar sering muncul di tengah aktivitas dan membutuhkan jawaban cepat yang tetap mengarahkan ke rujukan terpercaya.

## 3. Tujuan Produk dan Metrik Keberhasilan

### 3.1 Tujuan

1. Menyediakan autentikasi yang aman dengan kata sandi ter-hash, session bertoken, dan login biometrik, tanpa Firebase.
2. Menyediakan jadwal sholat dan arah kiblat yang akurat berdasarkan lokasi dan sensor.
3. Menyediakan pencatatan zakat dan donasi yang transparan dan dapat diverifikasi integritasnya.
4. Mendukung pengguna yang bepergian lewat konversi zona waktu dan mata uang.
5. Menyediakan data yang konsisten di perangkat dan server lewat sinkronisasi offline first.
6. Menunjukkan penerapan teknologi mobile (LBS, sensor, notifikasi, kriptografi, AI, LLM, game, multiplatform) dalam satu produk yang berjalan.

### 3.2 Metrik Keberhasilan

| No | Metrik | Target |
|---|---|---|
| 1 | Waktu tampil jadwal sholat setelah lokasi diperoleh | ≤ 2 detik |
| 2 | Deviasi arah kiblat setelah kalibrasi | ≤ 5 derajat |
| 3 | Ketepatan pengingat adzan terhadap waktu sholat | Selisih ≤ 1 menit |
| 4 | Waktu login kata sandi sampai beranda (jaringan normal) | ≤ 3 detik |
| 5 | Waktu login biometrik sampai beranda | ≤ 2 detik setelah verifikasi biometrik |
| 6 | Deteksi perubahan data pada ledger | 100% terdeteksi pada uji manipulasi |
| 7 | Keberhasilan sinkronisasi setelah koneksi pulih | ≥ 99% data terkirim tanpa duplikasi |
| 8 | Jadwal sholat tersedia saat offline | 7 hari ke depan dari cache terakhir |
| 9 | Tingkat selesai alur donasi pada uji pengguna | ≥ 80% |
| 10 | Skor kemudahan penggunaan (SUS) pada uji pengguna | ≥ 68 |

Tabel 3. Metrik keberhasilan

## 4. Target Pengguna dan Persona

| Persona | Profil | Kebutuhan | Titik Masalah |
|---|---|---|---|
| Rizky | Mahasiswa, 21 tahun, Yogyakarta | Jadwal akurat, pengingat adzan, tasbih, kuis, login cepat dengan sidik jari | Aplikasi penuh iklan dan terpisah-pisah |
| Bu Siti | Karyawan, 45 tahun, sering dinas Jakarta, Makassar, Jayapura | Jadwal di beberapa zona waktu, arah kiblat di hotel, data aman di akun | Salah menghitung selisih waktu sholat antar kota |
| Pak Ahmad | Jamaah umrah, 52 tahun, Jeddah dan transit London | Zakat dan donasi dalam SAR, USD, IDR, ledger yang transparan | Sulit memantau kurs dan memastikan donasi tercatat |

Tabel 4. Persona pengguna

## 5. Ruang Lingkup, Keputusan, dan Asumsi

### 5.1 Termasuk (In Scope)

1. Registrasi, login terenkripsi, session, dan login biometrik.
2. Jadwal sholat berbasis lokasi, masjid terdekat, pencarian, dan pemilihan.
3. Kiblat (magnetometer dan gyroscope), tasbih (accelerometer).
4. Konversi waktu (WIB, WITA, WIT, London) dan konversi mata uang (IDR, USD, SAR).
5. Kalkulator zakat dan pencatatan donasi, serta ledger berantai hash dengan proof of work ringan.
6. Tanya jawab fikih dasar (LLM) dan AI ringan (rekomendasi adaptif dan prediksi target dzikir).
7. Mini game: Kuis Islami dan Cari Arah.
8. Notifikasi lokal pengingat adzan, dzikir, dan donasi.
9. Profil dengan foto, Saran dan Kesan, dan Logout.
10. Basis data lokal (SQLite) dan online (Supabase PostgreSQL), web service REST, dan sinkronisasi.
11. Modul IoT opsional (ESP32) sebagai fase lanjutan.

### 5.2 Tidak Termasuk (Out of Scope)

1. Pembayaran riil (payment gateway, transfer bank). Donasi bersifat pencatatan dan simulasi.
2. Blockchain publik terdistribusi. Yang dibangun adalah rantai blok sederhana dengan verifikasi server.
3. Fatwa resmi. Jawaban LLM adalah informasi umum.
4. Lupa kata sandi lewat email (membutuhkan layanan email), dijadwalkan pada fase lanjutan.
5. Konten Al-Qur'an lengkap dan audio murottal.
6. Push notification jarak jauh lewat Firebase Cloud Messaging, agar konsisten dengan batasan tanpa Firebase.

### 5.3 Keputusan yang Sudah Ditetapkan

| No | Keputusan | Nilai |
|---|---|---|
| 1 | Framework | Flutter (Android dan iOS) |
| 2 | Backend dan basis data online | Supabase (PostgreSQL, Edge Functions, Storage) |
| 3 | Bottom navigation | 5 tab: Beranda, Ibadah, Profil, Saran dan Kesan, Logout |

Tabel 5. Keputusan yang sudah ditetapkan

### 5.4 Asumsi Bawaan (dapat diubah)

| No | Asumsi | Alasan |
|---|---|---|
| 1 | Autentikasi dibuat sendiri (custom) lewat Edge Functions, bukan Supabase Auth | Kriteria tugas meminta login dengan enkripsi dan session yang dibuat sendiri. Supabase Auth adalah alternatif yang lebih ringkas dan tetap bukan Firebase, tetapi implementasinya lebih sedikit terlihat sebagai karya mahasiswa. Konfirmasikan ke dosen |
| 2 | LLM diakses lewat Edge Function perantara dengan penyedia yang dapat diganti | Kunci API tidak boleh berada di aplikasi |
| 3 | AI non-LLM berupa rekomendasi kuis adaptif dan prediksi target dzikir (on-device) | Ringan dan tidak membutuhkan pelatihan model besar |
| 4 | Ledger berupa rantai per pengguna dengan jangkar head di server | Menghindari rebutan penulisan antar pengguna |
| 5 | IoT (ESP32) berstatus opsional dan tidak menghalangi kriteria lain | Kriteria menyebut IoT sebagai pilihan |
| 6 | Penyusun, dosen, dan jumlah anggota memakai placeholder | Belum diberikan |

Tabel 6. Asumsi bawaan

## 6. Matriks Kepatuhan terhadap Kriteria Tugas

| No | Kriteria | Fitur di Barakah | Modul | Kode Kebutuhan |
|---|---|---|---|---|
| 1 | Login dengan enkripsi (tanpa Firebase) dan session | Registrasi dan login dengan hash kata sandi di server, enkripsi data lokal AES-256, session access dan refresh token | M1, M2 | FR-AUTH, FR-SES |
| 2 | Login biometrik | Sidik jari atau wajah membuka kunci aplikasi dan login cepat | M3 | FR-BIO |
| 3 | Basis data lokal dan online | SQLite (drift) terenkripsi dan Supabase PostgreSQL, sinkronisasi dua arah | M20 | FR-SYNC |
| 4 | Web service/API, boleh IoT, game, multiplatform, serta LBS terkait tema | REST API (Edge Functions), Flutter Android dan iOS, game, IoT opsional, LBS masjid dan jadwal | M4, M6, M15, M21, M20 | FR-API, FR-LBS, FR-GAME, FR-IOT |
| 5 | Bottom navigation: profil (ada gambar), saran dan kesan, logout | Tab Beranda, Ibadah, Profil, Saran dan Kesan, Logout | M17, M18, M19 | FR-NAV, FR-PRO, FR-FB, FR-OUT |
| 6 | Konversi mata uang (minimal 3) dan waktu (WIB, WIT, WITA, London) terpadu dengan konsep | Zakat dan donasi dalam IDR, USD, SAR. Jadwal sholat dalam 4 zona | M9, M10, M11 | FR-TZ, FR-CUR, FR-ZKT |
| 7 | Minimal 2 sensor | Magnetometer (kiblat), gyroscope (kiblat halus dan game), accelerometer (tasbih) | M7, M8, M15 | FR-QBL, FR-TSB, FR-GAME |
| 8 | AI dan LLM | LLM: tanya fikih dan penjelasan zakat. AI: rekomendasi kuis adaptif dan prediksi target dzikir | M13, M14 | FR-LLM, FR-AI |
| 9 | Mini game sederhana | Kuis Islami dan Cari Arah | M15 | FR-GAME |
| 10 | Pencarian dan pemilihan | Pencarian masjid, kota, kampanye, riwayat, dan pemilihan zona waktu, mata uang, metode hitung | M5, M6 | FR-SRC |
| 11 | Notifikasi mobile | Pengingat adzan, dzikir harian, donasi tercatat, masjid dekat | M16 | FR-NTF |
| 12 | Blockchain sederhana | Rantai blok SHA-256 dengan proof of work ringan dan verifikasi server | M12 | FR-BLK |

Tabel 7. Matriks kepatuhan kriteria

## 7. Arsitektur dan Teknologi

### 7.1 Gambaran Arsitektur

```
+------------------------------------------------------------+
|                    APLIKASI FLUTTER                        |
|  Presentation: Beranda | Ibadah | Profil | Saran | Logout  |
|  State: Riverpod/Provider   Routing: go_router             |
|  Domain: AuthService SessionService BiometricService       |
|          PrayerService QiblaService TasbihService          |
|          TimezoneService CurrencyService ZakatService      |
|          LedgerService AiService QuizService NotifService  |
|          SyncService                                       |
|  Data: SQLite terenkripsi (drift)  | Secure Storage        |
|        Outbox sinkronisasi         | Cache gambar          |
+------------------------------------------------------------+
|        HTTPS (REST JSON, Bearer access token)              |
+------------------------------------------------------------+
|                     SUPABASE                               |
|  Edge Functions (REST): auth, profile, sync, ledger, ai,   |
|                         rates, mosques, quiz, feedback, iot|
|  PostgreSQL: users, sessions, ledger_blocks, ...           |
|  Storage: avatar pengguna                                  |
+------------------------------------------------------------+
|  Layanan eksternal: Aladhan (jadwal), penyedia kurs,       |
|  OpenStreetMap (Overpass, Nominatim), penyedia LLM         |
+------------------------------------------------------------+
|  Opsional: ESP32 (lampu/buzzer adzan, tasbih fisik)        |
+------------------------------------------------------------+
```

Gambar 1. Arsitektur sistem

### 7.2 Teknologi yang Direkomendasikan

| Lapisan | Rekomendasi | Alasan |
|---|---|---|
| Framework | Flutter (Dart) | Satu basis kode untuk Android dan iOS |
| State dan routing | Riverpod atau Provider, go_router | Sederhana dan mudah diuji |
| HTTP | dio atau http | Penanganan token dan interceptor |
| Basis data lokal | drift (SQLite) dengan sqlcipher_flutter_libs | Relasional dan dapat dienkripsi |
| Penyimpanan aman | flutter_secure_storage | Token dan kunci enkripsi di Keystore atau Keychain |
| Biometrik | local_auth | Sidik jari dan Face ID |
| Kriptografi | crypto (SHA-256), cryptography (AES-GCM, PBKDF2) | Hash ledger dan enkripsi |
| Lokasi | geolocator, geocoding | GPS dan nama kota |
| Peta | flutter_map dan latlong2 (OpenStreetMap) | Peta tanpa kunci berbayar |
| Sensor | sensors_plus (accelerometer, gyroscope, magnetometer), flutter_compass | Kiblat, tasbih, game |
| Zona waktu | timezone, intl | Zona IANA termasuk DST London |
| Notifikasi | flutter_local_notifications, workmanager | Pengingat terjadwal |
| Gambar | image_picker, cached_network_image | Foto profil |
| Konektivitas | connectivity_plus | Deteksi online dan offline |
| Izin | permission_handler | Lokasi, kamera, notifikasi |
| Backend | Supabase (PostgreSQL, Edge Functions, Storage) | API siap pakai dan SQL penuh |
| AI | Penyedia LLM lewat Edge Function | Kunci tetap di server |

Tabel 8. Rekomendasi teknologi

Catatan: pemilihan paket, versi, dan fitur layanan perlu diverifikasi ulang saat implementasi, karena ketersediaan, batas pemakaian, dan syarat layanan bisa berubah. Kunci rahasia (kunci LLM, kunci penandatangan token, service role) hanya disimpan sebagai variabel lingkungan Edge Function.

### 7.3 Prinsip Akses Data

1. Aplikasi tidak mengakses tabel secara langsung. Seluruh akses data pengguna lewat Edge Functions (web service REST) yang memverifikasi access token.
2. Row Level Security (RLS) diaktifkan pada semua tabel dengan kebijakan menolak akses langsung dari peran anon dan authenticated. Edge Function memakai peran service di sisi server.
3. Hanya data publik non-sensitif (misalnya daftar kampanye dan bank soal) yang boleh dibaca lewat endpoint publik.

### 7.4 Struktur Proyek Flutter yang Disarankan

```
lib/
  core/        (config, theme, router, network, constants)
  data/        (local drift, remote api, repositories, sync)
  features/
    auth/      (login, register, session, biometric)
    home/      (beranda, jadwal)
    worship/   (hub ibadah, masjid, kiblat, tasbih)
    converter/ (waktu, mata uang)
    donation/  (zakat, donasi, ledger)
    ai/        (chat, rekomendasi)
    games/     (kuis, cari arah)
    profile/   (profil, pengaturan)
    feedback/  (saran dan kesan)
    iot/       (opsional)
  shared/      (widgets, utils)
```

Gambar 2. Struktur folder proyek

## 8. Arsitektur Informasi dan Navigasi

### 8.1 Bottom Navigation (5 Tab)

| Tab | Isi | Perilaku |
|---|---|---|
| Beranda | Sholat berikutnya, hitung mundur, jadwal hari ini, ringkasan donasi dan dzikir, status sinkronisasi | Layar utama setelah login |
| Ibadah | Pusat fitur: Masjid Terdekat, Kiblat, Tasbih, Konversi, Zakat dan Donasi, Ledger, Tanya AI, Kuis dan Game | Berisi kolom pencarian fitur dan kartu fitur |
| Profil | Foto profil, data akun, pengaturan, keamanan, tema | Layar tab |
| Saran dan Kesan | Formulir saran dan kesan mata kuliah Pemrograman Aplikasi Mobile, riwayat kiriman | Layar tab |
| Logout | Dialog konfirmasi keluar | Tidak membuka layar. Menampilkan dialog, lalu menghapus sesi |

Tabel 9. Struktur bottom navigation

### 8.2 Peta Layar (Sitemap)

```
Splash
 |-- (belum login) Login <-> Registrasi
 |-- (sesi tersimpan, terkunci) Kunci Biometrik
 |
 +-- Beranda
 |     +-- Detail Jadwal / Pilih Zona Waktu
 +-- Ibadah (hub + pencarian)
 |     +-- Masjid Terdekat (peta, daftar, favorit)
 |     +-- Kiblat
 |     +-- Tasbih (+ riwayat)
 |     +-- Konversi (tab Waktu | tab Mata Uang)
 |     +-- Zakat (kalkulator) <-> Donasi (kampanye, form, bukti)
 |     +-- Ledger (daftar blok, verifikasi, detail blok)
 |     +-- Tanya AI (chat)
 |     +-- Kuis (kategori, soal, hasil) | Cari Arah (game)
 +-- Profil
 |     +-- Edit Profil (foto), Ganti Kata Sandi, Keamanan (biometrik)
 |     +-- Pengaturan (notifikasi, metode hitung, tema, sinkronisasi)
 +-- Saran dan Kesan (form, riwayat)
 +-- Logout (dialog)
```

Gambar 3. Peta layar

## 9. Kebutuhan Fungsional

Format: kebutuhan diberi kode FR, kriteria penerimaan diberi kode AC dalam bentuk Given, When, Then.

### 9.1 Modul M1: Registrasi dan Login Terenkripsi

Deskripsi: pengguna membuat akun dan masuk. Kata sandi tidak pernah disimpan atau dikirim dalam bentuk yang dapat dibaca setelah sampai di server.

Kebutuhan:

1. FR-AUTH-01 Registrasi menerima nama lengkap, email, nama pengguna, kata sandi, dan konfirmasi kata sandi.
2. FR-AUTH-02 Validasi: email berformat valid dan unik, nama pengguna unik, kata sandi minimal 8 karakter berisi huruf dan angka.
3. FR-AUTH-03 Server menyimpan kata sandi hanya sebagai hash dengan salt unik per pengguna memakai Argon2id atau bcrypt. Bila pustaka tidak tersedia di lingkungan Edge Function, gunakan PBKDF2 dengan SHA-256 dan jumlah iterasi tinggi lewat Web Crypto.
4. FR-AUTH-04 Seluruh komunikasi memakai HTTPS (TLS). Aplikasi menolak koneksi tanpa TLS.
5. FR-AUTH-05 Login memakai email atau nama pengguna dan kata sandi. Pesan galat tidak membedakan "akun tidak ada" dan "kata sandi salah".
6. FR-AUTH-06 Pembatasan percobaan: setelah 5 kali gagal berturut-turut, akun dikunci sementara 15 menit dan percobaan dicatat.
7. FR-AUTH-07 Basis data lokal dienkripsi AES-256 (SQLCipher). Kunci enkripsi dibangkitkan acak saat instalasi dan disimpan di Keystore atau Keychain lewat flutter_secure_storage.
8. FR-AUTH-08 Pengguna dapat mengganti kata sandi dengan memasukkan kata sandi lama. Seluruh sesi lain dicabut setelah penggantian.
9. FR-AUTH-09 Kolom kata sandi memiliki tombol tampil atau sembunyi dan tidak disimpan di riwayat input.

Catatan istilah: hash kata sandi bersifat satu arah dan bukan enkripsi. Enkripsi diterapkan pada penyimpanan lokal (AES-256) dan pada lalu lintas jaringan (TLS). PRD menyebut keduanya agar sesuai dengan kriteria.

Kriteria penerimaan:

1. AC-AUTH-01 Given data registrasi valid, When pengguna menekan Daftar, Then akun dibuat dan pengguna diarahkan ke Login (atau langsung masuk).
2. AC-AUTH-02 Given email sudah terdaftar, When pengguna mendaftar, Then muncul pesan galat pada kolom email.
3. AC-AUTH-03 Given basis data server diperiksa, When baris pengguna dibaca, Then kolom kata sandi berisi hash dan salt, tidak ada kata sandi asli.
4. AC-AUTH-04 Given 5 kali kata sandi salah, When percobaan ke-6 dilakukan, Then akun terkunci dan pesan menyebut waktu tunggu.
5. AC-AUTH-05 Given berkas basis data lokal dibuka dengan aplikasi SQLite biasa, When dibaca, Then isinya tidak terbaca (terenkripsi).
6. AC-AUTH-06 Given kata sandi kurang dari 8 karakter, When pengguna mengirim, Then validasi menolak dengan pesan yang jelas.

### 9.2 Modul M2: Manajemen Session

Deskripsi: setelah login, server menerbitkan token sesi. Sesi bertahan selama masa berlaku dan dapat dicabut.

Kebutuhan:

1. FR-SES-01 Login menghasilkan access token berumur pendek (15 menit) dan refresh token berumur lebih panjang (7 hari), keduanya ditandatangani server.
2. FR-SES-02 Token disimpan hanya di flutter_secure_storage, tidak di SharedPreferences atau SQLite biasa.
3. FR-SES-03 Aplikasi memperbarui access token otomatis memakai refresh token saat kedaluwarsa. Refresh token dirotasi pada setiap pembaruan.
4. FR-SES-04 Server menyimpan sesi (ID sesi, pengguna, perangkat, waktu dibuat, waktu kedaluwarsa, status cabut). Refresh token disimpan sebagai hash.
5. FR-SES-05 Sesi kedaluwarsa atau dicabut membuat aplikasi kembali ke layar Login dengan pesan "Sesi berakhir".
6. FR-SES-06 Kunci otomatis: bila aplikasi tidak aktif lebih dari 5 menit atau dimulai ulang dari kondisi tertutup, aplikasi menampilkan layar kunci (biometrik atau kata sandi) sebelum konten.
7. FR-SES-07 Setiap permintaan ke API membawa Bearer access token. Permintaan tanpa token valid ditolak dengan status 401.
8. FR-SES-08 Splash memeriksa sesi tersimpan. Bila valid, pengguna diarahkan ke Beranda. Bila tidak, ke Login.

Kriteria penerimaan:

1. AC-SES-01 Given pengguna sudah login, When aplikasi ditutup dan dibuka dalam masa berlaku refresh token, Then pengguna tidak perlu mengetik kata sandi (cukup lewat layar kunci).
2. AC-SES-02 Given access token kedaluwarsa, When aplikasi memanggil API, Then token diperbarui otomatis tanpa interupsi bagi pengguna.
3. AC-SES-03 Given refresh token dicabut di server, When aplikasi mencoba memperbarui, Then pengguna dikembalikan ke Login.
4. AC-SES-04 Given token disalin ke perangkat lain, When dipakai setelah rotasi, Then server menolak token lama.
5. AC-SES-05 Given aplikasi di latar belakang lebih dari 5 menit, When dibuka kembali, Then layar kunci tampil sebelum konten.

### 9.3 Modul M3: Login Biometrik

Deskripsi: pengguna dapat memakai sidik jari atau pengenalan wajah untuk membuka kunci aplikasi dan login cepat.

Kebutuhan:

1. FR-BIO-01 Aplikasi mendeteksi ketersediaan biometrik di perangkat (tersedia, belum terdaftar, tidak ada). Opsi biometrik hanya tampil bila tersedia.
2. FR-BIO-02 Mengaktifkan biometrik di Profil, bagian Keamanan, memerlukan memasukkan kata sandi lebih dulu, lalu verifikasi biometrik.
3. FR-BIO-03 Setelah aktif, server menerbitkan device token yang terikat pada perangkat dan akun. Device token disimpan di secure storage dan hanya dapat dibuka setelah verifikasi biometrik berhasil.
4. FR-BIO-04 Login biometrik menukar device token dengan sesi baru lewat endpoint server. Biometrik tidak pernah menggantikan verifikasi server.
5. FR-BIO-05 Biometrik juga dipakai pada layar kunci (FR-SES-06).
6. FR-BIO-06 Bila biometrik gagal 3 kali atau terkunci oleh sistem, aplikasi menawarkan login kata sandi.
7. FR-BIO-07 Bila pengguna mengubah biometrik pada perangkat (menambah atau menghapus sidik jari), device token dianggap tidak valid dan pengguna diminta login ulang dengan kata sandi.
8. FR-BIO-08 Pengguna dapat menonaktifkan biometrik kapan saja. Device token dihapus di perangkat dan dicabut di server.
9. FR-BIO-09 Aplikasi memiliki deskripsi izin Face ID pada iOS dan mendukung prompt biometrik pada Android.

Kriteria penerimaan:

1. AC-BIO-01 Given biometrik tersedia dan aktif, When pengguna membuka aplikasi, Then prompt biometrik tampil dan verifikasi berhasil membuka Beranda.
2. AC-BIO-02 Given perangkat tidak memiliki biometrik terdaftar, When pengguna membuka Keamanan, Then opsi biometrik nonaktif disertai penjelasan.
3. AC-BIO-03 Given biometrik gagal 3 kali, When prompt ditutup, Then tombol "Gunakan kata sandi" tersedia.
4. AC-BIO-04 Given pengguna menonaktifkan biometrik, When aplikasi dibuka berikutnya, Then login memakai kata sandi.
5. AC-BIO-05 Given perangkat dicuri tanpa biometrik pemilik, When penyerang mencoba membuka aplikasi, Then device token tidak dapat dipakai.

### 9.4 Modul M4: Beranda, Jadwal Sholat, dan LBS

Deskripsi: layar utama dengan jadwal sholat sesuai lokasi dan ringkasan aktivitas.

Kebutuhan:

1. FR-LBS-01 Aplikasi mengambil koordinat GPS dan nama kota pengguna.
2. FR-LBS-02 Aplikasi menampilkan enam waktu (Subuh, Terbit, Dzuhur, Ashar, Maghrib, Isya), penanda sholat berikutnya, dan hitung mundur.
3. FR-LBS-03 Cache jadwal minimal 7 hari ke depan disimpan di SQLite untuk pemakaian offline.
4. FR-LBS-04 Jadwal dihitung ulang otomatis bila lokasi bergeser lebih dari 20 km.
5. FR-LBS-05 Pengguna dapat memilih kota manual (lihat M5) bila izin lokasi ditolak.
6. FR-LBS-06 Beranda menampilkan ringkasan: total donasi bulan ini, hitungan dzikir hari ini, dan status sinkronisasi (tersinkron, menunggu, galat).
7. FR-LBS-07 Pengguna memilih metode hitung dan mazhab Ashar di Pengaturan.
8. FR-LBS-08 Tampilan jadwal mengikuti zona waktu tampilan yang dipilih (lihat M9).

Kriteria penerimaan:

1. AC-LBS-01 Given GPS aktif dan izin diberikan, When Beranda dibuka, Then jadwal enam waktu dan nama kota tampil dalam 2 detik.
2. AC-LBS-02 Given perangkat offline dan cache tersedia, When Beranda dibuka, Then jadwal dari cache tampil dengan label "Data offline".
3. AC-LBS-03 Given pengguna berpindah lebih dari 20 km, When aplikasi dibuka, Then jadwal dihitung ulang untuk lokasi baru.
4. AC-LBS-04 Given izin lokasi ditolak, When Beranda dibuka, Then aplikasi menawarkan pemilihan kota manual dan tidak menutup.

### 9.5 Modul M5: Pusat Ibadah dan Pencarian

Deskripsi: tab Ibadah menjadi pintu ke semua fitur serta menyediakan pencarian dan pemilihan.

Kebutuhan:

1. FR-SRC-01 Tab Ibadah memuat kolom pencarian fitur dan kartu fitur yang dikelompokkan: Ibadah (Masjid, Kiblat, Tasbih), Keuangan (Konversi, Zakat dan Donasi, Ledger), Belajar (Tanya AI, Kuis dan Game).
2. FR-SRC-02 Pencarian fitur menyaring kartu secara langsung saat mengetik.
3. FR-SRC-03 Pencarian kota manual memakai layanan geokode (Nominatim) dan menampilkan daftar hasil yang dapat dipilih.
4. FR-SRC-04 Pencarian masjid berdasarkan nama atau alamat dengan filter radius dan pengurutan (jarak, nama).
5. FR-SRC-05 Pencarian kampanye donasi berdasarkan kata kunci dan filter kategori.
6. FR-SRC-06 Pencarian riwayat (chat AI, donasi, kuis) berdasarkan kata kunci dan rentang tanggal.
7. FR-SRC-07 Pemilihan: zona waktu, mata uang, metode hitung sholat, kampanye, dan masjid favorit selalu memakai pemilih yang konsisten (bottom sheet dengan pilihan tunggal dan penanda).

Kriteria penerimaan:

1. AC-SRC-01 Given pengguna mengetik "kiblat", When hasil disaring, Then hanya kartu Kiblat yang tampil.
2. AC-SRC-02 Given pengguna mengetik "Bandung" pada pencarian kota, When hasil muncul, Then daftar kota yang cocok tampil dan dapat dipilih.
3. AC-SRC-03 Given kata kunci tidak ditemukan, When hasil disaring, Then keadaan kosong tampil dengan saran mengubah kata kunci.
4. AC-SRC-04 Given pengguna memilih kota dari hasil, When dikonfirmasi, Then jadwal sholat dihitung untuk kota itu dan pilihan disimpan.

### 9.6 Modul M6: Masjid Terdekat (LBS)

Kebutuhan:

1. FR-LBS-09 Aplikasi menampilkan masjid dalam radius default 2 km (dapat diubah sampai 10 km) pada peta dan daftar.
2. FR-LBS-10 Setiap item memuat nama, jarak, dan arah mata angin.
3. FR-LBS-11 Pengguna dapat membuka rute lewat aplikasi peta bawaan.
4. FR-LBS-12 Pengguna dapat menandai masjid sebagai favorit. Favorit disimpan lokal dan disinkronkan ke server.
5. FR-LBS-13 Hasil pencarian terakhir disimpan di cache.
6. FR-LBS-14 Edge Function perantara menyimpan sementara hasil Overpass untuk menghemat panggilan.

Kriteria penerimaan:

1. AC-LBS-05 Given lokasi tersedia, When tab Masjid dibuka, Then daftar terurut dari jarak terdekat tampil dengan penanda di peta.
2. AC-LBS-06 Given tidak ada masjid dalam radius, When pencarian selesai, Then aplikasi menyarankan memperbesar radius.
3. AC-LBS-07 Given pengguna menandai favorit saat offline, When koneksi pulih, Then favorit tersinkron ke server.

### 9.7 Modul M7: Arah Kiblat (Magnetometer dan Gyroscope)

Rumus arah kiblat (bearing dari posisi pengguna ke Ka'bah di 21.4225 LU, 39.8262 BT):

```
dLon = lonKabah - lonUser            (radian)
y    = sin(dLon) * cos(latKabah)
x    = cos(latUser) * sin(latKabah)
     - sin(latUser) * cos(latKabah) * cos(dLon)
kiblat = (atan2(y, x) dalam derajat + 360) mod 360
```

Penghalusan heading (filter komplementer):

```
heading = a * (heading + gyroYawRate * dt) + (1 - a) * magHeading
a ≈ 0.98
```

Kebutuhan:

1. FR-QBL-01 Aplikasi menghitung sudut kiblat dari koordinat pengguna.
2. FR-QBL-02 Aplikasi membaca heading dari magnetometer, dan menghaluskannya dengan gyroscope memakai filter komplementer.
3. FR-QBL-03 Umpan balik (getar dan perubahan status) saat perangkat menghadap kiblat dalam toleransi 3 derajat.
4. FR-QBL-04 Indikator akurasi sensor dan petunjuk kalibrasi gerakan angka 8.
5. FR-QBL-05 Peringatan bila terdeteksi gangguan medan magnet, atau fallback ke sudut statis bila sensor tidak tersedia.
6. FR-QBL-06 Sensor dilepas (unsubscribe) saat layar ditinggalkan.

Kriteria penerimaan:

1. AC-QBL-01 Given lokasi tersedia, When layar Kiblat dibuka, Then sudut kiblat dan jarak ke Ka'bah tampil.
2. AC-QBL-02 Given perangkat diputar, When heading berubah, Then jarum bergerak halus (minimal 10 pembaruan per detik) tanpa lonjakan.
3. AC-QBL-03 Given heading dalam ±3° dari kiblat, When kondisi tercapai, Then status berhasil tampil dan perangkat bergetar singkat.
4. AC-QBL-04 Given akurasi sensor rendah, When layar dibuka, Then banner kalibrasi tampil.
5. AC-QBL-05 Given perangkat tanpa magnetometer, When layar dibuka, Then sudut statis dan petunjuk tampil.

### 9.8 Modul M8: Tasbih Digital (Accelerometer)

Kebutuhan:

1. FR-TSB-01 Satu goyangan dihitung bila magnitudo percepatan melewati ambang (default 15 m/s²) dengan jeda antar hitungan minimal 500 ms.
2. FR-TSB-02 Pengguna memilih target (33, 99, 100, kustom) dan dapat mereset hitungan.
3. FR-TSB-03 Sensitivitas goyang (rendah, sedang, tinggi) dan getar dapat diatur.
4. FR-TSB-04 Tombol layar sebagai alternatif hitung manual.
5. FR-TSB-05 Riwayat dzikir harian disimpan lokal, disinkronkan ke server, dan menjadi masukan prediksi AI (M14).
6. FR-TSB-06 Sensor berhenti saat layar mati atau aplikasi di latar belakang.

Kriteria penerimaan:

1. AC-TSB-01 Given mode goyang aktif, When perangkat digoyang sekali, Then penghitung bertambah tepat satu.
2. AC-TSB-02 Given goyangan beruntun di bawah 500 ms, When terjadi, Then hanya satu hitungan dicatat.
3. AC-TSB-03 Given target tercapai, When hitungan sama dengan target, Then perangkat bergetar dan pesan selesai tampil.
4. AC-TSB-04 Given aplikasi di latar belakang, When perangkat bergoyang, Then penghitung tidak bertambah.

### 9.9 Modul M9: Konversi Waktu (WIB, WITA, WIT, London)

| Zona | Identitas IANA | Selisih UTC |
|---|---|---|
| WIB | Asia/Jakarta | UTC+7 |
| WITA | Asia/Makassar | UTC+8 |
| WIT | Asia/Jayapura | UTC+9 |
| London | Europe/London | UTC+0 (GMT), UTC+1 (BST saat musim panas) |

Tabel 10. Zona waktu yang didukung

Kebutuhan:

1. FR-TZ-01 Pengguna memilih zona tampilan (WIB, WITA, WIT, London) dari pemilih.
2. FR-TZ-02 Jadwal sholat tampil pada zona tampilan dengan label zona dan selisih jam terhadap zona lokasi.
3. FR-TZ-03 DST London ditangani otomatis memakai basis data zona IANA.
4. FR-TZ-04 Mode Bandingkan menampilkan dua zona berdampingan.
5. FR-TZ-05 Layar Konversi (tab Waktu) mengonversi jam bebas antar empat zona.
6. FR-TZ-06 Pengingat adzan selalu dijadwalkan berdasarkan waktu lokal lokasi pengguna, bukan zona tampilan.
7. FR-TZ-07 Waktu disimpan sebagai UTC di basis data lokal dan server, dikonversi saat ditampilkan (termasuk waktu blok ledger dan donasi).

Kriteria penerimaan:

1. AC-TZ-01 Given Dzuhur di Yogyakarta pukul 11.45 WIB, When zona tampilan diubah ke WIT, Then tampil 13.45 WIT.
2. AC-TZ-02 Given tanggal dalam masa BST, When London dipilih, Then selisih terhadap WIB dihitung UTC+1.
3. AC-TZ-03 Given mode Bandingkan aktif, When dua zona dipilih, Then kedua jadwal tampil berdampingan dengan label zona jelas.
4. AC-TZ-04 Given zona tampilan bukan zona lokal, When layar dibuka, Then terdapat penanda bahwa waktu ditampilkan dalam zona lain.

### 9.10 Modul M10: Konversi Mata Uang (IDR, USD, SAR)

Kebutuhan:

1. FR-CUR-01 Aplikasi mengambil kurs IDR, USD, dan SAR lewat Edge Function perantara dan menyimpan cache beserta waktu pembaruan. Penambahan mata uang lain harus dimungkinkan lewat konfigurasi.
2. FR-CUR-02 Layar Konversi (tab Mata Uang) mengonversi nominal antar tiga mata uang, dengan tombol tukar posisi.
3. FR-CUR-03 Pembulatan sesuai mata uang: IDR tanpa desimal, USD dan SAR dua desimal.
4. FR-CUR-04 Kurs offline memakai kurs terakhir dengan label waktu pembaruan.
5. FR-CUR-05 Konverter yang sama dipakai pada kalkulator zakat dan form donasi.

Kriteria penerimaan:

1. AC-CUR-01 Given nominal 100 USD dan kurs tersedia, When dikonversi, Then nilai IDR dan SAR tampil sesuai aturan pembulatan.
2. AC-CUR-02 Given kurs tidak dapat diambil, When pengguna mengonversi, Then kurs cache dipakai dan tampil "Kurs per [tanggal dan jam]".
3. AC-CUR-03 Given nominal kosong, nol, atau negatif, When pengguna mengonversi, Then validasi menolak dengan pesan.

### 9.11 Modul M11: Zakat dan Donasi

Kebutuhan:

1. FR-ZKT-01 Kalkulator zakat maal menghitung 2,5 persen dari harta yang mencapai nisab. Nilai nisab (setara 85 gram emas) dan harga emas dapat dikonfigurasi agar tidak tertanam kaku.
2. FR-ZKT-02 Kalkulator zakat fitrah berdasarkan jumlah jiwa dan nilai per jiwa yang dapat diatur.
3. FR-ZKT-03 Hasil ditampilkan dalam mata uang input dan padanannya pada dua mata uang lain.
4. FR-ZKT-04 Pengguna memilih kampanye (hasil pencarian) atau kampanye bebas, memasukkan nominal, dan mengonfirmasi.
5. FR-ZKT-05 Donasi terkonfirmasi diteruskan ke modul ledger (M12) dan disimpan sebagai transaksi.
6. FR-ZKT-06 Riwayat perhitungan zakat dan donasi tersimpan lokal dan tersinkron.
7. FR-ZKT-07 LLM menyediakan penjelasan hasil zakat dalam bahasa sederhana (M13).
8. FR-ZKT-08 Donasi bersifat pencatatan tanpa pembayaran riil. Layar menampilkan catatan bahwa transaksi bersifat simulasi.

Kriteria penerimaan:

1. AC-ZKT-01 Given harta di atas nisab, When pengguna menghitung, Then zakat 2,5% tampil dalam mata uang input dan padanannya.
2. AC-ZKT-02 Given harta di bawah nisab, When pengguna menghitung, Then keterangan belum wajib zakat tampil dan tombol donasi zakat nonaktif.
3. AC-ZKT-03 Given donasi dikonfirmasi, When disimpan, Then bukti donasi dengan nomor blok dan hash tampil.
4. AC-ZKT-04 Given nominal tidak valid, When pengguna mengonfirmasi, Then validasi menolak dengan pesan.

### 9.12 Modul M12: Blockchain Sederhana (Ledger Donasi)

Deskripsi: setiap donasi menjadi blok yang memuat hash blok sebelumnya dan nonce hasil proof of work ringan. Server memverifikasi blok sebelum menyimpannya.

Struktur blok:

```
Block {
  index         : integer (0 untuk genesis)
  timestamp     : ISO-8601 UTC
  user_id       : uuid
  donor_alias   : string
  campaign      : string
  amount        : decimal
  currency      : IDR | USD | SAR
  amount_idr    : decimal
  rate_used     : decimal
  prev_hash     : string (64 hex)
  nonce         : integer
  hash          : string (64 hex)
}

hash = SHA256( index | timestamp | user_id | donor_alias | campaign |
               amount | currency | amount_idr | rate_used |
               prev_hash | nonce )

Aturan PoW: hash harus diawali "000" (3 digit heksadesimal nol).
Nonce dicari dengan menaikkan nilainya dari 0 sampai syarat terpenuhi.
```

Kebutuhan:

1. FR-BLK-01 Aplikasi membuat blok genesis saat akun pertama kali memakai ledger.
2. FR-BLK-02 Setiap donasi baru menjadi blok dengan prev_hash sama dengan hash blok terakhir.
3. FR-BLK-03 Pencarian nonce (proof of work) berjalan di isolate agar antarmuka tidak macet, dengan indikator "Mengunci blok".
4. FR-BLK-04 Pengguna dapat menekan Verifikasi Rantai. Aplikasi menghitung ulang semua hash, mencocokkan prev_hash, dan memeriksa syarat PoW.
5. FR-BLK-05 Bila verifikasi gagal, aplikasi menampilkan indeks blok pertama yang tidak valid dan perbandingan hash tersimpan dengan hash hasil hitung ulang.
6. FR-BLK-06 Server (Edge Function) memverifikasi tiap blok yang masuk: prev_hash cocok dengan head server, hash dihitung ulang, dan PoW terpenuhi. Blok yang gagal ditolak.
7. FR-BLK-07 Tabel ledger di server bersifat append only: pembaruan dan penghapusan ditolak oleh pemicu (trigger) basis data.
8. FR-BLK-08 Server menyimpan hash head per pengguna sebagai jangkar. Aplikasi membandingkan head lokal dengan head server, dan menandai ketidakcocokan.
9. FR-BLK-09 Bila perangkat memakai lebih dari satu perangkat dan terjadi konflik head, blok yang ditolak dihitung ulang (re-mine) di atas head terbaru.
10. FR-BLK-10 Pengguna dapat melihat daftar blok (hash 8 karakter awal), menyalin hash lengkap, dan mengekspor ledger sebagai JSON.
11. FR-BLK-11 Antarmuka tidak menyediakan opsi ubah atau hapus blok.

Batasan yang dinyatakan secara jujur: ledger ini bukan jaringan terdistribusi. Keutuhan dijamin oleh rantai hash, PoW ringan, dan verifikasi serta jangkar di server.

Kriteria penerimaan:

1. AC-BLK-01 Given donasi terkonfirmasi, When disimpan, Then blok baru terbentuk dengan prev_hash sama dengan hash blok sebelumnya dan hash berawalan "000".
2. AC-BLK-02 Given ledger tidak diubah, When Verifikasi Rantai dijalankan, Then hasilnya "Rantai valid" beserta jumlah blok.
3. AC-BLK-03 Given satu nilai pada blok ke-N diubah langsung di basis data lokal, When verifikasi dijalankan, Then hasilnya "Rantai tidak valid pada blok N".
4. AC-BLK-04 Given server menerima blok dengan prev_hash yang salah, When blok dikirim, Then server menolak dengan kode 409.
5. AC-BLK-05 Given upaya UPDATE atau DELETE pada ledger_blocks, When dijalankan di server, Then pemicu menolak operasi itu.
6. AC-BLK-06 Given isi blok yang sama, When hash dihitung dua kali, Then hasilnya identik (deterministik).

### 9.13 Modul M13: Fitur LLM (Tanya Fikih dan Penjelasan Zakat)

Kebutuhan:

1. FR-LLM-01 Pengguna mengetik pertanyaan fikih dasar dan menerima jawaban berbahasa Indonesia.
2. FR-LLM-02 Prompt sistem membatasi cakupan pada fikih dasar, menyebut adanya perbedaan pendapat antar mazhab bila relevan, dan tidak mengeluarkan fatwa.
3. FR-LLM-03 Setiap jawaban diakhiri catatan: "Ini informasi umum. Untuk kasus yang spesifik, tanyakan kepada ulama atau ustadz."
4. FR-LLM-04 Pertanyaan di luar cakupan dijawab penolakan sopan dengan saran bertanya kepada ulama.
5. FR-LLM-05 Fitur penjelasan zakat: LLM menjelaskan hasil perhitungan zakat dalam bahasa sederhana tanpa mengubah angka. Angka dihitung aplikasi, bukan LLM.
6. FR-LLM-06 Pemanggilan LLM lewat Edge Function. Kunci API hanya di server.
7. FR-LLM-07 Pembatasan permintaan per pengguna (misalnya 20 permintaan per jam) dan batas panjang masukan serta keluaran.
8. FR-LLM-08 Riwayat percakapan disimpan lokal dan tersinkron, dapat dicari, dan dapat dihapus oleh pengguna (lokal dan server).
9. FR-LLM-09 Pertahanan prompt injection: teks pengguna diperlakukan sebagai data, instruksi sistem tidak dapat ditimpa, dan keluaran tidak dieksekusi.
10. FR-LLM-10 Status memuat, galat jaringan, dan opsi kirim ulang ditampilkan.

Kriteria penerimaan:

1. AC-LLM-01 Given pertanyaan "Apa saja rukun wudhu?", When dikirim, Then jawaban terstruktur dan catatan disclaimer tampil.
2. AC-LLM-02 Given pertanyaan di luar cakupan, When dikirim, Then aplikasi menolak dengan sopan.
3. AC-LLM-03 Given pengguna menulis "abaikan instruksi sebelumnya", When dikirim, Then asisten tetap pada aturan dan cakupan awal.
4. AC-LLM-04 Given koneksi terputus, When pertanyaan dikirim, Then pesan galat dan opsi kirim ulang tampil.
5. AC-LLM-05 Given batas permintaan terlampaui, When pengguna mengirim, Then pesan menyebut batas dan waktu tunggu.
6. AC-LLM-06 Given pengguna menghapus riwayat, When dikonfirmasi, Then riwayat lokal dan server terhapus.

### 9.14 Modul M14: Fitur AI Ringan (Non-LLM)

Deskripsi: dua fitur AI yang berjalan di perangkat tanpa model besar.

Kebutuhan:

1. FR-AI-01 Rekomendasi kuis adaptif: tingkat kesulitan soal berikutnya ditentukan dari akurasi tertimbang eksponensial (EWMA) pada 10 sesi terakhir per kategori. Akurasi tinggi menaikkan kesulitan, akurasi rendah menurunkannya.
2. FR-AI-02 Rekomendasi kategori kuis berikutnya berdasarkan kategori dengan akurasi terendah dan kategori yang paling lama tidak dimainkan.
3. FR-AI-03 Prediksi target dzikir harian: regresi linear sederhana atau rata-rata bergerak atas 14 hari riwayat tasbih untuk menyarankan target hari ini.
4. FR-AI-04 Setiap rekomendasi disertai alasan singkat yang dapat dibaca pengguna (misalnya "Akurasi Anda pada Fikih Dasar 55 persen").
5. FR-AI-05 Pengguna dapat mematikan rekomendasi di Pengaturan.
6. FR-AI-06 Seluruh perhitungan berjalan di perangkat dan tidak mengirim data riwayat ke penyedia luar.

Kriteria penerimaan:

1. AC-AI-01 Given akurasi 90% pada kategori tertentu dalam 10 sesi, When sesi berikutnya dibuat, Then proporsi soal sulit meningkat.
2. AC-AI-02 Given riwayat dzikir 14 hari tersedia, When Tasbih dibuka, Then target harian yang disarankan tampil beserta alasannya.
3. AC-AI-03 Given riwayat kurang dari 3 hari, When Tasbih dibuka, Then target bawaan dipakai dan tidak ada prediksi.

### 9.15 Modul M15: Mini Game (Kuis Islami dan Cari Arah)

Game 1: Kuis Islami.

1. FR-GAME-01 Kategori: Rukun Islam dan Iman, Sejarah Nabi, Fikih Dasar, Umum.
2. FR-GAME-02 Satu sesi berisi 10 soal acak tanpa duplikat, 4 pilihan, batas waktu 20 detik per soal, dan kesulitan adaptif (M14).
3. FR-GAME-03 Setelah menjawab, aplikasi menampilkan jawaban benar dan penjelasan singkat.
4. FR-GAME-04 Skor dihitung dari jawaban benar dan bonus kecepatan, disimpan sebagai skor tertinggi per kategori, dan tersinkron ke papan skor server.
5. FR-GAME-05 Bank soal diunduh dari server dan disimpan lokal untuk pemakaian offline.

Game 2: Cari Arah (memakai magnetometer dan gyroscope).

1. FR-GAME-06 Pemain diberi target arah acak (kiblat, utara, atau arah kota tertentu) dan harus mengarahkan ponsel ke target dan menahannya 2 detik dalam toleransi 5 derajat.
2. FR-GAME-07 Satu putaran berisi 5 target dengan batas waktu 15 detik per target. Skor dihitung dari kecepatan dan ketepatan.
3. FR-GAME-08 Heading dihaluskan dengan filter komplementer (lihat M7) agar permainan tidak bergetar.
4. FR-GAME-09 Skor tertinggi disimpan lokal dan tersinkron.

Kriteria penerimaan:

1. AC-GAME-01 Given kategori dipilih, When kuis dimulai, Then 10 soal acak tanpa duplikat tampil satu per satu.
2. AC-GAME-02 Given waktu 20 detik habis, When pengguna belum menjawab, Then soal dihitung salah dan lanjut.
3. AC-GAME-03 Given kuis selesai, When ringkasan tampil, Then skor, jumlah benar, dan skor tertinggi kategori tampil.
4. AC-GAME-04 Given pemain menahan arah dalam toleransi selama 2 detik, When waktu tercapai, Then target dinyatakan berhasil dan skor bertambah.
5. AC-GAME-05 Given sensor tidak tersedia, When Cari Arah dibuka, Then aplikasi menjelaskan dan menyarankan kuis.

### 9.16 Modul M16: Notifikasi Mobile

Kebutuhan:

1. FR-NTF-01 Notifikasi lokal terjadwal untuk lima waktu sholat (opsional Terbit) selama 7 hari ke depan.
2. FR-NTF-02 Pengguna mengaktifkan atau menonaktifkan pengingat per waktu sholat dan memilih suara (adzan penuh, adzan pendek, nada standar).
3. FR-NTF-03 Pengingat sebelum waktu masuk (0, 5, 10, atau 15 menit) dapat dipilih.
4. FR-NTF-04 Jadwal notifikasi dihitung ulang saat lokasi berubah signifikan, zona waktu berubah, atau pengaturan diubah.
5. FR-NTF-05 Notifikasi dijadwalkan ulang setelah perangkat dinyalakan ulang.
6. FR-NTF-06 Notifikasi pengingat dzikir harian pada jam pilihan pengguna.
7. FR-NTF-07 Notifikasi konfirmasi saat donasi tercatat dan tersinkron.
8. FR-NTF-08 Notifikasi berbasis lokasi (opsional): saat pengguna memasuki radius 200 m dari masjid favorit menjelang waktu sholat.
9. FR-NTF-09 Android 12 ke atas memakai izin alarm tepat waktu. iOS memiliki batas jumlah notifikasi terjadwal, sehingga jendela 7 hari dijadwalkan ulang saat aplikasi dibuka.
10. FR-NTF-10 Petunjuk pengecualian optimasi baterai ditampilkan pada perangkat yang membatasi proses latar belakang.

Kriteria penerimaan:

1. AC-NTF-01 Given pengingat Maghrib aktif, When waktu Maghrib tiba, Then notifikasi muncul dengan selisih paling lama 1 menit.
2. AC-NTF-02 Given pengguna menonaktifkan Dzuhur, When waktu Dzuhur tiba, Then tidak ada notifikasi Dzuhur.
3. AC-NTF-03 Given perangkat dimulai ulang, When sistem aktif, Then notifikasi tetap terjadwal.
4. AC-NTF-04 Given pengguna berpindah lokasi, When jadwal diperbarui, Then notifikasi lama dibatalkan dan diganti sesuai lokasi baru.
5. AC-NTF-05 Given pengguna logout, When logout selesai, Then notifikasi yang berisi data akun dibatalkan.

### 9.17 Modul M17: Profil (dengan Gambar)

Kebutuhan:

1. FR-PRO-01 Layar Profil menampilkan foto profil, nama, nama pengguna, email, dan tanggal bergabung.
2. FR-PRO-02 Pengguna mengganti foto lewat kamera atau galeri. Aplikasi memangkas ke rasio persegi dan mengompres sebelum unggah.
3. FR-PRO-03 Foto diunggah ke Supabase Storage lewat Edge Function, dan disimpan di cache lokal untuk tampilan offline.
4. FR-PRO-04 Bila belum ada foto, tampil avatar bawaan dengan inisial nama.
5. FR-PRO-05 Pengguna mengedit nama dan nama pengguna dengan validasi keunikan.
6. FR-PRO-06 Bagian Keamanan: ganti kata sandi, aktif atau nonaktif biometrik, dan daftar perangkat dengan sesi aktif (dapat dicabut).
7. FR-PRO-07 Bagian Pengaturan: tema (ikuti sistem, terang, gelap), metode hitung, zona tampilan, mata uang utama, notifikasi, dan sinkronisasi manual.
8. FR-PRO-08 Izin kamera dan galeri diminta saat dibutuhkan dengan penjelasan.
9. FR-PRO-09 Batas ukuran foto 2 MB dan format JPEG atau PNG.

Kriteria penerimaan:

1. AC-PRO-01 Given pengguna membuka tab Profil, When layar tampil, Then foto, nama, dan email tampil.
2. AC-PRO-02 Given pengguna memilih foto dari galeri, When disimpan, Then foto baru tampil di Profil dan tersinkron.
3. AC-PRO-03 Given perangkat offline, When Profil dibuka, Then foto dari cache tampil.
4. AC-PRO-04 Given foto lebih dari 2 MB setelah kompresi, When diunggah, Then pesan galat tampil.
5. AC-PRO-05 Given pengguna mencabut sesi perangkat lain, When dikonfirmasi, Then perangkat itu tidak lagi dapat memperbarui token.

### 9.18 Modul M18: Saran dan Kesan Mata Kuliah Pemrograman Aplikasi Mobile

Kebutuhan:

1. FR-FB-01 Formulir memuat penilaian bintang (1 sampai 5), kolom kesan, dan kolom saran untuk mata kuliah Pemrograman Aplikasi Mobile.
2. FR-FB-02 Validasi: penilaian wajib, kesan dan saran masing-masing minimal 10 karakter dan maksimal 500 karakter.
3. FR-FB-03 Kiriman disimpan lokal lalu dikirim ke server. Saat offline, kiriman masuk antrean dan dikirim otomatis saat online.
4. FR-FB-04 Riwayat kiriman milik pengguna tampil dengan status (terkirim, menunggu).
5. FR-FB-05 Pengguna dapat mengedit atau menghapus kiriman miliknya.
6. FR-FB-06 Konfirmasi keberhasilan berupa snackbar dan ringkasan.

Kriteria penerimaan:

1. AC-FB-01 Given semua kolom valid, When pengguna menekan Kirim, Then kiriman tersimpan dan muncul di riwayat.
2. AC-FB-02 Given kesan kurang dari 10 karakter, When pengguna menekan Kirim, Then validasi menolak dengan pesan.
3. AC-FB-03 Given perangkat offline, When pengguna mengirim, Then status "Menunggu" tampil dan berubah menjadi "Terkirim" setelah online.
4. AC-FB-04 Given pengguna menghapus kiriman, When dikonfirmasi, Then kiriman hilang dari riwayat lokal dan server.

### 9.19 Modul M19: Logout

Kebutuhan:

1. FR-OUT-01 Menekan tab Logout menampilkan dialog konfirmasi: "Keluar dari Barakah?" dengan tombol "Keluar" dan "Batal".
2. FR-OUT-02 Dialog memuat pilihan "Nonaktifkan login biometrik di perangkat ini" (tidak dicentang secara bawaan).
3. FR-OUT-03 Logout mencabut sesi di server, menghapus access token dan refresh token dari secure storage, dan membatalkan notifikasi terkait akun.
4. FR-OUT-04 Data lokal pengguna dibersihkan bila pengguna memilih "Hapus data di perangkat ini". Bila tidak, data tetap terenkripsi dan hanya dapat dibuka oleh akun yang sama.
5. FR-OUT-05 Setelah logout, aplikasi menuju layar Login dan riwayat navigasi dikosongkan.
6. FR-OUT-06 Bila logout dilakukan saat offline, sesi lokal dihapus dan pencabutan di server dijadwalkan saat online.

Kriteria penerimaan:

1. AC-OUT-01 Given pengguna menekan Logout, When dialog tampil, Then pengguna dapat memilih Keluar atau Batal.
2. AC-OUT-02 Given pengguna memilih Keluar, When proses selesai, Then layar Login tampil dan tombol kembali tidak membuka layar sebelumnya.
3. AC-OUT-03 Given pengguna sudah logout, When memanggil API memakai token lama, Then server menolak dengan 401.
4. AC-OUT-04 Given pengguna logout offline, When koneksi pulih, Then pencabutan di server tuntas.

### 9.20 Modul M20: Basis Data Lokal, Online, dan Sinkronisasi

Kebutuhan:

1. FR-SYNC-01 Seluruh data pengguna ditulis lebih dulu ke SQLite lokal (offline first), lalu dikirim ke server.
2. FR-SYNC-02 Setiap perubahan masuk tabel outbox (jenis, payload, waktu, jumlah percobaan). SyncService mengirim outbox saat online.
3. FR-SYNC-03 Sinkronisasi dua arah memakai penanda waktu: aplikasi mengirim perubahan (push) dan mengambil perubahan sejak sinkronisasi terakhir (pull).
4. FR-SYNC-04 Aturan konflik: data pengaturan memakai last write wins berdasarkan waktu server. Ledger bersifat append only (lihat M12). Kiriman Saran dan Kesan tidak pernah ditimpa.
5. FR-SYNC-05 Pengiriman idempoten: setiap catatan memiliki UUID klien sehingga pengiriman ulang tidak membuat duplikat.
6. FR-SYNC-06 Percobaan ulang dengan backoff eksponensial dan batas maksimal percobaan.
7. FR-SYNC-07 Status sinkronisasi terlihat di Beranda dan Pengaturan, dengan tombol sinkronisasi manual.
8. FR-SYNC-08 Data publik (kampanye, bank soal) diunduh dan disimpan lokal dengan versi, dan hanya diperbarui bila versi server lebih baru.
9. FR-API-01 Seluruh komunikasi dengan server melalui web service REST berformat JSON dengan kode status yang konsisten (200, 201, 400, 401, 403, 404, 409, 429, 500).
10. FR-API-02 Setiap respons galat memuat kode dan pesan yang dapat ditampilkan kepada pengguna.
11. FR-API-03 Seluruh endpoint terdokumentasi (lihat Bagian 13).

Kriteria penerimaan:

1. AC-SYNC-01 Given pengguna membuat donasi saat offline, When koneksi pulih, Then outbox terkirim dan status berubah menjadi tersinkron.
2. AC-SYNC-02 Given pengiriman yang sama dikirim dua kali, When server menerima, Then hanya satu catatan tersimpan.
3. AC-SYNC-03 Given pengguna login di perangkat kedua, When sinkronisasi pull berjalan, Then data dari perangkat pertama muncul.
4. AC-SYNC-04 Given pengaturan diubah di dua perangkat, When keduanya sinkron, Then nilai dengan waktu server terbaru dipakai.

### 9.21 Modul M21: IoT Opsional (ESP32)

Status: opsional, fase lanjutan. Tidak menghalangi pemenuhan kriteria lain.

Kebutuhan:

1. FR-IOT-01 Pengguna mendaftarkan perangkat ESP32 dari aplikasi dan menerima device key khusus IoT.
2. FR-IOT-02 ESP32 memanggil endpoint server (per menit) untuk membaca sholat berikutnya, lalu menyalakan lampu atau buzzer saat waktu masuk.
3. FR-IOT-03 Tasbih fisik (tombol atau sensor) pada ESP32 mengirim hitungan ke server. Aplikasi menampilkannya pada riwayat tasbih.
4. FR-IOT-04 Perangkat dapat dicabut dari aplikasi.
5. FR-IOT-05 Perangkat IoT hanya memakai device key terbatas dan tidak memakai token pengguna.

Kriteria penerimaan:

1. AC-IOT-01 Given perangkat terdaftar, When waktu sholat berikutnya tiba, Then perangkat menyalakan indikator.
2. AC-IOT-02 Given perangkat dicabut, When memanggil endpoint, Then server menolak.

## 10. Alur Pengguna (User Flow)

### 10.1 Alur Autentikasi, Session, dan Biometrik

```
[Buka aplikasi] -> [Splash: cek sesi tersimpan]
        |
        +-- tidak ada sesi --> [Login] -- Daftar --> [Registrasi] --+
        |                          |                               |
        |                    kata sandi/ID benar?                  |
        |                     |ya          |tidak                  |
        |                     |            +--> [Pesan galat, hitung percobaan]
        |                     |                  >=5 gagal -> [Terkunci 15 menit]
        |                     v
        |             [Server menerbitkan access+refresh token]
        |                     v
        |             [Simpan di Secure Storage]
        |                     v
        |             [Tawarkan aktifkan biometrik?] -ya-> [Verifikasi biometrik -> device token]
        |                     v
        +-- ada sesi, terkunci --> [Kunci Biometrik] -- berhasil --> [Beranda]
                                         | gagal 3x
                                         v
                                   [Login kata sandi]
```

Gambar 4. Alur autentikasi, session, dan biometrik

### 10.2 Alur Donasi sampai Ledger dan Sinkronisasi

```
[Ibadah > Zakat dan Donasi]
   |
   v
[Pilih Zakat/Donasi] -> [Cari/pilih kampanye] -> [Nominal + mata uang]
   |                                                   |
   v                                                   v
[Ringkasan: kurs, setara IDR]                  [Konfirmasi donasi?] -tidak-> [Kembali]
                                                       |ya
                                                       v
                                   [Buat blok: prev_hash + cari nonce (PoW)]
                                                       v
                                   [Simpan ke SQLite terenkripsi + outbox]
                                                       v
                                         [Online?] -ya-> [POST /ledger]
                                            |tidak          |
                                            v               v
                                   [Status: menunggu]  [Server verifikasi hash, PoW, prev_hash]
                                                            | valid            | tidak valid
                                                            v                  v
                                                     [Simpan, update head] [409: re-mine di atas head baru]
                                                            v
                                                   [Bukti donasi + notifikasi]
```

Gambar 5. Alur donasi, ledger, dan sinkronisasi

### 10.3 Alur Lain (Ringkas)

1. Kiblat: Ibadah, Kiblat, cek lokasi, hitung sudut, aktifkan sensor, kalibrasi bila akurasi rendah, putar sampai selaras, umpan balik getar, sensor dilepas saat keluar.
2. Tasbih: Ibadah, Tasbih, pilih target (atau terima saran AI), pilih mode, hitung, selesai, simpan riwayat, sinkron.
3. Konversi: Ibadah, Konversi, pilih tab Waktu atau Mata Uang, masukkan nilai, pilih zona atau mata uang, hasil tampil dengan label zona atau waktu kurs.
4. Tanya AI: Ibadah, Tanya AI, ketik pertanyaan, kirim ke Edge Function, jawaban dengan disclaimer, riwayat tersimpan.
5. Game: Ibadah, Kuis dan Game, pilih Kuis atau Cari Arah, mainkan, skor tampil, skor tersinkron.
6. Saran dan Kesan: tab Saran dan Kesan, isi bintang, kesan, dan saran, kirim, tersimpan lokal lalu terkirim, riwayat tampil.
7. Logout: tab Logout, dialog konfirmasi, cabut sesi, hapus token, kembali ke Login.

## 11. Wireframe

Wireframe berikut berupa sketsa kasar (low-fidelity). Tampilan akhir mengikuti panduan desain Material 3 dan DESIGN.md. Layar lama dari PRD v1 diperbarui dengan bottom navigation baru.

### 11.1 Login dan Registrasi

```
+--------------------------------+     +--------------------------------+
|           [Logo Barakah]       |     | < Buat Akun                    |
|        Selamat datang          |     |  Nama lengkap  [          ]    |
|                                |     |  Email         [          ]    |
|  Email / nama pengguna         |     |  Nama pengguna [          ]    |
|  [                       ]     |     |  Kata sandi    [        ][o]   |
|  Kata sandi                    |     |  Ulangi sandi  [        ][o]   |
|  [                     ][o]    |     |  Min. 8 karakter, huruf+angka  |
|                                |     |                                |
|  [        MASUK         ]      |     |  [        DAFTAR        ]      |
|  [ Masuk dengan sidik jari ]   |     |  Sudah punya akun? Masuk       |
|  Belum punya akun? Daftar      |     |                                |
+--------------------------------+     +--------------------------------+
```

Gambar 6. Wireframe login dan registrasi

### 11.2 Kunci Biometrik

```
+--------------------------------+
|           [Logo Barakah]       |
|     Aplikasi terkunci          |
|                                |
|          ( sidik jari )        |
|   Sentuh sensor untuk membuka  |
|                                |
|     [ Gunakan kata sandi ]     |
+--------------------------------+
```

Gambar 7. Wireframe kunci biometrik

### 11.3 Beranda

```
+--------------------------------+
| Halo, Rizky       Yogyakarta   |
| Zona: [WIB v]   [Bandingkan]   |
+--------------------------------+
|  Sholat berikutnya: ASHAR      |
|        15:08 WIB               |
|     dalam 02:14:35             |
+--------------------------------+
| Subuh    04:25         [Bell]  |
| Dzuhur   11:46         [Bell]  |
| Ashar    15:08  <---- next     |
| Maghrib  17:52         [Bell]  |
| Isya     19:03         [Bell]  |
+--------------------------------+
| Donasi bulan ini: Rp250.000    |
| Dzikir hari ini: 66            |
| Sinkron: tersinkron            |
+--------------------------------+
|[Beranda][Ibadah][Profil][Saran][Logout]|
+--------------------------------+
```

Gambar 8. Wireframe beranda (angka hanya ilustrasi)

### 11.4 Pusat Ibadah

```
+--------------------------------+
| Ibadah                         |
| [ Cari fitur...             ]  |
+--------------------------------+
| IBADAH                         |
| [Masjid] [Kiblat] [Tasbih]     |
| KEUANGAN                       |
| [Konversi] [Zakat/Donasi]      |
| [Ledger]                       |
| BELAJAR                        |
| [Tanya AI] [Kuis] [Cari Arah]  |
+--------------------------------+
|[Beranda][Ibadah][Profil][Saran][Logout]|
+--------------------------------+
```

Gambar 9. Wireframe pusat ibadah

### 11.5 Masjid Terdekat dengan Pencarian

```
+--------------------------------+
| < Masjid Terdekat     [Favorit]|
| [ Cari nama/alamat masjid   ]  |
| Radius: [1][2][5][10] km       |
| Urut: (o) Jarak ( ) Nama       |
+--------------------------------+
| [        PETA OSM        ]     |
+--------------------------------+
| 1. Masjid Al-Contoh     350 m  |
|    Timur Laut   [Star] [Rute]  |
| 2. Masjid An-Contoh     720 m  |
|    Barat        [Star] [Rute]  |
+--------------------------------+
```

Gambar 10. Wireframe masjid terdekat (nama hanya contoh)

### 11.6 Kiblat

```
+--------------------------------+
| < Arah Kiblat                  |
|   Kiblat: 295 derajat          |
|   Jarak ke Ka'bah: 8.xxx km    |
|              N                 |
|          .---^---.             |
|         /    |    \            |
|        W  ---+--->  E          |
|         \   Ka'bah   /         |
|          '---v---'             |
|   Heading: 290 derajat         |
|   [ Hampir tepat: selisih 5 ]  |
+--------------------------------+
| Sensor: magnetometer + gyro    |
| Akurasi: Sedang [Kalibrasi]    |
+--------------------------------+
```

Gambar 11. Wireframe kiblat

### 11.7 Tasbih Digital

```
+--------------------------------+
| < Tasbih Digital     [Riwayat] |
| Saran target hari ini: 99      |
| (rata-rata 7 hari terakhir)    |
| Target: [33][99][100][Kustom]  |
|           .-----------.        |
|          |     27      |       |
|          |   dari 33   |       |
|           '-----------'        |
| Mode: (o) Goyang  ( ) Ketuk    |
| Sensitivitas [----o----] Getar |
|     [ TAP UNTUK HITUNG ]       |
|          [ Reset ]             |
+--------------------------------+
```

Gambar 12. Wireframe tasbih

### 11.8 Konversi Waktu dan Mata Uang

```
+--------------------------------+
| < Konversi                     |
| [ Waktu ]  [ Mata Uang ]       |
+--------------------------------+
| (tab Waktu)                    |
| Jam   [ 11:45 ]  dari [WIB v]  |
| WITA   12:45                   |
| WIT    13:45                   |
| London 05:45 (GMT/BST)         |
+--------------------------------+
| (tab Mata Uang)                |
| Nominal [ 100 ]   [USD v]      |
| IDR  Rp1.xxx.xxx               |
| SAR  SAR 375,00                |
| Kurs per 15 Okt 2026 08.00     |
+--------------------------------+
```

Gambar 13. Wireframe konversi (nilai hanya ilustrasi)

### 11.9 Zakat dan Donasi

```
+--------------------------------+
| < Zakat & Donasi               |
| [ Zakat ]  [ Donasi ]          |
+--------------------------------+
| Kampanye: [ Cari kampanye... ] |
| (o) Air Bersih Pelosok         |
| ( ) Renovasi Musholla          |
| Mata uang: [IDR][USD][SAR]     |
| Nominal:   [ 1.000.000      ]  |
| Setara: USD xx,xx | SAR xxx,xx |
| Alias donatur: [Hamba Allah]   |
|  Donasi bersifat simulasi      |
|      [  KONFIRMASI DONASI  ]   |
+--------------------------------+
```

Gambar 14. Wireframe donasi

### 11.10 Ledger Blockchain

```
+--------------------------------+
| < Ledger Donasi                |
| Rantai valid: 12 blok          |
| Head server: sesuai            |
|              [Verifikasi]      |
+--------------------------------+
| #12  15 Okt 2026 08:15         |
|      Hamba Allah | IDR 100.000 |
|      nonce: 4821  hash: 000a3f..|
|      prev: 000c71...           |
|  |                             |
| #11  14 Okt 2026 19:40         |
|      Siti | SAR 50,00          |
|      hash: 000c71...           |
+--------------------------------+
| [ Ekspor JSON ]                |
+--------------------------------+
```

Gambar 15. Wireframe ledger

### 11.11 Tanya AI

```
+--------------------------------+
| < Tanya Fikih Dasar   [Hapus]  |
| [ Cari di riwayat...        ]  |
| Jawaban berupa info umum,      |
| bukan fatwa.                   |
+--------------------------------+
|          Anda:                 |
|          Apa saja rukun wudhu? |
| Barakah AI:                    |
| 1. Niat ...                    |
| 2. Membasuh wajah ...          |
| Catatan: informasi umum,       |
| tanyakan kepada ulama.         |
+--------------------------------+
| [ Ketik pertanyaan...  ][Kirim]|
+--------------------------------+
```

Gambar 16. Wireframe tanya AI

### 11.12 Kuis dan Cari Arah

```
+--------------------------------+     +--------------------------------+
| Kuis: Rukun Islam  Soal 3/10   |     | Cari Arah        Target 2/5    |
| Waktu 00:14        Skor 20     |     | Hadapkan ke: KIBLAT            |
| Rekomendasi: Fikih Dasar       |     | Waktu 00:09     Skor 140       |
| Berapa jumlah rukun Islam?     |     |         .---^---.              |
|  [A. 3]   [B. 4]               |     |        /    |    \             |
|  [C. 5]   [D. 6]               |     |        '---v---'               |
+--------------------------------+     | Tahan 2 detik dalam 5 derajat  |
                                       +--------------------------------+
```

Gambar 17. Wireframe kuis dan Cari Arah

### 11.13 Profil

```
+--------------------------------+
|           ( FOTO )             |
|       [ Ganti foto ]           |
|        Rizky Pratama           |
|        @rizky | rizky@mail.com |
+--------------------------------+
| Keamanan                       |
|  Ganti kata sandi          >   |
|  Login biometrik        [ON]   |
|  Perangkat aktif           >   |
| Pengaturan                     |
|  Tema, Zona, Mata uang     >   |
|  Notifikasi adzan          >   |
|  Sinkronisasi manual       >   |
+--------------------------------+
|[Beranda][Ibadah][Profil][Saran][Logout]|
+--------------------------------+
```

Gambar 18. Wireframe profil (nama hanya contoh)

### 11.14 Saran dan Kesan

```
+--------------------------------+
| Saran & Kesan                  |
| Mata kuliah: Pemrograman       |
| Aplikasi Mobile                |
| Penilaian: [*][*][*][*][ ]     |
| Kesan:                         |
| [                          ]   |
| Saran:                         |
| [                          ]   |
|        [     KIRIM      ]      |
+--------------------------------+
| Riwayat Anda                   |
|  15 Okt | 4 bintang | Terkirim |
|  12 Okt | 5 bintang | Menunggu |
+--------------------------------+
```

Gambar 19. Wireframe saran dan kesan

### 11.15 Dialog Logout

```
+--------------------------------+
|        Keluar dari Barakah?    |
|  Sesi Anda akan diakhiri.      |
|  [ ] Nonaktifkan login         |
|      biometrik di perangkat ini|
|  [ ] Hapus data di perangkat   |
|                                |
|     [ Batal ]   [ Keluar ]     |
+--------------------------------+
```

Gambar 20. Wireframe dialog logout

## 12. Model Data

### 12.1 Basis Data Server (Supabase PostgreSQL)

| Tabel | Atribut Utama |
|---|---|
| users | id, name, username, email, password_hash, avatar_url, failed_attempts, locked_until, created_at |
| sessions | id, user_id, device_id, refresh_hash, expires_at, revoked_at, created_at |
| device_tokens | id, user_id, device_id, token_hash, created_at, revoked_at |
| campaigns | id, title, description, category, target_idr, version |
| donations | id (UUID klien), user_id, campaign_id, amount, currency, amount_idr, rate_used, created_at |
| ledger_blocks | idx, user_id, timestamp, donor_alias, campaign, amount, currency, amount_idr, rate_used, prev_hash, nonce, hash |
| ledger_heads | user_id, head_idx, head_hash, updated_at |
| zakat_calcs | id, user_id, type, input_idr, nisab_idr, result_idr, created_at |
| tasbih_logs | id, user_id, date, target, count, source (app atau iot) |
| quiz_questions | id, category, difficulty, question, options, answer_index, explanation, version |
| quiz_attempts | id, user_id, category, score, correct, total, avg_time, created_at |
| game_scores | id, user_id, game, score, created_at |
| chat_messages | id, user_id, role, content, created_at |
| feedback | id, user_id, rating, impression, suggestion, created_at, updated_at |
| favorite_mosques | id, user_id, osm_id, name, lat, lon |
| rate_cache | base, quote, rate, fetched_at |
| iot_devices | id, user_id, name, key_hash, last_seen, revoked_at |

Tabel 11. Entitas server

Contoh skema inti:

```sql
CREATE TABLE users (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name            text NOT NULL,
  username        text NOT NULL UNIQUE,
  email           text NOT NULL UNIQUE,
  password_hash   text NOT NULL,
  avatar_url      text,
  failed_attempts int  NOT NULL DEFAULT 0,
  locked_until    timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE sessions (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id    text NOT NULL,
  refresh_hash text NOT NULL,
  expires_at   timestamptz NOT NULL,
  revoked_at   timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE ledger_blocks (
  idx         int  NOT NULL,
  user_id     uuid NOT NULL REFERENCES users(id),
  ts          timestamptz NOT NULL,
  donor_alias text NOT NULL,
  campaign    text NOT NULL,
  amount      numeric NOT NULL CHECK (amount > 0),
  currency    text NOT NULL CHECK (currency IN ('IDR','USD','SAR')),
  amount_idr  numeric NOT NULL,
  rate_used   numeric NOT NULL,
  prev_hash   text NOT NULL,
  nonce       bigint NOT NULL,
  hash        text NOT NULL UNIQUE CHECK (hash LIKE '000%'),
  PRIMARY KEY (user_id, idx)
);

CREATE OR REPLACE FUNCTION forbid_change() RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'ledger_blocks bersifat append only';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ledger_no_update_delete
BEFORE UPDATE OR DELETE ON ledger_blocks
FOR EACH ROW EXECUTE FUNCTION forbid_change();

CREATE TABLE feedback (
  id         uuid PRIMARY KEY,
  user_id    uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rating     int  NOT NULL CHECK (rating BETWEEN 1 AND 5),
  impression text NOT NULL CHECK (char_length(impression) BETWEEN 10 AND 500),
  suggestion text NOT NULL CHECK (char_length(suggestion) BETWEEN 10 AND 500),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ledger_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;
-- Tanpa kebijakan untuk anon/authenticated: akses hanya lewat Edge Function (service role).
```

Gambar 21. Contoh skema server

### 12.2 Basis Data Lokal (SQLite Terenkripsi)

| Tabel | Atribut Utama |
|---|---|
| prayer_cache | date, lat, lon, method, fajr, sunrise, dhuhr, asr, maghrib, isha |
| rate_cache | base, quote, rate, fetched_at |
| donation_local | id (UUID), campaign, amount, currency, amount_idr, rate_used, created_at, sync_state |
| ledger_local | idx, timestamp, donor_alias, campaign, amount, currency, amount_idr, rate_used, prev_hash, nonce, hash, sync_state |
| tasbih_log | id, date, target, count, sync_state |
| quiz_attempt | id, category, score, correct, total, created_at, sync_state |
| quiz_question | id, category, difficulty, question, options, answer_index, explanation, version |
| chat_message | id, role, content, created_at, sync_state |
| feedback_local | id, rating, impression, suggestion, created_at, sync_state |
| favorite_mosque | id, osm_id, name, lat, lon, sync_state |
| settings | key, value, updated_at |
| outbox | id, entity, op, payload, created_at, attempts, last_error |

Tabel 12. Entitas lokal

Nilai sync_state: pending, synced, failed. Token dan kunci enkripsi tidak disimpan di SQLite, melainkan di secure storage.

## 13. Spesifikasi Web Service (REST API)

Semua endpoint berupa Edge Function dengan format JSON. Kolom Auth: Publik (tanpa token), User (Bearer access token), Device (device key IoT).

| Metode | Path | Auth | Deskripsi |
|---|---|---|---|
| POST | /auth/register | Publik | Registrasi akun |
| POST | /auth/login | Publik | Login, mengembalikan access dan refresh token |
| POST | /auth/refresh | Publik (refresh token) | Memperbarui token, merotasi refresh token |
| POST | /auth/logout | User | Mencabut sesi |
| POST | /auth/password | User | Mengganti kata sandi |
| POST | /auth/biometric/enable | User | Menerbitkan device token |
| POST | /auth/biometric/login | Publik (device token) | Menukar device token dengan sesi |
| DELETE | /auth/biometric | User | Mencabut device token |
| GET | /auth/sessions | User | Daftar sesi aktif |
| DELETE | /auth/sessions/{id} | User | Mencabut sesi tertentu |
| GET | /profile | User | Data profil |
| PUT | /profile | User | Ubah nama dan nama pengguna |
| POST | /profile/avatar | User | Unggah foto profil |
| GET | /mosques/nearby | User | Masjid terdekat (lat, lng, radius, q) |
| GET, POST, DELETE | /favorites/mosques | User | Favorit masjid |
| GET | /rates | User | Kurs IDR, USD, SAR |
| GET | /campaigns | User | Daftar kampanye (q, category) |
| POST | /donations | User | Membuat donasi dan blok |
| GET | /ledger | User | Daftar blok milik pengguna |
| GET | /ledger/verify | User | Verifikasi rantai di server, mengembalikan head |
| POST | /zakat/calculations | User | Menyimpan hasil perhitungan |
| POST | /ai/chat | User | Tanya fikih (LLM) |
| POST | /ai/zakat-explain | User | Penjelasan zakat (LLM) |
| GET, DELETE | /ai/history | User | Riwayat chat |
| GET | /quiz/questions | User | Bank soal (category, version) |
| POST | /quiz/attempts | User | Mengirim hasil kuis |
| GET | /quiz/leaderboard | User | Papan skor |
| POST | /games/scores | User | Skor Cari Arah |
| POST, GET, PUT, DELETE | /feedback | User | Saran dan Kesan |
| POST | /sync/push | User | Mengirim perubahan dari outbox |
| GET | /sync/pull | User | Mengambil perubahan sejak waktu tertentu |
| POST | /iot/devices | User | Mendaftarkan perangkat IoT |
| GET | /iot/next-prayer | Device | Sholat berikutnya untuk perangkat |
| POST | /iot/tasbih | Device | Hitungan tasbih fisik |

Tabel 13. Daftar endpoint

Contoh permintaan dan respons login:

```
POST /auth/login
{ "identifier": "rizky@mail.com", "password": "********", "device_id": "a1b2c3" }

200 OK
{
  "access_token": "eyJ...",
  "expires_in": 900,
  "refresh_token": "r_9f2...",
  "user": { "id": "uuid", "name": "Rizky Pratama", "avatar_url": "https://..." }
}

401 Unauthorized
{ "error": { "code": "invalid_credentials", "message": "Email atau kata sandi salah." } }

423 Locked
{ "error": { "code": "account_locked", "message": "Coba lagi dalam 15 menit." } }
```

Gambar 22. Contoh kontrak API login

Contoh pengiriman blok:

```
POST /donations
{
  "id": "uuid-klien",
  "campaign": "Air Bersih Pelosok",
  "amount": 100000, "currency": "IDR",
  "amount_idr": 100000, "rate_used": 1,
  "block": { "idx": 12, "ts": "2026-10-15T08:15:00Z", "prev_hash": "000c71...",
             "nonce": 4821, "hash": "000a3f..." }
}

201 Created  { "idx": 12, "hash": "000a3f...", "head": "000a3f..." }
409 Conflict { "error": { "code": "prev_hash_mismatch", "head": "000b90...", "head_idx": 12 } }
```

Gambar 23. Contoh kontrak API donasi dan blok

## 14. Keamanan dan Privasi

| No | Ancaman | Kontrol |
|---|---|---|
| 1 | Pencurian kata sandi dari basis data server | Hash dengan salt unik (Argon2id, bcrypt, atau PBKDF2), tidak ada kata sandi asli di basis data atau log |
| 2 | Penyadapan jaringan | HTTPS (TLS) wajib. Opsi certificate pinning |
| 3 | Pencurian token dari perangkat | Token di Keystore atau Keychain, access token berumur pendek, rotasi refresh token |
| 4 | Pembacaan berkas basis data lokal | SQLite dienkripsi AES-256 dengan kunci di secure storage |
| 5 | Pembukaan aplikasi oleh orang lain | Kunci otomatis dan biometrik, device token terikat biometrik |
| 6 | Tebakan kata sandi (brute force) | Pembatasan percobaan dan penguncian sementara, pembatasan laju per IP |
| 7 | Akses data pengguna lain | Seluruh query difilter berdasarkan user_id dari token. RLS menolak akses langsung |
| 8 | Manipulasi ledger | Rantai hash, PoW, verifikasi server, pemicu append only, jangkar head |
| 9 | Kebocoran kunci API (LLM, penandatangan token) | Kunci hanya di variabel lingkungan Edge Function, tidak di aplikasi atau repositori |
| 10 | Prompt injection pada LLM | Prompt sistem tegas, masukan diperlakukan sebagai data, batas panjang, tidak mengeksekusi keluaran |
| 11 | Penyalahgunaan unggahan foto | Validasi tipe dan ukuran, nama berkas acak, bucket dengan batasan akses |
| 12 | Kebocoran lokasi | Koordinat tidak disimpan jangka panjang dan hanya dikirim ke layanan yang dibutuhkan |
| 13 | Log berisi data pribadi | Log tidak memuat kata sandi, token, atau isi chat penuh |

Tabel 14. Ancaman dan kontrol

Catatan: anon key Supabase yang tertanam di aplikasi bersifat publik, sehingga keamanan data bergantung pada RLS deny-all dan verifikasi token di Edge Function, bukan pada kerahasiaan anon key.

## 15. Kebutuhan Non-Fungsional

| Kode | Kategori | Kebutuhan |
|---|---|---|
| NFR-01 | Kinerja | Waktu mulai dingin aplikasi ≤ 3 detik pada perangkat kelas menengah |
| NFR-02 | Kinerja | Pembaruan sensor kompas ≥ 10 Hz tanpa gangguan tampilan (60 fps) |
| NFR-03 | Kinerja | Pencarian nonce PoW rata-rata ≤ 3 detik di perangkat kelas menengah dan tidak memblokir UI |
| NFR-04 | Keandalan | Jadwal, kiblat, tasbih, kuis, dan ledger berfungsi tanpa internet |
| NFR-05 | Keandalan | Sinkronisasi idempoten dan tahan gangguan jaringan |
| NFR-06 | Keamanan | Seluruh komunikasi HTTPS, token di secure storage, basis data lokal terenkripsi |
| NFR-07 | Privasi | Ledger memakai alias donatur, tanpa data pribadi sensitif |
| NFR-08 | Kegunaan | Target sentuh minimal 48 dp, kontras teks sesuai WCAG AA |
| NFR-09 | Aksesibilitas | Mendukung skala huruf sistem dan pembaca layar dasar |
| NFR-10 | Kompatibilitas | Android 8.0 (API 26) ke atas dan iOS 13 ke atas |
| NFR-11 | Lokalisasi | Bahasa Indonesia utama, struktur siap bahasa lain |
| NFR-12 | Konsumsi daya | Sensor dilepas saat layar sensor tidak aktif |
| NFR-13 | Kualitas | Cakupan uji unit minimal 60% untuk logika inti (kiblat, zakat, hash, PoW, zona waktu, sesi, sinkronisasi) |
| NFR-14 | Pemeliharaan | Struktur modul per fitur dan dokumentasi API |

Tabel 15. Kebutuhan non-fungsional

## 16. Dependensi Eksternal dan Strategi Gagal

| Layanan | Kegunaan | Strategi Gagal |
|---|---|---|
| Supabase (PostgreSQL, Edge Functions, Storage) | Basis data online, web service, penyimpanan foto | Aplikasi tetap berjalan offline first, outbox menunggu |
| API jadwal sholat (Aladhan) | Waktu sholat berdasarkan koordinat | Cache 7 hari atau hitung lokal |
| Overpass dan Nominatim (OpenStreetMap) | Masjid terdekat dan geokode kota | Hasil cache terakhir |
| Penyedia kurs | Konversi IDR, USD, SAR | Kurs cache berstempel waktu |
| Penyedia LLM | Tanya fikih dan penjelasan zakat | Pesan galat dan opsi kirim ulang |
| Layanan peta tile | Tampilan peta | Daftar tetap berfungsi tanpa peta |

Tabel 16. Dependensi eksternal

## 17. Perizinan Platform

| Fitur | Android | iOS |
|---|---|---|
| Lokasi | ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION | NSLocationWhenInUseUsageDescription |
| Biometrik | USE_BIOMETRIC | NSFaceIDUsageDescription |
| Notifikasi | POST_NOTIFICATIONS (Android 13 ke atas) | Izin notifikasi saat runtime |
| Alarm tepat waktu | SCHEDULE_EXACT_ALARM atau USE_EXACT_ALARM | Tidak ada, memakai notifikasi terjadwal dengan batas jumlah |
| Mulai ulang perangkat | RECEIVE_BOOT_COMPLETED | Tidak ada |
| Kamera dan galeri | CAMERA dan akses media | NSCameraUsageDescription, NSPhotoLibraryUsageDescription |
| Internet | INTERNET | Bawaan |
| Sensor gerak | Tidak perlu izin | NSMotionUsageDescription bila diperlukan |

Tabel 17. Perizinan platform (verifikasi ulang terhadap versi OS target)

## 18. Risiko dan Mitigasi

| No | Risiko | Dampak | Mitigasi |
|---|---|---|---|
| 1 | Pustaka hash (Argon2id atau bcrypt) tidak berjalan di Edge Function | Auth tertunda | Cadangan PBKDF2 lewat Web Crypto dengan iterasi tinggi |
| 2 | Kompleksitas auth buatan sendiri | Celah keamanan | Ikuti praktik standar, uji penetrasi dasar, siapkan alternatif Supabase Auth bila dosen mengizinkan |
| 3 | Biometrik berbeda antar perangkat dan emulator | Fitur sulit diuji | Uji di perangkat nyata, sediakan fallback kata sandi |
| 4 | Akurasi kiblat terganggu medan magnet | Arah salah | Kalibrasi, filter gyroscope, indikator akurasi |
| 5 | Pembatasan latar belakang dan batas notifikasi iOS | Adzan tidak muncul | Alarm tepat (Android), jendela 7 hari yang dijadwalkan ulang, petunjuk baterai |
| 6 | Jawaban LLM keliru atau tidak sesuai mazhab | Informasi menyesatkan | Batasi cakupan, disclaimer, sebut perbedaan pendapat |
| 7 | PoW terlalu lambat di perangkat murah | Donasi terasa lambat | Tingkat kesulitan dapat dikonfigurasi (3 digit), proses di isolate |
| 8 | Konflik head ledger antar perangkat | Blok ditolak | Mekanisme re-mine di atas head terbaru |
| 9 | Kuota atau batas Supabase dan layanan gratis | Layanan terhenti | Cache agresif, pembatasan laju, pemantauan pemakaian |
| 10 | Perbedaan perilaku Android dan iOS | Bug spesifik platform | Uji di keduanya sejak awal, daftar perizinan terpisah |
| 11 | Klaim "blockchain" berlebihan | Ekspektasi keliru | Gunakan istilah rantai blok sederhana dan jelaskan batasan |
| 12 | Cakupan terlalu luas untuk waktu tersedia | Fitur tidak selesai | Prioritas MoSCoW (Bagian 19) dan IoT sebagai opsional |

Tabel 18. Risiko dan mitigasi

## 19. Prioritas Fitur (MoSCoW) dan Rencana Pengembangan

### 19.1 Prioritas

| Prioritas | Modul |
|---|---|
| Must | M1, M2, M3, M4, M5, M7, M8, M9, M10, M11, M12, M13, M15 (Kuis), M16, M17, M18, M19, M20 |
| Should | M6 (favorit dan rute), M14, M15 (Cari Arah) |
| Could | Notifikasi berbasis lokasi, ekspor ledger, perangkat aktif di Profil |
| Won't (versi ini) | Pembayaran riil, lupa kata sandi lewat email, push jarak jauh |
| Opsional | M21 IoT |

Tabel 19. Prioritas modul

### 19.2 Milestone

| Tahap | Cakupan | Estimasi |
|---|---|---|
| 1 | Setup proyek, tema, navigasi 5 tab, skema Supabase, Edge Function auth | Minggu 1 |
| 2 | Registrasi, login, session, secure storage, enkripsi SQLite, biometrik | Minggu 2 sampai 3 |
| 3 | Jadwal sholat, lokasi, cache, zona waktu, pencarian kota | Minggu 3 sampai 4 |
| 4 | Kiblat (magnetometer, gyroscope), tasbih (accelerometer) | Minggu 4 sampai 5 |
| 5 | Masjid terdekat, pencarian, favorit, notifikasi adzan | Minggu 5 sampai 6 |
| 6 | Kurs, konversi, zakat, donasi, ledger dengan PoW dan verifikasi server | Minggu 6 sampai 7 |
| 7 | Sinkronisasi, profil dengan foto, saran dan kesan, logout | Minggu 7 sampai 8 |
| 8 | LLM, AI ringan, kuis dan Cari Arah | Minggu 8 sampai 9 |
| 9 | Pengujian, perbaikan, dokumentasi, demo (dan IoT bila waktu cukup) | Minggu 9 sampai 10 |

Tabel 20. Milestone (estimasi dapat disesuaikan dengan jadwal tugas akhir dan jumlah anggota)

## 20. Strategi Pengujian

1. Uji unit: rumus kiblat, filter komplementer, zakat 2,5% dan nisab, pembulatan mata uang, konversi zona waktu (termasuk DST London), hash dan PoW, validasi formulir, rotasi token, logika outbox, dan EWMA adaptif.
2. Uji widget: layar Login, Registrasi, Profil, Saran dan Kesan, dialog Logout, form donasi, kuis.
3. Uji integrasi: alur login ke Beranda, sesi kedaluwarsa dan refresh, donasi ke ledger ke server, sinkronisasi offline ke online.
4. Uji keamanan: periksa hash di basis data, pengambilan berkas SQLite lokal, penggunaan token lama setelah logout, percobaan UPDATE dan DELETE ledger, pembatasan laju login.
5. Uji perangkat nyata: biometrik, magnetometer, gyroscope, accelerometer, notifikasi tepat waktu pada minimal dua perangkat Android dan satu iOS bila tersedia.
6. Uji jaringan: mode pesawat, jaringan putus di tengah pengiriman, dan pemulihan koneksi.
7. Uji manipulasi ledger: ubah satu baris di SQLite lokal, pastikan verifikasi gagal pada blok yang benar. Kirim blok palsu ke server, pastikan ditolak.
8. Uji kegunaan: minimal 5 responden dengan skenario tugas dan kuesioner SUS.

### 20.1 Daftar Periksa Demo (Pemenuhan Kriteria)

| No | Kriteria | Cara Mendemonstrasikan |
|---|---|---|
| 1 | Login terenkripsi dan session | Tunjukkan hash di basis data, tutup dan buka aplikasi, tunjukkan refresh token otomatis |
| 2 | Biometrik | Aktifkan di Profil, kunci aplikasi, buka dengan sidik jari |
| 3 | Database lokal dan online | Buat data offline, tunjukkan SQLite terenkripsi, nyalakan jaringan, tunjukkan data di Supabase |
| 4 | Web service, multiplatform, LBS | Tunjukkan daftar endpoint, jalankan di Android dan iOS, tampilkan masjid terdekat |
| 5 | Bottom navigation | Tunjukkan lima tab, foto profil, Saran dan Kesan, dialog Logout |
| 6 | Konversi mata uang dan waktu | Konversi 100 USD ke IDR dan SAR, ubah jadwal ke WIT dan London |
| 7 | Dua sensor atau lebih | Putar ponsel (kiblat), goyang (tasbih), mainkan Cari Arah |
| 8 | AI dan LLM | Tanya fikih, tunjukkan rekomendasi kuis dan target dzikir |
| 9 | Mini game | Mainkan Kuis dan Cari Arah |
| 10 | Pencarian dan pemilihan | Cari kota, cari masjid, pilih zona dan mata uang |
| 11 | Notifikasi | Jadwalkan pengingat 1 menit ke depan untuk uji |
| 12 | Blockchain sederhana | Buat donasi, verifikasi rantai, ubah satu blok, tunjukkan verifikasi gagal |

Tabel 21. Daftar periksa demo

## 21. Asumsi dan Pertanyaan Terbuka

1. Pertanyaan terbuka 1: apakah dosen mengizinkan Supabase Auth, atau auth wajib dibuat sendiri? PRD ini mengasumsikan auth buatan sendiri.
2. Pertanyaan terbuka 2: penyedia LLM dan batas biaya perlu diputuskan.
3. Pertanyaan terbuka 3: apakah dosen menilai deployment (misalnya build APK atau IPA) dan dokumentasi API?
4. Pertanyaan terbuka 4: metode hitung sholat bawaan (misalnya Kemenag RI) perlu ditetapkan.
5. Pertanyaan terbuka 5: sumber bank soal kuis dan peninjau kontennya perlu ditentukan.
6. Pertanyaan terbuka 6: apakah IoT akan dikerjakan dan perangkat ESP32 tersedia?
7. Pertanyaan terbuka 7: apakah build iOS dapat diuji (membutuhkan Mac dan perangkat atau simulator iOS)?
8. Asumsi: donasi bersifat simulasi tanpa pembayaran riil.
9. Asumsi: penyusun, dosen, dan jumlah anggota memakai placeholder sampai diisi.

## 22. Glosarium

| Istilah | Arti |
|---|---|
| LBS | Location-Based Service, layanan berbasis lokasi |
| Magnetometer | Sensor medan magnet untuk menentukan arah utara magnetik |
| Gyroscope | Sensor kecepatan rotasi untuk melacak perubahan arah |
| Accelerometer | Sensor percepatan untuk mendeteksi gerakan atau goyangan |
| Filter komplementer | Penggabungan data gyroscope (cepat, bisa melenceng) dan magnetometer (stabil, bisa berisik) |
| Hash | Hasil fungsi satu arah yang mengubah data menjadi deretan karakter tetap |
| Salt | Nilai acak unik yang ditambahkan sebelum hashing kata sandi |
| Access token | Token berumur pendek untuk memanggil API |
| Refresh token | Token berumur lebih panjang untuk memperbarui access token |
| Session | Rangkaian akses pengguna yang terotentikasi dan dapat dicabut |
| Device token | Token terikat perangkat yang hanya dapat dibuka setelah verifikasi biometrik |
| Edge Function | Fungsi sisi server di Supabase yang dipakai sebagai web service |
| RLS | Row Level Security, pengendali akses tingkat baris pada PostgreSQL |
| Offline first | Pendekatan menulis ke penyimpanan lokal lebih dulu, lalu sinkron ke server |
| Outbox | Antrean perubahan lokal yang menunggu dikirim ke server |
| Idempoten | Pengiriman yang sama berulang tidak menimbulkan duplikasi |
| Proof of Work | Syarat pencarian nonce agar hash blok memenuhi pola tertentu |
| Nonce | Angka yang dicari agar hash blok memenuhi syarat PoW |
| EWMA | Exponentially Weighted Moving Average, rata-rata bergerak berbobot eksponensial |
| DST | Daylight Saving Time, perubahan waktu musim panas |
| Nisab | Batas minimal harta yang wajib dizakati |

Tabel 22. Glosarium
