import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/widgets/app_asset_image.dart';
import 'package:flutter/material.dart';

/// मंदिर टैब — देवता नाम, छोटा दर्शन, स्वाइप संकेत।
class MandirTopBar extends StatelessWidget {
  const MandirTopBar({
    super.key,
    required this.deityName,
    required this.deityImagePath,
    required this.pageIndex,
    required this.totalCount,
  });

  final String deityName;
  final String deityImagePath;
  final int pageIndex;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BhaktiTheme.maroonDeep,
            BhaktiTheme.maroonDeep.withValues(alpha: 0.98),
            BhaktiTheme.maroon.withValues(alpha: 0.92),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: BhaktiTheme.gold.withValues(alpha: 0.55),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _DeityAvatar(assetPath: deityImagePath),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.mandirGarbhagriha,
                      style: BhaktiTheme.labelSub.copyWith(
                        fontSize: 11,
                        letterSpacing: 1.4,
                        color: BhaktiTheme.gold.withValues(alpha: 0.85),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Text(
                        deityName,
                        key: ValueKey(deityName),
                        style: BhaktiTheme.displayHi.copyWith(fontSize: 22),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swipe_rounded,
                  size: 16,
                  color: BhaktiTheme.textMuted.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    AppStrings.mandirPhotoSwipeHint,
                    style: BhaktiTheme.labelSub.copyWith(fontSize: 11.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _DeityDots(
              count: totalCount,
              index: pageIndex,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeityAvatar extends StatelessWidget {
  const _DeityAvatar({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: BhaktiTheme.goldShimmer,
        boxShadow: [
          BoxShadow(
            color: BhaktiTheme.diyaGlow.withValues(alpha: 0.25),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.5),
      child: ClipOval(
        child: ColoredBox(
          color: const Color(0xFF0D0202),
          child: AppAssetImage(
            key: ValueKey(assetPath),
            assetPath: assetPath,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            width: 52,
            height: 52,
            cacheWidth: 104,
            cacheHeight: 104,
            fallback: Center(
              child: Text(
                'ॐ',
                style: BhaktiTheme.displayHi.copyWith(
                  fontSize: 18,
                  color: BhaktiTheme.gold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeityDots extends StatelessWidget {
  const _DeityDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: active
                ? BhaktiTheme.gold
                : BhaktiTheme.gold.withValues(alpha: 0.28),
          ),
        );
      }),
    );
  }
}
