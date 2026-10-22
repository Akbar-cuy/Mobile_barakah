// M4 Beranda dan Jadwal Sholat. Sumber jadwal: API publik Aladhan (kalender
// bulanan, metode 20 Kemenag), penentuan sholat berikutnya.
import 'package:dio/dio.dart';

import '../../converter/services/timezone_service.dart';
import '../models/prayer_times.dart';

class PrayerFetchException implements Exception {
  const PrayerFetchException(this.message);

  final String message;

  @override
  String toString() => 'PrayerFetchException: $message';
}

abstract interface class PrayerTimeSource {
  Future<List<PrayerTimes>> fetchMonth({
    required double lat,
    required double lon,
    required int year,
    required int month,
    required String method,
    required String locationKey,
  });
}

class AladhanPrayerTimeService implements PrayerTimeSource {
  AladhanPrayerTimeService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.aladhan.com',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  final Dio _dio;

  static final _hm = RegExp(r'(\d{1,2}):(\d{2})');

  @override
  Future<List<PrayerTimes>> fetchMonth({
    required double lat,
    required double lon,
    required int year,
    required int month,
    required String method,
    required String locationKey,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/v1/calendar/$year/$month',
        queryParameters: {'latitude': lat, 'longitude': lon, 'method': method},
      );
      return parse(
        response.data,
        lat: lat,
        lon: lon,
        method: method,
        locationKey: locationKey,
      );
    } on DioException catch (error) {
      throw PrayerFetchException(
        error.message ?? 'Gagal mengambil jadwal sholat.',
      );
    }
  }

  static List<PrayerTimes> parse(
    Object? body, {
    required double lat,
    required double lon,
    required String method,
    required String locationKey,
  }) {
    if (body is! Map || body['data'] is! List) {
      throw const PrayerFetchException('Respons jadwal sholat tidak dikenali.');
    }
    final days = <PrayerTimes>[];
    for (final item in body['data'] as List) {
      if (item is! Map) continue;
      final timings = item['timings'];
      final gregorian = (item['date'] as Map?)?['gregorian'];
      if (timings is! Map || gregorian is! Map) continue;

      final parts = gregorian['date'].toString().split('-');
      if (parts.length != 3) continue;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final zone = (item['meta'] as Map?)?['timezone']?.toString() ?? '';
      final offset =
          TimezoneService.offsetForZoneName(zone, DateTime(year, month, day));

      String? hm(String key) {
        final match = _hm.firstMatch(timings[key]?.toString() ?? '');
        return match == null
            ? null
            : '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
      }

      final times = {
        PrayerName.fajr: hm('Fajr'),
        PrayerName.sunrise: hm('Sunrise'),
        PrayerName.dhuhr: hm('Dhuhr'),
        PrayerName.asr: hm('Asr'),
        PrayerName.maghrib: hm('Maghrib'),
        PrayerName.isha: hm('Isha'),
      };
      if (times.values.any((value) => value == null)) continue;

      days.add(
        PrayerTimes(
          date: '${year.toString().padLeft(4, '0')}-'
              '${month.toString().padLeft(2, '0')}-'
              '${day.toString().padLeft(2, '0')}',
          times: {for (final entry in times.entries) entry.key: entry.value!},
          utcOffsetMinutes: offset,
          lat: lat,
          lon: lon,
          method: method,
          locationKey: locationKey,
        ),
      );
    }
    if (days.isEmpty) {
      throw const PrayerFetchException('Jadwal sholat kosong.');
    }
    return days;
  }
}

class NextPrayer {
  const NextPrayer({required this.name, required this.at, required this.day});

  final PrayerName name;

  /// Saat sholat dalam UTC.
  final DateTime at;

  final PrayerTimes day;

  Duration remaining(DateTime nowUtc) => at.difference(nowUtc);
}

abstract final class PrayerCalculator {
  /// Sholat wajib pertama yang waktunya masih setelah [nowUtc]. Null bila
  /// seluruh jadwal yang tersedia sudah lewat.
  static NextPrayer? next(List<PrayerTimes> days, DateTime nowUtc) {
    final sorted = [...days]..sort((a, b) => a.date.compareTo(b.date));
    for (final day in sorted) {
      for (final prayer in PrayerName.obligatory) {
        final at = day.instant(prayer);
        if (at.isAfter(nowUtc)) {
          return NextPrayer(name: prayer, at: at, day: day);
        }
      }
    }
    return null;
  }

  /// Jadwal hari ini menurut tanggal lokasi sholat. Bila tidak ada yang cocok,
  /// memakai hari pertama.
  static PrayerTimes? today(List<PrayerTimes> days, DateTime nowUtc) {
    for (final day in days) {
      final local = nowUtc.toUtc().add(
            Duration(minutes: day.utcOffsetMinutes),
          );
      final key = '${local.year.toString().padLeft(4, '0')}-'
          '${local.month.toString().padLeft(2, '0')}-'
          '${local.day.toString().padLeft(2, '0')}';
      if (day.date == key) return day;
    }
    return days.isEmpty ? null : days.first;
  }
}
