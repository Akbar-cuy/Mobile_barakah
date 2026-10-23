// M6 Masjid Terdekat (FR-LBS-10)
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/mosque.dart';

/// Peta OpenStreetMap dengan penanda masjid dan posisi pengguna.
class MosqueMap extends StatelessWidget {
  const MosqueMap({
    super.key,
    required this.userLat,
    required this.userLon,
    required this.mosques,
    required this.selectedId,
    required this.onSelect,
  });

  final double userLat;
  final double userLon;
  final List<Mosque> mosques;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FlutterMap(
      options: MapOptions(initialCenter: LatLng(userLat, userLon), initialZoom: 14),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.barakah',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(userLat, userLon),
              width: 28,
              height: 28,
              child: Icon(Icons.my_location, color: scheme.primary, semanticLabel: 'Lokasi Anda'),
            ),
            for (final m in mosques)
              Marker(
                point: LatLng(m.lat, m.lon),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => onSelect(m.osmId),
                  child: Icon(
                    Icons.location_on,
                    size: m.osmId == selectedId ? 40 : 30,
                    color: m.osmId == selectedId ? scheme.tertiary : scheme.error,
                    semanticLabel: m.name,
                  ),
                ),
              ),
          ],
        ),
        const SimpleAttributionWidget(source: Text('OpenStreetMap')),
      ],
    );
  }
}
