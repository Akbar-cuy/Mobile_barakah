// M8 Tasbih Digital (FR-TSB-02)
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Cincin kemajuan hitungan dengan isi di tengah.
class CounterRing extends StatelessWidget {
  const CounterRing({
    super.key,
    required this.progress,
    required this.child,
    this.size = 240,
    this.strokeWidth = 14,
  });

  /// 0..1
  final double progress;
  final Widget child;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          track: scheme.surfaceContainerHighest,
          color: progress >= 1 ? scheme.tertiary : scheme.primary,
          strokeWidth: strokeWidth,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color track;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arc = rect.deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arc, 0, math.pi * 2, false, paint..color = track);
    if (progress > 0) {
      canvas.drawArc(arc, -math.pi / 2, math.pi * 2 * progress, false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
