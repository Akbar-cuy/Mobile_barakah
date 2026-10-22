// M20 Basis Data Lokal, Online, dan Sinkronisasi
import 'dart:convert';

import '../constants/api_endpoints.dart';
import '../database/daos/ledger_dao.dart';
import '../database/daos/outbox_dao.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import 'sync_status.dart';

class OutboxRunResult {
  const OutboxRunResult({
    this.sent = 0,
    this.failed = 0,
    this.offline = false,
    this.sessionExpired = false,
  });

  final int sent;

  final int failed;

  final bool offline;

  final bool sessionExpired;
}

// donation, feedback, favorite_mosque, dan session_revoke punya endpoint khusus.
// Entity lain dikirim lewat /sync/push. Item gagal melewati item sejenis agar urutan terjaga.
class OutboxProcessor {
  OutboxProcessor({
    required this.outbox,
    required this.ledger,
    required this.api,
    DateTime Function()? clock,
    this.batchSize = 200,
  }) : _now = clock ?? DateTime.now;

  final OutboxDao outbox;
  final LedgerDao ledger;
  final ApiGateway api;
  final int batchSize;
  final DateTime Function() _now;

  Future<OutboxRunResult> run() async {
    var sent = 0;
    var failed = 0;
    final skipped = <String>{};
    final due = await outbox.getDue(now: _now(), limit: batchSize);

    for (final item in due) {
      if (skipped.contains(item.entity)) continue;
      try {
        await _send(item);
        await outbox.markSuccess(item.id);
        sent++;
      } on ApiException catch (e) {
        if (e.isConnectivity) {
          return OutboxRunResult(sent: sent, failed: failed, offline: true);
        }
        if (e.kind == ApiErrorKind.unauthorized) {
          return OutboxRunResult(sent: sent, failed: failed, sessionExpired: true);
        }
        await outbox.markFailure(
          item.id,
          '${e.code ?? e.kind.name}: ${e.message}',
          now: _now(),
        );
        skipped.add(item.entity);
        failed++;
      } catch (e) {
        await outbox.markFailure(item.id, e.toString(), now: _now());
        skipped.add(item.entity);
        failed++;
      }
    }
    return OutboxRunResult(sent: sent, failed: failed);
  }

  Future<void> _send(OutboxItem item) async {
    final payload = (jsonDecode(item.payload) as Map).cast<String, dynamic>();
    switch (item.entity) {
      case OutboxEntity.donation:
        await api.request('POST', ApiEndpoints.donations, body: payload);
        final block = payload['block'];
        final idx = block is Map ? block['idx'] : null;
        if (idx is int) await ledger.markSynced(idx);
        // Blok genesis ikut terkirim bersama donasi pertama (M12).
        final genesis = payload['genesis'];
        final genesisIdx = genesis is Map ? genesis['idx'] : null;
        if (genesisIdx is int) await ledger.markSynced(genesisIdx);
      case OutboxEntity.feedback:
        await _sendFeedback(item.op, payload);
      case OutboxEntity.favoriteMosque:
        if (item.op == OutboxOp.delete) {
          await api.request(
            'DELETE',
            ApiEndpoints.favoriteMosques,
            query: {'osm_id': payload['osm_id']},
          );
        } else {
          await api.request('POST', ApiEndpoints.favoriteMosques, body: payload);
        }
      case OutboxEntity.sessionRevoke:
        await api.request(
          'POST',
          ApiEndpoints.logout,
          body: {'refresh_token': payload['refresh_token']},
        );
      default:
        await api.request(
          'POST',
          ApiEndpoints.syncPush,
          body: {
            'changes': [
              {'entity': item.entity, 'op': item.op, 'payload': payload},
            ],
          },
        );
    }
  }

  Future<void> _sendFeedback(String op, Map<String, dynamic> payload) {
    final id = payload['id'].toString();
    switch (op) {
      case OutboxOp.update:
        return api.request('PUT', ApiEndpoints.feedbackById(id), body: payload);
      case OutboxOp.delete:
        return api.request('DELETE', ApiEndpoints.feedbackById(id));
      default:
        return api.request('POST', ApiEndpoints.feedback, body: payload);
    }
  }
}
