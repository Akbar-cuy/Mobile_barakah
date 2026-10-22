abstract final class RouteNames {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const lock = '/lock';
  static const home = '/home';
  static const worship = '/ibadah';
  static const profile = '/profil';
  static const feedback = '/saran';
  static const notificationSettings = '/pengingat-adzan';

  // ---- Ibadah (M5, M6, M7, M8)
  static const mosque = '/masjid';
  static const qibla = '/kiblat';
  static const tasbih = '/tasbih';
  static const tasbihHistory = '/tasbih/riwayat';

  // ---- Keuangan dan belajar. Layar milik modul lain, hub ibadah hanya
  // membukanya lewat nama rute ini.
  static const converter = '/konversi';
  static const donation = '/donasi';
  static const zakat = '/zakat';
  static const aiChat = '/tanya-ai';
  static const quiz = '/kuis';
  static const directionGame = '/cari-arah';

  // ---- Ledger (M12)
  static const ledger = '/ledger';
  static const ledgerBlockPattern = '/ledger/blok/:index';
  static String ledgerBlock(int index) => '/ledger/blok/$index';

  // ---- Profil (M17)
  static const editProfile = '/profil/ubah';
  static const changePassword = '/profil/kata-sandi';
  static const security = '/profil/keamanan';
  static const settings = '/profil/pengaturan';

  // ---- IoT (M21, opsional)
  static const iot = '/iot';
}
