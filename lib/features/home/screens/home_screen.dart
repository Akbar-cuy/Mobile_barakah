// M4 Beranda dan Jadwal Sholat (FR-LBS-01 sampai FR-LBS-05)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_box.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../auth/providers/session_provider.dart';
import '../../converter/services/timezone_service.dart';
import '../models/prayer_times.dart';
import '../providers/home_provider.dart';
import '../services/location_service.dart';
import '../services/prayer_time_service.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/prayer_row.dart';
import '../widgets/summary_cards.dart';
import '../widgets/zone_chips.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static String _issueText(LocationIssue issue) => switch (issue) {
        LocationIssue.serviceOff =>
          'Layanan lokasi mati. Jadwal memakai lokasi terakhir.',
        LocationIssue.denied =>
          'Izin lokasi ditolak. Jadwal memakai lokasi terakhir.',
        LocationIssue.deniedForever =>
          'Izin lokasi ditolak permanen. Aktifkan dari pengaturan perangkat.',
        LocationIssue.failed =>
          'Lokasi belum didapat. Jadwal memakai lokasi terakhir.',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);
    final zone = ref.watch(zoneProvider);
    final user = ref.watch(sessionProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            user == null ? 'Beranda' : 'Assalamualaikum, ${user.firstName}'),
        actions: [
          IconButton(
            tooltip: 'Pengingat adzan',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(RouteNames.notificationSettings),
          ),
        ],
      ),
      body: home.when(
        loading: () => const _HomeSkeleton(),
        error: (_, __) => EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Jadwal sholat belum bisa dimuat',
          message: 'Periksa koneksi internet, lalu coba lagi.',
          actionLabel: 'Coba lagi',
          onAction: () => ref.invalidate(homeProvider),
        ),
        data: (state) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(homeProvider);
            await ref.read(homeProvider.future);
          },
          child: _HomeContent(state: state, zone: zone),
        ),
      ),
    );
  }

  static String dateLabel(DateTime d) =>
      '${_days[d.weekday - 1]}, ${DateTimeUtils.formatDate(d)}';
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state, required this.zone});

  final HomeState state;
  final AppZone zone;

  @override
  Widget build(BuildContext context) {
    final nowUtc = DateTime.now().toUtc();
    final next = PrayerCalculator.next(state.days, nowUtc);
    final today = PrayerCalculator.today(state.days, nowUtc);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Text(
          HomeScreen.dateLabel(DateTime.now()),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.locationIssue != null) ...[
          StatusBanner(
            message: HomeScreen._issueText(state.locationIssue!),
            kind: BannerKind.warning,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (state.offline) ...[
          const StatusBanner(
            message: 'Tidak ada koneksi. Jadwal diambil dari data tersimpan.',
            kind: BannerKind.offline,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        NextPrayerCard(next: next, zone: zone),
        const SizedBox(height: AppSpacing.lg),
        SummaryCards(location: state.location),
        const SizedBox(height: AppSpacing.xl),
        Text('Zona waktu', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        const ZoneChips(),
        const SizedBox(height: AppSpacing.lg),
        if (today != null)
          for (final prayer in PrayerName.values) ...[
            PrayerRow(
              name: prayer.label,
              time: DateTimeUtils.hm(
                TimezoneService.wallClock(
                  zone,
                  today.instant(prayer),
                  today.utcOffsetMinutes,
                ),
              ),
              highlighted: next != null &&
                  next.day.date == today.date &&
                  next.name == prayer,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        const SkeletonBox(height: 160, radius: AppRadius.large),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonBox(height: 80),
        const SizedBox(height: AppSpacing.xl),
        for (var i = 0; i < 6; i++) ...[
          const SkeletonBox(height: 52),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
