// M5 Pusat Ibadah dan Pencarian (FR-SRC-01, FR-SRC-02)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/feature_search_provider.dart';
import '../widgets/feature_tile.dart';

class WorshipHubScreen extends ConsumerWidget {
  const WorshipHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final query = ref.watch(featureQueryProvider);
    final features = ref.watch(filteredFeaturesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ibadah')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          TextField(
            onChanged: ref.read(featureQueryProvider.notifier).set,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cari fitur',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (features.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Center(
                child: Text('Tidak ada fitur untuk "$query".',
                    textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
              ),
            ),
          for (final group in FeatureGroup.values)
            ..._section(context, group, [for (final f in features) if (f.group == group) f]),
        ],
      ),
    );
  }

  List<Widget> _section(BuildContext context, FeatureGroup group, List<AppFeature> items) {
    if (items.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.sm),
        child: Text(group.label, style: Theme.of(context).textTheme.titleMedium),
      ),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.25,
        children: [
          for (final f in items) FeatureTile(feature: f, onTap: () => context.push(f.route)),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
    ];
  }
}
