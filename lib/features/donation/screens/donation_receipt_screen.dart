import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../converter/services/currency_service.dart';
import '../models/donation_models.dart';

// Bukti donasi: menampilkan nomor blok dan hash (PRD AC.ZKT.03)
class DonationReceiptScreen extends StatelessWidget {
  final Donation donation;

  const DonationReceiptScreen({super.key, required this.donation});

  // Waktu disimpan UTC, ditampilkan di zona waktu perangkat
  String _formatDate(DateTime utc) {
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final d = utc.toLocal();
    final jam = d.hour.toString().padLeft(2, '0');
    final menit = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${bulan[d.month - 1]} ${d.year} $jam.$menit';
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final money = CurrencyService();

    return Scaffold(
      appBar: AppBar(title: const Text('Bukti Donasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 8),
          Text(
            donation.isSynced
                ? 'Donasi tercatat di server'
                : 'Menunggu sinkronisasi',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (!donation.isSynced)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Donasi tersimpan di perangkat dan menunggu sinkronisasi ke server.',
                textAlign: TextAlign.center,
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row('Kampanye', donation.campaignTitle),
                  _row('Donatur', donation.donorAlias),
                  _row('Nominal',
                      money.format(donation.amount, donation.currency)),
                  _row('Setara IDR', money.format(donation.amountIdr, 'IDR')),
                  _row('Waktu', _formatDate(donation.createdAt)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data blok',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _row('Nomor blok', '#${donation.blockIndex}'),
                  _row('Nonce', donation.nonce.toString()),
                  const SizedBox(height: 4),
                  const Text('Hash'),
                  SelectableText(
                    donation.hash,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 8),
                  const Text('Hash blok sebelumnya'),
                  SelectableText(
                    donation.prevHash,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: donation.hash));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hash disalin')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Salin hash'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Donasi bersifat simulasi, tidak ada pembayaran riil.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}
