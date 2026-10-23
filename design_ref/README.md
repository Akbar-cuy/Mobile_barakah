# Barakah

Dokumentasi developer untuk aplikasi mobile Barakah dan backend Supabase yang
terdapat di repository ini. README ini membedakan implementasi yang sudah ada
dari layar atau kontrak yang masih berupa TODO.

## 1. Project Overview

Barakah adalah aplikasi Flutter untuk mendukung aktivitas ibadah sehari-hari.
Aplikasi menggabungkan jadwal sholat, arah kiblat, pencarian masjid, tasbih,
notifikasi, profil, serta beberapa modul pendukung. Data tertentu disimpan
secara lokal agar dapat dibuka saat offline; perubahan yang didukung backend
dimasukkan ke outbox untuk dikirim saat koneksi tersedia.

Repository juga berisi Supabase Edge Functions berbasis TypeScript dan migrasi
PostgreSQL. Aplikasi menggunakan API Functions melalui klien HTTP Dio dan
session Barakah sendiri; ini bukan integrasi Supabase Auth SDK.

## 2. Features

| Area | Implementasi yang tersedia |
|---|---|
| Beranda dan jadwal sholat | Lokasi perangkat (dengan lokasi tersimpan/default jika tidak tersedia), jadwal bulanan dari API publik Aladhan dengan metode `20`, cache Drift, dan perhitungan sholat berikutnya. |
| Arah kiblat | Bearing dan jarak Ka'bah dihitung lokal; fitur kompas memakai sensor perangkat serta filter heading. |
| Masjid | Pencarian masjid sekitar melalui Edge Function yang mengambil data OpenStreetMap Overpass; cache lokal digunakan saat jaringan gagal. Favorit disimpan lokal dan dikirim melalui outbox. |
| Tasbih | Penghitung, target, dukungan hitung dengan gerakan/shake, riwayat Drift, dan sinkronisasi log yang didukung backend. |
| Notifikasi | Penjadwalan lokal untuk waktu sholat, pengingat sebelum sholat, dan dzikir. Izin notifikasi dan opsi suara dikelola di aplikasi. |
| Profil dan pengaturan | Profil, pengaturan, tema, perubahan password, tampilan sesi, dan pengelolaan keamanan. Beberapa perubahan profil/session memanggil backend. |
| Autentikasi | Registrasi/login dengan password, penyimpanan token aman, pemulihan/refresh sesi, logout, serta kunci aplikasi dan login biometrik perangkat. |
| Saran & Kesan | Form, riwayat, dan operasi milik pengguna. Feedback menggunakan Drift dan outbox saat offline; server memvalidasi rating serta panjang teks. |
| Donasi dan ledger | Layar donasi/kwitansi serta ledger lokal dengan hashing, proof-of-work, dan verifikasi rantai. Endpoint backend penerimaan donasi dan pembacaan ledger ada; repository/alur donasi Flutter masih memiliki TODO. |
| Worship hub | Hub navigasi untuk fitur ibadah yang diimplementasikan, termasuk masjid, kiblat, dan tasbih. |
| IoT | Layar pengelolaan perangkat dan endpoint registrasi/pencabutan perangkat tersedia. Endpoint perangkat ESP32 untuk polling sholat atau mengirim tasbih belum tersedia. |
| Konverter, zakat, kuis, dan game | Sebagian layar/model/layanan lokal ada, tetapi beberapa repository, provider, atau service masih TODO; fitur ini belum dapat dianggap sebagai integrasi end-to-end. |
| AI chat | Layar dan penyimpanan sementara di memori ada, tetapi jawaban saat ini berupa teks contoh. Backend AI dan persistensi riwayat belum diimplementasikan. |

Navigasi bawah mempunyai empat tab layar—**Beranda**, **Ibadah**, **Profil**,
dan **Saran & Kesan**—serta satu aksi **Logout**.

## 3. Screenshots

Belum ada screenshot aplikasi di repository. Direktori `assets/images/` tidak
berisi screenshot; gambar launcher Android bukan screenshot UI. Screenshot
dapat ditambahkan kemudian, misalnya ke `assets/images/screenshots/`, lalu
ditautkan dari bagian ini dengan gambar perangkat yang tidak berisi data
pribadi.

