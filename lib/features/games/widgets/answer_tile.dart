import 'package:flutter/material.dart';

// Keadaan satu pilihan jawaban
enum AnswerState {
  normal, // belum dijawab
  correct, // jawaban yang benar
  wrong, // jawaban yang dipilih tapi salah
  dimmed, // pilihan lain setelah soal dijawab
}

// Satu pilihan jawaban (A, B, C, D) pada layar soal
class AnswerTile extends StatelessWidget {
  final String letter;
  final String text;
  final AnswerState state;
  final VoidCallback? onTap;

  const AnswerTile({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? background;
    IconData? icon;

    if (state == AnswerState.correct) {
      background = Colors.green.withAlpha(60);
      icon = Icons.check_circle;
    } else if (state == AnswerState.wrong) {
      background = Colors.red.withAlpha(60);
      icon = Icons.cancel;
    }

    final dimmed = state == AnswerState.dimmed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: dimmed ? 0.5 : 1,
        child: Card(
          margin: EdgeInsets.zero,
          color: background,
          child: ListTile(
            minVerticalPadding: 14,
            leading: CircleAvatar(
              radius: 16,
              child: Text(letter),
            ),
            title: Text(text),
            trailing: icon == null ? null : Icon(icon),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
