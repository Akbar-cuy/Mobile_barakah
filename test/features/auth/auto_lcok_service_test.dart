import 'package:barakah/features/auth/services/auto_lock_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime now;
  late int locked;
  late AutoLockService service;

  setUp(() {
    now = DateTime(2026, 10, 17, 10, 0);
    locked = 0;
    service = AutoLockService(
      onLock: () => locked++,
      clock: () => now,
      timeout: const Duration(minutes: 5),
    );
  });

  test('mengunci bila kembali setelah melewati batas waktu', () {
    service.didChangeAppLifecycleState(AppLifecycleState.paused);
    now = now.add(const Duration(minutes: 6));
    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(locked, 1);
  });

  test('tidak mengunci bila kembali sebelum batas waktu', () {
    service.didChangeAppLifecycleState(AppLifecycleState.paused);
    now = now.add(const Duration(minutes: 2));
    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(locked, 0);
  });

  test('resume tanpa paused tidak mengunci', () {
    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(locked, 0);
  });
}
