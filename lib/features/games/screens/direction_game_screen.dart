import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/utils/geo_utils.dart';
import '../../qibla/services/qibla_sensor_service.dart';
import '../providers/direction_game_provider.dart';

class DirectionGameScreen extends ConsumerStatefulWidget {
  const DirectionGameScreen({super.key});

  @override
  ConsumerState<DirectionGameScreen> createState() =>
      _DirectionGameScreenState();
}

class _DirectionGameScreenState extends ConsumerState<DirectionGameScreen>
    with WidgetsBindingObserver {
  late final DirectionGameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(directionGameProvider.notifier);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.start();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(directionGameProvider);
    final controller = ref.read(directionGameProvider.notifier);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Arah')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              children: [
                if (state.phase == DirectionGamePhase.loading) ...[
                  const SizedBox(height: 80),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 20),
                  const Text(
                    'Menyiapkan lokasi dan sensor kompas…',
                    textAlign: TextAlign.center,
                  ),
                ] else if (state.phase == DirectionGamePhase.playing) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Target ${state.targetIndex + 1}/${state.targets.length}'),
                      Text('Skor ${state.score}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (state.targetIndex + 1) / state.targets.length,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Hadapkan ponsel ke',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    state.target?.label ?? '—',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                      child: state.heading == null || state.errorDegrees == null
                          ? const Icon(Icons.explore_outlined, size: 90)
                          : Transform.rotate(
                              angle: GeoUtils.angleDifference(
                                    state.target!.bearing,
                                    state.heading!,
                                  ) *
                                  3.141592653589793 /
                                  180,
                              child: Icon(
                                Icons.navigation,
                                size: 94,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.heading == null
                        ? 'Menunggu pembacaan kompas…'
                        : 'Selisih ${state.errorDegrees!.toStringAsFixed(1)}° • '
                            '${state.heading!.toStringAsFixed(0)}°',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sisa waktu ${state.remainingSeconds} detik',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: state.holdProgress),
                  const SizedBox(height: 8),
                  Text(
                    state.holdProgress > 0
                        ? 'Pertahankan arah… ${(state.holdProgress * 2).toStringAsFixed(1)} / 2 detik'
                        : 'Tahan dalam toleransi 5° selama 2 detik',
                    textAlign: TextAlign.center,
                  ),
                ] else if (state.phase == DirectionGamePhase.finished) ...[
                  const Icon(Icons.emoji_events_outlined, size: 72),
                  const SizedBox(height: 12),
                  Text('Permainan selesai',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall),
                  Text(
                      'Berhasil ${state.successes}/${state.targets.length} target',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text('Skor ${state.score}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium),
                  Text('Skor tertinggi ${state.bestScore}',
                      textAlign: TextAlign.center),
                  if (state.message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(state.message!, textAlign: TextAlign.center),
                    ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: controller.start,
                    icon: const Icon(Icons.replay),
                    label: const Text('Main lagi'),
                  ),
                ] else ...[
                  Icon(
                    state.sensorHealth == SensorHealth.unavailable
                        ? Icons.sensors_off
                        : Icons.location_off_outlined,
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message ?? 'Permainan siap dimulai.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: controller.start,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba lagi'),
                  ),
                  TextButton(
                    onPressed: () => context.push(RouteNames.quiz),
                    child: const Text('Buka Kuis Islami'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
