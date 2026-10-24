// M13 Fitur LLM (FR-LLM)

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/sync/sync_status.dart';
import '../models/chat_message.dart';

class ChatRepository {
  ChatRepository({required AppDatabase db, required ApiGateway api})
      : _db = db,
        _api = api;

  final AppDatabase _db;
  final ApiGateway _api;

  Future<List<ChatMessage>> ambilRiwayat() async {
    final local = await _ambilRiwayatLokal();
    try {
      final response = await _api.request('GET', ApiEndpoints.aiHistory);
      final items = response['items'];
      if (items is! List) {
        throw const FormatException('Riwayat AI tidak valid.');
      }
      final localById = {for (final message in local) message.id: message};
      for (final item in items) {
        if (item is! Map) throw const FormatException('Pesan AI tidak valid.');
        final map = Map<String, dynamic>.from(item);
        map['sync_state'] = localById[map['id']]?.syncState ?? SyncState.synced;
        final message = ChatMessage.fromMap(map);
        await simpan(message);
      }
      return await _ambilRiwayatLokal();
    } on ApiException catch (error) {
      if (!error.isConnectivity) rethrow;
      return local;
    }
  }

  Future<List<ChatMessage>> _ambilRiwayatLokal() async {
    final rows = await (_db.select(_db.chatMessageTable)
          ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
        .get();
    return rows
        .map((row) => ChatMessage(
              id: row.id,
              role: row.role,
              content: row.content,
              createdAt: DateTime.parse(row.createdAt).toUtc(),
              syncState: row.syncState,
            ))
        .toList();
  }

  Future<void> simpan(ChatMessage pesan) async {
    await _db.into(_db.chatMessageTable).insertOnConflictUpdate(
          ChatMessageTableCompanion.insert(
            id: pesan.id,
            role: pesan.role,
            content: pesan.content,
            createdAt: pesan.createdAt.toUtc().toIso8601String(),
            syncState: Value(pesan.syncState),
          ),
        );
  }

  Future<void> tandaiTersinkron(ChatMessage pesan) async {
    await (_db.update(_db.chatMessageTable)
          ..where((row) => row.id.equals(pesan.id)))
        .write(const ChatMessageTableCompanion(
      syncState: Value(SyncState.synced),
    ));
  }

  Future<ChatMessage> kirimPertanyaan(ChatMessage pesan) async {
    final response = await _api.request(
      'POST',
      ApiEndpoints.aiChat,
      body: {'id': pesan.id, 'content': pesan.content},
      receiveTimeout: const Duration(seconds: 45),
    );
    final item = response['message'];
    if (item is! Map ||
        item['id'] is! String ||
        item['content'] is! String ||
        item['role'] != 'assistant' ||
        item['created_at'] is! String) {
      throw const FormatException('Respons AI tidak valid.');
    }
    return ChatMessage(
      id: item['id'] as String,
      role: 'assistant',
      content: (item['content'] as String).trim(),
      createdAt: DateTime.parse(item['created_at'] as String).toUtc(),
      syncState: SyncState.synced,
    );
  }

  Future<void> hapusRiwayat() async {
    await _api.request('DELETE', ApiEndpoints.aiHistory);
    await _db.delete(_db.chatMessageTable).go();
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    db: ref.watch(appDatabaseProvider),
    api: ref.watch(apiGatewayProvider),
  );
});
