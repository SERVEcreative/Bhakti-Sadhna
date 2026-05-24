import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/models/deity.dart';
import 'package:bhakti_sadhana/widgets/app_asset_image.dart';
import 'package:flutter/material.dart';

/// Deity photo with mandir-style gold frame; emoji fallback if image missing.
class DeityPortrait extends StatelessWidget {
  const DeityPortrait({
    super.key,
    required this.deity,
    this.size = 56,
    this.showFrame = true,
    this.borderRadius,
  });

  final Deity deity;
  final double size;
  final bool showFrame;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size * 0.22);

    Widget inner;
    if (deity.hasImage) {
      final px = assetCacheDimension(size, context);
      inner = ClipRRect(
        borderRadius: radius,
        child: AppAssetImage(
          assetPath: deity.imageAsset!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: px,
          cacheHeight: px,
          fallback: _emojiFallback(radius),
        ),
      );
    } else {
      inner = _emojiFallback(radius);
    }

    if (!showFrame) return SizedBox(width: size, height: size, child: inner);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: BhaktiTheme.gold.withValues(alpha: 0.75),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: inner,
      ),
    );
  }

  Widget _emojiFallback(BorderRadius radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: BhaktiTheme.cardGradient,
      ),
      alignment: Alignment.center,
      child: Text(deity.emoji, style: TextStyle(fontSize: size * 0.45)),
    );
  }
}

/// Wide banner portrait for detail screen.
class DeityPortraitBanner extends StatelessWidget {
  const DeityPortraitBanner({super.key, required this.deity});

  final Deity deity;

  @override
  Widget build(BuildContext context) {
    const height = 200.0;
    final radius = BorderRadius.circular(20);

    if (!deity.hasImage) {
      return DeityPortrait(
        deity: deity,
        size: 100,
        borderRadius: BorderRadius.circular(50),
      );
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: BhaktiTheme.diyaGlow.withValues(alpha: 0.3),
            blurRadius: 24,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppAssetImage(
              assetPath: deity.imageAsset!,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              cacheWidth: assetCacheDimension(height, context),
              cacheHeight: assetCacheDimension(height, context),
              fallback: Center(
                child: Text(deity.emoji, style: const TextStyle(fontSize: 64)),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    BhaktiTheme.maroonDeep.withValues(alpha: 0.85),
                  ],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
