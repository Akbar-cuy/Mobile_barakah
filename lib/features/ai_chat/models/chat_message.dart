// M13 Fitur LLM (FR-LLM)

import 'dart:math';

// (FR-LLM-03)
const String catatanChat =
    'Ini informasi umum. Untuk kasus yang spesifik, tanyakan kepada ulama atau ustadz.';

class ChatMessage {
  String id; // dibuat di perangkat agar kirim ulang tidak menggandakan data
  String role; // 'user' atau 'assistant'
  String content;
  DateTime createdAt; // disimpan UTC, ditampilkan sebagai waktu lokal
  String syncState; // 'pending', 'synced', atau 'failed'

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.syncState = 'pending',
  });

  static final Random _random = Random.secure();

  // pesan baru dengan id unik (format UUID v4) dan waktu UTC
  factory ChatMessage.baru(String role, String content) {
    String hex(int n) =>
        List.generate(n, (i) => _random.nextInt(16).toRadixString(16)).join();
    return ChatMessage(
      id: '${hex(8)}-${hex(4)}-4${hex(3)}-a${hex(3)}-${hex(12)}',
      role: role,
      content: content,
      createdAt: DateTime.now().toUtc(),
    );
  }

  bool get dariUser => role == 'user';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'sync_state': syncState,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> m) {
    return ChatMessage(
      id: m['id'] as String,
      role: m['role'] as String,
      content: m['content'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
      syncState: m['sync_state'] as String,
    );
  }
}
