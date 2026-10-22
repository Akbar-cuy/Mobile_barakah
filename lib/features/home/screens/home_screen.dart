// Layar Beranda: kota, pilihan zona, sholat berikutnya, jadwal, ringkasan.
// Tampilan dipecah ke widget di folder widgets/ supaya file ini tetap pendek.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/prayer_row.dart';
import '../widgets/summary_cards.dart';
import '../widgets/zone_chips.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // watch: layar dibangun ulang tiap provider memanggil notifyListeners()
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      body: SafeArea(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(HomeProvider provider) {
    // 1. Sedang memuat
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Terjadi galat (GPS mati, izin ditolak, tidak ada internet, dll)
    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(provider.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.loadData(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Data belum ada
    if (provider.times == null || provider.nextPrayer == null) {
      return const Center(child: Text('Belum ada data'));
    }

    // 4. Data siap ditampilkan
    final times = provider.times!;
    final next = provider.nextPrayer!;
    final zone = provider.selectedZone;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Nama kota dan sapaan
        Text(times.city, style: const TextStyle(fontSize: 14)),
        const Text(
          'Halo, Rizky',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Pilihan zona waktu
        ZoneChips(
          zones: provider.zoneNames,
          selectedZone: zone,
          onSelected: (value) => provider.changeZone(value),
        ),

        // Penanda kalau zona yang tampil bukan zona lokal
        if (provider.isOtherZone)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Waktu ditampilkan dalam zona lain. '
              'Pengingat adzan tetap mengikuti waktu lokal.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),

        // Kartu sholat berikutnya
        NextPrayerCard(
          name: next.name,
          time: provider.showTime(next.timeText),
          zone: zone,
          countdown: provider.countdown,
        ),
        const SizedBox(height: 12),

        // Daftar jadwal sholat
        ...times.toMap().entries.map((entry) {
          return PrayerRow(
            name: entry.key,
            time: '${provider.showTime(entry.value)} $zone',
            isNext: entry.key == next.name,
          );
        }),
        const SizedBox(height: 16),

        // Ringkasan (sementara masih angka contoh)
        const SummaryCards(
          donation: 'Rp250.000',
          dhikr: '66',
          syncStatus: 'Tersinkron',
        ),
      ],
    );
  }
}
