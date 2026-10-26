// M7 Arah Kiblat (FR-QBL, AC-QBL-01 sampai AC-QBL-05)
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../worship/services/position_source.dart';
import '../../worship/widgets/city_picker_sheet.dart';
import '../providers/qibla_provider.dart';
import '../services/compass_math.dart';
import '../services/qibla_sensor_service.dart';
import '../widgets/calibration_banner.dart';
import '../widgets/compass_dial.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen>
    with WidgetsBindingObserver {
  late final QiblaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(qiblaControllerProvider.notifier);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Sensor hanya hidup saat layar tampil di depan (FR-QBL-06, NFR-12).
    if (state == AppLifecycleState.resumed) {
      unawaited(_controller.start(askPermission: false));
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      unawaited(_controller.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller.stop());
    super.dispose();
  }

  Future<void> _pickCity() async {
    final city = await showCityPickerSheet(context);
    if (city != null && mounted) await _controller.retry(askPermission: false);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(qiblaControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Arah Kiblat')),
      body: SafeArea(child: _body(context, s)),
    );
  }

  Widget _body(BuildContext context, QiblaState s) {
    if (s.location == QiblaLocationStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final result = s.result;
    if (result == null) return _noLocation(context, s);

    final theme = Theme.of(context);
    final status = theme.extension<AppStatusColors>() ?? AppStatusColors.light;
    final unavailable = s.sensor == SensorHealth.unavailable;
    final reading = s.reading;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Text(
          'Kiblat: ${result.bearing.toStringAsFixed(0)}° ${result.compassName}',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "Jarak ke Ka'bah: ${Formatters.number(result.distanceKm)} km",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        if (s.position?.isManual ?? false)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              'Lokasi: ${s.position?.label ?? 'kota pilihan'}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Center(
            child: CompassDial(
              headingDegrees: unavailable ? 0 : s.dialAngle,
              qiblaBearing: result.bearing,
              aligned: s.aligned,
              dimmed: unavailable || s.reading == null,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (unavailable)
          StatusBanner(
            kind: BannerKind.info,
            message: 'Sensor kompas tidak tersedia di perangkat ini. Arah kiblat '
                'ditampilkan sebagai sudut statis: ${result.bearing.toStringAsFixed(0)}° '
                'dari utara. Cocokkan dengan kompas lain atau peta.',
          )
        else ...[
          _AlignmentStatus(state: s, success: status.success),
          const SizedBox(height: AppSpacing.sm),
          if (reading != null)
            Text(
              'Heading: ${reading.heading.toStringAsFixed(0)}°',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (!unavailable && reading != null) ...[
          if (reading.accuracy.needsCalibration)
            CalibrationBanner(interference: reading.interference),
          const SizedBox(height: AppSpacing.md),
          _SensorRow(accuracy: reading.accuracy, hasGyro: reading.hasGyro),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          'Toleransi menghadap kiblat ±${AppConfig.qiblaToleranceDegrees.toStringAsFixed(0)}°. '
          'Arah dihitung terhadap utara sejati, sedangkan kompas ponsel menunjuk utara '
          'magnetik (selisih kecil di Indonesia).',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _noLocation(BuildContext context, QiblaState s) {
    final theme = Theme.of(context);
    final (String text, String action, VoidCallback onAction) = switch (s.location) {
      QiblaLocationStatus.denied => (
          'Izin lokasi diperlukan untuk menghitung arah kiblat dari posisi Anda.',
          'Izinkan lokasi',
          () => _controller.retry(),
        ),
      QiblaLocationStatus.deniedForever => (
          'Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengizinkannya, '
              'atau pilih kota secara manual.',
          'Buka pengaturan',
          () => ref.read(positionSourceProvider).openAppSettings(),
        ),
      QiblaLocationStatus.serviceDisabled => (
          'GPS perangkat nonaktif. Aktifkan lokasi, atau pilih kota secara manual.',
          'Buka pengaturan lokasi',
          () => ref.read(positionSourceProvider).openLocationSettings(),
        ),
      _ => (
          'Lokasi belum didapat. Coba lagi di tempat terbuka, atau pilih kota secara manual.',
          'Coba lagi',
          () => _controller.retry(),
        ),
    };
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        const SizedBox(height: AppSpacing.xl),
        Icon(Icons.location_off_outlined, size: 56, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: AppSpacing.lg),
        Text(text, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(onPressed: onAction, child: Text(action)),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(onPressed: _pickCity, child: const Text('Pilih kota manual')),
      ],
    );
  }
}

class _AlignmentStatus extends StatelessWidget {
  const _AlignmentStatus({required this.state, required this.success});

  final QiblaState state;
  final Color success;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diff = state.difference;
    if (diff == null || state.reading == null) {
      return Text(
        'Menunggu sensor...',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium,
      );
    }
    final abs = diff.abs();
    final IconData icon;
    final String text;
    final Color color;
    if (state.aligned) {
      icon = Icons.check_circle;
      text = 'Menghadap kiblat';
      color = success;
    } else if (abs <= 10) {
      icon = Icons.adjust;
      text = 'Hampir tepat: selisih ${abs.toStringAsFixed(0)}°';
      color = theme.colorScheme.secondary;
    } else {
      icon = diff > 0 ? Icons.rotate_right : Icons.rotate_left;
      text = 'Putar ke ${diff > 0 ? 'kanan' : 'kiri'} ${abs.toStringAsFixed(0)}°';
      color = theme.colorScheme.onSurfaceVariant;
    }
    return Semantics(
      liveRegion: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: theme.textTheme.titleMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _SensorRow extends StatelessWidget {
  const _SensorRow({required this.accuracy, required this.hasGyro});

  final CompassAccuracy accuracy;
  final bool hasGyro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasGyro ? 'Sensor: magnetometer + gyroscope' : 'Sensor: magnetometer',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Akurasi: ${accuracy.label}',
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
