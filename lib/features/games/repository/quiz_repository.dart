import 'dart:math';

import '../models/quiz_attempt.dart';
import '../models/quiz_question.dart';

// Kategori kuis (FR.GAME.01)
class QuizCategories {
  static const String rukun = 'Rukun Islam dan Iman';
  static const String sejarah = 'Sejarah Nabi';
  static const String fikih = 'Fikih Dasar';
  static const String umum = 'Umum';

  static const List<String> all = [rukun, sejarah, fikih, umum];
}

// Bank soal, riwayat kuis, dan skor game (PRD M15).
// Sementara semuanya di memori. Nanti diganti:
// - soal: GET /quiz/questions (category, version), disimpan ke tabel quiz_question
// - riwayat: tabel quiz_attempt + POST /quiz/attempts
// - skor Cari Arah: tabel game_scores + POST /games/scores
class QuizRepository {
  QuizRepository._();

  // Satu instance dipakai bersama supaya riwayat tidak hilang
  // saat layar ditutup dan dibuka lagi.
  static final QuizRepository instance = QuizRepository._();

  // Hanya untuk uji: isi false untuk meniru perangkat offline
  static bool serverOnline = true;

  // FR.AI.05: pengguna bisa mematikan rekomendasi di Pengaturan.
  // TODO: hubungkan dengan layar Pengaturan.
  bool recommendationsEnabled = true;

  final List<QuizAttempt> _attempts = []; // urutan lama ke baru
  final Map<String, int> _gameScores = {};

  List<QuizAttempt> get attempts => List.unmodifiable(_attempts);

  // ---------- Soal ----------

  // Ambil soal satu kategori (FR.GAME.05: nanti dari server lalu cache lokal)
  Future<List<QuizQuestion>> getQuestions(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _bank.where((q) => q.category == category).toList();
  }

  // ---------- Riwayat kuis ----------

  // Skor tertinggi per kategori (FR.GAME.04)
  int bestScore(String category) {
    int best = 0;
    for (final a in _attempts) {
      if (a.category == category && a.score > best) best = a.score;
    }
    return best;
  }

  Future<QuizAttempt> saveAttempt({
    required String category,
    required int score,
    required int correct,
    required int total,
    required double avgTime,
  }) async {
    final now = DateTime.now().toUtc();
    final attempt = QuizAttempt(
      // TODO: pakai UUID sungguhan agar pengiriman ulang tidak duplikat
      id: '${now.microsecondsSinceEpoch}-${Random().nextInt(99999)}',
      category: category,
      score: score,
      correct: correct,
      total: total,
      avgTime: avgTime,
      createdAt: now,
      syncState: QuizAttempt.statePending,
    );
    _attempts.add(attempt);
    await _send(attempt.id);
    return _attempts.firstWhere((a) => a.id == attempt.id);
  }

  // Kirim hasil yang masih menunggu (dipanggil saat online lagi)
  Future<void> syncPending() async {
    final ids = _attempts
        .where((a) => a.syncState != QuizAttempt.stateSynced)
        .map((a) => a.id)
        .toList();
    for (final id in ids) {
      await _send(id);
    }
  }

