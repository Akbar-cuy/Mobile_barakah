import 'dart:math';

import '../../../core/config/app_config.dart';
import '../../../core/utils/geo_utils.dart';

enum DirectionTargetKind { qibla, north, city }

class DirectionTarget {
  const DirectionTarget({
    required this.kind,
    required this.label,
    required this.bearing,
  });

  final DirectionTargetKind kind;
  final String label;
  final double bearing;
}

class DirectionGameEngine {
  const DirectionGameEngine();

  static const cities = <({String name, double lat, double lng})>[
    (name: 'Jakarta', lat: -6.2088, lng: 106.8456),
    (name: 'Madinah', lat: 24.4672, lng: 39.6111),
    (name: 'Kairo', lat: 30.0444, lng: 31.2357),
  ];

  List<DirectionTarget> createTargets({
    required double qiblaBearing,
    required double latitude,
    required double longitude,
    required Random random,
  }) {
    if (![qiblaBearing, latitude, longitude].every((v) => v.isFinite) ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw ArgumentError('Koordinat atau arah target tidak valid.');
    }
    final targets = <DirectionTarget>[
      DirectionTarget(
        kind: DirectionTargetKind.qibla,
        label: 'Kiblat',
        bearing: GeoUtils.normalizeDegrees(qiblaBearing),
      ),
      const DirectionTarget(
        kind: DirectionTargetKind.north,
        label: 'Utara',
        bearing: 0,
      ),
      for (final city in cities)
        DirectionTarget(
          kind: DirectionTargetKind.city,
          label: city.name,
          bearing: GeoUtils.bearingDegrees(
            latitude,
            longitude,
            city.lat,
            city.lng,
          ),
        ),
    ];
    return List.unmodifiable(List.generate(
      AppConfig.directionGameTargets,
      (_) => targets[random.nextInt(targets.length)],
    ));
  }

  double errorDegrees(double target, double heading) =>
      GeoUtils.angleDifference(target, heading).abs();

  bool isWithinTolerance(double target, double heading) =>
      errorDegrees(target, heading) <= AppConfig.directionGameToleranceDegrees;

  /// Score: 100 base points, up to 75 for remaining seconds and up to 50 for
  /// precision within the five-degree tolerance.
  int scoreTarget({
    required double errorDegrees,
    required Duration elapsed,
  }) {
    if (!errorDegrees.isFinite ||
        errorDegrees < 0 ||
        elapsed.isNegative ||
        errorDegrees > AppConfig.directionGameToleranceDegrees) {
      return 0;
    }
    final remaining = (AppConfig.directionGameTimePerTarget - elapsed)
        .inMilliseconds
        .clamp(0, AppConfig.directionGameTimePerTarget.inMilliseconds);
    final timeBonus = (remaining ~/ 1000) * 5;
    final precisionBonus =
        ((AppConfig.directionGameToleranceDegrees - errorDegrees) * 10).round();
    return 100 + timeBonus + precisionBonus;
  }
}
