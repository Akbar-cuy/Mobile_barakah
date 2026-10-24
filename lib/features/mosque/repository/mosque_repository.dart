// M6 Masjid Terdekat (FR-LBS-09, FR-LBS-13, FR-SYNC-01)
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/config/app_config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/outbox_dao.dart';
import '../../../core/database/daos/settings_dao.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/utils/uuid.dart';
import '../models/mosque.dart';

abstract interface class MosqueRepository {
  /// Masjid sekitar titik. Bila server tidak terjangkau memakai hasil terakhir
  /// yang tersimpan (FR-LBS-13). Melempar [ApiException] bila tidak ada cache.
  Future<MosqueResult> nearby({
    required double lat,
    required double lon,
    required double radiusKm,
  });

  Stream<List<Mosque>> watchFavorites();

  /// Mengembalikan status favorit yang baru.
  Future<bool> toggleFavorite(Mosque mosque);
}

class ApiMosqueRepository implements MosqueRepository {
  ApiMosqueRepository({
    required this.api,
    required this.db,
    required this.settings,
    required this.outbox,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final ApiGateway api;
  final AppDatabase db;
  final SettingsDao settings;
  final OutboxDao outbox;
  final DateTime Function() _now;

  static const cacheKey = 'mosque_cache';

  @override
  Future<MosqueResult> nearby({
    required double lat,
    required double lon,
    required double radiusKm,
  }) async {
    if (!lat.isFinite ||
        lat < -90 ||
        lat > 90 ||
        !lon.isFinite ||
        lon < -180 ||
        lon > 180 ||
        !radiusKm.isFinite ||
        radiusKm <= 0 ||
        radiusKm > AppConfig.mosqueMaxRadiusKm) {
      throw const FormatException(
          'Koordinat atau radius pencarian tidak valid.');
    }
    try {
      // Server dapat membatasi radius; permintaan selalu memakai radius terbesar
      // yang dipilih agar mengubah radius ke bawah tidak perlu jaringan.
      final res = await api.request(
        'GET',
        ApiEndpoints.mosquesNearby,
        query: {'lat': lat, 'lng': lon, 'radius': radiusKm},
      );
      final raw = res['items'];
      if (raw is! List) {
        throw const FormatException('Respons masjid tidak valid.');
      }
      final unique = <String, Mosque>{};
      for (final e in raw) {
        try {
          if (e is! Map) continue;
          final mosque = Mosque.fromJson(e.cast<String, dynamic>())
              .withDistanceFrom(lat, lon);
          unique.putIfAbsent(mosque.osmId, () => mosque);
        } catch (_) {
          continue; // entri rusak dilewati
        }
      }
      final items = unique.values.toList(growable: false);
      await _saveCache(lat, lon, radiusKm, items);
      return MosqueResult(items: await _markFavorites(items));
    } on ApiException catch (e) {
      if (!e.isConnectivity &&
          !(e.kind == ApiErrorKind.server &&
              e.code == 'mosque_source_unavailable')) {
        rethrow;
      }
      final cached = await _loadCache(lat, lon);
      if (cached == null) rethrow;
      return MosqueResult(
        items: await _markFavorites(cached.$1),
        fromCache: true,
        cachedAt: cached.$2,
      );
    }
  }

  Future<void> _saveCache(
      double lat, double lon, double radiusKm, List<Mosque> items) {
    return settings.set(
      cacheKey,
      jsonEncode({
        'lat': lat,
        'lon': lon,
        'radius': radiusKm,
        'at': _now().toUtc().toIso8601String(),
        'items': [for (final m in items) m.toJson()],
      }),
      now: _now(),
    );
  }

  /// Cache terakhir dipakai apa adanya; jarak dihitung ulang dari posisi kini.
  Future<(List<Mosque>, DateTime?)?> _loadCache(double lat, double lon) async {
    final raw = await settings.get(cacheKey);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final items = [
        for (final e in m['items'] as List)
          Mosque.fromJson(e.cast<String, dynamic>()).withDistanceFrom(lat, lon),
      ];
      return (items, DateTime.tryParse('${m['at']}'));
    } catch (_) {
      return null;
    }
  }

  Future<List<Mosque>> _markFavorites(List<Mosque> items) async {
    final favs = (await db.select(db.favoriteMosqueTable).get())
        .map((r) => r.osmId)
        .toSet();
    return [
      for (final m in items) m.copyWith(isFavorite: favs.contains(m.osmId))
    ];
  }

  @override
  Stream<List<Mosque>> watchFavorites() {
    return db.select(db.favoriteMosqueTable).watch().map((rows) => [
          for (final r in rows)
            Mosque(
                osmId: r.osmId,
                name: r.name,
                lat: r.lat,
                lon: r.lon,
                isFavorite: true),
        ]);
  }

  @override
  Future<bool> toggleFavorite(Mosque mosque) {
    return db.transaction(() async {
      final existing = await (db.select(db.favoriteMosqueTable)
            ..where((t) => t.osmId.equals(mosque.osmId)))
          .getSingleOrNull();
      if (existing != null) {
        await (db.delete(db.favoriteMosqueTable)
              ..where((t) => t.osmId.equals(mosque.osmId)))
            .go();
        await outbox.enqueue(
          entity: OutboxEntity.favoriteMosque,
          op: OutboxOp.delete,
          payload: jsonEncode({'osm_id': mosque.osmId}),
          now: _now(),
        );
        return false;
      }
      await db.into(db.favoriteMosqueTable).insert(
            FavoriteMosqueTableCompanion.insert(
              id: Uuid4.generate(),
              osmId: mosque.osmId,
              name: mosque.name,
              lat: mosque.lat,
              lon: mosque.lon,
              syncState: const Value(SyncState.pending),
            ),
          );
      await outbox.enqueue(
        entity: OutboxEntity.favoriteMosque,
        op: OutboxOp.create,
        payload: jsonEncode(mosque.toJson()),
        now: _now(),
      );
      return true;
    });
  }
}
