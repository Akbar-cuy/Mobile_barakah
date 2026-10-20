// M2 Manajemen Session (FR-SES-06)
import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/config/app_config.dart';

/// Mengunci aplikasi bila kembali dari latar belakang setelah melewati batas
/// waktu AppConfig.autoLockAfter.
class AutoLockService with WidgetsBindingObserver {
  AutoLockService({
    required this.onLock,
    DateTime Function()? clock,
    Duration? timeout,
  })  : _now = clock ?? DateTime.now,
        timeout = timeout ?? AppConfig.autoLockAfter;

  final FutureOr<void> Function() onLock;
  final Duration timeout;
  final DateTime Function() _now;
  DateTime? _pausedAt;

  void start() => WidgetsBinding.instance.addObserver(this);

  void stop() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = _now();
    } else if (state == AppLifecycleState.resumed) {
      final pausedAt = _pausedAt;
      _pausedAt = null;
      if (pausedAt != null && _now().difference(pausedAt) >= timeout) {
        onLock();
      }
    }
  }
}
