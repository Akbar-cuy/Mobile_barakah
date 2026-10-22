import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import '../services/quiz_session.dart';
import '../widgets/answer_tile.dart';
import 'quiz_result_screen.dart';

// Layar soal: satu soal per halaman dengan hitung mundur 20 detik
class QuizQuestionScreen extends StatefulWidget {
  const QuizQuestionScreen({super.key});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  bool _navigated = false;

  // Format 00:14
  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  AnswerState _stateOf(QuizProvider provider, int index, int answerIndex) {
    if (!provider.answered) return AnswerState.normal;
    if (index == answerIndex) return AnswerState.correct;
    if (index == provider.selectedIndex) return AnswerState.wrong;
    return AnswerState.dimmed;
  }

  // Pindah ke layar hasil setelah sesi tersimpan
  void _openResult(QuizProvider provider) {
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: const QuizResultScreen(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final session = provider.session;

    if (provider.finished && !_navigated) {
      _openResult(provider);
    }

    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = session.current;
    const letters = ['A', 'B', 'C', 'D'];

    // Bila pengguna keluar di tengah sesi, hentikan timer
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !provider.finished) provider.cancelQuiz();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kuis: ${session.category}'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nomor soal, waktu, dan skor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soal ${session.number}/${session.total}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Waktu ${_formatTime(provider.secondsLeft)}'),
                Text('Skor ${session.score}'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: provider.secondsLeft / QuizSession.secondsPerQuestion,
            ),

            // Alasan susunan soal (FR.AI.04)
            if (session.reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Rekomendasi: ${session.reason}',
                style: const TextStyle(fontSize: 12),
              ),
            ],

            const SizedBox(height: 16),
            Text(
              question.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Pilihan jawaban
            for (int i = 0; i < question.options.length; i++)
              AnswerTile(
                letter: letters[i],
                text: question.options[i],
                state: _stateOf(provider, i, question.answerIndex),
                onTap: provider.answered ? null : () => provider.answer(i),
              ),

            // Jawaban benar dan penjelasan (FR.GAME.03)
            if (provider.answered) ...[
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.timedOut
                            ? 'Waktu habis.'
                            : provider.lastPoints > 0
                                ? 'Benar! +${provider.lastPoints}'
                                : 'Salah.',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jawaban benar: '
                        '${question.options[question.answerIndex]}',
                      ),
                      const SizedBox(height: 4),
                      Text(question.explanation),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: provider.saving ? null : provider.nextQuestion,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: provider.saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(session.isLast ? 'Lihat hasil' : 'Lanjut'),
              ),
              if (provider.timedOut && !session.isLast)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Lanjut otomatis dalam beberapa detik.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
