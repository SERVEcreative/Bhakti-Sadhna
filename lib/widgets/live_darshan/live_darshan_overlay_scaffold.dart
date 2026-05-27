import 'package:flutter/material.dart';

/// 16:9 player box — सीमित ऊँचाई में, overflow बिना।
class LiveDarshanOverlayScaffold extends StatelessWidget {
  const LiveDarshanOverlayScaffold({
    super.key,
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: ClipRect(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Align(
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
