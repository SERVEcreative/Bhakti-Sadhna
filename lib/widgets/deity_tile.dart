import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/models/deity.dart';
import 'package:bhakti_sadhana/widgets/app_asset_image.dart';
import 'package:bhakti_sadhana/widgets/deity_portrait.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeityTile extends StatelessWidget {
  const DeityTile({super.key, required this.deity, required this.onTap});

  final Deity deity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: BhaktiTheme.cardGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: BhaktiTheme.gold.withValues(alpha: 0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                DeityPortrait(deity: deity, size: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(deity.name, style: BhaktiTheme.titleHi.copyWith(fontSize: 19)),
                      if (deity.tagline.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(deity.tagline, style: BhaktiTheme.labelSub),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: BhaktiTheme.goldLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Grid card with large deity photo for selection screen.
class DeityGridCard extends StatelessWidget {
  const DeityGridCard({super.key, required this.deity, required this.onTap});

  final Deity deity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cachePx = assetCacheDimension(140, context);

    return RepaintBoundary(
      child: GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: BhaktiTheme.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: deity.hasImage
                    ? AppAssetImage(
                        assetPath: deity.imageAsset!,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        cacheWidth: cachePx,
                        cacheHeight: cachePx,
                        fallback: _fallback(),
                      )
                    : _fallback(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                children: [
                  Text(
                    deity.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: BhaktiTheme.titleHi.copyWith(fontSize: 14),
                  ),
                  if (deity.tagline.isNotEmpty)
                    Text(
                      deity.tagline,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BhaktiTheme.labelSub.copyWith(fontSize: 10),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _fallback() {
    return Container(
      color: BhaktiTheme.maroon,
      alignment: Alignment.center,
      child: Text(deity.emoji, style: const TextStyle(fontSize: 40)),
    );
  }
}
