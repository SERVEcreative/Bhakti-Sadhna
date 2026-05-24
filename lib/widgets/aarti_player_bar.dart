import 'package:bhakti_sadhana/bootstrap/supabase_bootstrap.dart';
import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/services/aarti_player/aarti_player_service.dart';
import 'package:flutter/material.dart';

class AartiPlayerBar extends StatelessWidget {
  const AartiPlayerBar({
    super.key,
    required this.aartiId,
    required this.title,
  });

  final String aartiId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final service = AartiPlayerService.instance;

    return ValueListenableBuilder<AartiPlaybackSnapshot>(
      valueListenable: service.snapshot,
      builder: (context, snap, _) {
        final isThis = snap.aartiId == aartiId;
        final supabaseReady = SupabaseBootstrap.initialized;

        final isLoading = isThis && snap.isLoading;
        final isPlaying = isThis && (snap.isPlaying || (snap.audioPlaying && !snap.isPaused));
        final isPaused = isThis && snap.isPaused;
        final isActive = isThis && snap.isActive;
        final hasError = isThis && snap.status == AartiPlayerStatus.error;

        // Play: दूसरी आरती या यही रुकी हुई / idle / error
        final playEnabled = supabaseReady &&
            !isLoading &&
            (!isThis || isPaused || hasError || (!isPlaying && !isLoading));

        // Pause: यही आरती चल रही या load हो रही
        final pauseEnabled = supabaseReady && isThis && (isPlaying || isLoading);

        final showSeek = isThis && isActive && !isLoading;
        final duration = isThis ? (snap.duration ?? Duration.zero) : Duration.zero;
        final position = isThis ? snap.position : Duration.zero;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            gradient: BhaktiTheme.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlaying ? BhaktiTheme.saffronLight : BhaktiTheme.gold.withValues(alpha: 0.45),
              width: isPlaying ? 1.5 : 1,
            ),
            boxShadow: [
              if (isPlaying)
                BoxShadow(
                  color: BhaktiTheme.diyaGlow.withValues(alpha: 0.2),
                  blurRadius: 14,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _RoundControl(
                    icon: Icons.play_arrow_rounded,
                    label: AppStrings.aartiPlay,
                    enabled: playEnabled,
                    highlighted: isPlaying,
                    onTap: () => service.play(aartiId),
                  ),
                  const SizedBox(width: 8),
                  _RoundControl(
                    icon: Icons.pause_rounded,
                    label: AppStrings.aartiPause,
                    enabled: pauseEnabled,
                    highlighted: isPaused,
                    onTap: service.pause,
                  ),
                  if (isLoading) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: BhaktiTheme.gold,
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.aartiListen,
                          style: BhaktiTheme.labelSub.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: BhaktiTheme.bodyHi.copyWith(
                            fontSize: 15,
                            color: BhaktiTheme.goldLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    IconButton(
                      tooltip: AppStrings.aartiStop,
                      onPressed: service.stop,
                      icon: const Icon(Icons.stop_circle_outlined, color: BhaktiTheme.creamDim),
                    ),
                ],
              ),
              if (!supabaseReady) ...[
                const SizedBox(height: 8),
                Text(
                  AppStrings.aartiSupabaseSetup,
                  style: BhaktiTheme.bodyHi.copyWith(fontSize: 13, color: BhaktiTheme.creamDim),
                ),
              ],
              if (showSeek) ...[
                const SizedBox(height: 8),
                _AartiSeekSlider(
                  position: position,
                  duration: duration,
                  onSeek: service.seek,
                ),
              ],
              if (hasError && supabaseReady) ...[
                const SizedBox(height: 8),
                Text(
                  AppStrings.aartiPlayError,
                  style: BhaktiTheme.bodyHi.copyWith(fontSize: 13, color: BhaktiTheme.lotusPink),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AartiSeekSlider extends StatefulWidget {
  const _AartiSeekSlider({
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  @override
  State<_AartiSeekSlider> createState() => _AartiSeekSliderState();
}

class _AartiSeekSliderState extends State<_AartiSeekSlider> {
  double? _dragMs;

  @override
  Widget build(BuildContext context) {
    final durationMs = widget.duration.inMilliseconds;
    final maxMs = durationMs > 0 ? durationMs.toDouble() : 1.0;
    final posMs = widget.position.inMilliseconds;
    final sliderMs = _dragMs ?? posMs.clamp(0, durationMs > 0 ? durationMs : 0).toDouble();

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: BhaktiTheme.saffronLight,
            inactiveTrackColor: BhaktiTheme.maroon.withValues(alpha: 0.5),
            thumbColor: BhaktiTheme.gold,
            overlayColor: BhaktiTheme.saffron.withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            min: 0,
            max: maxMs,
            value: sliderMs.clamp(0, maxMs),
            onChangeStart: (_) => setState(() => _dragMs = sliderMs),
            onChanged: (v) {
              setState(() => _dragMs = v);
              widget.onSeek(Duration(milliseconds: v.round()));
            },
            onChangeEnd: (v) {
              widget.onSeek(Duration(milliseconds: v.round()));
              setState(() => _dragMs = null);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _format(Duration(milliseconds: sliderMs.round())),
              style: BhaktiTheme.labelSub.copyWith(fontSize: 11),
            ),
            Text(
              _format(widget.duration),
              style: BhaktiTheme.labelSub.copyWith(fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  static String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            customBorder: const CircleBorder(),
            child: Opacity(
              opacity: enabled ? 1 : 0.35,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: highlighted ? BhaktiTheme.goldShimmer : BhaktiTheme.cardGradient,
                  border: Border.all(
                    color: enabled ? BhaktiTheme.gold : BhaktiTheme.gold.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(icon, size: 28, color: BhaktiTheme.maroonDeep),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: BhaktiTheme.labelSub.copyWith(
            fontSize: 10,
            color: enabled ? BhaktiTheme.creamDim : BhaktiTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
