// M18 Saran dan Kesan (FR-FB-01). Penilaian bintang 1 sampai 5.
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 36,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    final stars = [
      for (var i = 1; i <= 5; i++)
        Icon(
          i <= value ? Icons.star : Icons.star_border,
          size: size,
          color: color,
        ),
    ];

    if (onChanged == null) {
      return Semantics(
        label: 'Penilaian $value dari 5 bintang',
        child: ExcludeSemantics(
          child: Row(mainAxisSize: MainAxisSize.min, children: stars),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            tooltip: '$i bintang',
            iconSize: size,
            padding: EdgeInsets.zero,
            constraints:
                BoxConstraints(minWidth: size + 8, minHeight: size + 8),
            color: color,
            icon: stars[i - 1],
            onPressed: () => onChanged!(i),
          ),
      ],
    );
  }
}
