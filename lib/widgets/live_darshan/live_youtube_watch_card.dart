import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/widgets/live_darshan/live_darshan_overlay_scaffold.dart';
import 'package:flutter/material.dart';

/// लाइव मिला — YouTube बटन (कॉम्पैक्ट, player box के अंदर)।
class LiveYoutubeWatchCard extends StatelessWidget {
  const LiveYoutubeWatchCard({
    super.key,
    required this.templeName,
    required this.onWatchYoutube,
    this.onTryInApp,
    this.showTryInApp = true,
  });

  final String templeName;
  final VoidCallback onWatchYoutube;
  final VoidCallback? onTryInApp;
  final bool showTryInApp;

  @override
  Widget build(BuildContext context) {
    return LiveDarshanOverlayScaffold(
      color: const Color(0xFF140404),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LivePulseBadge(),
          const SizedBox(height: 8),
          Text(
            templeName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BhaktiTheme.titleHi.copyWith(
              fontSize: 13,
              color: BhaktiTheme.goldLight,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onWatchYoutube,
              icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppStrings.liveDarshanWatchOnYoutube,
                  style: BhaktiTheme.titleHi.copyWith(
                    fontSize: 12,
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (showTryInApp && onTryInApp != null)
            TextButton(
              onPressed: onTryInApp,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                AppStrings.liveDarshanTryInApp,
                style: BhaktiTheme.labelSub.copyWith(
                  fontSize: 10,
                  color: BhaktiTheme.cream.withValues(alpha: 0.55),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LivePulseBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFB71C1C).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF5252).withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFFFF4444),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            AppStrings.liveDarshanLiveNow,
            style: BhaktiTheme.labelSub.copyWith(
              color: const Color(0xFFFF8A80),
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
