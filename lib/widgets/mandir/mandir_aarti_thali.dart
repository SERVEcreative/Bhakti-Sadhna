import 'package:bhakti_sadhana/core/assets/asset_paths.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:flutter/material.dart';

/// आरती थाली — animated `thali_diya.gif`।
class MandirAartiThali extends StatelessWidget {
  const MandirAartiThali({
    super.key,
    required this.archWidth,
    required this.archHeight,
  });

  final double archWidth;
  final double archHeight;

  static const double _gifAspect = 1536 / 864;

  @override
  Widget build(BuildContext context) {
    final thaliW = archWidth * 0.42;
    final thaliH = thaliW / _gifAspect;
    final cx = archWidth * 0.5;
    final cy = archHeight * 0.68;

    return Positioned(
      left: cx - thaliW / 2,
      top: cy - thaliH / 2,
      width: thaliW,
      height: thaliH,
      child: IgnorePointer(
        child: Image.asset(
          AssetPaths.mandirThaliDiyaGif,
          width: thaliW,
          height: thaliH,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => Icon(
            Icons.local_fire_department_rounded,
            size: thaliW * 0.5,
            color: BhaktiTheme.diyaGlow,
          ),
        ),
      ),
    );
  }
}
