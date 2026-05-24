import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/models/worship_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CategoryCard extends StatefulWidget {
  const CategoryCard({super.key, required this.category, required this.onTap});

  final WorshipCategory category;
  final VoidCallback onTap;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _pressed = false;

  static const _outerRadius = 22.0;
  static const _innerPadding = 10.0;
  static const _imageRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context).round();
    final imageCachePx = (140 * dpr).clamp(128, 384);

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_outerRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  BhaktiTheme.maroon.withValues(alpha: 0.95),
                  BhaktiTheme.maroonDeep.withValues(alpha: 0.98),
                ],
              ),
              border: Border.all(
                color: BhaktiTheme.gold.withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: Offset(0, _pressed ? 3 : 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(_innerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_imageRadius),
                        color: BhaktiTheme.maroonDeep.withValues(alpha: 0.5),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(_imageRadius - 1),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            widget.category.imageAsset,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            filterQuality: FilterQuality.medium,
                            cacheWidth: imageCachePx,
                            cacheHeight: imageCachePx,
                            gaplessPlayback: true,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Icon(
                                widget.category.icon,
                                size: 48,
                                color:
                                    BhaktiTheme.gold.withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: BhaktiTheme.maroonDeep.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                widget.category.icon,
                                size: 16,
                                color: BhaktiTheme.goldLight,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.category.label,
                                  style: BhaktiTheme.titleHi.copyWith(
                                    fontSize: 15,
                                    height: 1.15,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.category.subtitle,
                            style: BhaktiTheme.labelSub.copyWith(
                              fontSize: 11,
                              color: BhaktiTheme.cream.withValues(alpha: 0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
