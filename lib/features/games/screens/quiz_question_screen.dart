import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/route_names.dart';
import '../providers/quiz_provider.dart';
import '../widgets/answer_tile.dart';

class QuizQuestionScreen extends ConsumerWidget {
  const QuizQuestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizProvider);
    final controller = ref.read(quizProvider.notifier);
    final category = state.category;
    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kuis Islami')),
        body: const Center(child: Text('Pilih kategori untuk memulai kuis.')),
      );
    }
    if (state.loading) {
      return Scaffold(
        appBar: AppBar(title: Text(category.label)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final question = controller.currentQuestion;
    if (question == null) {
      return Scaffold(
        appBar: AppBar(title: Text(category.label)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.error ?? 'Soal belum tersedia.'),
                const SizedBox(height: 12),
                if (state.error != null &&
                    state.index >= AppConfig.quizQuestionsPerSession)
                  FilledButton(
                    onPressed: state.loading
                        ? null
                        : () async {
                            await ref.read(quizProvider.notifier).retrySave();
                            if (context.mounted &&
                                ref.read(quizProvider).finished) {
                              context.go(RouteNames.quizResult);
                            }
                          },
                    child: const Text('Coba simpan hasil lagi'),
                  ),
                TextButton(
                  onPressed: () {
                    ref.read(quizProvider.notifier).leaveQuestion();
                    context.pop();
                  },
                  child: const Text('Kembali ke kategori'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final result = state.result;
    const letters = ['A', 'B', 'C', 'D'];
    return Scaffold(
      appBar: AppBar(
        title: Text(category.label),
        leading: BackButton(onPressed: () {
          controller.leaveQuestion();
          context.pop();
        }),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Soal ${state.index + 1}/${AppConfig.quizQuestionsPerSession}'),
                Text('Skor ${state.score}'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (state.index + (result == null ? 0 : 1)) /
                  AppConfig.quizQuestionsPerSession,
            ),
            const SizedBox(height: 8),
            Text(
              'Waktu ${state.remainingSeconds.toString().padLeft(2, '0')} detik',
              textAlign: TextAlign.end,
            ),
            if (state.composition != null) ...[
              const SizedBox(height: 8),
              Text(
                state.composition!.alasan,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 24),
            Text(
              question.question,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < question.options.length; index++)
              AnswerTile(
                label: letters[index],
                text: question.options[index],
                selected: state.selectedIndex == index,
                correct: result != null && question.answerIndex == index,
                enabled: result == null,
                onTap: () => controller.answer(index),
              ),
            if (result != null) ...[
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    '${result.isCorrect ? 'Benar.' : result.selectedIndex == null ? 'Waktu habis.' : 'Belum tepat.'} '
                    'Jawaban: ${letters[question.answerIndex]}. ${question.explanation}',
                  ),
                ),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton(
                onPressed: state.loading
                    ? null
                    : () async {
                        await controller.next();
                        if (context.mounted &&
                            ref.read(quizProvider).finished) {
                          context.go(RouteNames.quizResult);
                        }
                      },
                child: state.loading
                    ? const CircularProgressIndicator()
                    : Text(state.index + 1 == AppConfig.quizQuestionsPerSession
                        ? 'Lihat hasil'
                        : 'Soal berikutnya'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
