import 'package:bhakti_sadhana/core/assets/asset_paths.dart';
import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/widgets/app_asset_image.dart';
import 'package:bhakti_sadhana/widgets/mandir/mandir_aarti_thali.dart';
import 'package:flutter/material.dart';

/// गर्भगृह — देवता फोटो, थाली, arch।
class VirtualMandirShrine extends StatelessWidget {
  VirtualMandirShrine({
    super.key,
    required this.deityName,
    required this.photoController,
    required this.photoAssetPaths,
    required this.onPhotoPageChanged,
  });

  final String deityName;
  final PageController photoController;
  final List<String> photoAssetPaths;
  final ValueChanged<int> onPhotoPageChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        _TempleArchShrine(
          controller: photoController,
          assetPaths: photoAssetPaths,
          onPageChanged: onPhotoPageChanged,
        ),
        Positioned(
          top: 4,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: _GarbhagrihaHeader(deityName: deityName),
          ),
        ),
      ],
    );
  }
}

class _GarbhagrihaHeader extends StatelessWidget {
  const _GarbhagrihaHeader({required this.deityName});

  final String deityName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.mandirGarbhagriha,
          style: BhaktiTheme.labelSub.copyWith(
            fontSize: 12,
            letterSpacing: 1.2,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Text(
            deityName,
            key: ValueKey(deityName),
            style: BhaktiTheme.displayHi.copyWith(
              fontSize: 24,
              shadows: const [Shadow(color: Colors.black87, blurRadius: 8)],
            ),
          ),
        ),
      ],
    );
  }
}

class _TempleArchShrine extends StatelessWidget {
  _TempleArchShrine({
    required this.controller,
    required this.assetPaths,
    required this.onPageChanged,
  });

  final PageController controller;
  final List<String> assetPaths;
  final ValueChanged<int> onPageChanged;

  static const double _archLiftPx = 30;

  /// नीचे थाली के लिए जगह (0–1)
  static const double _thaliBottomReserve = 0.2;

  static const double _photoInsetTop = 0.02;

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
            clipBehavior: Clip.hardEdge,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.1),
                    radius: 1.1,
                    colors: [
                      BhaktiTheme.maroonDeep,
                      Color(0xFF0D0202),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: archH * _photoInsetTop,
                bottom: archH * _thaliBottomReserve,
                child: _DeityPhotoSwiper(
                  controller: controller,
                  assetPaths: assetPaths,
                  onPageChanged: onPageChanged,
                ),
              ),
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(0, -_archLiftPx),
                  child: IgnorePointer(
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.hardEdge,
                      children: [
                        MandirAartiThali(
                          archWidth: archW,
                          archHeight: archH,
                        ),
                        Image.asset(
                          AssetPaths.mandirTempleArch,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          filterQuality: FilterQuality.high,
                        ),
                      ],
                    ),
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
  _DeityPhotoSwiper({
    required this.controller,
    required this.assetPaths,
    required this.onPageChanged,
  });

  final PageController controller;
  final List<String> assetPaths;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final cache = assetCacheDimension(400, context);

    return ColoredBox(
      color: const Color(0xFF0D0202),
      child: PageView.builder(
        controller: controller,
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
