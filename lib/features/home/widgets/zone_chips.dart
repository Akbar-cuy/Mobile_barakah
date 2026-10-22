// Pilihan zona waktu: WIB, WITA, WIT, London.

import 'package:flutter/material.dart';

class ZoneChips extends StatelessWidget {
  final List<String> zones; // daftar nama zona
  final String selectedZone; // zona yang sedang dipilih
  final Function(String) onSelected; // dipanggil saat chip ditekan

  const ZoneChips({
    super.key,
    required this.zones,
    required this.selectedZone,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: zones.map((zone) {
        return ChoiceChip(
          label: Text(zone),
          selected: selectedZone == zone,
          onSelected: (_) => onSelected(zone),
        );
      }).toList(),
    );
  }
}