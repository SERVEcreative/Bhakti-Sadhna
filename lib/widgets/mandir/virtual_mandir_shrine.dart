import 'package:bhakti_sadhana/core/assets/asset_paths.dart';
import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/widgets/app_asset_image.dart';
import 'package:bhakti_sadhana/widgets/mandir/mandir_aarti_thali.dart';
import 'package:bhakti_sadhana/widgets/mandir/mandir_carpet_decorations.dart';
import 'dart:async' show unawaited;

import 'package:bhakti_sadhana/services/mandir/mandir_shrine_audio_service.dart';
import 'package:bhakti_sadhana/widgets/mandir/mandir_genda_phool_rain.dart';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Carpet पर फूल / शंख — एक ही पंक्ति, नीचे संरेखित।
const double _carpetPujaRowBottom = 12;
const double _carpetPujaRowInsetH = 28;
const double _carpetPujaRowHeight = 58;

/// गर्भगृह — arch + फोटो ऊपर, पूजा सामग्री सबसे नीचे।
class VirtualMandirShrine extends StatefulWidget {
  const VirtualMandirShrine({
    super.key,
    required this.photoController,
    required this.photoAssetPaths,
    required this.onPhotoPageChanged,
    this.thaliInteractionEnabled = true,
  });

  final PageController photoController;
  final List<String> photoAssetPaths;
  final ValueChanged<int> onPhotoPageChanged;
  final bool thaliInteractionEnabled;

  /// नीचे थाली + फूल + पूजा सामग्री।
  static double carpetHeight(double totalHeight) {
    return (totalHeight * 0.22).clamp(110.0, 165.0);
  }

  @override
  State<VirtualMandirShrine> createState() => _VirtualMandirShrineState();
}

class _VirtualMandirShrineState extends State<VirtualMandirShrine> {
  bool _aartiActive = false;
  bool _shankhActive = false;
  int _phoolRainSession = 0;
  bool _phoolRainVisible = false;

