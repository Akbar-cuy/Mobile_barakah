import 'package:barakah/features/notification/services/geofence_service.dart';
import 'package:barakah/features/notification/services/notification_prefs.dart';
import 'package:barakah/features/notification/services/prayer_scheduler.dart';
import 'package:barakah/features/mosque/models/mosque.dart';
import 'package:flutter_test/flutter_test.dart';

PrayerDay _day(String date, {int offset = 420}) => PrayerDay(
      date: date,
      utcOffsetMinutes: offset,
      times: const {
        PrayerSlot.fajr: '04.30',
        PrayerSlot.dhuhr: '12:00',
        PrayerSlot.asr: '15:15',
        PrayerSlot.maghrib: '18:00',
        PrayerSlot.isha: '19:10',
      },
    );

void main() {
  final now = DateTime.utc(2026, 1, 1);

  group('PrayerScheduler.parseTime', () {
    test('titik dua atau titik', () {
      expect(PrayerScheduler.parseTime('04:30'), (4, 30));
      expect(PrayerScheduler.parseTime('4.05'), (4, 5));
      expect(PrayerScheduler.parseTime('24:00'), isNull);
      expect(PrayerScheduler.parseTime('abc'), isNull);
      expect(PrayerScheduler.parseTime(null), isNull);
    });
  });

  group('PrayerScheduler.plan', () {
    test('mengubah waktu lokasi ke UTC memakai offset', () {
      final plan = PrayerScheduler.plan(
        days: [_day('2026-01-02')],
        prefs: const NotificationPrefs(),
        now: now,
      );
      final fajr = plan.firstWhere((n) => n.slot == PrayerSlot.fajr);
      // 04.30 WIB (UTC+7) = 21.30 UTC hari sebelumnya.
      expect(fajr.when, DateTime.utc(2026, 1, 1, 21, 30));
      expect(plan.length, 5);
    });

    test('hasil terurut dan notifikasi yang sudah lewat dibuang', () {
      final plan = PrayerScheduler.plan(
        days: [_day('2026-01-02')],
        prefs: const NotificationPrefs(),
        now: DateTime.utc(2026, 1, 2, 6),
      );
      // Subuh (21.30Z) dan Dzuhur (05.00Z) sudah lewat pada 06.00Z.
      expect([for (final n in plan) n.slot], [PrayerSlot.asr, PrayerSlot.maghrib, PrayerSlot.isha]);
      for (var i = 1; i < plan.length; i++) {
        expect(plan[i].when.isAfter(plan[i - 1].when), isTrue);
      }
      expect(plan.every((n) => n.when.isAfter(DateTime.utc(2026, 1, 2, 6))), isTrue);
    });

    test('waktu sholat yang dimatikan tidak dijadwalkan', () {
      final prefs = const NotificationPrefs().copyWith(
        enabled: {for (final s in PrayerSlot.values) s: s == PrayerSlot.maghrib},
      );
      final plan = PrayerScheduler.plan(days: [_day('2026-01-02')], prefs: prefs, now: now);
      expect(plan.map((n) => n.slot), [PrayerSlot.maghrib]);
    });

    test('pengingat 10 menit sebelum adzan', () {
      final prefs = const NotificationPrefs().copyWith(reminderMinutes: 10);
      final plan = PrayerScheduler.plan(days: [_day('2026-01-02')], prefs: prefs, now: now);
      final fajr = plan.where((n) => n.slot == PrayerSlot.fajr).toList();
      expect(fajr.length, 2);
      expect(fajr.first.kind, PlannedKind.reminder);
      expect(fajr.first.when, DateTime.utc(2026, 1, 1, 21, 20));
      expect(plan.length, 10);
    });

    test('ID unik dan stabil, serta muat 32 bit', () {
      final prefs = const NotificationPrefs().copyWith(reminderMinutes: 5);
      final days = [for (var d = 2; d <= 8; d++) _day('2026-01-0$d')];
      final a = PrayerScheduler.plan(days: days, prefs: prefs, now: now, maxItems: 1000);
      final b = PrayerScheduler.plan(days: days, prefs: prefs, now: now, maxItems: 1000);
      expect(a.map((n) => n.id).toSet().length, a.length);
      expect(a.map((n) => n.id), b.map((n) => n.id));
      expect(a.every((n) => n.id > 0 && n.id < 2147483647), isTrue);
    });

    test('batas jumlah menyisakan yang terdekat', () {
      final days = [for (var d = 2; d <= 8; d++) _day('2026-01-0$d')];
      final plan = PrayerScheduler.plan(
        days: days,
        prefs: const NotificationPrefs(),
        now: now,
        maxItems: 12,
      );
      expect(plan.length, 12);
      final all = PrayerScheduler.plan(
        days: days,
        prefs: const NotificationPrefs(),
        now: now,
        maxItems: 1000,
      );
      expect(plan.map((n) => n.id), all.take(12).map((n) => n.id));
    });

    test('baris rusak dilewati', () {
      final plan = PrayerScheduler.plan(
        days: [
          const PrayerDay(date: 'bukan-tanggal', utcOffsetMinutes: 0, times: {}),
          PrayerDay(date: '2026-01-02', utcOffsetMinutes: 420, times: const {PrayerSlot.fajr: 'x'}),
        ],
        prefs: const NotificationPrefs(),
        now: now,
      );
      expect(plan, isEmpty);
    });

    test('dzikir harian untuk 7 hari', () {
      final prefs = const NotificationPrefs().copyWith(dhikrEnabled: true);
      final plan = PrayerScheduler.plan(
        days: const [],
        prefs: prefs,
        now: DateTime(2026, 1, 1, 0, 0),
      );
      expect(plan.length, 7);
      expect(plan.every((n) => n.kind == PlannedKind.dhikr), isTrue);
      expect(plan.map((n) => n.id).toSet().length, 7);
    });
  });

  group('NotificationPrefs', () {
    test('JSON bolak-balik dan nilai tidak valid dikembalikan ke bawaan', () {
      final p = const NotificationPrefs().copyWith(
        reminderMinutes: 15,
        sound: NotificationSound.silent,
        dhikrEnabled: true,
        dhikrHour: 6,
        dhikrMinute: 5,
        enabled: {for (final s in PrayerSlot.values) s: s != PrayerSlot.asr},
      );
      final back = NotificationPrefs.fromJson(p.toJson());
      expect(back.reminderMinutes, 15);
      expect(back.sound, NotificationSound.silent);
      expect(back.isOn(PrayerSlot.asr), isFalse);
      expect(back.isOn(PrayerSlot.fajr), isTrue);
      expect(back.dhikrHour, 6);
      expect(NotificationPrefs.fromJson({'reminder': 7, 'dhikr_h': 99}).reminderMinutes, 0);
      expect(NotificationPrefs.fromJson({'dhikr_h': 99}).dhikrHour, 23);
    });
  });

  group('GeofenceService', () {
    const near = Mosque(osmId: 'a', name: 'Dekat', lat: 0, lon: 0.001); // sekitar 111 m
    const far = Mosque(osmId: 'b', name: 'Jauh', lat: 0, lon: 0.01); // sekitar 1,1 km
    final t0 = DateTime(2026, 1, 1, 12);

    test('hanya masjid dalam radius, dengan cooldown', () {
      final g = GeofenceService();
      expect(g.check(lat: 0, lon: 0, favorites: [far], now: t0), isNull);
      expect(g.check(lat: 0, lon: 0, favorites: [near, far], now: t0)?.osmId, 'a');
      expect(g.check(lat: 0, lon: 0, favorites: [near], now: t0.add(const Duration(hours: 1))), isNull);
      expect(g.check(lat: 0, lon: 0, favorites: [near], now: t0.add(const Duration(hours: 7)))?.osmId, 'a');
    });
  });
}
