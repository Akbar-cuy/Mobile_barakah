import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/converter_provider.dart';
import '../services/timezone_service.dart';

// Tab Waktu: konversi jam bebas antar WIB, WITA, WIT, dan London
class TimeConverterTab extends StatelessWidget {
  const TimeConverterTab({super.key});

  Future<void> _pickTime(BuildContext context) async {
    final provider = context.read<ConverterProvider>();
    final picked = await showTimePicker(
      context: context,
      initialTime: provider.time,
    );
    if (picked != null) {
      provider.setTime(picked);
    }
  }

  void _pickZone(BuildContext context) {
    final provider = context.read<ConverterProvider>();
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Pilih zona asal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              for (final zone in zoneList)
                ListTile(
                  title: Text(zone.label),
                  subtitle: Text(zone.iana),
                  trailing: zone.label == provider.fromZone.label
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    provider.setFromZone(zone);
                    Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConverterProvider>();
    final results = provider.timeResults;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Input jam dan zona asal
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickTime(context),
                icon: const Icon(Icons.access_time),
                label: Text(provider.timeText),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickZone(context),
                icon: const Icon(Icons.public),
                label: Text('Dari ${provider.fromZone.label}'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Hasil untuk tiap zona
        for (final r in results)
          Card(
            child: ListTile(
              title: Text(r.zoneLabel),
              subtitle: Text(
                r.dayNote.isEmpty
                    ? r.abbreviation
                    : '${r.abbreviation} (${r.dayNote})',
              ),
              trailing: Text(
                r.time,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        const SizedBox(height: 8),
        const Text(
          'London memakai GMT atau BST (musim panas) secara otomatis.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}