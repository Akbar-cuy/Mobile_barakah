import 'package:barakah/core/database/app_database.dart';
import 'package:barakah/core/network/api_client.dart';
import 'package:barakah/features/ai_chat/models/chat_message.dart';
import 'package:barakah/features/ai_chat/repository/chat_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGateway implements ApiGateway {
  final calls = <(String, String, Object?)>[];
  Map<String, dynamic> nextResponse = {'items': <Object>[]};

  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Duration? receiveTimeout,
  }) async {
    calls.add((method, path, body));
    return nextResponse;
  }
}

void main() {
  late AppDatabase db;
  late _FakeGateway api;
  late ChatRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = _FakeGateway();
    repository = ChatRepository(db: db, api: api);
  });

  tearDown(() async => db.close());

  test('stores chat messages in Drift and loads them in order', () async {
    final user = ChatMessage(
      id: 'user-id',
      role: 'user',
      content: 'Pertanyaan',
      createdAt: DateTime.utc(2026, 1, 1),
    );
    final assistant = ChatMessage(
      id: 'assistant-id',
      role: 'assistant',
      content: 'Jawaban',
      createdAt: DateTime.utc(2026, 1, 1, 0, 1),
      syncState: 'synced',
    );

    await repository.simpan(user);
    await repository.simpan(assistant);

    final history = await repository.ambilRiwayat();
    expect(history.map((message) => message.id), ['user-id', 'assistant-id']);
    expect(history.last.content, 'Jawaban');
  });

  test('sends a question through the API gateway and parses its server reply',
      () async {
    final question = ChatMessage(
      id: 'question-id',
      role: 'user',
      content: 'Apa itu wudhu?',
      createdAt: DateTime.utc(2026),
    );
    api.nextResponse = {
      'message': {
        'id': 'reply-id',
        'role': 'assistant',
        'content': 'Jawaban dari server',
        'created_at': '2026-01-01T00:00:01Z',
      },
    };

    final answer = await repository.kirimPertanyaan(question);

    expect(api.calls.single.$1, 'POST');
    expect(api.calls.single.$2, '/ai/chat');
    expect(api.calls.single.$3,
        {'id': 'question-id', 'content': 'Apa itu wudhu?'});
    expect(answer.id, 'reply-id');
    expect(answer.content, 'Jawaban dari server');
  });

  test('merges server history into local Drift history', () async {
    api.nextResponse = {
      'items': [
        {
          'id': 'remote-id',
          'role': 'assistant',
          'content': 'Riwayat server',
          'created_at': '2026-01-01T00:00:00Z',
        },
      ],
    };

    final history = await repository.ambilRiwayat();

    expect(history.single.id, 'remote-id');
    expect(history.single.syncState, 'synced');
    expect(api.calls.single.$1, 'GET');
    expect(api.calls.single.$2, '/ai/history');
  });

  test('clears local history only after the server accepts deletion', () async {
    await repository.simpan(ChatMessage(
      id: 'local-id',
      role: 'user',
      content: 'Pertanyaan',
      createdAt: DateTime.utc(2026),
    ));

    await repository.hapusRiwayat();

    expect(api.calls.single.$1, 'DELETE');
    expect(api.calls.single.$2, '/ai/history');
    expect(await db.select(db.chatMessageTable).get(), isEmpty);
  });
}