## 4. Tech Stack

- **Flutter** untuk aplikasi lintas platform; konfigurasi Android tersedia.
- **Dart** dengan batas SDK di `pubspec.yaml`: `>=3.3.0 <4.0.0`.
- **Riverpod** (`flutter_riverpod`) untuk dependency injection dan state.
- **go_router** untuk navigasi dan pengalihan berdasarkan status sesi.
- **Drift** untuk basis data SQLite lokal, bersama `sqlite3mc` untuk enkripsi.
- **Dio** untuk panggilan HTTP.
- **Supabase Edge Functions** dengan TypeScript/Deno dan Supabase JS client
  untuk backend.
- Paket lain yang digunakan: `flutter_secure_storage`, `local_auth`,
  `flutter_local_notifications`, `geolocator`, `geocoding`, `sensors_plus`,
  `flutter_map`, `latlong2`, `timezone`, `connectivity_plus`,
  `shared_preferences`, `permission_handler`, `path_provider`,
  `flutter_dotenv`, `crypto`, dan `url_launcher`.
- Tooling pengembangan: `flutter_test`, `flutter_lints`, `drift_dev`, dan
  `build_runner`.

## 5. Architecture

### Aplikasi Flutter

- `lib/main.dart` memuat `.env`, membuat secure storage dan kunci enkripsi,
  membuka database terenkripsi, menyiapkan `ProviderContainer`, lalu
  menginisialisasi layanan notifikasi.
- `lib/app.dart` membangun `MaterialApp.router`, tema, provider auto-lock, dan
  router.
- `lib/core/` berisi konfigurasi, database/DAO, jaringan, router, keamanan,
  sinkronisasi, tema, dan utilitas bersama.
- `lib/features/<fitur>/` memisahkan model, provider, repository, service,
  screen, dan widget sesuai kebutuhan fitur.
- Repository menghubungkan provider/UI dengan Drift atau API. Beberapa modul
  yang belum selesai secara eksplisit ditandai TODO di kode.

### Data lokal dan sinkronisasi

Drift menyimpan cache jadwal, pengaturan, feedback, favorit masjid, tasbih,
donasi, ledger, dan tabel fitur lain. Database dibuka melalui
`openEncryptedExecutor`; kunci acak database disimpan menggunakan
`flutter_secure_storage`. Tabel outbox menyimpan entity, operasi, payload,
jumlah percobaan, error terakhir, dan waktu percobaan berikutnya.

`OutboxProcessor` mengirim donasi, feedback, favorit, dan pencabutan sesi
melalui endpoint khusus; entity lain dikirim melalui `/sync/push`.
`SyncService` memproses outbox ketika koneksi tersedia lalu mengambil
perubahan lewat `/sync/pull`. Implementasi backend sync saat ini hanya
menerima `tasbih_log` dan `setting`; deklarasi entity lain di Flutter tidak
berarti semuanya sudah tersinkron.

### Backend

Folder `supabase/functions/` berisi handler Deno serta helper bersama untuk
auth, kriptografi, database, CORS, HTTP, dan router. Fungsi memakai
service-role Supabase client hanya di server. Session menggunakan JWT Barakah
sendiri; setiap protected handler tetap harus memvalidasi token dan session
aktif.

## 6. Project Structure

