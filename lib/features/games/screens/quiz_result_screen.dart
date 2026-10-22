import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import 'quiz_question_screen.dart';

// Ringkasan kuis: skor, jumlah benar, dan skor tertinggi kategori (AC.GAME.03)
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Main lagi di kategori yang sama
  Future<void> _playAgain(BuildContext context, String category) async {
    final provider = context.read<QuizProvider>();
    final ok = await provider.startQuiz(category);
    if (!ok || !context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const QuizQuestionScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final result = provider.result;

    if (result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final advice = provider.advice;

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Kuis')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            result.category,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${result.score}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Text('Skor', textAlign: TextAlign.center),
          if (provider.isNewBest)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Skor tertinggi baru!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row('Jawaban benar', '${result.correct} dari ${result.total}'),
                  _row('Rata-rata waktu',
                      '${result.avgTime.toStringAsFixed(1)} detik'),
                  _row('Skor tertinggi kategori', '${provider.bestScore}'),
                  _row('Status',
                      result.syncState == 'synced' ? 'Terkirim' : 'Menunggu'),
                ],
              ),
            ),
          ),

          // Rekomendasi berikutnya (FR.AI.02 dan FR.AI.04)
          if (advice != null) ...[
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rekomendasi berikutnya: ${advice.category}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(advice.reason),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _playAgain(context, advice.category),
                      child: const Text('Mainkan kategori ini'),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _playAgain(context, result.category),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Main lagi'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Pilih kategori'),
          ),
        ],
      ),
    );
  }
}