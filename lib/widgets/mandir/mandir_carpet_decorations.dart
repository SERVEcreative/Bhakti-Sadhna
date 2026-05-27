import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:flutter/material.dart';

/// थाली और bottom nav के बीच — लाल-कालीन trapezium + शंख।
class MandirCarpetDecorations extends StatelessWidget {
  const MandirCarpetDecorations({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: const [
        CustomPaint(painter: _TrapeziumCarpetPainter()),
      ],
    );
  }
}

/// ऊपर संकर, नीचे चौड़ा — लाल / काला gradient।
class _TrapeziumCarpetPainter extends CustomPainter {
  const _TrapeziumCarpetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final topInset = w * 0.14;

    final path = Path()
      ..moveTo(topInset, 0)
      ..lineTo(w - topInset, 0)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0D0202),
          Color(0xFF2D0808),
          Color(0xFF6B1010),
          Color(0xFF9B1C1C),
          Color(0xFF7A1212),
        ],
        stops: [0.0, 0.2, 0.45, 0.78, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, fill);

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = BhaktiTheme.gold.withValues(alpha: 0.45);
    canvas.drawPath(path, edge);

    final fold = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.35));
    canvas.drawPath(path, fold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

