import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/route_names.dart';
import '../providers/quiz_provider.dart';

class QuizCategoryScreen extends ConsumerStatefulWidget {
  const QuizCategoryScreen({super.key});

  @override
  ConsumerState<QuizCategoryScreen> createState() => _QuizCategoryScreenState();
}

class _QuizCategoryScreenState extends ConsumerState<QuizCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(quizProvider.notifier).loadOverview();
    });
  }

  Future<void> _start(QuizCategory category) async {
    final started = await ref.read(quizProvider.notifier).start(category);
    if (started && mounted) context.push(RouteNames.quizQuestion);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Kuis Islami')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Pilih kategori', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Setiap sesi berisi 10 soal. Waktu menjawab tiap soal 20 detik.',
            style: theme.textTheme.bodyMedium,
          ),
          if (state.recommendation != null) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: Text('Saran: ${state.recommendation!.kategori}'),
                subtitle: Text(
                  '${state.recommendation!.alasan} ${state.composition?.alasan ?? ''}',
                ),
              ),
            ),
          ],
          if (state.error != null) ...[
            const SizedBox(height: 12),
            MaterialBanner(
              content: Text(state.error!),
              actions: [
                TextButton(
                  onPressed: () =>
                      ref.read(quizProvider.notifier).loadOverview(),
                  child: const Text('Muat ulang'),
                ),
              ],
            ),
          ],
          if (state.loading) const LinearProgressIndicator(),
          const SizedBox(height: 12),
          for (final category in QuizCategory.values)
            Card(
              child: ListTile(
                leading: const Icon(Icons.quiz_outlined),
                title: Text(category.label),
                subtitle: const Text('10 soal • 4 pilihan'),
                trailing:
                    state.loading ? null : const Icon(Icons.chevron_right),
                onTap: state.loading ? null : () => _start(category),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Soal disimpan di perangkat setelah berhasil diunduh dan dapat dimainkan kembali saat offline.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