| Path | Isi |
|---|---|
| `lib/main.dart`, `lib/app.dart` | Entry point, inisialisasi layanan, tema, dan router aplikasi. |
| `lib/core/config/`, `constants/` | Environment, konfigurasi, nama endpoint, dan nilai bersama. |
| `lib/core/database/` | Drift database, tabel, DAO, dan kode generated. |
| `lib/core/network/` | Klien Dio, interceptor auth, error API, konektivitas, dan token store. |
| `lib/core/security/` | Secure storage, pembuatan kunci, dan helper hash. |
| `lib/core/sync/` | Outbox processor, service sinkronisasi, dan status sync. |
| `lib/core/router/`, `theme/`, `utils/` | Navigasi, tema, dan helper bersama. |
| `lib/features/` | Fitur auth, home, qibla, mosque, tasbih, notification, profile, donation, ledger, feedback, converter, games, AI chat, IoT, worship, dan shell. |
| `lib/shared/` | Widget umum lintas fitur. |
| `assets/` | Audio, data, font, dan gambar aplikasi. |
| `android/` | Konfigurasi Gradle, manifest, permission, dan resource Android. |
| `supabase/functions/` | Edge Functions serta `_shared/` helper dan tes Deno. |
| `supabase/migrations/` | Migrasi skema dan kontrak PostgreSQL. |
| `test/` | Unit, widget, dan pengujian fitur Flutter. |
| `design_ref/` | Dokumen referensi desain dan PRD. |

## 7. Requirements

Versi minimum hanya dicantumkan jika repository atau konfigurasi
menetapkannya. Versi lokal di bawah adalah hasil pemeriksaan pada mesin saat
dokumentasi ini disusun, bukan jaminan versi minimum:

| Tool | Persyaratan dari repository / hasil verifikasi |
|---|---|
| Flutter | Repository tidak menetapkan batas versi minimum Flutter. Versi yang terverifikasi di mesin ini: **3.47.4**. |
| Dart | `pubspec.yaml` menetapkan `>=3.3.0 <4.0.0`; versi lokal terverifikasi: **3.13.3**. |
| Android SDK | Konfigurasi Android menetapkan `compileSdk = 37`; `minSdk` dan `targetSdk` mengikuti nilai Flutter SDK. Versi SDK yang terpasang tidak diverifikasi. |
| Java | Gradle Android dikonfigurasi dengan Java/JVM **17**. Versi lokal terverifikasi: **17.0.20.1**. |
| Supabase CLI | Tidak ada batas versi minimum yang dipatok dalam repository. Versi lokal terverifikasi: **2.121.0**. |
| Deno | Diperlukan untuk memeriksa dan menguji Edge Functions; versi minimum tidak dipatok. Deno tidak tersedia di PATH saat diperiksa. |
| Docker Desktop | Diperlukan untuk menjalankan stack Supabase lokal; ketersediaannya tidak terverifikasi (perintah `docker` tidak ditemukan). |

Ketersediaan Android SDK platform/build tools API 37 perlu dipastikan pada mesin
developer sebelum build.

## 8. Getting Started

Contoh berikut menggunakan Windows PowerShell dari root repository:

```powershell
Set-Location D:\barakah
flutter --version
flutter pub get
```

Konfigurasi Flutter menggunakan `.env` di root. File `.env.example` hanya
memuat nama konfigurasi client. Jika `.env` belum ada, buat salinannya:

```powershell
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
```

Edit `.env` secara lokal untuk mengisi `SUPABASE_URL` dan
`SUPABASE_ANON_KEY` dari project yang memang berhak Anda gunakan. Jangan
menaruh service-role key atau secret penandatangan JWT di file Flutter.
Jalankan aplikasi pada perangkat/emulator yang terhubung:

```powershell
flutter devices
flutter run
```

Tanpa konfigurasi backend, nilai URL/key dibaca sebagai string kosong dan
panggilan fitur yang membutuhkan API tidak akan berfungsi normal. Lokasi,
izin, sensor, biometrik, dan notifikasi sebaiknya diuji pada perangkat Android
yang sesuai, bukan diasumsikan bekerja penuh di emulator.

## 9. Environment Configuration

### Konfigurasi Flutter (`.env`)

| Nama | Tujuan |
|---|---|
| `SUPABASE_URL` | URL project Supabase; dipakai untuk membentuk base URL `/functions/v1`. |
| `SUPABASE_ANON_KEY` | Client-safe anon/publishable key untuk header `apikey`; tidak menggantikan autentikasi user. |
| `APP_ENV` | Nama lingkungan (`dev`, `staging`, atau `prod`); default kode adalah `dev`. |
| `ENABLE_IOT` | Flag opsional untuk fitur IoT; hanya aktif jika nilainya `true`. |
| `ENABLE_GEOFENCE` | Flag opsional untuk notifikasi geofence; hanya aktif jika nilainya `true`. |

