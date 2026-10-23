// M8 Tasbih Digital (FR-TSB-05)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../shared/widgets/status_banner.dart';
import '../models/tasbih_log.dart';
import '../providers/tasbih_provider.dart';

class TasbihHistoryScreen extends ConsumerWidget {
  const TasbihHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logs = ref.watch(tasbihLogsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Dzikir')),
      body: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Padding(
          padding: EdgeInsets.all(AppSpacing.page),
          child: StatusBanner(
            kind: BannerKind.error,
            message: 'Riwayat tidak dapat dibaca.',
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text('Belum ada dzikir tercatat.',
                  style: theme.textTheme.bodyLarge),
            );
          }
          final byDate = <String, List<TasbihLog>>{};
          for (final l in list) {
            byDate.putIfAbsent(l.date, () => []).add(l);
          }
          final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              for (final d in dates) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_label(d), style: theme.textTheme.titleSmall),
                      ),
                      Text(
                        '${byDate[d]!.fold<int>(0, (a, l) => a + l.count)} dzikir',
                        style: theme.textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
                for (final l in byDate[d]!)
                  Card(
                    elevation: 0,
                    child: ListTile(
                      leading: Icon(
                        l.isCompleted ? Icons.check_circle : Icons.timelapse,
                        color: l.isCompleted
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      title: Text('${l.count} dari ${l.target}'),
                      subtitle: Text(l.isCompleted ? 'Target tercapai' : 'Belum selesai'),
                      trailing: l.isSynced
                          ? null
                          : Icon(Icons.cloud_off_outlined,
                              size: 18, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  static String _label(String key) {
    final parsed = DateTime.tryParse(key);
    return parsed == null ? key : DateTimeUtils.formatDate(parsed);
  }
}
