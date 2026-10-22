// Satu baris jadwal sholat, contoh: "Dzuhur ........ 11:45 WIB".
// Kalau isNext = true, baris diberi warna dan huruf tebal.

import 'package:flutter/material.dart';

class PrayerRow extends StatelessWidget {
  final String name;
  final String time;
  final bool isNext;

  const PrayerRow({
    super.key,
    required this.name,
    required this.time,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNext ? Colors.grey.shade200 : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: style),
          Text(time, style: style),
        ],
      ),
    );
  }
}