Tiga variabel terakhir dibaca oleh kode Flutter; `.env.example` yang ada hanya
menyediakan `SUPABASE_URL` dan `SUPABASE_ANON_KEY`. Geofence tidak berarti
endpoint backend untuk IoT telah tersedia.

### Secret server Edge Functions

Nama environment server yang dibaca helper backend:

- `SUPABASE_URL` — alamat Supabase untuk client database function.
- `SUPABASE_SERVICE_ROLE_KEY` — kredensial server-only untuk akses database.
- `BARAKAH_JWT_SECRET` — secret server-only untuk penandatanganan/verifikasi
  JWT Barakah.

Untuk pengembangan lokal, berikan nilai secret ke runtime Functions melalui
file terpisah yang diabaikan Git, misalnya `.env.local`; jangan gunakan `.env`
Flutter untuk secret server. Untuk hosted Supabase, konfigurasi secret melalui
secret store server Supabase. Jangan menyalin, mencetak, atau membagikan
nilainya.

## 10. Database

### Drift lokal

`AppDatabase` memakai `DriftDatabase` dengan tabel ledger, outbox, settings,
cache sholat, cache kurs, donasi, tasbih, kuis, chat, feedback, dan favorit
masjid. File SQLite bernama `barakah.db` dan dibuka dengan
`NativeDatabase.createInBackground` serta PRAGMA key. `sqlite3mc` dikonfigurasi
melalui hook `sqlite3` di `pubspec.yaml`; kunci database acak disimpan di
`flutter_secure_storage`.

Versi skema lokal yang tercatat saat ini adalah **1**. Kode repository tidak
mendeklarasikan migration strategy Drift tersendiri. Jangan mengasumsikan
perubahan tabel otomatis aman untuk data yang sudah terpasang. File
`app_database.g.dart` adalah output generated; jangan mengeditnya manual.
Untuk perubahan skema, tinjau strategi migrasi lalu jalankan generator:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Perintah generator ditujukan untuk pekerjaan pengembangan yang memang
mengubah definisi Drift, bukan langkah rutin untuk menjalankan aplikasi.

### PostgreSQL Supabase

Migrasi yang tersedia:

- `supabase/migrations/0001_init_schema.sql` membuat tabel pengguna, session,
  device token, campaign/donation, ledger, zakat, tasbih, kuis/game, chat,
  feedback, favorit masjid, rate cache, dan IoT.
- `supabase/migrations/0002_backend_contract.sql` menambah constraint/index
  case-insensitive, `user_settings`, kolom sinkronisasi, pencabutan akses
  tabel langsung untuk role aplikasi, dan fungsi database untuk operasi
  tertentu.

Migrasi `0001` mengaktifkan RLS pada tabel awal. Migrasi `0002` juga
mengaktifkan RLS untuk `user_settings`; tidak ada kebijakan RLS user yang
didefinisikan di file migrasi yang diperiksa. Akses backend memakai service
role, sehingga ownership tetap diperiksa oleh handler. File migrasi lokal
bukan bukti bahwa migrasi sudah diterapkan pada project remote.

Pemeriksaan lokal (memerlukan Supabase CLI dan Docker):

```powershell
supabase start
supabase status
supabase migration list --local
supabase db lint --local
```

`supabase status` dapat menampilkan kredensial lokal; jangan salin outputnya
ke issue atau log publik. Untuk inspeksi remote, `supabase migration list
--linked` dan `supabase db push --dry-run --linked` tidak menerapkan migrasi.
Jangan menjalankan `supabase db push --linked` tanpa peninjauan dan persetujuan
terpisah.

## 11. Authentication and Security

- Password akun tidak disimpan plaintext. Kode Edge Function menggunakan
  PBKDF2-HMAC-SHA-256 dengan salt acak; format hash saat ini
  `pbkdf2$sha256$<iterations>$<salt>$<hash>`.
