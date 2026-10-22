// M4 Beranda (FR-LBS-02). Kartu sholat berikutnya dengan hitung mundur.
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../converter/services/timezone_service.dart';
import '../services/prayer_time_service.dart';

class NextPrayerCard extends StatefulWidget {
  const NextPrayerCard({super.key, required this.next, required this.zone});

  final NextPrayer? next;
  final AppZone zone;

  @override
  State<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<NextPrayerCard> {
  Timer? _timer;
  DateTime _now = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now().toUtc());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final next = widget.next;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: next == null
          ? Text(
              'Seluruh jadwal yang tersedia sudah lewat. Tarik layar ke bawah untuk memuat ulang.',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: scheme.onPrimaryContainer),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sholat berikutnya',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: scheme.onPrimaryContainer),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${next.name.label}  '
                  '${DateTimeUtils.hm(TimezoneService.wallClock(widget.zone, next.at, next.day.utcOffsetMinutes))}'
                  ' ${widget.zone == AppZone.local ? '' : widget.zone.label}',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: scheme.onPrimaryContainer),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  DateTimeUtils.hms(next.remaining(_now)),
                  style: theme.textTheme.displayLarge
                      ?.copyWith(color: scheme.onPrimaryContainer),
                ),
                Text(
                  'lagi',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
    );
  }
}
