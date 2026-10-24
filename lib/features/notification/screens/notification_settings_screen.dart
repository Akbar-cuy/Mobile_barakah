// M16 Notifikasi (FR-NTF-01..06)
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
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted =
        await ref.read(notificationGatewayProvider).hasPermission();
    if (mounted) setState(() => _granted = granted);
  }

  Future<bool> _ensurePermission() async {
    final granted =
        await ref.read(notificationServiceProvider).ensurePermission();
    if (mounted) setState(() => _granted = granted);
    if (!granted && mounted) {
      showAppSnackBar(
        context,
        'Izin notifikasi ditolak. Aktifkan lewat pengaturan sistem.',
        actionLabel: 'Buka pengaturan',
        onAction: () =>
            ref.read(notificationServiceProvider).openSystemSettings(),
      );
    }
    return granted;
  }

  Future<void> _update(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (error) {
      if (mounted) showAppSnackBar(context, 'Pengaturan gagal disimpan: $error');
    }
  }

  Future<void> _setSlot(PrayerSlot slot, bool enabled) async {
    if (enabled && !await _ensurePermission()) return;
    await _update(() => ref
        .read(notificationPrefsProvider.notifier)
        .setSlot(slot, enabled));
  }

  Future<void> _pickTime(NotificationPrefs prefs) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: prefs.dhikrHour,
        minute: prefs.dhikrMinute,
      ),
    );
    if (time == null || !mounted) return;
    if (prefs.dhikrEnabled && !await _ensurePermission()) return;
    await _update(() => ref
        .read(notificationPrefsProvider.notifier)
        .setDhikrTime(time.hour, time.minute));
  }

  Future<void> _test(NotificationPrefs prefs) async {
    if (!await _ensurePermission()) return;
    setState(() => _busy = true);
    try {
      final service = ref.read(notificationServiceProvider);
      final shown = await service.showTest(
        'Uji notifikasi',
        'Notifikasi Barakah berfungsi.',
        prefs.sound,
      );
      if (!mounted) return;
      if (shown) {
        showAppSnackBar(context, 'Notifikasi uji dikirim. Lihat bilah notifikasi.');
      } else {
        showAppSnackBar(
          context,
          'Notifikasi tidak tampil. Periksa mode Jangan Ganggu dan pengaturan '
          'notifikasi Barakah.',
          actionLabel: 'Buka pengaturan',
          onAction: service.openSystemSettings,
        );
      }
    } on Object catch (error) {
      if (mounted) showAppSnackBar(context, 'Uji notifikasi gagal: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = ref.watch(notificationPrefsProvider);
    final controller = ref.read(notificationPrefsProvider.notifier);

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
                trailing: TextButton(
                  onPressed: _ensurePermission,
                  child: const Text('Izinkan'),
                ),
              ),
            ),
          Text('Waktu sholat', style: theme.textTheme.titleSmall),
          for (final slot in PrayerSlot.values)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(slot.label),
              value: prefs.isOn(slot),
              onChanged: (value) => _setSlot(slot, value),
            ),
          const Divider(height: AppSpacing.xxl),
          Text('Pengingat sebelum adzan', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final minutes in NotificationPrefs.reminderOptions)
                ChoiceChip(
                  label: Text(minutes == 0 ? 'Mati' : '$minutes menit'),
                  selected: prefs.reminderMinutes == minutes,
                  onSelected: (_) => _update(
                    () => controller.setReminder(minutes),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Suara', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<NotificationSound>(
            segments: const [
              ButtonSegment(
                value: NotificationSound.defaultSound,
                icon: Icon(Icons.volume_up),
                label: Text('Bawaan'),
              ),
              ButtonSegment(
                value: NotificationSound.silent,
                icon: Icon(Icons.volume_off),
                label: Text('Senyap'),
              ),
            ],
            selected: {prefs.sound},
            onSelectionChanged: (value) => _update(
              () => controller.setSound(value.first),
            ),
          ),
          const Divider(height: AppSpacing.xxl),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Pengingat dzikir harian'),
            value: prefs.dhikrEnabled,
            onChanged: (enabled) async {
              if (enabled && !await _ensurePermission()) return;
              await _update(() => controller.setDhikr(enabled));
            },
          ),
          if (prefs.dhikrEnabled)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Jam pengingat'),
              trailing: Text(
                '${prefs.dhikrHour.toString().padLeft(2, '0')}.'
                '${prefs.dhikrMinute.toString().padLeft(2, '0')}',
                style: theme.textTheme.titleMedium,
              ),
              onTap: () => _pickTime(prefs),
            ),
          if (AppConfig.enableGeofenceNotification)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ingatkan saat dekat masjid favorit'),
              subtitle: Text(
                'Radius ${AppConfig.geofenceRadiusMeters.round()} m, '
                'dicek saat aplikasi dibuka.',
              ),
              value: prefs.nearMosque,
              onChanged: (value) =>
                  _update(() => controller.setNearMosque(value)),
            ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _test(prefs),
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Uji notifikasi'),
          ),
        ],
      ),
    );
  }
}
