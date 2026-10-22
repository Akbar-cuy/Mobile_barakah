// Tiga kartu ringkasan di bawah jadwal:
// donasi bulan ini, dzikir hari ini, dan status sinkronisasi.

import 'package:flutter/material.dart';

class SummaryCards extends StatelessWidget {
  final String donation;
  final String dhikr;
  final String syncStatus;

  const SummaryCards({
    super.key,
    required this.donation,
    required this.dhikr,
    required this.syncStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _card('Donasi bulan ini', donation),
        _card('Dzikir hari ini', dhikr),
        _card('Sinkronisasi', syncStatus),
      ],
    );
  }

  // Fungsi kecil untuk membuat satu kartu, supaya tidak menulis kode 3 kali.
  Widget _card(String title, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}