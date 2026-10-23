// M5 Pusat Ibadah (FR-SRC-04), M4 (FR-LBS-05). Pilih kota manual saat izin
// lokasi ditolak atau GPS mati.
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../services/manual_city.dart';
import '../services/position_source.dart';

/// Kota besar Indonesia yang tersedia tanpa jaringan.
const List<ManualCity> kBuiltInCities = [
  ManualCity(name: 'Jakarta', latitude: -6.2088, longitude: 106.8456),
  ManualCity(name: 'Bandung', latitude: -6.9175, longitude: 107.6191),
  ManualCity(name: 'Semarang', latitude: -6.9667, longitude: 110.4167),
  ManualCity(name: 'Yogyakarta', latitude: -7.7956, longitude: 110.3695),
  ManualCity(name: 'Surabaya', latitude: -7.2575, longitude: 112.7521),
  ManualCity(name: 'Malang', latitude: -7.9666, longitude: 112.6326),
  ManualCity(name: 'Medan', latitude: 3.5952, longitude: 98.6722),
  ManualCity(name: 'Palembang', latitude: -2.9761, longitude: 104.7754),
  ManualCity(name: 'Pekanbaru', latitude: 0.5071, longitude: 101.4478),
  ManualCity(name: 'Padang', latitude: -0.9471, longitude: 100.4172),
  ManualCity(name: 'Banda Aceh', latitude: 5.5483, longitude: 95.3238),
  ManualCity(name: 'Bandar Lampung', latitude: -5.4294, longitude: 105.2610),
  ManualCity(name: 'Pontianak', latitude: -0.0263, longitude: 109.3425),
  ManualCity(name: 'Banjarmasin', latitude: -3.3186, longitude: 114.5944),
  ManualCity(name: 'Balikpapan', latitude: -1.2379, longitude: 116.8529),
  ManualCity(name: 'Makassar', latitude: -5.1477, longitude: 119.4327),
  ManualCity(name: 'Manado', latitude: 1.4748, longitude: 124.8421),
  ManualCity(name: 'Denpasar', latitude: -8.6705, longitude: 115.2126),
  ManualCity(name: 'Mataram', latitude: -8.5833, longitude: 116.1167),
  ManualCity(name: 'Ambon', latitude: -3.6954, longitude: 128.1814),
  ManualCity(name: 'Jayapura', latitude: -2.5337, longitude: 140.7181),
];

/// Pencarian nama kota lewat Nominatim (OpenStreetMap).
abstract interface class CityGeocoder {
  Future<List<ManualCity>> search(String query);
}

class NominatimGeocoder implements CityGeocoder {
  NominatimGeocoder({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://nominatim.openstreetmap.org',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              // Kebijakan Nominatim mewajibkan User-Agent yang mengenali aplikasi.
              headers: {'User-Agent': 'BarakahApp/1.0 (com.example.barakah)'},
            ));

  final Dio _dio;

  @override
  Future<List<ManualCity>> search(String query) async {
    final res = await _dio.get<List<dynamic>>('/search', queryParameters: {
      'q': query,
      'format': 'jsonv2',
      'limit': 8,
      'countrycodes': 'id',
      'addressdetails': 0,
    });
    final out = <ManualCity>[];
    for (final e in res.data ?? const []) {
      final m = (e as Map).cast<String, dynamic>();
      final lat = double.tryParse('${m['lat']}');
      final lon = double.tryParse('${m['lon']}');
      if (lat == null || lon == null) continue;
      final name = (m['display_name'] ?? m['name'] ?? '').toString();
      if (name.isEmpty) continue;
      out.add(ManualCity(name: name, latitude: lat, longitude: lon));
    }
    return out;
  }
}

final cityGeocoderProvider = Provider<CityGeocoder>((ref) => NominatimGeocoder());

/// Menampilkan pemilih kota. Mengembalikan kota terpilih (sudah disimpan),
/// atau null bila ditutup tanpa memilih.
Future<ManualCity?> showCityPickerSheet(BuildContext context) {
  return showModalBottomSheet<ManualCity>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _CityPicker(),
  );
}

class _CityPicker extends ConsumerStatefulWidget {
  const _CityPicker();

  @override
  ConsumerState<_CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends ConsumerState<_CityPicker> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List<ManualCity> _remote = const [];
  bool _searching = false;
  bool _offline = false;
  int _token = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  List<ManualCity> get _local {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return kBuiltInCities;
    return kBuiltInCities.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  void _onChanged(String v) {
    setState(() => _query = v);
    _debounce?.cancel();
    final q = v.trim();
    if (q.length < 3) {
      setState(() {
        _remote = const [];
        _searching = false;
        _offline = false;
      });
      return;
    }
    // Jeda agar tidak melampaui batas 1 permintaan per detik Nominatim.
    _debounce = Timer(const Duration(milliseconds: 900), () => _searchRemote(q));
  }

  Future<void> _searchRemote(String q) async {
    final token = ++_token;
    setState(() => _searching = true);
    try {
      final res = await ref.read(cityGeocoderProvider).search(q);
      if (!mounted || token != _token) return;
      setState(() {
        _remote = res;
        _searching = false;
        _offline = false;
      });
    } catch (_) {
      if (!mounted || token != _token) return;
      setState(() {
        _remote = const [];
        _searching = false;
        _offline = true;
      });
    }
  }

  Future<void> _choose(ManualCity city) async {
    await ref.read(manualCityStoreProvider).save(city);
    if (mounted) Navigator.pop(context, city);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cities = [..._local, ..._remote];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.sm),
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Cari kota atau kabupaten',
                ),
              ),
            ),
            if (_searching) const LinearProgressIndicator(),
            if (_offline)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Text(
                  'Pencarian online gagal. Menampilkan kota bawaan.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            Expanded(
              child: cities.isEmpty
                  ? Center(
                      child: Text('Kota tidak ditemukan.', style: theme.textTheme.bodyLarge),
                    )
                  : ListView.builder(
                      itemCount: cities.length,
                      itemBuilder: (_, i) => ListTile(
                        leading: const Icon(Icons.location_city_outlined),
                        title: Text(cities[i].name, maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () => _choose(cities[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
