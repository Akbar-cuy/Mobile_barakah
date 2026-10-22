// M7 Arah Kiblat (FR-QBL-01, AC-QBL-01)
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/geo_utils.dart';

/// Sudut kiblat dan jarak ke Ka'bah dari satu titik.
class QiblaResult {
  const QiblaResult({required this.bearing, required this.distanceKm});

  /// Derajat dari utara sejati searah jarum jam, 0 sampai kurang dari 360.
  final double bearing;
  final double distanceKm;

  /// Nama arah mata angin, misalnya "Barat Laut".
  String get compassName => GeoUtils.compassName(bearing);
}

/// Rumus PRD bagian 9.7 (bearing awal great circle ke Ka'bah):
///
/// ```
/// dLon = lonKabah - lonUser
/// y = sin(dLon) * cos(latKabah)
/// x = cos(latUser) * sin(latKabah) - sin(latUser) * cos(latKabah) * cos(dLon)
/// kiblat = (atan2(y, x) dalam derajat + 360) mod 360
/// ```
///
/// Hasilnya relatif terhadap utara sejati. Magnetometer menunjuk utara
/// magnetik, selisihnya (deklinasi) di Indonesia kecil, sekitar 0 sampai 2 derajat.
abstract final class QiblaCalculator {
  static QiblaResult calculate(double latitude, double longitude) {
    final bearing = GeoUtils.bearingDegrees(
      latitude,
      longitude,
      AppConstants.kaabaLatitude,
      AppConstants.kaabaLongitude,
    );
    final meters = GeoUtils.distanceMeters(
      latitude,
      longitude,
      AppConstants.kaabaLatitude,
      AppConstants.kaabaLongitude,
    );
    return QiblaResult(bearing: bearing, distanceKm: meters / 1000);
  }
}
