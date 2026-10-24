// Tes widget layar Tanya Fikih Dasar.
// Memastikan kolom pertanyaan dan tombol Kirim tampil, aktif, dan bisa dipakai
// di tema terang maupun gelap, serta filter pencarian tidak bocor antar kunjungan.
//
// Catatan: ganti 'barakah' pada impor package bila nama paket di pubspec.yaml
// berbeda.

import 'package:barakah/core/theme/app_theme.dart';
import 'package:barakah/features/ai_chat/providers/chat_provider.dart';
import 'package:barakah/features/ai_chat/screens/ai_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Notifier palsu: tidak memanggil repository, hanya mencatat pertanyaan.
class _FakeChatNotifier extends ChatNotifier {
  _FakeChatNotifier(this._awal);

  final ChatState _awal;
  final List<String> dikirim = [];

  @override
  ChatState build() => _awal;

  @override
  Future<void> kirim(String teks) async {
    dikirim.add(teks);
  }
}

Future<_FakeChatNotifier> _pasang(
  WidgetTester tester,
  ThemeData tema, {
  ChatState awal = const ChatState(),
}) async {
  final fake = _FakeChatNotifier(awal);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [chatProvider.overrideWith(() => fake)],
      child: MaterialApp(theme: tema, home: const AiChatScreen()),
    ),
  );
  await tester.pump();
  return fake;
}

void main() {
  final temaUji = <String, ThemeData>{
    'terang': AppTheme.light(),
    'gelap': AppTheme.dark(),
  };

  for (final entri in temaUji.entries) {
    group('AiChatScreen tema ${entri.key}', () {
      testWidgets('kolom pertanyaan dan tombol Kirim tampil dan aktif',
          (tester) async {
        await _pasang(tester, entri.value);

        expect(tester.takeException(), isNull);
        expect(find.text('Ketik pertanyaan'), findsOneWidget);

        final tombol = find.widgetWithText(FilledButton, 'Kirim');
        expect(tombol, findsOneWidget);
        expect(tester.widget<FilledButton>(tombol).onPressed, isNotNull);

        // Lebar tombol harus berhingga (tidak mewarisi lebar tak hingga tema).
        final ukuran = tester.getSize(tombol);
        expect(ukuran.width.isFinite, isTrue);
        expect(ukuran.width, lessThan(200));
        expect(ukuran.height, 48);
      });

      testWidgets('teks yang diketik memakai warna eksplisit', (tester) async {
        await _pasang(tester, entri.value);

        final editable = tester.widget<EditableText>(
          find.descendant(
            of: find.byType(TextField).last,
            matching: find.byType(EditableText),
          ),
        );
        expect(editable.style.color, const Color(0xFF1B1F1D));
      });

      testWidgets('mengetik lalu menekan Kirim memanggil kirim',
          (tester) async {
        final fake = await _pasang(tester, entri.value);

        await tester.enterText(
          find.byType(TextField).last,
          'Apa rukun wudhu?',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Kirim'));
        await tester.pump();

        expect(fake.dikirim, ['Apa rukun wudhu?']);
      });

      testWidgets('saat memuat: tombol nonaktif, kolom pertanyaan tetap aktif',
          (tester) async {
        await _pasang(tester, entri.value, awal: const ChatState(memuat: true));

        final tombol = find.widgetWithText(FilledButton, 'Kirim');
        expect(tester.widget<FilledButton>(tombol).onPressed, isNull);

        final input = tester.widget<TextField>(find.byType(TextField).last);
        expect(input.enabled, isNot(false));
      });

      testWidgets('filter pencarian lama direset saat layar dibuka',
          (tester) async {
        await _pasang(
          tester,
          entri.value,
          awal: const ChatState(kataKunci: 'wudhu'),
        );
        await tester.pump();

        expect(find.text('Tidak ada hasil'), findsNothing);
        expect(find.text('Belum ada percakapan'), findsOneWidget);
      });
    });
  }
}
