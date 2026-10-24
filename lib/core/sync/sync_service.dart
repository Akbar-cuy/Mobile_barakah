// M20 Basis Data Lokal, Online, dan Sinkronisasi
import 'dart:async';

import '../constants/api_endpoints.dart';
import '../database/daos/outbox_dao.dart';
import '../database/daos/settings_dao.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../network/connectivity_service.dart';
import 'outbox_processor.dart';
import 'sync_status.dart';

abstract interface class SyncPullHandler {
  String get entity;
  Future<void> apply(List<Map<String, dynamic>> items);
}

// Pull: GET /sync/pull?since= -> {server_time, changes: [{entity, items}]}.
class SyncService {
  SyncService({
    required this.processor,
    required this.outbox,
    required this.settings,
    required this.api,
    required this.connectivity,
    List<SyncPullHandler> pullHandlers = const [],
  }) : _handlers = {for (final h in pullHandlers) h.entity: h};

  final OutboxProcessor processor;
  final OutboxDao outbox;
  final SettingsDao settings;
  final ApiGateway api;
  final ConnectivityService connectivity;
  final Map<String, SyncPullHandler> _handlers;

  static const _kLastPull = 'sync_last_pull';

  final _controller = StreamController<SyncStatus>.broadcast();
  StreamSubscription<int>? _pendingSub;
  StreamSubscription<bool>? _netSub;
  int _pending = 0;
  bool _error = false;
  bool _running = false;

  /// Galat terakhir saat mengambil perubahan dari server (pull), atau null.
  String? lastPullError;

  SyncStatus get status {
    if (_error) return SyncStatus.error;
    return _pending > 0 ? SyncStatus.pending : SyncStatus.synced;
  }

  Stream<SyncStatus> get statusStream => _controller.stream;

  void start() {
    _pendingSub ??= outbox.watchPendingCount().listen((n) {
      _pending = n;
      _emit();
    });
    _netSub ??= connectivity.onStatusChange.listen((online) {
      if (online) syncNow();
    });
  }

  Future<void> syncNow({bool manual = false}) async {
    if (_running) return;
    _running = true;
    try {
      if (!await connectivity.isOnline()) return;
      if (manual) await outbox.retryAllNow();
      final result = await processor.run();
      _error = result.failed > 0;
      if (!result.offline && !result.sessionExpired) {
        await _pull();
        lastPullError = null;
      }
    } catch (e) {
      _error = true;
      lastPullError = e is ApiException
          ? '${e.statusCode ?? '-'} ${e.code ?? e.kind.name}: ${e.message}'
          : e.toString();
    } finally {
      _running = false;
      _emit();
    }
  }

  Future<void> _pull() async {
    if (_handlers.isEmpty) return;
    final since = await settings.get(_kLastPull);
    final res = await api.request(
      'GET',
      ApiEndpoints.syncPull,
      query: {ApiParams.since: since},
    );
    final changes = res['changes'];
    if (changes is List) {
      for (final change in changes) {
        if (change is! Map) continue;
        final handler = _handlers[change['entity']];
        final items = change['items'];
        if (handler == null || items is! List) continue;
        await handler.apply([
          for (final i in items)
            if (i is Map) i.cast<String, dynamic>(),
        ]);
      }
    }
    final serverTime = res['server_time'];
    if (serverTime is String) await settings.set(_kLastPull, serverTime);
  }

  Future<void> stop() async {
    await _pendingSub?.cancel();
    await _netSub?.cancel();
    _pendingSub = null;
    _netSub = null;
  }

  void _emit() {
    if (!_controller.isClosed) _controller.add(status);
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
