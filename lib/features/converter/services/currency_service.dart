// Mata uang yang didukung (PRD M10)
const List<String> currencyList = ['IDR', 'USD', 'SAR'];

class CurrencyService {
  // Mengembalikan pesan galat, atau null kalau input valid
  String? validateAmount(String text) {
    if (text.trim().isEmpty) return 'Nominal tidak boleh kosong.';
    final value = parseAmount(text);
    if (value == null) return 'Nominal harus berupa angka.';
    if (value <= 0) return 'Nominal harus lebih dari nol.';
    return null;
  }

  // Terima "1000", "1000.50", atau "1,5"
  double? parseAmount(String text) {
    final clean = text.trim().replaceAll(',', '.');
    return double.tryParse(clean);
  }

  // Konversi lewat USD sebagai jembatan.
  // perUsd berisi kurs tiap mata uang terhadap 1 USD.
  double convert(
    double amount,
    String from,
    String to,
    Map<String, double> perUsd,
  ) {
    final inUsd = amount / perUsd[from]!;
    return inUsd * perUsd[to]!;
  }

  // IDR tanpa desimal, USD dan SAR dua desimal
  String format(double value, String currency) {
    if (currency == 'IDR') {
      return 'Rp${_addThousands(value.round().toString())}';
    }
    final fixed = value.toStringAsFixed(2); // contoh 1234.50
    final parts = fixed.split('.');
    return '$currency ${_addThousands(parts[0])},${parts[1]}';
  }

  // Sisipkan pemisah ribuan: 1234567 -> 1.234.567
  String _addThousands(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final fromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  // Label waktu pembaruan kurs, contoh: "Kurs per 15 Okt 2026 08.00"
  String ratesLabel(DateTime d) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final jam = d.hour.toString().padLeft(2, '0');
    final menit = d.minute.toString().padLeft(2, '0');
    return 'Kurs per ${d.day} ${bulan[d.month - 1]} ${d.year} $jam.$menit';
  }
}