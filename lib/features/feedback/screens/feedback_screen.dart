// M18 Saran dan Kesan (FR-FB-01 sampai FR-FB-06)
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/primary_button.dart';
import '../models/feedback_entry.dart';
import '../providers/feedback_provider.dart';
import '../widgets/star_rating.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _impression = TextEditingController();
  final _suggestion = TextEditingController();
  int _rating = 0;
  String? _ratingError;
  String? _editingId;
  String? _lastSubmittedId;
  bool _busy = false;

  @override
  void dispose() {
    _impression.dispose();
    _suggestion.dispose();
    super.dispose();
  }

  void _reset() {
    _formKey.currentState?.reset();
    _impression.clear();
    _suggestion.clear();
    setState(() {
      _rating = 0;
      _ratingError = null;
      _editingId = null;
    });
  }

  void _edit(FeedbackEntry entry) {
    setState(() {
      _editingId = entry.id;
      _rating = entry.rating;
      _ratingError = null;
      _impression.text = entry.impression;
      _suggestion.text = entry.suggestion;
    });
  }

  Future<void> _submit() async {
    final ratingError = Validators.rating(_rating == 0 ? null : _rating);
    setState(() => _ratingError = ratingError);
    if (!_formKey.currentState!.validate() || ratingError != null) return;

    setState(() => _busy = true);
    final repository = ref.read(feedbackRepositoryProvider);
    try {
      final id = _editingId;
      final entry = id == null
          ? await repository.submit(
              rating: _rating,
              impression: _impression.text,
              suggestion: _suggestion.text,
            )
          : await repository.update(
              id: id,
              rating: _rating,
              impression: _impression.text,
              suggestion: _suggestion.text,
            );
      if (!mounted) return;

      setState(() => _lastSubmittedId = entry.id);
      showAppSnackBar(
        context,
        id == null
            ? 'Masukan tersimpan dan menunggu sinkronisasi.'
            : 'Perubahan tersimpan dan menunggu sinkronisasi.',
      );
      _reset();
      unawaited(ref.read(syncServiceProvider).syncNow());
    } on ApiException catch (e) {
      if (mounted) showAppSnackBar(context, e.message);
    } on Object catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Gagal menyimpan masukan: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(FeedbackEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus saran dan kesan?'),
        content: const Text('Entri akan dihapus dari perangkat dan server.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await ref.read(feedbackRepositoryProvider).delete(entry.id);
      if (!mounted) return;
      if (_editingId == entry.id) _reset();
      if (_lastSubmittedId == entry.id) {
        setState(() => _lastSubmittedId = null);
      }
      showAppSnackBar(context, 'Masukan dihapus dari perangkat.');
      unawaited(ref.read(syncServiceProvider).syncNow());
    } on Object catch (e) {
      if (mounted) showAppSnackBar(context, 'Gagal menghapus masukan: $e');
    }
  }

  Future<void> _retrySync() async {
    await ref.read(syncServiceProvider).syncNow(manual: true);
  }

  Widget _historyCard(FeedbackEntry entry) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StarRating(value: entry.rating, size: 18),
                const Spacer(),
                Text(
                  entry.statusLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: entry.isSynced
                        ? theme.colorScheme.primary
                        : theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            Text(
              DateTimeUtils.formatDate(entry.createdAt),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Kesan', style: theme.textTheme.labelMedium),
            Text(entry.impression),
            const SizedBox(height: AppSpacing.sm),
            Text('Saran', style: theme.textTheme.labelMedium),
            Text(entry.suggestion),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _busy ? null : () => _edit(entry),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Ubah'),
                ),
                TextButton.icon(
                  onPressed: _busy ? null : () => _delete(entry),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Hapus'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = ref.watch(feedbackListProvider);
    final isEditing = _editingId != null;
    FeedbackEntry? summary;
    final loadedEntries = entries.asData?.value;
    if (_lastSubmittedId != null && loadedEntries != null) {
      for (final entry in loadedEntries) {
        if (entry.id == _lastSubmittedId) {
          summary = entry;
          break;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Saran dan Kesan')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Text(
            'Mata kuliah Pemrograman Aplikasi Mobile',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEditing ? 'Ubah penilaian' : 'Beri penilaian'),
                StarRating(
                  value: _rating,
                  onChanged: (value) => setState(() {
                    _rating = value;
                    _ratingError = null;
                  }),
                ),
                if (_ratingError != null)
                  Text(
                    _ratingError!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _impression,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Kesan',
                    hintText: 'Kesan Anda',
                  ),
                  validator: (value) =>
                      Validators.feedbackText(value, field: 'Kesan'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _suggestion,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Saran',
                    hintText: 'Saran Anda',
                  ),
                  validator: (value) =>
                      Validators.feedbackText(value, field: 'Saran'),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: isEditing ? 'Simpan perubahan' : 'Kirim',
                  loading: _busy,
                  onPressed: _submit,
                ),
                if (isEditing)
                  TextButton(
                    onPressed: _busy ? null : _reset,
                    child: const Text('Batal mengubah'),
                  ),
              ],
            ),
          ),
          if (summary != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan kiriman',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        StarRating(value: summary.rating, size: 18),
                        const SizedBox(width: AppSpacing.sm),
                        Text(summary.statusLabel),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Kesan: ${summary.impression}'),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Saran: ${summary.suggestion}'),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text('Riwayat Anda', style: theme.textTheme.titleMedium),
              ),
              IconButton(
                tooltip: 'Kirim yang masih menunggu',
                onPressed: _busy ? null : _retrySync,
                icon: const Icon(Icons.sync),
              ),
            ],
          ),
          entries.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Riwayat gagal dimuat: $error'),
            data: (items) => items.isEmpty
                ? const Text('Belum ada kiriman. Isi kesan dan saran di atas.')
                : Column(
                    children: [for (final entry in items) _historyCard(entry)]),
          ),
        ],
      ),
    );
  }
}
