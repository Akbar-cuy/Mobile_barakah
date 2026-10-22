// M7 Arah Kiblat (FR-QBL-02, AC-QBL-02, AC-QBL-05)
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Piringan kompas. Piringan berputar mengikuti heading sehingga huruf U
/// selalu menunjuk utara sejati, penanda Ka'bah berada pada sudut kiblat, dan
/// panah tetap di atas menunjuk arah yang dihadapi ponsel. Menghadap kiblat
/// berarti penanda Ka'bah tepat di bawah panah.
///
/// Tanpa sensor, [headingDegrees] bernilai 0 dan piringan diam sebagai sudut
/// statis (AC-QBL-05).
class CompassDial extends StatelessWidget {
  const CompassDial({
    super.key,
    required this.headingDegrees,
    required this.qiblaBearing,
    this.aligned = false,
    this.dimmed = false,
  });

  /// Heading kontinu (tidak dibungkus 0 sampai 360) agar putaran tidak melonjak.
  final double headingDegrees;
  final double? qiblaBearing;
  final bool aligned;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = theme.extension<AppStatusColors>() ?? AppStatusColors.light;
    final ringColor = aligned ? status.success : theme.colorScheme.primary;

    return Semantics(
      label: aligned
          ? 'Kompas kiblat. Perangkat menghadap kiblat.'
          : 'Kompas kiblat',
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedRotation(
              turns: -headingDegrees / 360,
              duration: const Duration(milliseconds: 120),
              child: CustomPaint(
                size: Size.infinite,
                painter: _DialPainter(
                  ringColor: dimmed ? theme.colorScheme.outline : ringColor,
                  tickColor: theme.colorScheme.onSurfaceVariant,
                  northColor: theme.colorScheme.error,
                  textColor: theme.colorScheme.onSurface,
                  qiblaColor: theme.colorScheme.secondary,
                  fill: theme.colorScheme.surfaceContainerLowest,
                  qiblaBearing: qiblaBearing,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Icon(
                Icons.arrow_drop_down,
                size: 44,
                color: aligned ? status.success : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.ringColor,
    required this.tickColor,
    required this.northColor,
    required this.textColor,
    required this.qiblaColor,
    required this.fill,
    required this.qiblaBearing,
  });

  final Color ringColor;
  final Color tickColor;
  final Color northColor;
  final Color textColor;
  final Color qiblaColor;
  final Color fill;
  final double? qiblaBearing;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 22;

    canvas.drawCircle(center, radius, Paint()..color = fill);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = ringColor,
    );

    final tick = Paint()
      ..color = tickColor
      ..strokeWidth = 2;
    for (var deg = 0; deg < 360; deg += 30) {
      final major = deg % 90 == 0;
      final a = _rad(deg.toDouble());
      final outer = center + Offset(math.sin(a), -math.cos(a)) * (radius - 8);
      final inner =
          center + Offset(math.sin(a), -math.cos(a)) * (radius - (major ? 24 : 16));
      canvas.drawLine(inner, outer, tick);
    }

    const labels = {0: 'U', 90: 'T', 180: 'S', 270: 'B'};
    labels.forEach((deg, text) {
      final a = _rad(deg.toDouble());
      final pos = center + Offset(math.sin(a), -math.cos(a)) * (radius - 42);
      _text(canvas, text, pos, deg == 0 ? northColor : textColor, 20);
    });

    final bearing = qiblaBearing;
    if (bearing != null) {
      final a = _rad(bearing);
      final dir = Offset(math.sin(a), -math.cos(a));
      canvas.drawLine(
        center,
        center + dir * (radius - 64),
        Paint()
          ..color = qiblaColor
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
      final marker = center + dir * (radius - 64);
      canvas.drawCircle(marker, 17, Paint()..color = qiblaColor);
      _text(canvas, 'K', marker, Colors.white, 18);
    }
    canvas.drawCircle(center, 6, Paint()..color = ringColor);
  }

  static double _rad(double deg) => deg * math.pi / 180;

  void _text(Canvas canvas, String text, Offset center, Color color, double size) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.ringColor != ringColor ||
      old.qiblaBearing != qiblaBearing ||
      old.fill != fill;
}
