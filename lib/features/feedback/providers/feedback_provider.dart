// M18 Saran dan Kesan
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/sync/sync_status.dart';
import '../models/feedback_entry.dart';
import '../repository/feedback_repository.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository(
    db: ref.watch(appDatabaseProvider),
    api: ref.watch(apiGatewayProvider),
    outbox: ref.watch(outboxDaoProvider),
  );
});

final feedbackListProvider = StreamProvider<List<FeedbackEntry>>((ref) {
  final repository = ref.watch(feedbackRepositoryProvider);
  final sub = ref.watch(syncServiceProvider).statusStream.listen((status) {
    if (status == SyncStatus.synced) unawaited(repository.markPendingSynced());
  });
  ref.onDispose(sub.cancel);
  return repository.watchAll();
});
