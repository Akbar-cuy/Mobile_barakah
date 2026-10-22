// M16 Notifikasi (FR-NTF-02..06)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../providers/notification_provider.dart';
import '../services/notification_prefs.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _State();
}

class _State extends ConsumerState<NotificationSettingsScreen> {
  bool? _granted;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final ok = await ref.read(notificationGatewayProvider).hasPermission();
    if (mounted) setState(() => _granted = ok);
  }

  Future<void> _askPermission() async {
    final ok = await ref.read(notificationServiceProvider).ensurePermission();
    if (!mounted) return;
    setState(() => _granted = ok);
    if (!ok) {
      showAppSnackBar(context, 'Izin notifikasi ditolak. Aktifkan lewat pengaturan sistem.');
    }
  }

  Future<void> _pickTime(NotificationPrefs p) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: p.dhikrHour, minute: p.dhikrMinute),
    );
    if (t != null) {
      await ref.read(notificationPrefsProvider.notifier).setDhikrTime(t.hour, t.minute);
    }
  }

  Future<void> _test(NotificationPrefs p) async {
    if (!await ref.read(notificationServiceProvider).ensurePermission()) {
      if (mounted) setState(() => _granted = false);
      return;
    }
    await ref
        .read(notificationServiceProvider)
        .showNow('Uji notifikasi', 'Notifikasi Barakah berfungsi.', p.sound);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = ref.watch(notificationPrefsProvider);
    final c = ref.read(notificationPrefsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengingat Adzan')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          if (_granted == false)
            Card(
              elevation: 0,
              color: theme.colorScheme.errorContainer,
              child: ListTile(
                leading: const Icon(Icons.notifications_off_outlined),
                title: const Text('Izin notifikasi belum diberikan'),
                subtitle: const Text('Pengingat tidak akan tampil tanpa izin.'),
                trailing: TextButton(onPressed: _askPermission, child: const Text('Izinkan')),
              ),
            ),
          Text('Waktu sholat', style: theme.textTheme.titleSmall),
          for (final slot in PrayerSlot.values)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(slot.label),
              value: p.isOn(slot),
              onChanged: (v) => c.setSlot(slot, v),
            ),
          const Divider(height: AppSpacing.xxl),
          Text('Pengingat sebelum adzan', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final m in NotificationPrefs.reminderOptions)
                ChoiceChip(
                  label: Text(m == 0 ? 'Mati' : '$m menit'),
                  selected: p.reminderMinutes == m,
                  onSelected: (_) => c.setReminder(m),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Suara', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<NotificationSound>(
            segments: const [
              ButtonSegment(value: NotificationSound.defaultSound, icon: Icon(Icons.volume_up), label: Text('Bawaan')),
              ButtonSegment(value: NotificationSound.silent, icon: Icon(Icons.volume_off), label: Text('Senyap')),
            ],
            selected: {p.sound},
            onSelectionChanged: (v) => c.setSound(v.first),
          ),
          const Divider(height: AppSpacing.xxl),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Pengingat dzikir harian'),
            value: p.dhikrEnabled,
            onChanged: c.setDhikr,
          ),
          if (p.dhikrEnabled)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Jam pengingat'),
              trailing: Text(
                '${p.dhikrHour.toString().padLeft(2, '0')}.${p.dhikrMinute.toString().padLeft(2, '0')}',
                style: theme.textTheme.titleMedium,
              ),
              onTap: () => _pickTime(p),
            ),
          if (AppConfig.enableGeofenceNotification)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ingatkan saat dekat masjid favorit'),
              subtitle: Text('Radius ${AppConfig.geofenceRadiusMeters.round()} m, dicek saat aplikasi dibuka.'),
              value: p.nearMosque,
              onChanged: c.setNearMosque,
            ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => _test(p),
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Uji notifikasi'),
          ),
        ],
      ),
    );
  }
}
