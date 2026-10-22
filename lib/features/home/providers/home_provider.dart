// M4 Beranda dan Jadwal Sholat
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../converter/services/timezone_service.dart';
import '../models/prayer_times.dart';
import '../repository/prayer_repository.dart';
import '../services/location_service.dart';
import '../services/prayer_time_service.dart';

final prayerTimeSourceProvider =
    Provider<PrayerTimeSource>((ref) => AladhanPrayerTimeService());

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepository(
    dao: ref.watch(prayerCacheDaoProvider),
    source: ref.watch(prayerTimeSourceProvider),
  );
});

final locationServiceProvider =
    Provider<LocationService>((ref) => GeolocatorLocationService());

final locationStoreProvider =
    Provider<LocationStore>((ref) => LocationStore(ref.watch(settingsDaoProvider)));

class HomeState {
  const HomeState({
    required this.location,
    required this.days,
    this.offline = false,
    this.locationIssue,
  });

  final GeoPoint location;
  final List<PrayerTimes> days;

  /// Jadwal berasal dari cache karena jaringan gagal.
  final bool offline;

  /// Alasan lokasi perangkat tidak dipakai (izin ditolak, layanan mati).
  final LocationIssue? locationIssue;
}

class HomeController extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final store = ref.read(locationStoreProvider);
    GeoPoint point;
    LocationIssue? issue;
    try {
      point = await ref.read(locationServiceProvider).current();
      await store.save(point);
    } on LocationException catch (e) {
      issue = e.issue;
      point = await store.load() ?? GeoPoint.defaultPoint;
    }
    final result = await ref.read(prayerRepositoryProvider).load(point);
    return HomeState(
      location: point,
      days: result.days,
      offline: result.offline,
      locationIssue: issue,
    );
  }
}

final homeProvider =
    AsyncNotifierProvider<HomeController, HomeState>(HomeController.new);

class ZoneNotifier extends Notifier<AppZone> {
  @override
  AppZone build() => AppZone.local;

  void select(AppZone zone) => state = zone;
}

final zoneProvider = NotifierProvider<ZoneNotifier, AppZone>(ZoneNotifier.new);
