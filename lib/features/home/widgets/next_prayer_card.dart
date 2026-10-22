// Kartu besar yang menampilkan sholat berikutnya dan hitung mundurnya.

import 'package:flutter/material.dart';

class NextPrayerCard extends StatelessWidget {
  final String name; // contoh: "Ashar"
  final String time; // contoh: "15:08"
  final String zone; // contoh: "WIB"
  final String countdown; // contoh: "01:23:45"

  const NextPrayerCard({
    super.key,
    required this.name,
    required this.time,
    required this.zone,
    required this.countdown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sholat berikutnya'),
          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            '$time $zone',
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
          Text('dalam $countdown'),
        ],
      ),
    );
  }
}
