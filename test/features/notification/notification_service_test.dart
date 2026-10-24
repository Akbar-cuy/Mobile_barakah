import 'package:barakah/features/notification/services/notification_prefs.dart';
import 'package:barakah/features/notification/services/notification_service.dart';
import 'package:barakah/features/notification/services/prayer_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

class _Gateway implements NotificationGateway {
  bool showing = true;
  bool opened = false;
  final shown = <int>[];

  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> schedule(PlannedNotification notification, NotificationSound sound) async {}
  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required NotificationSound sound,
  }) async =>
      shown.add(id);
  @override
  Future<bool> isShowing(int id) async => showing && shown.contains(id);
  @override
  Future<void> openSystemSettings() async => opened = true;
}

void main() {
  test('uji notifikasi berhasil bila notifikasi tampil', () async {
    final gateway = _Gateway();
    final ok = await NotificationService(gateway)
        .showTest('Uji', 'Isi', NotificationSound.defaultSound);
    expect(ok, isTrue);
    expect(gateway.shown, [1]);
  });

  test('uji notifikasi melaporkan bila sistem menahannya', () async {
    final gateway = _Gateway()..showing = false;
    final ok = await NotificationService(gateway)
        .showTest('Uji', 'Isi', NotificationSound.defaultSound);
    expect(ok, isFalse);
  });

  test('pintasan pengaturan sistem diteruskan', () async {
    final gateway = _Gateway();
    await NotificationService(gateway).openSystemSettings();
    expect(gateway.opened, isTrue);
  });
}
