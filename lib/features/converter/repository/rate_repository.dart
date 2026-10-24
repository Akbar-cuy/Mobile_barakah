// Data kurs: nilai tiap mata uang terhadap 1 USD + waktu pembaruan
class RateData {
  final Map<String, double> perUsd;
  final DateTime updatedAt;

  RateData(this.perUsd, this.updatedAt);
}

class RateRepository {
  // TODO: ganti dengan panggilan ke endpoint /rates (Edge Function),
  // lalu simpan hasilnya ke cache SQLite supaya bisa dipakai offline.
  // Untuk sementara pakai kurs contoh. SAR memang dipatok 3,75 per USD,
  // sedangkan nilai IDR hanya contoh dan perlu diperbarui dari server.
  Future<RateData> getRates() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return RateData(
      {
        'USD': 1,
        'SAR': 3.75,
        'IDR': 16500,
      },
      DateTime(2026, 10, 15, 8, 0),
    );
  }
}