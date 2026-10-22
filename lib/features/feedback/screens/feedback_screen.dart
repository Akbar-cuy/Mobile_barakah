// M18 Saran dan Kesan (FR-FB-01 sampai FR-FB-05)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
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
      if (_editingId == null) {
        await repository.submit(
          rating: _rating,
          impression: _impression.text,
          suggestion: _suggestion.text,
        );
      } else {
        await repository.update(
          id: _editingId!,
          rating: _rating,
          impression: _impression.text,
          suggestion: _suggestion.text,
        );
      }
      if (!mounted) return;
      showAppSnackBar(context, _editingId == null ? 'Terima kasih atas masukannya.' : 'Perubahan disimpan.');
      _reset();
    } on ApiException catch (e) {
      if (mounted) showAppSnackBar(context, e.message);
    } catch (_) {
      if (mounted) showAppSnackBar(context, 'Gagal menyimpan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(FeedbackEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus saran dan kesan?'),
        content: const Text('Entri yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(feedbackRepositoryProvider).delete(entry.id);
      if (_editingId == entry.id) _reset();
    } on ApiException catch (e) {
      if (mounted) showAppSnackBar(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = ref.watch(feedbackListProvider).value ?? const <FeedbackEntry>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Saran dan Kesan')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editingId == null ? 'Beri penilaian' : 'Ubah penilaian',
                  style: theme.textTheme.titleMedium,
                ),
                StarRating(value: _rating, onChanged: (v) => setState(() => _rating = v)),
                if (_ratingError != null)
                  Text(
                    _ratingError!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                  ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _impression,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: const InputDecoration(hintText: 'Kesan Anda'),
                  validator: (v) => Validators.feedbackText(v, field: 'Kesan'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _suggestion,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: const InputDecoration(hintText: 'Saran Anda'),
                  validator: (v) => Validators.feedbackText(v, field: 'Saran'),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: _editingId == null ? 'Kirim' : 'Simpan perubahan',
                  loading: _busy,
                  onPressed: _submit,
                ),
                if (_editingId != null)
                  TextButton(onPressed: _busy ? null : _reset, child: const Text('Batal mengubah')),
              ],
            ),
          ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Riwayat', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final entry in entries)
              Card(
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
                          IconButton(
                            tooltip: 'Ubah',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _edit(entry),
                          ),
                          IconButton(
                            tooltip: 'Hapus',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(entry),
                          ),
                        ],
                      ),
                      Text('Kesan', style: theme.textTheme.labelMedium),
                      Text(entry.impression),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Saran', style: theme.textTheme.labelMedium),
                      Text(entry.suggestion),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            entry.synced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${DateTimeUtils.formatDate(entry.createdAt)}, '
                            '${entry.synced ? 'tersinkron' : 'menunggu sinkronisasi'}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
