import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/feedback_entry.dart';
import '../providers/feedback_provider.dart';
import '../widgets/star_rating.dart';

// Tab Saran dan Kesan mata kuliah Pemrograman Aplikasi Mobile (PRD M18)
class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedbackProvider(),
      child: const _FeedbackView(),
    );
  }
}

class _FeedbackView extends StatefulWidget {
  const _FeedbackView();

  @override
  State<_FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<_FeedbackView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _impressionController = TextEditingController();
  final TextEditingController _suggestionController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _impressionController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }

  void _clearControllers() {
    _impressionController.clear();
    _suggestionController.clear();
  }

  Future<void> _submit() async {
    final provider = context.read<FeedbackProvider>();
    final message = await provider.submit();
    if (message == null || !mounted) return;
    _clearControllers();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _startEdit(FeedbackEntry entry) {
    _impressionController.text = entry.impression;
    _suggestionController.text = entry.suggestion;
    context.read<FeedbackProvider>().startEdit(entry);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _cancelEdit() {
    _clearControllers();
    context.read<FeedbackProvider>().cancelEdit();
  }

  Future<void> _confirmDelete(FeedbackEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus kiriman?'),
          content:
              const Text('Kiriman ini akan dihapus dari perangkat dan server.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;

    final provider = context.read<FeedbackProvider>();
    final wasEditing = provider.editing?.id == entry.id;
    await provider.deleteEntry(entry);
    if (wasEditing) _clearControllers();
  }

  // Waktu disimpan UTC, ditampilkan di zona waktu perangkat
  String _formatDate(DateTime utc) {
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final d = utc.toLocal();
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  Widget _spinner() {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  Widget _historyCard(FeedbackEntry e) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StarRating(rating: e.rating, size: 18),
                const SizedBox(width: 8),
                Text(
                  _formatDate(e.createdAt),
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
                Text(
                  e.statusLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: e.isSynced ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Kesan: ${e.impression}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Saran: ${e.suggestion}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _startEdit(e),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Ubah'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(e),
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
    final provider = context.watch<FeedbackProvider>();
    final summary = provider.summaryEntry;
    final entries = provider.entries;
    final errorColor = Theme.of(context).colorScheme.error;
    final isEditing = provider.editing != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Saran dan Kesan')),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Mata kuliah Pemrograman Aplikasi Mobile'),
          const SizedBox(height: 12),

          if (isEditing) ...[
            const Text(
              'Mengubah kiriman. Tekan Simpan perubahan untuk menyimpan.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
          ],

          // Penilaian bintang
          const Text('Penilaian',
              style: TextStyle(fontWeight: FontWeight.bold)),
          StarRating(rating: provider.rating, onChanged: provider.setRating),
          if (provider.showErrors && provider.ratingError != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                provider.ratingError!,
                style: TextStyle(color: errorColor, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),

          // Kesan
          TextField(
            controller: _impressionController,
            maxLength: 500,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Kesan',
              hintText: 'Kesan Anda',
              border: const OutlineInputBorder(),
              errorText: provider.showErrors ? provider.impressionError : null,
            ),
            onChanged: provider.setImpression,
          ),
          const SizedBox(height: 12),

          // Saran
          TextField(
            controller: _suggestionController,
            maxLength: 500,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Saran',
              hintText: 'Saran Anda',
              border: const OutlineInputBorder(),
              errorText: provider.showErrors ? provider.suggestionError : null,
            ),
            onChanged: provider.setSuggestion,
          ),
          const SizedBox(height: 12),

          // Tombol kirim, atau simpan perubahan saat mengubah
          if (!isEditing)
            ElevatedButton(
              onPressed: provider.saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: provider.saving ? _spinner() : const Text('Kirim'),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: provider.saving ? null : _cancelEdit,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: provider.saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: provider.saving
                        ? _spinner()
                        : const Text('Simpan perubahan'),
                  ),
                ),
              ],
            ),

          // Ringkasan kiriman terakhir (FR.FB.06)
          if (summary != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Ringkasan kiriman',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: provider.clearSummary,
                          icon: const Icon(Icons.close),
                          tooltip: 'Tutup',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        StarRating(rating: summary.rating, size: 18),
                        const SizedBox(width: 8),
                        Text(summary.statusLabel),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Kesan: ${summary.impression}'),
                    const SizedBox(height: 4),
                    Text('Saran: ${summary.suggestion}'),
                  ],
                ),
              ),
            ),
          ],

          // Riwayat kiriman (FR.FB.04)
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Riwayat Anda',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (provider.syncing)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  onPressed: provider.syncPending,
                  icon: const Icon(Icons.sync),
                  tooltip: 'Kirim yang masih menunggu',
                ),
            ],
          ),
          if (entries.isEmpty)
            const Text('Belum ada kiriman. Isi kesan dan saran di atas.')
          else
            for (final e in entries) _historyCard(e),
        ],
      ),
    );
  }
}
