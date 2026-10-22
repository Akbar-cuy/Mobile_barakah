// M6 Masjid Terdekat (FR-LBS-09..14)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../worship/services/position_source.dart';
import '../../worship/widgets/city_picker_sheet.dart';
import '../models/mosque.dart';
import '../providers/mosque_provider.dart';
import '../widgets/mosque_map.dart';
import '../widgets/mosque_tile.dart';

class MosqueScreen extends ConsumerStatefulWidget {
  const MosqueScreen({super.key});

  @override
  ConsumerState<MosqueScreen> createState() => _MosqueScreenState();
}

class _MosqueScreenState extends ConsumerState<MosqueScreen> {
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(mosqueControllerProvider.notifier).load();
    });
  }

  Future<void> _route(Mosque m) async {
    final ok = await ref.read(mosqueControllerProvider.notifier).openRoute(m);
    if (!ok && mounted) showAppSnackBar(context, 'Aplikasi peta tidak dapat dibuka.');
  }

  Future<void> _pickCity() async {
    final chosen = await showCityPickerSheet(context);
    if (chosen != null && mounted) {
      ref.read(mosqueControllerProvider.notifier).load(askPermission: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.watch(mosqueControllerProvider);
    final c = ref.read(mosqueControllerProvider.notifier);
    final visible = s.visible;
    final pos = s.position;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Masjid Terdekat'),
        actions: [
          IconButton(
            tooltip: _showMap ? 'Tampilkan daftar' : 'Tampilkan peta',
            icon: Icon(_showMap ? Icons.list : Icons.map_outlined),
            onPressed: pos == null ? null : () => setState(() => _showMap = !_showMap),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, 0),
            child: TextField(
              onChanged: c.setQuery,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari nama atau alamat masjid',
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.sm),
            child: Row(
              children: [
                for (final r in MosqueFilter.radii)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text('${r.toStringAsFixed(0)} km'),
                      selected: s.radiusKm == r,
                      onSelected: (_) => c.setRadius(r),
                    ),
                  ),
                const SizedBox(width: AppSpacing.sm),
                SegmentedButton<MosqueSort>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: MosqueSort.distance, label: Text('Jarak')),
                    ButtonSegment(value: MosqueSort.name, label: Text('Nama')),
                  ],
                  selected: {s.sort},
                  onSelectionChanged: (v) => c.setSort(v.first),
                ),
              ],
            ),
          ),
          if (s.fromCache)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: StatusBanner(
                kind: BannerKind.offline,
                message: 'Offline. Menampilkan hasil pencarian terakhir.',
              ),
            ),
          if (s.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: StatusBanner(kind: BannerKind.error, message: s.error!),
            ),
          Expanded(child: _body(context, theme, s, c, visible)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, ThemeData theme, MosqueState s,
      MosqueController c, List<Mosque> visible) {
    if (s.loading && s.all.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final pos = s.position;
    if (pos == null) return _NoLocation(access: s.access, onRetry: c.load, onCity: _pickCity);
    if (_showMap) {
      return MosqueMap(
        userLat: pos.latitude,
        userLon: pos.longitude,
        mosques: visible,
        selectedId: s.selectedId,
        onSelect: c.select,
      );
    }
    if (visible.isEmpty) {
      return RefreshIndicator(
        onRefresh: c.load,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Center(
                child: Text(
                  s.query.isNotEmpty
                      ? 'Tidak ada masjid yang cocok.'
                      : 'Tidak ada masjid dalam ${s.radiusKm.toStringAsFixed(0)} km. Coba perbesar radius.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: c.load,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.page),
        itemCount: visible.length,
        itemBuilder: (_, i) {
          final m = visible[i];
          return MosqueTile(
            mosque: m,
            selected: m.osmId == s.selectedId,
            onTap: () => c.select(m.osmId),
            onFavorite: () => c.toggleFavorite(m),
            onRoute: () => _route(m),
          );
        },
      ),
    );
  }
}

class _NoLocation extends StatelessWidget {
  const _NoLocation({required this.access, required this.onRetry, required this.onCity});

  final LocationAccess access;
  final Future<void> Function({bool askPermission}) onRetry;
  final VoidCallback onCity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = switch (access) {
      LocationAccess.serviceDisabled => 'GPS mati. Nyalakan GPS atau pilih kota secara manual.',
      LocationAccess.deniedForever => 'Izin lokasi ditolak. Ubah di pengaturan aplikasi atau pilih kota manual.',
      _ => 'Izin lokasi diperlukan untuk mencari masjid terdekat.',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text(text, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: () => onRetry(), child: const Text('Coba lagi')),
            TextButton(onPressed: onCity, child: const Text('Pilih kota manual')),
          ],
        ),
      ),
    );
  }
}
