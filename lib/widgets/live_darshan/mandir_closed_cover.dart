import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/widgets/live_darshan/live_darshan_overlay_scaffold.dart';
import 'package:flutter/material.dart';

/// लाइव बंद — कॉम्पैक्ट (16:9 बॉक्स में overflow नहीं)।
class MandirClosedCover extends StatelessWidget {
  const MandirClosedCover({
    super.key,
    required this.templeName,
    this.onRefresh,
    this.onOpenYoutube,
    this.showRefresh = true,
  });

  final String templeName;
  final VoidCallback? onRefresh;
  final VoidCallback? onOpenYoutube;
  final bool showRefresh;

  @override
  Widget build(BuildContext context) {
    return LiveDarshanOverlayScaffold(
      color: const Color(0xFF140404),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.nights_stay_rounded,
            size: 28,
            color: BhaktiTheme.gold.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.liveDarshanTempleClosed,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BhaktiTheme.displayHi.copyWith(
              fontSize: 15,
              color: BhaktiTheme.cream.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            templeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: BhaktiTheme.titleHi.copyWith(
              fontSize: 12,
              color: BhaktiTheme.goldLight.withValues(alpha: 0.75),
            ),
          ),
          if (onOpenYoutube != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenYoutube,
                icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppStrings.liveDarshanOpenYoutube,
                    style: BhaktiTheme.titleHi.copyWith(
                      fontSize: 11,
                      color: BhaktiTheme.maroonDeep,
                    ),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: BhaktiTheme.saffron,
                  foregroundColor: BhaktiTheme.maroonDeep,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
          if (showRefresh && onRefresh != null)
            TextButton(
              onPressed: onRefresh,
              style: TextButton.styleFrom(
                foregroundColor: BhaktiTheme.saffronLight,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppStrings.liveDarshanRefresh,
                style: BhaktiTheme.titleHi.copyWith(fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}
