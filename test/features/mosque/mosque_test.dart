import 'package:barakah/features/mosque/models/mosque.dart';
import 'package:flutter_test/flutter_test.dart';

Mosque _m(String id, String name, double meters, {String? address}) => Mosque(
      osmId: id,
      name: name,
      lat: 0,
      lon: 0,
      address: address,
      distanceM: meters,
    );

void main() {
  group('Mosque.fromJson', () {
    test('membaca lon atau lng dan jarak meter atau kilometer', () {
      final a = Mosque.fromJson({'osm_id': 1, 'name': 'A', 'lat': -6.2, 'lng': 106.8, 'distance_m': 250});
      final b = Mosque.fromJson({'id': 'x', 'name': 'B', 'lat': '1.5', 'lon': 2, 'distance_km': 1.2});
      expect(a.osmId, '1');
      expect(a.lon, 106.8);
      expect(a.distanceM, 250);
      expect(b.lat, 1.5);
      expect(b.distanceM, closeTo(1200, 1e-9));
    });

    test('nama kosong diganti, koordinat hilang ditolak', () {
      expect(Mosque.fromJson({'id': 1, 'name': ' ', 'lat': 0, 'lon': 0}).name, 'Masjid tanpa nama');
      expect(() => Mosque.fromJson({'id': 1, 'name': 'A'}), throwsFormatException);
    });
  });

  group('Mosque.distanceLabel', () {
    test('meter dan kilometer', () {
      expect(_m('1', 'A', 480.4).distanceLabel, '480 m');
      expect(_m('1', 'A', 1530).distanceLabel, '1.5 km');
    });
  });

  group('MosqueFilter.apply', () {
    final all = [
      _m('1', 'Masjid Raya', 3000, address: 'Jl. Merdeka'),
      _m('2', 'Al-Ikhlas', 400),
      _m('3', 'Baiturrahman', 1500, address: 'Jl. Sudirman'),
      _m('4', 'Jauh', 9000),
    ];

    test('radius menyaring dan urut jarak', () {
      final r = MosqueFilter.apply(all, radiusKm: 2);
      expect([for (final m in r) m.osmId], ['2', '3']);
    });

    test('urut nama tanpa membedakan huruf besar', () {
      final r = MosqueFilter.apply(all, radiusKm: 10, sort: MosqueSort.name);
      expect([for (final m in r) m.name], ['Al-Ikhlas', 'Baiturrahman', 'Jauh', 'Masjid Raya']);
    });

    test('pencarian nama atau alamat', () {
      expect([for (final m in MosqueFilter.apply(all, radiusKm: 10, query: 'sudirman')) m.osmId], ['3']);
      expect([for (final m in MosqueFilter.apply(all, radiusKm: 10, query: 'IKHLAS')) m.osmId], ['2']);
    });

    test('tanpa jarak tidak tersaring oleh radius dan diurut terakhir', () {
      final r = MosqueFilter.apply([
        const Mosque(osmId: 'n', name: 'N', lat: 0, lon: 0),
        _m('1', 'A', 100),
      ], radiusKm: 1);
      expect([for (final m in r) m.osmId], ['1', 'n']);
    });
  });
}
