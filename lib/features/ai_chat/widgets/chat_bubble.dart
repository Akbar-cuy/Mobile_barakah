// M13 Fitur LLM (FR-LLM)
// Tampilan gelembung chat untuk fitur Tanya Fikih Dasar.

import 'package:flutter/material.dart';

import '../models/chat_message.dart';

// ====== TAMPILAN GELEMBUNG CHAT (warna dari prototipe HTML) ======
class ChatBubble extends StatelessWidget {
  final ChatMessage pesan;
  const ChatBubble({super.key, required this.pesan});

  @override
  Widget build(BuildContext context) {
    const Color hijau = Color(0xFF0E6B57); // --pri
    const Color abu = Color(0xFFF1EFE8); // --sf2
    const Color teks = Color(0xFF1B1F1D); // --on
    const Color teksSub = Color(0xFF4A524E); // --on2

    final bool user = pesan.dariUser;
    final DateTime lokal = pesan.createdAt.toLocal();
    final String jam =
        '${lokal.hour.toString().padLeft(2, '0')}:${lokal.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        decoration: BoxDecoration(
          color: user ? hijau : abu,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(user ? 20 : 4),
            bottomRight: Radius.circular(user ? 4 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user ? 'Anda' : 'Barakah AI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: user ? Colors.white70 : hijau,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pesan.content,
              style: TextStyle(color: user ? Colors.white : teks),
            ),
            if (!user) ...[
              const SizedBox(height: 8),
              const Text(
                catatanChat,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: teksSub,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  jam,
                  style: TextStyle(
                    fontSize: 11,
                    color: user ? Colors.white70 : teksSub,
                  ),
                ),
                if (user) ...[
                  const SizedBox(width: 4),
                  Icon(
                    pesan.syncState == 'synced'
                        ? Icons.done
                        : (pesan.syncState == 'failed'
                            ? Icons.error_outline
                            : Icons.schedule),
                    size: 12,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}