  // TODO: ganti dengan POST /quiz/attempts
  Future<void> _send(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!serverOnline) return;
    final index = _attempts.indexWhere((a) => a.id == id);
    if (index == -1) return;
    _attempts[index] =
        _attempts[index].copyWith(syncState: QuizAttempt.stateSynced);
  }

  // ---------- Skor game Cari Arah ----------

  int getGameHighScore(String game) => _gameScores[game] ?? 0;

  // TODO: simpan ke tabel game_scores dan kirim lewat POST /games/scores
  Future<void> saveGameScore(String game, int score) async {
    if (score > getGameHighScore(game)) {
      _gameScores[game] = score;
    }
  }

  // ---------- Bank soal contoh ----------
  // Soal berikut contoh awal. Sumber dan peninjau konten belum ditentukan
  // (PRD pertanyaan terbuka 5), jadi isinya perlu ditinjau sebelum dipakai.

  static QuizQuestion _q(
    String id,
    String category,
    int difficulty,
    String question,
    List<String> options,
    int answerIndex,
    String explanation,
  ) {
    return QuizQuestion(
      id: id,
      category: category,
      difficulty: difficulty,
      question: question,
      options: options,
      answerIndex: answerIndex,
      explanation: explanation,
      version: 1,
    );
  }

  static final List<QuizQuestion> _bank = [
    // ===== Rukun Islam dan Iman =====
    _q(
        'r1',
        QuizCategories.rukun,
        1,
        'Berapa jumlah rukun Islam?',
        ['3', '4', '5', '6'],
        2,
        'Lima rukun Islam: syahadat, sholat, zakat, puasa Ramadhan, dan haji.'),
    _q(
        'r2',
        QuizCategories.rukun,
        1,
        'Rukun Islam yang pertama adalah?',
        ['Sholat', 'Syahadat', 'Zakat', 'Puasa'],
        1,
        'Rukun Islam pertama adalah mengucapkan dua kalimat syahadat.'),
    _q(
        'r3',
        QuizCategories.rukun,
        1,
        'Berapa jumlah rukun iman?',
        ['4', '5', '6', '7'],
        2,
        'Enam rukun iman: kepada Allah, malaikat, kitab, rasul, hari akhir, dan qada dan qadar.'),
    _q(
        'r4',
        QuizCategories.rukun,
        1,
        'Rukun iman yang pertama adalah iman kepada?',
        ['Malaikat', 'Allah', 'Rasul', 'Hari akhir'],
        1,
        'Iman kepada Allah adalah rukun iman yang pertama.'),
    _q(
        'r5',
        QuizCategories.rukun,
        2,
        'Malaikat yang bertugas menyampaikan wahyu kepada para nabi adalah?',
        ['Mikail', 'Israfil', 'Jibril', 'Izrail'],
        2,
        'Jibril bertugas menyampaikan wahyu dari Allah kepada para nabi.'),
    _q(
        'r6',
        QuizCategories.rukun,
        2,
        'Malaikat yang bertugas meniup sangkakala pada hari kiamat adalah?',
        ['Israfil', 'Jibril', 'Mikail', 'Malik'],
        0,
        'Israfil bertugas meniup sangkakala.'),
    _q(
        'r7',
        QuizCategories.rukun,
        2,
        'Kitab suci yang diturunkan kepada Nabi Musa adalah?',
        ['Zabur', 'Taurat', 'Injil', "Al-Qur'an"],
        1,
        'Taurat diturunkan kepada Nabi Musa.'),
    _q(
        'r8',
        QuizCategories.rukun,
        2,
        'Kitab suci yang diturunkan kepada Nabi Daud adalah?',
        ['Zabur', 'Taurat', 'Injil', 'Suhuf Ibrahim'],
        0,
        'Zabur diturunkan kepada Nabi Daud.'),
    _q(
        'r9',
        QuizCategories.rukun,
        2,
        'Kitab suci yang diturunkan kepada Nabi Isa adalah?',
        ['Zabur', 'Taurat', 'Injil', "Al-Qur'an"],
        2,
        'Injil diturunkan kepada Nabi Isa.'),
    _q(
        'r10',
        QuizCategories.rukun,
        2,
        'Zakat fitrah ditunaikan pada bulan?',
        ['Ramadhan', 'Muharram', 'Rajab', 'Dzulhijjah'],
        0,
        'Zakat fitrah ditunaikan pada bulan Ramadhan, paling lambat sebelum sholat Idulfitri.'),
    _q(
        'r11',
        QuizCategories.rukun,
        3,
        'Rukun Islam yang ke-4 adalah?',
        ['Zakat', 'Sholat', 'Puasa Ramadhan', 'Haji'],
        2,
        'Urutannya: syahadat, sholat, zakat, puasa Ramadhan, haji.'),
    _q(
        'r12',
        QuizCategories.rukun,
        3,
        'Puncak ibadah haji dilaksanakan pada bulan?',
        ['Ramadhan', 'Rajab', 'Muharram', 'Dzulhijjah'],
        3,
        'Wukuf di Arafah dilaksanakan pada 9 Dzulhijjah.'),
    _q(
        'r13',
        QuizCategories.rukun,
        3,
        'Malaikat penjaga neraka bernama?',
        ['Ridwan', 'Malik', 'Munkar', 'Nakir'],
        1,
        'Malik adalah penjaga neraka, sedangkan Ridwan penjaga surga.'),

    // ===== Sejarah Nabi =====
    _q(
        's1',
        QuizCategories.sejarah,
        1,
        'Nabi Muhammad SAW lahir di kota?',
        ['Madinah', 'Mekkah', 'Thaif', 'Yatsrib'],
        1,
        'Nabi Muhammad SAW lahir di Mekkah.'),
    _q(
        's2',
        QuizCategories.sejarah,
        1,
        'Nabi terakhir dalam ajaran Islam adalah?',
        ['Nabi Isa', 'Nabi Musa', 'Nabi Muhammad SAW', 'Nabi Ibrahim'],
        2,
        'Nabi Muhammad SAW adalah nabi dan rasul terakhir.'),
    _q(
        's3',
        QuizCategories.sejarah,
        1,
        'Siapa nama ibu Nabi Muhammad SAW?',
        ['Khadijah', 'Aminah', 'Aisyah', 'Fatimah'],
        1,
        'Ibu Nabi bernama Aminah binti Wahab.'),
    _q(
        's4',
        QuizCategories.sejarah,
        1,
        'Siapa nama ayah Nabi Muhammad SAW?',
        ['Abdullah', 'Abu Thalib', 'Abdul Muthalib', 'Abu Lahab'],
        0,
        'Ayah Nabi bernama Abdullah bin Abdul Muthalib.'),
    _q(
        's5',
        QuizCategories.sejarah,
        2,
        'Di gua manakah Nabi menerima wahyu pertama?',
        ['Gua Tsur', 'Gua Hira', 'Gua Kahfi', 'Gua Uhud'],
        1,
        'Wahyu pertama turun di Gua Hira.'),
    _q(
        's6',
        QuizCategories.sejarah,
        2,
        'Wahyu pertama yang turun adalah awal surat?',
        ['Al-Fatihah', 'Al-Baqarah', 'Al-Alaq', 'Al-Ikhlas'],
        2,
        'Wahyu pertama adalah Surat Al-Alaq ayat 1 sampai 5.'),
    _q(
        's7',
        QuizCategories.sejarah,
        2,
        'Nabi hijrah dari Mekkah menuju kota?',
        ['Madinah', 'Thaif', 'Damaskus', 'Yerusalem'],
        0,
        'Hijrah menuju Madinah, yang dahulu bernama Yatsrib.'),
    _q(
        's8',
        QuizCategories.sejarah,
        2,
        'Sahabat yang menemani Nabi dalam perjalanan hijrah adalah?',
        [
          'Umar bin Khattab',
          'Abu Bakar Ash-Shiddiq',
          'Utsman bin Affan',
          'Ali bin Abi Thalib'
        ],
        1,
        'Abu Bakar Ash-Shiddiq menemani Nabi hijrah ke Madinah.'),
    _q(
        's9',
        QuizCategories.sejarah,
        2,
        'Siapa istri pertama Nabi Muhammad SAW?',
        ['Aisyah', 'Hafshah', 'Khadijah', 'Zainab'],
        2,
        'Khadijah binti Khuwailid adalah istri pertama Nabi.'),
    _q(
        's10',
        QuizCategories.sejarah,
        3,
        'Perang besar pertama antara kaum Muslimin dan kaum Quraisy terjadi di?',
        ['Uhud', 'Badar', 'Khandaq', 'Hunain'],
        1,
        'Perang Badar terjadi pada tahun 2 Hijriyah.'),
    _q(
        's11',
        QuizCategories.sejarah,
        3,
        'Penanggalan Hijriyah dihitung mulai dari peristiwa?',
        [
          'Kelahiran Nabi',
          'Turunnya wahyu pertama',
          'Hijrah ke Madinah',
          'Fathu Makkah'
        ],
        2,
        'Tahun Hijriyah dihitung dari hijrah Nabi dari Mekkah ke Madinah.'),
    _q(
        's12',
        QuizCategories.sejarah,
        3,
        'Tahun kelahiran Nabi Muhammad SAW dikenal sebagai?',
        ['Tahun Gajah', 'Tahun Kesedihan', 'Tahun Hijrah', 'Tahun Perjanjian'],
        0,
        'Dikenal sebagai Tahun Gajah, saat pasukan Abrahah menyerang Ka\'bah.'),
    _q(
        's13',
        QuizCategories.sejarah,
        3,
        'Khalifah kedua dalam Khulafaur Rasyidin adalah?',
        [
          'Abu Bakar',
          'Umar bin Khattab',
          'Utsman bin Affan',
          'Ali bin Abi Thalib'
        ],
        1,
        'Umar bin Khattab menggantikan Abu Bakar sebagai khalifah.'),

    // ===== Fikih Dasar =====
    _q(
        'f1',
        QuizCategories.fikih,
        1,
        'Berapa kali sholat wajib dalam sehari semalam?',
        ['3', '4', '5', '6'],
        2,
        'Subuh, Dzuhur, Ashar, Maghrib, dan Isya.'),
    _q(
        'f2',
        QuizCategories.fikih,
        1,
        'Sholat Subuh terdiri dari berapa rakaat?',
        ['2', '3', '4', '5'],
        0,
        'Sholat Subuh dua rakaat.'),
    _q(
        'f3',
        QuizCategories.fikih,
        1,
        'Sholat Maghrib terdiri dari berapa rakaat?',
        ['2', '3', '4', '5'],
        1,
        'Sholat Maghrib tiga rakaat.'),
    _q(
        'f4',
        QuizCategories.fikih,
        1,
        'Cara bersuci dari hadas kecil dengan air adalah?',
        ['Mandi besar', 'Wudhu', 'Istinja', 'Menyamak'],
        1,
        'Hadas kecil disucikan dengan wudhu.'),
    _q(
        'f5',
        QuizCategories.fikih,
        2,
        'Berapa kali dianjurkan membasuh setiap anggota wudhu?',
        ['1 kali', '2 kali', '3 kali', '4 kali'],
        2,
        'Dianjurkan tiga kali, meski satu kali sudah cukup untuk sahnya wudhu.'),
    _q(
        'f6',
        QuizCategories.fikih,
        2,
        'Hadas besar disucikan dengan?',
        ['Wudhu', 'Mandi wajib', 'Istinja', 'Berkumur'],
        1,
        'Hadas besar disucikan dengan mandi wajib.'),
    _q('f7', QuizCategories.fikih, 2, 'Sholat Isya terdiri dari berapa rakaat?',
        ['2', '3', '4', '5'], 2, 'Sholat Isya empat rakaat.'),
    _q(
        'f8',
        QuizCategories.fikih,
        2,
        'Kadar zakat maal yang dikeluarkan adalah?',
        ['1 persen', '2,5 persen', '5 persen', '10 persen'],
        1,
        'Zakat maal sebesar 2,5 persen bila harta mencapai nisab dan haul.'),
    _q(
        'f9',
        QuizCategories.fikih,
        2,
        'Hal berikut yang membatalkan wudhu adalah?',
        ['Makan', 'Berbicara', 'Buang air kecil', 'Berjalan'],
        2,
        'Keluarnya sesuatu dari qubul atau dubur, seperti buang air kecil, membatalkan wudhu.'),
    _q(
        'f10',
        QuizCategories.fikih,
        3,
        'Pengganti wudhu atau mandi bila tidak ada air atau tidak boleh terkena air adalah?',
        ['Tayamum', 'Istinja', 'Qasar', 'Jamak'],
        0,
        'Tayamum dengan debu yang suci menggantikan wudhu atau mandi.'),
    _q(
        'f11',
        QuizCategories.fikih,
        3,
        'Jumlah takbir dalam sholat jenazah adalah?',
        ['2', '3', '4', '5'],
        2,
        'Sholat jenazah dikerjakan dengan empat takbir, tanpa rukuk dan sujud.'),
    _q(
        'f12',
        QuizCategories.fikih,
        3,
        'Waktu sholat Dzuhur dimulai ketika?',
        [
          'Matahari terbit',
          'Matahari tergelincir ke barat',
          'Matahari terbenam',
          'Bayangan sama panjang dengan benda'
        ],
        1,
        'Dzuhur dimulai saat matahari tergelincir dari titik tertingginya.'),

    // ===== Umum =====
    _q(
        'u1',
        QuizCategories.umum,
        1,
        'Kitab suci umat Islam adalah?',
        ['Taurat', 'Zabur', 'Injil', "Al-Qur'an"],
        3,
        "Al-Qur'an adalah kitab suci umat Islam."),
    _q(
        'u2',
        QuizCategories.umum,
        1,
        'Ke arah mana umat Islam menghadap saat sholat?',
        ['Utara', "Ka'bah", 'Masjid Nabawi', 'Timur'],
        1,
        "Menghadap kiblat, yaitu Ka'bah di Masjidil Haram, Mekkah."),
    _q(
        'u3',
        QuizCategories.umum,
        1,
        'Hari raya setelah bulan Ramadhan adalah?',
        ['Idul Adha', 'Idulfitri', 'Maulid Nabi', 'Isra Miraj'],
        1,
        'Idulfitri dirayakan pada 1 Syawal.'),
    _q(
        'u4',
        QuizCategories.umum,
        1,
        'Ucapan salam sesama Muslim adalah?',
        ["Assalamu'alaikum", 'Bismillah', 'Alhamdulillah', 'Astaghfirullah'],
        0,
        "Salam yang dianjurkan adalah Assalamu'alaikum."),
    _q('u5', QuizCategories.umum, 2, "Berapa jumlah surat dalam Al-Qur'an?",
        ['99', '100', '114', '124'], 2, "Al-Qur'an terdiri dari 114 surat."),
    _q('u6', QuizCategories.umum, 2, "Berapa jumlah juz dalam Al-Qur'an?",
        ['20', '30', '40', '60'], 1, "Al-Qur'an terbagi menjadi 30 juz."),
    _q(
        'u7',
        QuizCategories.umum,
        2,
        'Ramadhan adalah bulan ke berapa dalam kalender Hijriyah?',
        ['7', '8', '9', '10'],
        2,
        'Ramadhan adalah bulan kesembilan.'),
    _q(
        'u8',
        QuizCategories.umum,
        2,
        "Surat pembuka dalam Al-Qur'an adalah?",
        ['Al-Baqarah', 'Al-Fatihah', 'An-Nas', 'Yasin'],
        1,
        'Al-Fatihah berarti pembukaan.'),
    _q(
        'u9',
        QuizCategories.umum,
        2,
        'Masjid Nabawi terletak di kota?',
        ['Mekkah', 'Madinah', 'Yerusalem', 'Kairo'],
        1,
        'Masjid Nabawi berada di Madinah.'),
    _q(
        'u10',
        QuizCategories.umum,
        3,
        'Malam yang lebih baik daripada seribu bulan disebut?',
        ['Lailatul Qadar', 'Nisfu Syaban', 'Malam Jumat', 'Isra Miraj'],
        0,
        'Lailatul Qadar terjadi pada bulan Ramadhan.'),
    _q(
        'u11',
        QuizCategories.umum,
        3,
        "Surat terpanjang dalam Al-Qur'an adalah?",
        ['Al-Baqarah', 'Ali Imran', 'An-Nisa', 'Al-Maidah'],
        0,
        'Al-Baqarah terdiri dari 286 ayat.'),
    _q(
        'u12',
        QuizCategories.umum,
        3,
        'Idul Adha jatuh pada tanggal?',
        ['1 Syawal', '10 Dzulhijjah', '12 Rabiul Awal', '1 Muharram'],
        1,
        'Idul Adha dirayakan pada 10 Dzulhijjah.'),
    _q(
        'u13',
        QuizCategories.umum,
        3,
        "Surat dalam Al-Qur'an yang tidak diawali Basmalah adalah?",
        ['At-Taubah', 'Al-Fatihah', 'Al-Anfal', 'Yasin'],
        0,
        'Surat At-Taubah tidak diawali Basmalah.'),
  ];
}
