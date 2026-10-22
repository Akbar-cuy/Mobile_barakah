// M9 Konversi Waktu (FR-TZ-01). Pilihan zona tampilan jadwal sholat.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../converter/services/timezone_service.dart';
import '../providers/home_provider.dart';

class ZoneChips extends ConsumerWidget {
  const ZoneChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(zoneProvider);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final zone in AppZone.values)
          AppChip(
            label: zone.label,
            selected: zone == selected,
            onSelected: () => ref.read(zoneProvider.notifier).select(zone),
          ),
      ],
    );
  }
}
