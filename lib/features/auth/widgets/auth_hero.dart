import 'package:flutter/material.dart';

/// Ilustrasi siluet masjid dan lanskap untuk layar Login (design.md bagian 1).
class AuthHero extends StatelessWidget {
  const AuthHero({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final dark = s.brightness == Brightness.dark;
    return AspectRatio(
      aspectRatio: _w / _h,
      child: CustomPaint(
        painter: _HeroPainter(
          sky: s.primaryContainer,
          ground: s.surface,
          gold: s.secondary,
          cloud: s.surfaceContainerLowest,
          hillBack: Color.alphaBlend(s.primary.withValues(alpha: 0.35), s.primaryContainer),
          hillFront: Color.alphaBlend(s.primary.withValues(alpha: 0.55), s.primaryContainer),
          mosque: dark ? s.surfaceContainerLowest : s.onPrimaryContainer,
        ),
      ),
    );
  }
}

const double _w = 400;
const double _h = 230;

class _HeroPainter extends CustomPainter {
  _HeroPainter({
    required this.sky,
    required this.ground,
    required this.gold,
    required this.cloud,
    required this.hillBack,
    required this.hillFront,
    required this.mosque,
  });

  final Color sky, ground, gold, cloud, hillBack, hillFront, mosque;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _w);
    final bg = const Rect.fromLTWH(0, 0, _w, _h);
    canvas.drawRect(
      bg,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sky, ground],
        ).createShader(bg),
    );

    canvas.drawCircle(const Offset(326, 52), 22, Paint()..color = gold);
    canvas.drawCircle(const Offset(337, 46), 20, Paint()..color = sky);

    final cloudPaint = Paint()..color = cloud.withValues(alpha: 0.85);
    for (final c in const [
      Rect.fromLTWH(36, 48, 68, 24),
      Rect.fromLTWH(72, 40, 48, 24),
      Rect.fromLTWH(270, 110, 60, 20),
    ]) {
      canvas.drawOval(c, cloudPaint);
    }

    canvas.drawPath(
      Path()
        ..moveTo(0, 190)
        ..quadraticBezierTo(100, 140, 200, 178)
        ..quadraticBezierTo(300, 216, 400, 160)
        ..lineTo(400, _h)
        ..lineTo(0, _h)
        ..close(),
      Paint()..color = hillBack,
    );

    canvas.drawCircle(
      const Offset(200, 150),
      64,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = gold.withValues(alpha: 0.6),
    );

    final m = Paint()..color = mosque;
    canvas.drawPath(
      Path()
        ..moveTo(160, 182)
        ..lineTo(160, 157)
        ..arcToPoint(const Offset(240, 157), radius: const Radius.circular(40))
        ..lineTo(240, 182)
        ..close(),
      m,
    );
    canvas.drawRect(const Rect.fromLTWH(198, 106, 4, 14), m);
    canvas.drawRect(const Rect.fromLTWH(156, 180, 88, 22), m);
    for (final x in const [134.0, 254.0]) {
      canvas.drawRect(Rect.fromLTWH(x, 132, 12, 70), m);
      canvas.drawPath(
        Path()
          ..moveTo(x, 132)
          ..lineTo(x + 6, 118)
          ..lineTo(x + 12, 132)
          ..close(),
        m,
      );
    }

    canvas.drawPath(
      Path()
        ..moveTo(0, 214)
        ..quadraticBezierTo(120, 180, 240, 208)
        ..quadraticBezierTo(360, 236, 400, 196)
        ..lineTo(400, _h)
        ..lineTo(0, _h)
        ..close(),
      Paint()..color = hillFront,
    );
  }

  @override
  bool shouldRepaint(_HeroPainter old) =>
      old.sky != sky ||
      old.ground != ground ||
      old.gold != gold ||
      old.cloud != cloud ||
      old.hillBack != hillBack ||
      old.hillFront != hillFront ||
      old.mosque != mosque;
}
