import 'package:flutter/material.dart';

// Penilaian bintang 1 sampai 5.
// Bila onChanged diisi, bintang bisa diketuk. Bila null, hanya tampil.
class StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.amber.shade700;

    // Mode tampil saja (dipakai di riwayat dan ringkasan)
    if (onChanged == null) {
      return Semantics(
        label: 'Penilaian $rating dari 5 bintang',
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 1; i <= 5; i++)
                Icon(
                  i <= rating ? Icons.star : Icons.star_border,
                  size: size,
                  color: color,
                ),
            ],
          ),
        ),
      );
    }

    // Mode bisa diketuk (dipakai di form)
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          IconButton(
            onPressed: () => onChanged!(i),
            tooltip: '$i bintang',
            icon: Icon(
              i <= rating ? Icons.star : Icons.star_border,
              size: size,
              color: color,
            ),
          ),
      ],
    );
  }
}
