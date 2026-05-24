import 'dart:async';

import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/services/temple_bell/temple_bell_service.dart';
import 'package:bhakti_sadhana/widgets/temple_background.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Launch splash: ॐ → स्वचालित मंदिर घंटी → होम।
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _omPulse;
  late final AnimationController _glowPulse;
  late final AnimationController _fadeIn;
  late final AnimationController _launchTimer;
  late final Animation<double> _omScale;
  late final Animation<double> _omGlow;
  late final Animation<double> _contentOpacity;

  bool _bellPlayed = false;
  bool _navigated = false;
  bool _sequenceStarted = false;

  @override
  void initState() {
    super.initState();

    _omPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _fadeIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _launchTimer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..addStatusListener(_onLaunchTimerStatus);

    _omScale = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _omPulse, curve: Curves.easeInOut),
    );
    _omGlow = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _glowPulse, curve: Curves.easeInOut),
    );
    _contentOpacity = CurvedAnimation(parent: _fadeIn, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _beginSequence();
    });
  }

  void _beginSequence() {
    if (_sequenceStarted) return;
    _sequenceStarted = true;

    unawaited(_ringBell());

    if (!kIsWeb) {
      _launchTimer.forward();
    } else {
      // वेब: अधिकतम 3 सेकंड बाद होम (स्पर्श / घंटी के बाद भी)।
      Future<void>.delayed(const Duration(seconds: 3), () {
        if (mounted && !_navigated && _launchTimer.status != AnimationStatus.completed) {
          _launchTimer.forward(from: 0);
        }
      });
    }
  }

  void _onLaunchTimerStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _navigated || !mounted) return;
    _goHome();
  }

  void _goHome() {
    _navigated = true;
    _omPulse.stop();
    _glowPulse.stop();
    context.go('/');
  }

  Future<void> _ringBell() async {
    if (_bellPlayed) return;
    final ok = await TempleBellService.instance.playWithRetry();
    if (!mounted) return;
    if (ok) {
      setState(() => _bellPlayed = true);
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    // वेब: ब्राउज़र की पॉलिसी — पहली स्पर्श पर घंटी (बिना अलग बटन)।
    HapticFeedback.lightImpact();
    unawaited(_ringBell());
    if (kIsWeb && !_launchTimer.isAnimating && !_navigated) {
      _launchTimer.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _launchTimer.removeStatusListener(_onLaunchTimerStatus);
    _omPulse.dispose();
    _glowPulse.dispose();
    _fadeIn.dispose();
    _launchTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onPointerDown,
        child: TempleBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _contentOpacity,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: Listenable.merge([_omScale, _omGlow]),
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: BhaktiTheme.goldShimmer,
                            boxShadow: [
                              BoxShadow(
                                color: BhaktiTheme.diyaGlow
                                    .withValues(alpha: _omGlow.value),
                                blurRadius: 48 * _omScale.value,
                                spreadRadius: 8,
                              ),
                            ],
                            border: Border.all(
                              color: BhaktiTheme.gold,
                              width: 2.5,
                            ),
                          ),
                          child: Transform.scale(
                            scale: _omScale.value,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        'ॐ',
                        style: GoogleFonts.yatraOne(
                          fontSize: 72,
                          color: BhaktiTheme.maroonDeep,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _OmChantText(),
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.appTitle,
                      style: BhaktiTheme.displayHi.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.appTagline,
                      style: BhaktiTheme.labelSub,
                    ),
                    const SizedBox(height: 32),
                    if (_bellPlayed)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_active_rounded,
                            color: BhaktiTheme.saffronLight.withValues(alpha: 0.9),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.bellPlaying,
                            style: BhaktiTheme.bodyHi.copyWith(fontSize: 14),
                          ),
                        ],
                      )
                    else if (kIsWeb)
                      Text(
                        AppStrings.webEnterHint,
                        textAlign: TextAlign.center,
                        style: BhaktiTheme.bodyHi.copyWith(fontSize: 14),
                      )
                    else
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BhaktiTheme.gold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _OmChantText extends StatefulWidget {
  const _OmChantText();

  @override
  State<_OmChantText> createState() => _OmChantTextState();
}

class _OmChantTextState extends State<_OmChantText>
    with SingleTickerProviderStateMixin {
  static const _full = 'ओ३म्…';
  late final AnimationController _controller;
  int _visibleChars = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _controller.addListener(_onAnimate);
  }

  void _onAnimate() {
    final step =
        (_controller.value * _full.length).floor().clamp(1, _full.length);
    if (step != _visibleChars && mounted) {
      setState(() => _visibleChars = step);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onAnimate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = _full.substring(0, _visibleChars);
    return Text(
      shown,
      style: BhaktiTheme.mantraHi.copyWith(
        fontSize: 28,
        letterSpacing: 4,
        color: BhaktiTheme.goldLight,
      ),
    );
  }
}
