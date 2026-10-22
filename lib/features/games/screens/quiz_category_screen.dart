import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import 'direction_game_screen.dart';
import 'quiz_question_screen.dart';

// Layar awal Kuis dan Game: pilih kategori kuis atau buka Cari Arah
class QuizCategoryScreen extends StatelessWidget {
  const QuizCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizProvider(),
      child: const _CategoryView(),
    );
  }
}

class _CategoryView extends StatelessWidget {
  const _CategoryView();

  // Mulai kuis, lalu buka layar soal dengan provider yang sama
  Future<void> _start(BuildContext context, String category) async {
    final provider = context.read<QuizProvider>();
    final ok = await provider.startQuiz(category);
    if (!ok || !context.mounted) return;

    Navigator.push(
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

    return Scaffold(
      appBar: AppBar(title: const Text('Kuis dan Game')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Rekomendasi kategori (FR.AI.02 dan FR.AI.04)
                if (provider.advice != null)
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rekomendasi: ${provider.advice!.category}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(provider.advice!.reason),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: provider.starting
                                ? null
                                : () => _start(
                                      context,
                                      provider.advice!.category,
                                    ),
                            child: const Text('Mulai kategori ini'),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
                const Text(
                  'Kuis Islami',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text('10 soal acak, 20 detik per soal.'),
                const SizedBox(height: 8),

                if (provider.errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      provider.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),

                // Daftar kategori
                for (final category in provider.categories)
                  Card(
                    child: ListTile(
                      title: Text(category),
                      subtitle: Text(
                        '${provider.accuracyTextOf(category)}\n'
                        'Skor tertinggi: ${provider.bestScoreOf(category)}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.play_arrow),
                      enabled: !provider.starting,
                      onTap: () => _start(context, category),
                    ),
                  ),

                if (provider.starting)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                const SizedBox(height: 16),
                const Text(
                  'Game sensor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.explore),
                    title: const Text('Cari Arah'),
                    subtitle: const Text(
                      'Hadapkan ponsel ke arah target. Memakai magnetometer dan gyroscope.',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DirectionGameScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
