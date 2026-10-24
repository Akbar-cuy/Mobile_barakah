import 'package:flutter/material.dart';

class AnswerTile extends StatelessWidget {
  const AnswerTile({
    super.key,
    required this.label,
    required this.text,
    required this.selected,
    required this.correct,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool selected;
  final bool correct;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = correct
        ? colors.primaryContainer
        : selected
            ? colors.errorContainer
            : colors.surfaceContainerHighest;
    return Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                child: Text(label),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
              if (correct) const Icon(Icons.check_circle_outline),
              if (selected && !correct) const Icon(Icons.cancel_outlined),
            ],
          ),
        ),
      ),
    );
  }
}
