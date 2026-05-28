import 'dart:async';

import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/services/katha_tts/katha_tts_service.dart';
import 'package:bhakti_sadhana/widgets/ads/puja_section_banner_shell.dart';
import 'package:bhakti_sadhana/widgets/temple_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// कथा सुनें — TTS से अनुच्छेद-दर-अनुच्छेद।
class KathaListenScreen extends StatefulWidget {
  const KathaListenScreen({
    super.key,
    required this.title,
    required this.texts,
    this.autoStart = false,
  });

  final String title;
  final List<String> texts;

  /// Web पर ब्राउज़र को यूज़र टैप चाहिए — डिफ़ॉल्ट false।
  final bool autoStart;

  @override
  State<KathaListenScreen> createState() => _KathaListenScreenState();
}

class _KathaListenScreenState extends State<KathaListenScreen> {
  final _tts = KathaTtsService.instance;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_tts.playAll(widget.texts));
      });
    }
  }

  @override
  void dispose() {
    unawaited(_tts.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.title,
          style: BhaktiTheme.titleHi.copyWith(fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: TempleBackground(
        child: SafeArea(
          child: PujaSectionBannerShell(
            child: ValueListenableBuilder<KathaTtsSnapshot>(
            valueListenable: _tts.snapshot,
            builder: (context, snap, _) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      snap.isActive
                          ? AppStrings.kathaListenNow
                          : AppStrings.kathaTapToPlay,
                      textAlign: TextAlign.center,
                      style: BhaktiTheme.labelSub.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: BhaktiTheme.cardGradient,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: snap.isPlaying
                                ? BhaktiTheme.saffronLight
                                : BhaktiTheme.gold.withValues(alpha: 0.45),
                            width: snap.isPlaying ? 2 : 1,
                          ),
                          boxShadow: [
                            if (snap.isPlaying)
                              BoxShadow(
                                color: BhaktiTheme.diyaGlow.withValues(alpha: 0.25),
                                blurRadius: 20,
                              ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            snap.currentText.isNotEmpty
                                ? snap.currentText
                                : (widget.texts.isNotEmpty ? widget.texts.first : ''),
                            textAlign: TextAlign.center,
                            style: BhaktiTheme.bodyHi.copyWith(
                              fontSize: 19,
                              height: 1.75,
                              color: BhaktiTheme.cream,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (snap.total > 0)
                      Text(
                        '${AppStrings.kathaPartLabel} ${snap.currentIndex + 1} / ${snap.total}',
                        textAlign: TextAlign.center,
                        style: BhaktiTheme.titleHi.copyWith(fontSize: 17),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ListenControl(
                          icon: Icons.skip_previous_rounded,
                          label: AppStrings.kathaPrev,
                          onTap: snap.total > 0 ? _tts.previous : null,
                        ),
                        const SizedBox(width: 12),
                        _ListenControl(
                          icon: snap.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          label: snap.isPlaying
                              ? AppStrings.aartiPause
                              : AppStrings.aartiPlay,
                          highlighted: snap.isPlaying,
                          onTap: () {
                            if (snap.isPlaying) {
                              unawaited(_tts.pause());
                            } else if (snap.isPaused) {
                              unawaited(_tts.resume());
                            } else {
                              unawaited(_tts.playAll(widget.texts, startIndex: snap.currentIndex));
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _ListenControl(
                          icon: Icons.skip_next_rounded,
                          label: AppStrings.kathaNext,
                          onTap: snap.total > 0 ? _tts.next : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => unawaited(_tts.stop()),
                      icon: const Icon(Icons.stop_circle_outlined, color: BhaktiTheme.creamDim),
                      label: Text(
                        AppStrings.aartiStop,
                        style: BhaktiTheme.bodyHi.copyWith(color: BhaktiTheme.creamDim),
                      ),
                    ),
                    if (snap.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.kathaTtsError,
                        textAlign: TextAlign.center,
                        style: BhaktiTheme.bodyHi.copyWith(
                          fontSize: 13,
                          color: BhaktiTheme.lotusPink,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          ),
        ),
      ),
    );
  }
}

class _ListenControl extends StatelessWidget {
  const _ListenControl({
    required this.icon,
    required this.label,
    this.highlighted = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Opacity(
              opacity: enabled ? 1 : 0.35,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: highlighted ? BhaktiTheme.goldShimmer : BhaktiTheme.cardGradient,
                  border: Border.all(color: BhaktiTheme.gold),
                ),
                child: Icon(icon, size: 30, color: BhaktiTheme.maroonDeep),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: BhaktiTheme.labelSub.copyWith(fontSize: 10)),
      ],
    );
  }
}
