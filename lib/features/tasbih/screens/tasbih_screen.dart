// M8 Tasbih Digital (FR-TSB-01..04)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/status_banner.dart';
import '../providers/tasbih_provider.dart';
import '../services/shake_detector.dart';
import '../services/tasbih_counter.dart';
import '../widgets/counter_ring.dart';

class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen>
    with WidgetsBindingObserver {
  late final TasbihController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = ref.read(tasbihControllerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.activate());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.paused || s == AppLifecycleState.hidden) {
      _controller.deactivate();
    } else if (s == AppLifecycleState.resumed) {
      _controller.activate();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.deactivate();
    super.dispose();
  }

  Future<void> _customTarget() async {
    final formKey = GlobalKey<FormState>();
    final field = TextEditingController();
    const targetHint = '${TasbihLimits.minTarget} - ${TasbihLimits.maxTarget}';
    final value = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Target kustom'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: field,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: targetHint,
            ),
            validator: (v) {
              final n = int.tryParse((v ?? '').trim());
              if (n == null || !TasbihLimits.isValidTarget(n)) {
                return 'Isi angka ${TasbihLimits.minTarget}-${TasbihLimits.maxTarget}';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, int.parse(field.text.trim()));
              }
            },
            child: const Text('Pakai'),
          ),
        ],
      ),
    );
    field.dispose();
    if (value != null) await _controller.setTarget(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.watch(tasbihControllerProvider);
    final suggestion = ref.watch(tasbihSuggestionProvider).value;
    final isPreset = TasbihSuggestion.presets.contains(s.target);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih Digital'),
        actions: [
          IconButton(
            tooltip: 'Riwayat',
            icon: const Icon(Icons.history),
            onPressed: () => context.push(RouteNames.tasbihHistory),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          if (!s.sensorAvailable)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: StatusBanner(
                kind: BannerKind.warning,
                message: 'Sensor gerak tidak tersedia. Dipindah ke mode ketuk.',
              ),
            ),
          Center(
            child: Semantics(
              label: 'Hitungan ${s.count} dari ${s.target}. Ketuk untuk menambah.',
              button: true,
              child: GestureDetector(
                onTap: s.mode == TasbihMode.tap ? _controller.tap : null,
                child: CounterRing(
                  progress: s.progress,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${s.count}',
                          style: theme.textTheme.displayLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text('dari ${s.target}', style: theme.textTheme.bodyMedium),
                      if (s.isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text('Target tercapai',
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(color: theme.colorScheme.tertiary)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              s.mode == TasbihMode.shake
                  ? 'Goyangkan ponsel untuk menghitung'
                  : 'Ketuk lingkaran untuk menghitung',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              for (final t in TasbihSuggestion.presets)
                ChoiceChip(
                  label: Text('$t'),
                  selected: s.target == t,
                  onSelected: (_) => _controller.setTarget(t),
                ),
              ChoiceChip(
                label: Text(isPreset ? 'Kustom' : 'Kustom (${s.target})'),
                selected: !isPreset,
                onSelected: (_) => _customTarget(),
              ),
            ],
          ),
          if (suggestion != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Center(
                child: Text(
                  'Saran target: $suggestion (rata-rata 7 hari terakhir)',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.tonalIcon(
            onPressed: s.count == 0 ? null : _controller.reset,
            icon: const Icon(Icons.restart_alt),
            label: Text(s.isCompleted ? 'Mulai lagi' : 'Reset'),
          ),
          const Divider(height: AppSpacing.xxl),
          SegmentedButton<TasbihMode>(
            segments: const [
              ButtonSegment(
                  value: TasbihMode.shake, icon: Icon(Icons.vibration), label: Text('Goyang')),
              ButtonSegment(
                  value: TasbihMode.tap, icon: Icon(Icons.touch_app), label: Text('Ketuk')),
            ],
            selected: {s.mode},
            onSelectionChanged: (v) => _controller.setMode(v.first),
          ),
          if (s.mode == TasbihMode.shake) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Sensitivitas', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            SegmentedButton<ShakeSensitivity>(
              segments: [
                for (final v in ShakeSensitivity.values)
                  ButtonSegment(value: v, label: Text(v.label)),
              ],
              selected: {s.sensitivity},
              onSelectionChanged: (v) => _controller.setSensitivity(v.first),
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Getar saat menghitung'),
            value: s.vibrate,
            onChanged: _controller.setVibrate,
          ),
        ],
      ),
    );
  }
}
