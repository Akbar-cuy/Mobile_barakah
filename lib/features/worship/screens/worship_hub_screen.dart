// M5 Pusat Ibadah dan Pencarian (FR-SRC-01, FR-SRC-02)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/feature_search_provider.dart';
import '../widgets/feature_tile.dart';

class WorshipHubScreen extends ConsumerWidget {
  const WorshipHubScreen({super.key});

  void _open(BuildContext context, AppFeature feature) {
    if (feature.route == RouteNames.home) {
      context.go(feature.route);
    } else {
      context.push(feature.route);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(featureQueryProvider);
    final features = ref.watch(filteredFeaturesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ibadah')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.sm,
              AppSpacing.page,
              AppSpacing.md,
            ),
            child: TextField(
              onChanged: ref.read(featureQueryProvider.notifier).set,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Cari fitur',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: features.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'Fitur tidak ditemukan',
                    message: 'Tidak ada fitur untuk "$query". Coba kata kunci lain.',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      0,
                      AppSpacing.page,
                      AppSpacing.page,
                    ),
                    children: [
                      for (final group in FeatureGroup.values)
                        ..._section(
                          context,
                          group,
                          features.where((f) => f.group == group).toList(),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    FeatureGroup group,
    List<AppFeature> items,
  ) {
    if (items.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.sm),
        child: Text(group.label, style: Theme.of(context).textTheme.titleMedium),
      ),
      GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final feature = items[index];
          return FeatureTile(
            feature: feature,
            onTap: () => _open(context, feature),
          );
        },
      ),
      const SizedBox(height: AppSpacing.md),
    ];
  }
}
