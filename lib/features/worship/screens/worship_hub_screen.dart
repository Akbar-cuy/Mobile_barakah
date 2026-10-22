// M16 Beranda Ibadah (FR-HUB). Pintu masuk seluruh fitur.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/feature_search_provider.dart';
import '../widgets/feature_tile.dart';

class WorshipHubScreen extends ConsumerWidget {
  const WorshipHubScreen({super.key});

  void _open(BuildContext context, WorshipFeature feature) {
    final route = feature.route;
    if (route == null) {
      showAppSnackBar(context, '${feature.title} belum tersedia.');
      return;
    }
    feature.isTab ? context.go(route) : context.push(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(filteredFeaturesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ibadah')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.md,
            ),
            child: TextField(
              onChanged: ref.read(featureQueryProvider.notifier).set,
              decoration: const InputDecoration(
                hintText: 'Cari fitur',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: features.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    title: 'Fitur tidak ditemukan',
                    message: 'Coba kata kunci lain.',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.page),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: features.length,
                    itemBuilder: (_, i) => FeatureTile(
                      feature: features[i],
                      onTap: () => _open(context, features[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
