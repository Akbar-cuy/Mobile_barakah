// M14 Notifikasi Adzan (FR-NTF-01, FR-NTF-03). Pengaturan pengingat adzan.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../home/models/prayer_times.dart';
import '../providers/notification_provider.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings next,
  ) async {
    final permitted =
        await ref.read(notificationSettingsProvider.notifier).updateSettings(next);
    if (!permitted && context.mounted) {
      showAppSnackBar(
        context,
        'Izin notifikasi belum diberikan. Aktifkan dari pengaturan perangkat.',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengingat Adzan')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Pengaturan gagal dimuat.')),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            const StatusBanner(
              message:
                  'Pengingat dijadwalkan dari jadwal sholat 7 hari ke depan dan diperbarui setiap Beranda dibuka.',
            ),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile(
              title: const Text('Aktifkan pengingat adzan'),
              value: settings.enabled,
              onChanged: (v) => _save(context, ref, settings.copyWith(enabled: v)),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text('Sholat yang diingatkan',
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            for (final prayer in PrayerName.obligatory)
              CheckboxListTile(
                title: Text(prayer.label),
                value: settings.prayers.contains(prayer),
                onChanged: settings.enabled
                    ? (v) {
                        final next = {...settings.prayers};
                        v == true ? next.add(prayer) : next.remove(prayer);
                        _save(context, ref, settings.copyWith(prayers: next));
                      }
                    : null,
              ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text('Waktu pengingat',
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            SegmentedButton<int>(
              segments: [
                for (final m in NotificationSettings.minutesChoices)
                  ButtonSegment(value: m, label: Text(m == 0 ? 'Tepat waktu' : '$m mnt')),
              ],
              selected: {settings.minutesBefore},
              onSelectionChanged: settings.enabled
                  ? (s) => _save(context, ref, settings.copyWith(minutesBefore: s.first))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
