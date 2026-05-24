import 'dart:ui';

import 'package:flutter/material.dart';

/// Neeche patli glass पट्टी — पूरी तस्वीर ऊपर साफ दिखे।
class GlassBottomBar extends StatelessWidget {
  const GlassBottomBar({
    super.key,
    required this.child,
    this.heightFraction = 0.36,
    this.blur = 10,
  });

  final Widget child;
  final double heightFraction;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: heightFraction,
        widthFactor: 1,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
