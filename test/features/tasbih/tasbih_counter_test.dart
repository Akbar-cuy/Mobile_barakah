import 'package:barakah/core/sync/sync_status.dart';
import 'package:barakah/features/tasbih/models/tasbih_log.dart';
import 'package:barakah/features/tasbih/services/tasbih_counter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TasbihCounter (AC-TSB-03)', () {
    test('mencapai target tepat sekali lalu berhenti', () {
      final c = TasbihCounter(id: 'a', target: 3, date: '2026-01-01');
      expect(c.increment(), isFalse);
      expect(c.increment(), isFalse);
      expect(c.increment(), isTrue);
      expect(c.isCompleted, isTrue);
      expect(c.increment(), isFalse);
      expect(c.count, 3);
      expect(c.progress, 1.0);
    });

    test('progres proporsional', () {
      final c = TasbihCounter(id: 'a', target: 4, date: '2026-01-01')..increment();
      expect(c.progress, 0.25);
    });
  });

  group('TasbihLimits', () {
    test('rentang 1-9999', () {
      expect(TasbihLimits.isValidTarget(0), isFalse);
      expect(TasbihLimits.isValidTarget(1), isTrue);
      expect(TasbihLimits.isValidTarget(9999), isTrue);
      expect(TasbihLimits.isValidTarget(10000), isFalse);
    });
  });

  group('TasbihSuggestion', () {
    test('null bila belum ada riwayat', () {
      expect(TasbihSuggestion.fromTotals([]), isNull);
      expect(TasbihSuggestion.fromTotals([0, 0]), isNull);
    });

    test('memilih preset terdekat dengan rata-rata', () {
      expect(TasbihSuggestion.fromTotals([30, 36]), 33);
      expect(TasbihSuggestion.fromTotals([95, 99, 103]), 99);
      expect(TasbihSuggestion.fromTotals([100, 120]), 100);
    });
  });

  group('TasbihLog', () {
    test('payload memakai nama kolom server', () {
      const log = TasbihLog(id: 'x', date: '2026-01-02', target: 33, count: 20);
      expect(log.toPayload(), {
        'id': 'x',
        'log_date': '2026-01-02',
        'target': 33,
        'count': 20,
        'source': 'app',
      });
    });

    test('fromJson menerima log_date atau date, termasuk format ISO', () {
      final a = TasbihLog.fromJson({'id': '1', 'log_date': '2026-01-02', 'target': 33, 'count': 33});
      final b = TasbihLog.fromJson({'id': '2', 'date': '2026-01-03T00:00:00Z', 'target': 99, 'count': 5});
      expect(a.date, '2026-01-02');
      expect(b.date, '2026-01-03');
      expect(a.isCompleted, isTrue);
      expect(b.isCompleted, isFalse);
      expect(a.syncState, SyncState.synced);
    });
  });
}
