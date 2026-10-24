import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../providers/quiz_provider.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizProvider);
    final attempt = state.attempt;
    if (!state.finished || attempt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hasil Kuis')),
        body: const Center(child: Text('Hasil kuis belum tersedia.')),
      );
    }
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Kuis')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.emoji_events_outlined, size: 64),
            const SizedBox(height: 12),
            Text(
              attempt.category.label,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Skor ${attempt.score}',
                        style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text('Benar ${attempt.correct} dari ${attempt.total} soal'),
                    Text('Skor tertinggi ${state.bestScore}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (state.leaderboard.isNotEmpty) ...[
              Text('Papan skor', style: theme.textTheme.titleLarge),
              for (var i = 0; i < state.leaderboard.length; i++)
                ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(
                    (state.leaderboard[i]['name'] ?? 'Pemain').toString(),
                  ),
                  trailing: Text('${state.leaderboard[i]['score'] ?? 0}'),
                ),
            ] else
              const Text('Papan skor belum tersedia saat offline.'),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.go(RouteNames.quiz),
              icon: const Icon(Icons.replay),
              label: const Text('Main lagi'),
            ),
            TextButton(
              onPressed: () => context.go(RouteNames.worship),
              child: const Text('Kembali ke Ibadah'),
            ),
          ],
        ),
      ),
    );
  }
}
