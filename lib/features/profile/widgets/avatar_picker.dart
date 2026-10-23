// M17 Profil (FR-PRO-03). Foto tautan, dengan inisial sebagai cadangan.
import 'package:flutter/material.dart';

class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.initials,
    this.url,
    this.radius = 44,
    this.onEdit,
  });

  final String initials;
  final String? url;
  final double radius;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasUrl = url != null && url!.trim().isNotEmpty;
    final fallback = Text(
      initials,
      style: Theme.of(context)
          .textTheme
          .headlineMedium
          ?.copyWith(color: scheme.onPrimaryContainer),
    );
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: scheme.primaryContainer,
          child: hasUrl
              ? ClipOval(
                  child: Image.network(
                    url!,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => fallback,
                  ),
                )
              : fallback,
        ),
        if (onEdit != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: IconButton.filled(
              tooltip: 'Ubah foto',
              iconSize: 18,
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
            ),
          ),
      ],
    );
  }
}
