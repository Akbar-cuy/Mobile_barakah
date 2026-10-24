// M6 Masjid Terdekat (FR-LBS-09..14)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../worship/services/position_source.dart';
import '../models/mosque.dart';
import '../repository/mosque_repository.dart';

final mosqueRepositoryProvider = Provider<MosqueRepository>((ref) {
  return ApiMosqueRepository(
    api: ref.watch(apiGatewayProvider),
    db: ref.watch(appDatabaseProvider),
    settings: ref.watch(settingsDaoProvider),
    outbox: ref.watch(outboxDaoProvider),
  );
});

final favoriteMosquesProvider = StreamProvider<List<Mosque>>(
  (ref) => ref.watch(mosqueRepositoryProvider).watchFavorites(),
);

class MosqueState {
  const MosqueState({
    this.loading = false,
    this.all = const [],
    this.position,
    this.access = LocationAccess.granted,
    this.radiusKm = 2,
    this.query = '',
    this.sort = MosqueSort.distance,
    this.fromCache = false,
    this.error,
    this.selectedId,
  });

  final bool loading;
  final List<Mosque> all;
  final GeoPosition? position;

  /// Alasan tidak ada posisi (izin ditolak, GPS mati).
  final LocationAccess access;
  final double radiusKm;
  final String query;
  final MosqueSort sort;
  final bool fromCache;
  final String? error;
  final String? selectedId;

  List<Mosque> get visible =>
      MosqueFilter.apply(all, radiusKm: radiusKm, query: query, sort: sort);

  bool get needsLocation => position == null && !loading;

  MosqueState copyWith({
    bool? loading,
    List<Mosque>? all,
    GeoPosition? position,
    LocationAccess? access,
    double? radiusKm,
    String? query,
    MosqueSort? sort,
    bool? fromCache,
    String? error,
    String? selectedId,
    bool clearError = false,
    bool clearSelected = false,
    bool clearPosition = false,
  }) {
    return MosqueState(
      loading: loading ?? this.loading,
      all: all ?? this.all,
      position: clearPosition ? null : (position ?? this.position),
      access: access ?? this.access,
      radiusKm: radiusKm ?? this.radiusKm,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      fromCache: fromCache ?? this.fromCache,
      error: clearError ? null : (error ?? this.error),
      selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
    );
  }
}

class MosqueController extends Notifier<MosqueState> {
  bool _loadInProgress = false;

  @override
  MosqueState build() => const MosqueState();

  /// Mencari posisi lalu memuat masjid. Radius yang dikirim ke server selalu
  /// yang terbesar sehingga mengecilkan radius tidak butuh permintaan baru.
  Future<void> load({bool askPermission = true}) async {
    if (_loadInProgress) return;
    _loadInProgress = true;
    state = state.copyWith(loading: true, clearError: true);
    GeoPosition? resolvedPosition;
    try {
      final outcome = await ref
          .read(locationResolverProvider)
          .resolve(askPermission: askPermission);
      final pos = outcome.position;
      resolvedPosition = pos;
      if (pos == null) {
        state = state.copyWith(
          loading: false,
          access: outcome.access,
          clearPosition: true,
          all: const [],
        );
        return;
      }
      state = state.copyWith(position: pos, access: LocationAccess.granted);
      final res = await ref.read(mosqueRepositoryProvider).nearby(
            lat: pos.latitude,
            lon: pos.longitude,
            radiusKm: MosqueFilter.radii.last,
          );
      state = state.copyWith(
          loading: false, all: res.items, fromCache: res.fromCache);
    } on ApiException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.isConnectivity
            ? 'Tidak ada koneksi dan belum ada data masjid tersimpan.'
            : e.message,
      );
    } catch (_) {
      state = state.copyWith(
        loading: false,
        clearPosition: resolvedPosition == null,
        all: resolvedPosition == null ? const [] : null,
        error:
            'Lokasi atau data masjid gagal dimuat. Periksa izin dan koneksi lalu coba lagi.',
      );
    } finally {
      _loadInProgress = false;
    }
  }

  Future<void> openAppSettings() =>
      ref.read(positionSourceProvider).openAppSettings();

  Future<void> openLocationSettings() =>
      ref.read(positionSourceProvider).openLocationSettings();

  void setRadius(double km) => state = state.copyWith(radiusKm: km);
  void setQuery(String q) => state = state.copyWith(query: q);
  void setSort(MosqueSort s) => state = state.copyWith(sort: s);
  void select(String? osmId) => osmId == null
      ? state = state.copyWith(clearSelected: true)
      : state = state.copyWith(selectedId: osmId);

  Future<void> toggleFavorite(Mosque m) async {
    final now = await ref.read(mosqueRepositoryProvider).toggleFavorite(m);
    state = state.copyWith(
      all: [
        for (final x in state.all)
          x.osmId == m.osmId ? x.copyWith(isFavorite: now) : x
      ],
    );
  }

  /// Membuka rute di aplikasi peta (FR-LBS-12). Mengembalikan false bila gagal.
  Future<bool> openRoute(Mosque m) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${m.lat},${m.lon}&travelmode=driving',
    );
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

final mosqueControllerProvider =
    NotifierProvider<MosqueController, MosqueState>(MosqueController.new);
