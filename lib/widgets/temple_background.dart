import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:flutter/material.dart';

/// Full-screen mandir atmosphere — gradient sky + subtle diya glow orbs.
class TempleBackground extends StatelessWidget {
  const TempleBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: BhaktiTheme.templeSky),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: Stack(
              fit: StackFit.expand,
              children: const [
                _GlowOrb(top: 80, left: 30, size: 120, opacity: 0.12),
                _GlowOrb(top: 200, right: 20, size: 90, opacity: 0.08),
                _GlowOrb(bottom: 120, left: 60, size: 70, opacity: 0.1),
                CustomPaint(painter: _MandalaPainter()),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.opacity,
  });

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: BhaktiTheme.diyaGlow.withValues(alpha: opacity),
                blurRadius: size * 0.5,
                spreadRadius: size * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MandalaPainter extends CustomPainter {
  const _MandalaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BhaktiTheme.gold.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final center = Offset(size.width / 2, size.height * 0.15);
    for (var r = 40.0; r < 180; r += 40) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