  @override
  void dispose() {
    unawaited(MandirShrineAudioService.instance.stopAll());
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VirtualMandirShrine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.thaliInteractionEnabled && (_aartiActive || _shankhActive)) {
      setState(() {
        _aartiActive = false;
        _shankhActive = false;
      });
      unawaited(MandirShrineAudioService.instance.stopAll());
    }
  }

  Future<void> _toggleAarti() async {
    if (!widget.thaliInteractionEnabled) return;
    HapticFeedback.lightImpact();
    final next = !_aartiActive;
    if (next) {
      setState(() {
        _aartiActive = true;
        _shankhActive = false;
      });
      await MandirShrineAudioService.instance.startAarti();
    } else {
      setState(() => _aartiActive = false);
      await MandirShrineAudioService.instance.stopAarti();
    }
  }

  Future<void> _toggleShankh() async {
    if (!widget.thaliInteractionEnabled) return;
    HapticFeedback.lightImpact();
    final next = !_shankhActive;
    if (next) {
      setState(() {
        _shankhActive = true;
        _aartiActive = false;
      });
      await MandirShrineAudioService.instance.startShankh();
    } else {
      setState(() => _shankhActive = false);
      await MandirShrineAudioService.instance.stopShankh();
    }
  }

  void _onGendaPhoolTap() {
    if (!widget.thaliInteractionEnabled) return;
    setState(() {
      _phoolRainSession++;
      _phoolRainVisible = true;
    });
  }

  void _onPhoolRainFinished() {
    if (!mounted) return;
    setState(() => _phoolRainVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final carpetH = VirtualMandirShrine.carpetHeight(constraints.maxHeight);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _TempleArchShrine(
                    controller: widget.photoController,
                    assetPaths: widget.photoAssetPaths,
                    onPageChanged: widget.onPhotoPageChanged,
                    photoSwipeEnabled:
                        widget.thaliInteractionEnabled && !_aartiActive,
                  ),
                ),
                SizedBox(
                  height: carpetH,
                  width: double.infinity,
                  child: const MandirCarpetDecorations(),
                ),
              ],
            ),
            Positioned.fill(
              child: MandirAartiThali(
                carpetHeight: carpetH,
                interactionEnabled: widget.thaliInteractionEnabled,
                aartiActive: _aartiActive,
              ),
            ),
            if (_phoolRainVisible)
              Positioned.fill(
                child: IgnorePointer(
                  child: MandirGendaPhoolRain(
                    key: ValueKey(_phoolRainSession),
                    session: _phoolRainSession,
                    carpetHeight: carpetH,
                    onFinished: _onPhoolRainFinished,
                  ),
                ),
              ),
            Positioned(
              left: _carpetPujaRowInsetH,
              right: _carpetPujaRowInsetH,
              bottom: _carpetPujaRowBottom,
              height: _carpetPujaRowHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _InteractiveCarpetPujaItem(
                    key: const ValueKey('mandir_flower'),
                    enabled: widget.thaliInteractionEnabled,
                    assetPath: AssetPaths.mandirGendaPhool,
                    height: 46,
                    cacheSize: 92,
                    onTap: _onGendaPhoolTap,
                  ),
                  const Spacer(),
                  _InteractiveCarpetPujaItem(
                    key: const ValueKey('mandir_shankh'),
                    enabled: widget.thaliInteractionEnabled,
                    assetPath: AssetPaths.mandirShankha,
                    fallbackPaths: const [AssetPaths.mandirShankhaLegacy],
                    height: 52,
                    width: 68,
                    cacheSize: 144,
                    onTap: () => unawaited(_toggleShankh()),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 10,
              bottom: carpetH + 10,
              child: _MandirPillButton(
                label: AppStrings.mandirAartiButton,
                active: _aartiActive,
                activeIcon: Icons.stop_rounded,
                idleIcon: Icons.local_fire_department_rounded,
                onPressed: widget.thaliInteractionEnabled
                    ? () => unawaited(_toggleAarti())
                    : null,
              ),
            ),
            Positioned(
              right: 10,
              bottom: carpetH + 10,
              child: _MandirPillButton(
                label: AppStrings.mandirShankhButton,
                active: _shankhActive,
                activeIcon: Icons.stop_rounded,
                idleIcon: Icons.campaign_rounded,
                onPressed: widget.thaliInteractionEnabled
                    ? () => unawaited(_toggleShankh())
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Carpet पर फूल / शंख — tap पर ripple + glow (active).
class _InteractiveCarpetPujaItem extends StatefulWidget {
  const _InteractiveCarpetPujaItem({
    super.key,
    required this.assetPath,
    required this.height,
    this.width,
    this.cacheSize,
    this.fallbackPaths = const [],
    this.enabled = true,
    this.onTap,
  });

  final String assetPath;
  final List<String> fallbackPaths;
  final double height;
  final double? width;
  final int? cacheSize;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<_InteractiveCarpetPujaItem> createState() =>
      _InteractiveCarpetPujaItemState();
}

class _InteractiveCarpetPujaItemState extends State<_InteractiveCarpetPujaItem>
    with SingleTickerProviderStateMixin {
  bool _active = false;

  late final AnimationController _glowPulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  late final List<String> _paths = [
    widget.assetPath,
    ...widget.fallbackPaths,
  ];
  int _pathIndex = 0;

  String get _resolvedPath => _paths[_pathIndex];

  void _tryNextAssetPath() {
    if (_pathIndex + 1 >= _paths.length) return;
    setState(() => _pathIndex++);
  }

  @override
  void dispose() {
    _glowPulse.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.enabled) return;
    HapticFeedback.lightImpact();
    widget.onTap?.call();
    setState(() => _active = !_active);
    if (_active) {
      _glowPulse.repeat(reverse: true);
    } else {
      _glowPulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? widget.height;
    final h = widget.height;

    return SizedBox(
      width: widget.width ?? w,
      height: h,
      child: AnimatedBuilder(
        animation: _glowPulse,
        builder: (context, _) {
          final pulse =
              _active ? Curves.easeInOut.transform(_glowPulse.value) : 0.0;
          final glowA = _active ? 0.58 + pulse * 0.38 : 0.0;
          final outerBlur = 20.0 + pulse * 8;
          final innerBlur = 10.0 + pulse * 4;

          return GestureDetector(
            onTap: widget.enabled ? _onTap : null,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                if (_active) ...[
                  _PujaSilhouetteGlow(
                    assetPath: _resolvedPath,
                    width: w,
                    height: h,
                    cacheSize: widget.cacheSize,
                    blurSigma: outerBlur,
                    opacity: glowA * 0.7,
                  ),
                  _PujaSilhouetteGlow(
                    assetPath: _resolvedPath,
                    width: w,
                    height: h,
                    cacheSize: widget.cacheSize,
                    blurSigma: innerBlur,
                    opacity: glowA,
                  ),
                ],
                Center(
                  child: _CarpetPujaAsset(
                    assetPath: _resolvedPath,
                    height: h,
                    width: widget.width,
                    cacheSize: widget.cacheSize,
                    onLoadFailed: _tryNextAssetPath,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Image की आकृति पर soft दीये जैसा glow — कोई चौकोर बॉक्स नहीं।
class _PujaSilhouetteGlow extends StatelessWidget {
  const _PujaSilhouetteGlow({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.blurSigma,
    required this.opacity,
    this.cacheSize,
  });

  final String assetPath;
  final double width;
  final double height;
  final double blurSigma;
  final double opacity;
  final int? cacheSize;

  @override
  Widget build(BuildContext context) {
    final glowColor = Color.lerp(
      BhaktiTheme.gold,
      BhaktiTheme.diyaGlow,
      0.45,
    )!.withValues(alpha: opacity.clamp(0.0, 1.0));

    return Center(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: blurSigma,
          sigmaY: blurSigma,
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(glowColor, BlendMode.srcIn),
          child: Image.asset(
            assetPath,
            width: width,
            height: height,
            fit: BoxFit.contain,
            cacheWidth: cacheSize,
            cacheHeight: cacheSize,
            filterQuality: FilterQuality.low,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _CarpetPujaAsset extends StatelessWidget {
  const _CarpetPujaAsset({
    required this.assetPath,
    required this.height,
    this.width,
    this.cacheSize,
    this.onLoadFailed,
  });

  final String assetPath;
  final double height;
  final double? width;
  final int? cacheSize;
  final VoidCallback? onLoadFailed;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      cacheWidth: cacheSize,
      cacheHeight: cacheSize,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        if (onLoadFailed != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onLoadFailed!();
          });
          return SizedBox(width: width, height: height);
        }
        debugPrint('mandir puja asset failed: $assetPath — $error');
        return Icon(
          Icons.music_note_rounded,
          size: height * 0.85,
          color: BhaktiTheme.gold,
        );
      },
    );
  }
}

class _MandirPillButton extends StatelessWidget {
  const _MandirPillButton({
    required this.label,
    required this.active,
    required this.activeIcon,
    required this.idleIcon,
    required this.onPressed,
  });

  final String label;
  final bool active;
  final IconData activeIcon;
  final IconData idleIcon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    colors: [
                      BhaktiTheme.saffron.withValues(alpha: 0.95),
                      BhaktiTheme.diyaGlow.withValues(alpha: 0.9),
                    ],
                  )
                : null,
            color: active ? null : BhaktiTheme.maroon.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: active ? BhaktiTheme.goldLight : BhaktiTheme.gold,
              width: 1.5,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: BhaktiTheme.diyaGlow.withValues(alpha: 0.45),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? activeIcon : idleIcon,
                size: 18,
                color: active ? BhaktiTheme.maroonDeep : BhaktiTheme.goldLight,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: BhaktiTheme.labelSub.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? BhaktiTheme.maroonDeep : BhaktiTheme.goldLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TempleArchShrine extends StatelessWidget {
  const _TempleArchShrine({
    required this.controller,
    required this.assetPaths,
    required this.onPageChanged,
    this.photoSwipeEnabled = true,
  });

  final PageController controller;
  final List<String> assetPaths;
  final ValueChanged<int> onPageChanged;
  final bool photoSwipeEnabled;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final archW = screenW;
        final archH = constraints.maxHeight;

        return SizedBox(
          width: archW,
          height: archH,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: BhaktiTheme.maroonDeep,
                ),
              ),
              Positioned.fill(
                child: _DeityPhotoSwiper(
                  controller: controller,
                  assetPaths: assetPaths,
                  onPageChanged: onPageChanged,
                  swipeEnabled: photoSwipeEnabled,
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Image.asset(
                    AssetPaths.mandirTempleArch,
                    width: archW,
                    height: archH,
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeityPhotoSwiper extends StatelessWidget {
  const _DeityPhotoSwiper({
    required this.controller,
    required this.assetPaths,
    required this.onPageChanged,
    this.swipeEnabled = true,
  });

  final PageController controller;
  final List<String> assetPaths;
  final ValueChanged<int> onPageChanged;
  final bool swipeEnabled;

  @override
  Widget build(BuildContext context) {
    final cache = assetCacheDimension(400, context);

    return ColoredBox(
      color: const Color(0xFF0D0202),
      child: PageView.builder(
        controller: controller,
        physics: swipeEnabled
            ? const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              )
            : const NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
        itemCount: assetPaths.length,
        itemBuilder: (context, index) {
          return AppAssetImage(
            key: ValueKey(assetPaths[index]),
            assetPath: assetPaths[index],
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            width: double.infinity,
            height: double.infinity,
            cacheWidth: cache,
            cacheHeight: cache,
            fallback: Icon(
              Icons.temple_hindu_rounded,
              size: 72,
              color: BhaktiTheme.gold,
            ),
          );
        },
      ),
    );
  }
}
