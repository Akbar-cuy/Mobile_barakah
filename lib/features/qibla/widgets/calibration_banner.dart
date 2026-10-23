// M7 Arah Kiblat (FR-QBL-04, FR-QBL-05, AC-QBL-04)
import 'package:flutter/material.dart';

import '../../../shared/widgets/status_banner.dart';

/// Petunjuk kalibrasi gerakan angka 8, tampil pada akurasi sensor rendah.
class CalibrationBanner extends StatelessWidget {
  const CalibrationBanner({super.key, this.interference = false});

  /// Gangguan medan magnet kuat (logam, magnet, speaker) terdeteksi.
  final bool interference;

  @override
  Widget build(BuildContext context) {
    return StatusBanner(
      kind: BannerKind.warning,
      message: interference
          ? 'Terdeteksi gangguan medan magnet. Jauhkan ponsel dari logam, '
              'magnet, atau speaker, lalu gerakkan membentuk angka 8.'
          : 'Akurasi sensor rendah. Gerakkan ponsel membentuk angka 8 '
              'beberapa kali untuk mengkalibrasi.',
    );
  }
}
