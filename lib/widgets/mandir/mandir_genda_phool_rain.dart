import 'dart:math' as math;

import 'package:bhakti_sadhana/core/assets/asset_paths.dart';
import 'package:bhakti_sadhana/widgets/mandir/mandir_aarti_thali.dart';
import 'package:flutter/material.dart';

/// पूरे shrine में फूल पथ — nav↔arch जंक्शन से थाली → carpet।
class MandirFlowerRainLayout {
  MandirFlowerRainLayout({
    required this.width,
    required this.height,
    required this.carpetHeight,
  });

  final double width;
  final double height;
  final double carpetHeight;

  double get carpetTop => height - carpetHeight;

  Size get thaliSize {
    final shortest = math.min(width, height);
    final side = shortest * MandirAartiThaliLayout.sizeFactor;
    return Size(side, side * 0.72);
  }

  Offset get thaliRestCenter {
    final y =
        carpetTop + carpetHeight * MandirAartiThaliLayout.restOnCarpetFraction;
    return Offset(width / 2, y);
  }

  double get thaliTopY => thaliRestCenter.dy - thaliSize.height / 2;

  double get carpetLandY => carpetTop + carpetHeight * 0.32;

  /// Shrine के ऊपर — top nav और arch का मिलन बिंदु।
  double get spawnY => 0;

  double get spawnCenterX => width / 2;
}

/// गेंदे के फूल — ऊपर से थाली पर टकराकर carpet पर, 1 सेकंड बाद गायब।
class MandirGendaPhoolRain extends StatefulWidget {
  const MandirGendaPhoolRain({
    super.key,
    required this.session,
    required this.carpetHeight,
    this.flowerCount = 31,
    this.onFinished,
  });

  final int session;
  final double carpetHeight;
  final int flowerCount;
  final VoidCallback? onFinished;

  @override
  State<MandirGendaPhoolRain> createState() => _MandirGendaPhoolRainState();
}

class _MandirGendaPhoolRainState extends State<MandirGendaPhoolRain>
    with SingleTickerProviderStateMixin {
  static const _fallToThaliSec = 1.9;
  static const _fallToCarpetSec = 0.4;
  static const _restSec = 1.0;
  static const _maxDelaySec = 0.45;

  static double get _flowerSpanSec =>
      _fallToThaliSec + _fallToCarpetSec + _restSec;

  static Duration get _totalDuration => Duration(
        milliseconds: ((_maxDelaySec + _flowerSpanSec) * 1000).round(),
      );

  late final AnimationController _controller;
  List<_RainFlower>? _flowers;
  int? _flowersSession;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration)
      ..forward();
    _controller.addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onFinished?.call();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  List<_RainFlower> _flowersFor(MandirFlowerRainLayout layout) {
    if (_flowers != null && _flowersSession == widget.session) {
      return _flowers!;
    }
    _flowersSession = widget.session;
    _flowers = _RainFlower.generate(
      widget.flowerCount,
      widget.session,
      layout,
    );
    return _flowers!;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = MandirFlowerRainLayout(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          carpetHeight: widget.carpetHeight,
        );
        final flowers = _flowersFor(layout);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final elapsed =
                _controller.value * _totalDuration.inMilliseconds / 1000.0;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (final f in flowers)
                  _buildFlower(f, layout, elapsed),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFlower(
    _RainFlower f,
    MandirFlowerRainLayout layout,
    double elapsedSec,
  ) {
    final t = elapsedSec - f.delaySec;
    if (t < 0 || t >= _flowerSpanSec) {
      return const SizedBox.shrink();
    }

    final thaliHitY = layout.thaliTopY - f.size;
    final carpetY = layout.carpetLandY - f.size;

    late final Offset pos;
    late final double spin;
    var opacity = 1.0;

    if (t < _fallToThaliSec) {
      final seg = t / _fallToThaliSec;
      final pY = Curves.easeIn.transform(seg);
      // नीचे जाते ही क्षैतिज फैलाव बढ़े (ऊपर संकीर्ण → नीचे चौड़ा)।
      final pX = Curves.easeOut.transform(seg);
      pos = Offset(
        f.topX + (f.thaliX - f.topX) * pX,
        layout.spawnY + (thaliHitY - layout.spawnY) * pY,
      );
      spin = f.spin * pY;
    } else if (t < _fallToThaliSec + _fallToCarpetSec) {
      final seg = (t - _fallToThaliSec) / _fallToCarpetSec;
      final pY = Curves.easeIn.transform(seg);
      final pX = Curves.easeOut.transform(seg);
      pos = Offset(
        f.thaliX + (f.carpetX - f.thaliX) * pX,
        thaliHitY + (carpetY - thaliHitY) * pY,
      );
      spin = f.spin * (0.85 + pX * 0.15);
    } else {
      pos = Offset(f.carpetX, carpetY);
      spin = f.spin;
      final restT = t - _fallToThaliSec - _fallToCarpetSec;
      if (restT >= _restSec - 0.15) {
        opacity = ((_restSec - restT) / 0.15).clamp(0.0, 1.0);
      }
    }

    return Positioned(
      left: pos.dx - f.size / 2,
      top: pos.dy,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: spin,
          child: Image.asset(
            AssetPaths.mandirGendaPhool,
            width: f.size,
            height: f.size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            cacheWidth: (f.size * 2).round(),
            cacheHeight: (f.size * 2).round(),
            gaplessPlayback: true,
            errorBuilder: (_, e, s) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _RainFlower {
  _RainFlower({
    required this.topX,
    required this.thaliX,
    required this.carpetX,
    required this.delaySec,
    required this.size,
    required this.spin,
  });

  final double topX;
  final double thaliX;
  final double carpetX;
  final double delaySec;
  final double size;
  final double spin;

  static List<_RainFlower> generate(
    int count,
    int session,
    MandirFlowerRainLayout layout,
  ) {
    final rng = math.Random(session);
    final thali = layout.thaliSize;
    final center = layout.spawnCenterX;
    final thaliHalfW = thali.width / 2;
    return List.generate(count, (i) {
      final side = rng.nextDouble() > 0.5 ? 1.0 : -1.0;
      final reach = layout.width * (0.18 + rng.nextDouble() * 0.28);

      // ऊपर संकीर्ण → थाली पर मध्यम → carpet पर सबसे चौड़ा (शंकु जैसा)।
      final topX = center + side * reach * (0.03 + rng.nextDouble() * 0.05);
      var thaliX = center + side * reach * (0.48 + rng.nextDouble() * 0.14);
      var carpetX = center + side * reach * (0.88 + rng.nextDouble() * 0.12);

      thaliX = thaliX.clamp(
        layout.thaliRestCenter.dx - thaliHalfW + 8,
        layout.thaliRestCenter.dx + thaliHalfW - 8,
      );
      carpetX = carpetX.clamp(10.0, layout.width - 10.0);

      return _RainFlower(
        topX: topX,
        thaliX: thaliX,
        carpetX: carpetX,
        delaySec: (i / count) * _MandirGendaPhoolRainState._maxDelaySec +
            rng.nextDouble() * 0.08,
        size: 18 + rng.nextDouble() * 18,
        spin: (rng.nextDouble() - 0.5) * math.pi * 1.2,
      );
    });
  }
}
