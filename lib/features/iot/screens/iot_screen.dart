// M21 IoT Opsional (FR-IOT-01, FR-IOT-02)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../models/iot_device.dart';
import '../providers/iot_provider.dart';

class IotScreen extends ConsumerWidget {
  const IotScreen({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final c = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daftarkan perangkat'),
        content: TextField(
          controller: c,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(hintText: 'Nama, mis. Tasbih meja'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text.trim()),
            child: const Text('Daftar'),
          ),
        ],
      ),
    );
    c.dispose();
    if (name == null || name.isEmpty || !context.mounted) return;
    try {
      final device = await ref.read(iotActionsProvider).register(name);
      if (context.mounted) await _showToken(context, device);
    } on IotException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message);
    }
  }

  Future<void> _showToken(BuildContext context, IotDevice d) {
    final token = d.token;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Perangkat terdaftar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan ID dan token ini ke firmware perangkat.'),
            const SizedBox(height: AppSpacing.md),
            const Text('ID perangkat'),
            SelectableText(d.id),
            if (token != null) ...[
              const SizedBox(height: AppSpacing.md),
              const Text('Token (hanya ditampilkan sekali)'),
              SelectableText(token),
            ],
          ],
        ),
        actions: [
          if (token != null)
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: token));
                if (ctx.mounted) showAppSnackBar(ctx, 'Token disalin');
              },
              child: const Text('Salin token'),
            ),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Selesai')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final devices = ref.watch(iotDevicesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tasbih Fisik (IoT)')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Daftarkan'),
      ),
      body: devices.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Daftar perangkat tidak dapat dibaca.')),
        data: (list) => list.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: Text(
                    'Belum ada perangkat. Daftarkan ESP32 tasbih Anda agar hitungan dan jadwal sholat berikutnya tersinkron.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.page),
                children: [
                  for (final d in list)
                    Card(
                      elevation: 0,
                      child: ListTile(
                        leading: const Icon(Icons.sensors),
                        title: Text(d.name),
                        subtitle: Text(d.id, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          tooltip: 'Hapus dari daftar',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => ref.read(iotActionsProvider).forget(d.id),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