- Server menerbitkan JWT HS256 Barakah dengan issuer `barakah`, audience
  `barakah-app`, subject user, session, device, waktu terbit, dan expiry.
  Protected route memeriksa tanda tangan/klaim serta session aktif di database.
- Access token berumur 15 menit; refresh token berlaku 7 hari, disimpan di
  server sebagai hash, dan dirotasi saat refresh. Aplikasi menyimpan access
  dan refresh token memakai `flutter_secure_storage`.
- Percobaan login gagal dibatasi melalui database: lima kegagalan mengunci
  akun selama 15 menit.
- Login biometrik memerlukan biometrik perangkat dan device token yang
  disimpan lokal secara aman. Layar lock aplikasi setelah idle adalah
  perlindungan lokal dan terpisah dari validasi session server.
- Kunci database lokal dan device ID disimpan menggunakan secure storage.
- `supabase/config.toml` menonaktifkan verifikasi JWT gateway untuk fungsi
  custom-token yang terdaftar. Handler tetap harus memanggil validasi
  autentikasi Barakah; pengaturan ini bukan alasan untuk membuka endpoint
  terlindungi.
- Fungsi memakai service-role key server-side. Jangan memasukkannya ke Flutter.
  Request ke Supabase hosted harus memakai HTTPS.

## 12. Supabase Backend

Base endpoint dibentuk dari
`${SUPABASE_URL}/functions/v1/<function>/<route>`. Klien mengirim header
`apikey`; rute terlindungi juga menggunakan header Authorization dengan access
token Barakah bertipe Bearer. Rute publik/token-body dikecualikan sebagaimana
tercantum di bawah.
Contoh route ini berasal dari route map handler di repository.

| Function | Route yang diimplementasikan | Akses dan catatan |
|---|---|---|
| `auth` | `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`, `POST /auth/password`, `POST /auth/biometric/enable`, `POST /auth/biometric/login`, `DELETE /auth/biometric`, `GET /auth/sessions`, `DELETE /auth/sessions/:id` | Register/login publik; refresh dan logout memakai refresh token pada body; operasi lain memerlukan session user kecuali biometric login memakai device token. |
| `profile` | `GET /profile`, `PUT /profile` | Session user. |
| `feedback` | `GET /feedback`, `POST /feedback`, `PUT /feedback/:id`, `DELETE /feedback/:id` | Session user; validasi ownership dan rating 1–5 serta teks 10–500 karakter. |
| `mosques` | `GET /mosques/nearby` | Session user; parameter `lat`, `lng`, `radius` (km), opsional `q`; data bersumber dari Overpass. |
| `favorites` | `GET /favorites/mosques`, `POST /favorites/mosques`, `DELETE /favorites/mosques` | Session user; operasi atas favorit milik user. |
| `donations` | `POST /donations` | Session user; handler memvalidasi request dan meminta operasi database atomik untuk donasi/ledger. |
| `ledger` | `GET /ledger`, `GET /ledger/verify` | Session user; membaca blok/head ledger user. |
| `sync` | `POST /sync/push`, `GET /sync/pull` | Session user; push menerima `tasbih_log` dan `setting`; pull menerima opsi `since`. |
| `iot` | `POST /iot/devices`, `DELETE /iot/devices/:id` | Session user; registrasi dan pencabutan perangkat. |

Semua rute selain yang ditandai publik atau menggunakan token body memerlukan
session yang valid. Handler merespons JSON dan menggunakan error terstruktur
sesuai shared helper. Untuk payload dan respons yang lebih rinci, lihat
handler terkait di `supabase/functions/`.

Belum ada handler `campaigns`, `rates`, `zakat`, `ai`, `quiz`, atau `games`.
Konstanta endpoint di Flutter bukan bukti bahwa route backend tersedia.
Endpoint `/profile/avatar`, `/iot/next-prayer`, dan `/iot/tasbih` juga tidak
memiliki handler saat ini. Jangan mengirim data produksi ke route yang belum
diimplementasikan.

## 13. Testing and Validation

Jalankan dari root repository:

```powershell
flutter test
flutter analyze
```

