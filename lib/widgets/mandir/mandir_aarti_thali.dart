import 'dart:async';
import 'dart:math' as math;

import 'package:bhakti_sadhana/core/assets/asset_paths.dart';
import 'package:flutter/material.dart';

abstract final class MandirAartiThaliLayout {
  static const double sizeFactor = 0.38;
  /// Carpet पर थाली — band की ऊँचाई का अंश (नीचे से)।
  static const double restOnCarpetFraction = 0.42;
  static const Duration snapDuration = Duration(milliseconds: 450);
  static const Duration riseDuration = Duration(milliseconds: 1200);
  static const Duration descendDuration = Duration(milliseconds: 750);
  static const Duration orbitDuration = Duration(milliseconds: 3200);
}

enum _ThaliPhase { idle, dragging, snapping, rising, orbiting, descending }

/// `puja_thali.png` — पैरों के पास; छोड़ने पर वापस; आरती पर धीरे ऊपर फिर गोल।
class MandirAartiThali extends StatefulWidget {
  const MandirAartiThali({
    super.key,
    required this.carpetHeight,
    this.interactionEnabled = true,
    this.aartiActive = false,
  });

  final double carpetHeight;
  final bool interactionEnabled;
  final bool aartiActive;

  @override
  State<MandirAartiThali> createState() => _MandirAartiThaliState();
}

