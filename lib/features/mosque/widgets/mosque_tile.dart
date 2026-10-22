// M6 Masjid Terdekat (FR-LBS-12, FR-LBS-14)
import 'package:flutter/material.dart';

import '../models/mosque.dart';

class MosqueTile extends StatelessWidget {
  const MosqueTile({
    super.key,
    required this.mosque,
    required this.selected,
    required this.onTap,
    required this.onFavorite,
    required this.onRoute,
  });

  final Mosque mosque;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: selected ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.mosque_outlined),
        title: Text(mosque.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text([
          if (mosque.distanceLabel.isNotEmpty) mosque.distanceLabel,
          if (mosque.address != null && mosque.address!.isNotEmpty) mosque.address!,
        ].join(' • ')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: mosque.isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
              icon: Icon(mosque.isFavorite ? Icons.star : Icons.star_border),
              onPressed: onFavorite,
            ),
            IconButton(
              tooltip: 'Rute ke ${mosque.name}',
              icon: const Icon(Icons.directions),
              onPressed: onRoute,
            ),
          ],
        ),
      ),
    );
  }
}