Untuk memeriksa seluruh TypeScript Edge Functions menggunakan Deno:

```powershell
$tsFiles = Get-ChildItem .\supabase\functions -Recurse -Filter *.ts |
  ForEach-Object FullName
deno check $tsFiles
```

Tes unit shared backend:

```powershell
deno test --allow-env=BARAKAH_JWT_SECRET `
  .\supabase\functions\_shared\auth_test.ts `
  .\supabase\functions\_shared\crypto_test.ts `
  .\supabase\functions\_shared\router_test.ts
```

Pemeriksaan migrasi lokal menggunakan `supabase db lint --local` setelah stack
lokal berjalan. Tes backend tersebut bukan tes integrasi seluruh API dan tidak
membuktikan migrasi remote telah diterapkan.

## 14. Build and Deployment

Build APK Android:

```powershell
flutter build apk --release
```

File hasil build biasanya berada di `build\app\outputs\flutter-apk\`. Perintah
build belum dijalankan sebagai bagian dokumentasi ini dan tidak berarti
aplikasi telah dirilis.

Sebelum rilis:

1. Pastikan environment production memakai URL dan anon key yang benar, dan
   tidak berisi secret server.
2. Verifikasi permission lokasi, notifikasi, dan biometrik pada perangkat.
3. Siapkan signing config release; konfigurasi `release` saat ini memakai
   debug signing.
4. Tinjau `applicationId` Android yang saat ini masih `com.example.barakah`.
5. Jalankan `flutter test`, `flutter analyze`, dan build release pada CI atau
   mesin rilis.
6. Tinjau status migrasi dan perubahan backend secara terpisah sebelum
   deployment. Jangan menganggap build Flutter mengirim Edge Functions atau
   menerapkan migrasi.

## 16. Known Limitations and Roadmap

Berikut status yang dapat ditunjukkan langsung oleh kode saat dokumentasi
ditulis:

- Repository donasi/campaign dan kalkulator zakat Flutter masih memiliki TODO;
  keberadaan layar atau endpoint donasi tidak membuktikan alur end-to-end.
- Modul konverter kurs, kuis, dan game memiliki service/repository/provider
  bertanda TODO.
- AI chat saat ini mengembalikan jawaban contoh dan riwayatnya belum dipersist
  melalui Drift/backend.
- Backend belum memiliki handler campaign, rates, zakat, AI, kuis, game,
  unggah avatar, atau route IoT perangkat (`next-prayer`/`tasbih`).
- Sinkronisasi backend generik hanya mendukung `tasbih_log` dan `setting`.
- Kode Drift menetapkan schema version 1 tetapi tidak mendeklarasikan
  migration strategy; upgrade data lama perlu dirancang dan diuji.
- Skema remote Supabase tidak dapat dipastikan hanya dari migrasi yang ada di
  repository. Status penerapan `0001` dan `0002` harus diverifikasi pada project
  yang digunakan.
- Status signing production, ketersediaan SDK API 37 pada mesin lain, serta
  hasil build/tes pada CI belum diverifikasi di sini.

Roadmap implementasi sebaiknya memprioritaskan alur yang konsisten antara
repository Flutter, outbox, kontrak Edge Function, dan migrasi database;
kemudian tambahkan tes integrasi lokal untuk operasi tersebut sebelum
mengaktifkan endpoint yang belum tersedia.

## 17. Contributing and License

Kontribusi sebaiknya mempertahankan pemisahan fitur, pola Riverpod/repository,
penggunaan Drift untuk data lokal, dan pemeriksaan ownership pada operasi
backend. Tambahkan atau perbarui tes untuk perubahan perilaku dan jangan
mengedit file Drift generated secara manual. Jangan commit `.env`, kredensial,
token, service-role key, atau secret JWT.

Repository yang diperiksa tidak menyediakan file `LICENSE` di root dan
`pubspec.yaml` menggunakan `publish_to: 'none'`. Dengan demikian, README ini
tidak menyatakan lisensi atau izin penggunaan tertentu; status lisensi perlu
ditetapkan oleh pemilik proyek.