class _MandirAartiThaliState extends State<MandirAartiThali>
    with TickerProviderStateMixin {
  Offset? _center;
  double _tilt = 0;
  _ThaliPhase _phase = _ThaliPhase.idle;

  Size? _cachedArea;
  Size? _cachedThali;

  late final AnimationController _transitionController;
  late final AnimationController _orbitController;
  Offset? _transitionFrom;
  double _orbitAngle = -math.pi / 2;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _orbitController = AnimationController(
      vsync: this,
      duration: MandirAartiThaliLayout.orbitDuration,
    )..addListener(() {
        if (_phase == _ThaliPhase.orbiting && mounted) {
          _orbitAngle = -math.pi / 2 + _orbitController.value * 2 * math.pi;
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  Size _thaliSize(Size area) {
    final side = area.shortestSide * MandirAartiThaliLayout.sizeFactor;
    return Size(side, side * 0.72);
  }

  Offset _restCenter(Size area, Size thali) {
    final carpetTop = area.height - widget.carpetHeight;
    final y = carpetTop +
        widget.carpetHeight * MandirAartiThaliLayout.restOnCarpetFraction;
    return Offset(area.width / 2, y);
  }

  Offset _orbitCenter(Size area) {
    final garbhaH = area.height - widget.carpetHeight;
    return Offset(area.width * 0.5, garbhaH * 0.44);
  }

  Offset _aartiCenter(Size area, Size thali, double angle) {
    final c = _orbitCenter(area);
    final garbhaH = area.height - widget.carpetHeight;
    final rx = area.width * 0.24;
    final ry = garbhaH * 0.11;
    return Offset(
      c.dx + rx * math.cos(angle),
      c.dy + ry * math.sin(angle),
    );
  }

  Offset _orbitEntry(Size area, Size thali) =>
      _aartiCenter(area, thali, -math.pi / 2);

  Offset _clampCenter(Offset center, Size area, Size thali) {
    final halfW = thali.width / 2;
    final halfH = thali.height / 2;
    return Offset(
      center.dx.clamp(halfW, area.width - halfW),
      center.dy.clamp(halfH, area.height - halfH),
    );
  }

  void _ensureCenter(Size area, Size thali) {
    _center ??= _clampCenter(_restCenter(area, thali), area, thali);
  }

  void _updateTilt(Offset center, Size area, Size thali) {
    if (_phase == _ThaliPhase.orbiting ||
        _phase == _ThaliPhase.rising ||
        _phase == _ThaliPhase.descending) {
      _tilt = math.sin(_orbitAngle) * 0.14;
      return;
    }
    const maxTilt = 0.14;
    final range = (area.width - thali.width) / 2;
    _tilt = range > 0 ? ((center.dx - area.width / 2) / range) * maxTilt : 0;
  }

  Future<void> _runTransition({
    required Duration duration,
    required _ThaliPhase phase,
    required Offset from,
    required Offset to,
    required Curve curve,
    required VoidCallback onComplete,
  }) async {
    _transitionFrom = from;
    setState(() => _phase = phase);
    _transitionController.duration = duration;
    await _transitionController.forward(from: 0);
    if (!mounted) return;
    _center = to;
    _transitionFrom = null;
    _transitionController.reset();
    onComplete();
  }

  void _snapToRest(Size area, Size thali) {
    if (_phase != _ThaliPhase.idle && _phase != _ThaliPhase.dragging) return;
    _ensureCenter(area, thali);
    final from = _center!;
    final to = _restCenter(area, thali);
    if ((from - to).distance < 2) {
      _center = to;
      setState(() => _phase = _ThaliPhase.idle);
      return;
    }
    unawaited(
      _runTransition(
        duration: MandirAartiThaliLayout.snapDuration,
        phase: _ThaliPhase.snapping,
        from: from,
        to: to,
        curve: Curves.easeOutCubic,
        onComplete: () => setState(() => _phase = _ThaliPhase.idle),
      ),
    );
  }

  void _startRise(Size area, Size thali) {
    if (_phase == _ThaliPhase.rising || _phase == _ThaliPhase.orbiting) return;
    _transitionController.stop();
    _ensureCenter(area, thali);
    final from = _center!;
    final to = _orbitEntry(area, thali);
    unawaited(
      _runTransition(
        duration: MandirAartiThaliLayout.riseDuration,
        phase: _ThaliPhase.rising,
        from: from,
        to: to,
        curve: Curves.easeInOutCubic,
        onComplete: () {
          if (!mounted || !widget.aartiActive) return;
          _orbitAngle = -math.pi / 2;
          _orbitController.forward(from: 0);
          _orbitController.repeat();
          setState(() => _phase = _ThaliPhase.orbiting);
        },
      ),
    );
  }

  void _startDescend(Size area, Size thali) {
    if (_phase == _ThaliPhase.descending) return;
    _orbitController.stop();
    final from = switch (_phase) {
      _ThaliPhase.orbiting => _aartiCenter(area, thali, _orbitAngle),
      _ThaliPhase.rising => _transitionFrom != null
          ? Offset.lerp(
              _transitionFrom!,
              _orbitEntry(area, thali),
              Curves.easeInOutCubic.transform(_transitionController.value),
            )!
          : _orbitEntry(area, thali),
      _ => _center ?? _restCenter(area, thali),
    };
    unawaited(
      _runTransition(
        duration: MandirAartiThaliLayout.descendDuration,
        phase: _ThaliPhase.descending,
        from: from,
        to: _restCenter(area, thali),
        curve: Curves.easeInOutCubic,
        onComplete: () {
          if (!mounted) return;
          _orbitController.reset();
          _orbitAngle = -math.pi / 2;
          setState(() => _phase = _ThaliPhase.idle);
        },
      ),
    );
  }

  @override
  void didUpdateWidget(MandirAartiThali oldWidget) {
    super.didUpdateWidget(oldWidget);
    final area = _cachedArea;
    final thali = _cachedThali;
    if (area == null || thali == null) return;

    if (widget.aartiActive && !oldWidget.aartiActive) {
      _startRise(area, thali);
    } else if (!widget.aartiActive && oldWidget.aartiActive) {
      _startDescend(area, thali);
    }
  }

  void _onPanStart(Size area, Size thali) {
    if (!widget.interactionEnabled || widget.aartiActive) return;
    if (_phase == _ThaliPhase.snapping ||
        _phase == _ThaliPhase.rising ||
        _phase == _ThaliPhase.descending) {
      _transitionController.stop();
      _transitionController.reset();
      _transitionFrom = null;
    }
    _ensureCenter(area, thali);
    setState(() => _phase = _ThaliPhase.dragging);
  }

  void _onPanUpdate(DragUpdateDetails details, Size area, Size thali) {
    if (!widget.interactionEnabled ||
        widget.aartiActive ||
        _phase == _ThaliPhase.orbiting) {
      return;
    }
    _ensureCenter(area, thali);
    setState(() {
      _center = _clampCenter(_center! + details.delta, area, thali);
      _updateTilt(_center!, area, thali);
    });
  }

  void _onPanEnd(Size area, Size thali) {
    if (!widget.interactionEnabled || widget.aartiActive) return;
    _snapToRest(area, thali);
  }

  Offset _displayCenter(Size area, Size thali) {
    switch (_phase) {
      case _ThaliPhase.snapping:
        return Offset.lerp(
          _transitionFrom!,
          _restCenter(area, thali),
          Curves.easeOutCubic.transform(_transitionController.value),
        )!;
      case _ThaliPhase.rising:
        return Offset.lerp(
          _transitionFrom!,
          _orbitEntry(area, thali),
          Curves.easeInOutCubic.transform(_transitionController.value),
        )!;
      case _ThaliPhase.descending:
        return Offset.lerp(
          _transitionFrom!,
          _restCenter(area, thali),
          Curves.easeInOutCubic.transform(_transitionController.value),
        )!;
      case _ThaliPhase.orbiting:
        return _aartiCenter(area, thali, _orbitAngle);
      case _ThaliPhase.dragging:
      case _ThaliPhase.idle:
        _ensureCenter(area, thali);
        return _center!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final area = Size(constraints.maxWidth, constraints.maxHeight);
        if (area.width <= 0 || area.height <= 0) {
          return const SizedBox.shrink();
        }

        final thali = _thaliSize(area);
        _cachedArea = area;
        _cachedThali = thali;

        final center = _displayCenter(area, thali);
        _updateTilt(center, area, thali);

        final left = center.dx - thali.width / 2;
        final top = center.dy - thali.height / 2;

        final canDrag = widget.interactionEnabled &&
            !widget.aartiActive &&
            _phase != _ThaliPhase.orbiting &&
            _phase != _ThaliPhase.rising &&
            _phase != _ThaliPhase.descending;

        final thaliBody = Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..rotateZ(_tilt),
          child: Image.asset(
            AssetPaths.mandirPujaThali,
            width: thali.width,
            height: thali.height,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
            semanticLabel: widget.aartiActive
                ? 'आरती चल रही है'
                : 'पूजा थाली — खींचकर छोड़ें, पैरों के पास लौटेगी',
            errorBuilder: (context, error, stackTrace) {
              debugPrint('puja_thali: $error');
              return SizedBox(
                width: thali.width,
                height: thali.height,
                child: const Center(
                  child: Text(
                    'थाली लोड नहीं हुई',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              );
            },
          ),
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: left,
              top: top,
              width: thali.width,
              height: thali.height,
              child: canDrag
                  ? GestureDetector(
                      onPanStart: (_) => _onPanStart(area, thali),
                      onPanUpdate: (d) => _onPanUpdate(d, area, thali),
                      onPanEnd: (_) => _onPanEnd(area, thali),
                      child: thaliBody,
                    )
                  : thaliBody,
            ),
          ],
        );
      },
    );
  }
}
