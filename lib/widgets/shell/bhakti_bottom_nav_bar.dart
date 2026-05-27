import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// तीन टैब — साफ modern bar, स्लाइडिंग इंडिकेटर, मंदिर थीम।
class BhaktiBottomNavBar extends StatefulWidget {
  const BhaktiBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<BhaktiBottomNavBar> createState() => _BhaktiBottomNavBarState();
}

class _BhaktiBottomNavBarState extends State<BhaktiBottomNavBar> {
  static const _tabs = <_NavTabSpec>[
    _NavTabSpec(
      Icons.volunteer_activism_outlined,
      Icons.volunteer_activism_rounded,
      AppStrings.navPuja,
    ),
    _NavTabSpec(
      Icons.temple_hindu_outlined,
      Icons.temple_hindu_rounded,
      AppStrings.navMandir,
      center: true,
    ),
    _NavTabSpec(
      Icons.sensors_outlined,
      Icons.sensors_rounded,
      AppStrings.navLiveDarshan,
    ),
    _NavTabSpec(
      Icons.favorite_outline_rounded,
      Icons.favorite_rounded,
      AppStrings.navDaan,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E0606),
        border: Border(
          top: BorderSide(
            color: BhaktiTheme.gold.withValues(alpha: 0.28),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // ऊपर की soft highlight
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 28,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      BhaktiTheme.goldLight.withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: SizedBox(
                height: kBottomNavigationBarHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final count = _tabs.length;
                    final tabW = constraints.maxWidth / count;
                    final indicatorW = (tabW * 0.78).clamp(52.0, 68.0);
                    final left =
                        tabW * widget.currentIndex + (tabW - indicatorW) / 2;

                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          left: left,
                          top: 7,
                          width: indicatorW,
                          height: 42,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(21),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  BhaktiTheme.maroon.withValues(alpha: 0.95),
                                  const Color(0xFF2A0808),
                                ],
                              ),
                              border: Border.all(
                                color: BhaktiTheme.gold.withValues(alpha: 0.38),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: BhaktiTheme.diyaGlow.withValues(
                                    alpha: 0.18,
                                  ),
                                  blurRadius: 14,
                                  spreadRadius: -2,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(count, (i) {
                            return Expanded(
                              child: _NavItem(
                                spec: _tabs[i],
                                selected: widget.currentIndex == i,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  widget.onTap(i);
                                },
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTabSpec {
  const _NavTabSpec(
    this.icon,
    this.activeIcon,
    this.label, {
    this.center = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool center;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _NavTabSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected
        ? BhaktiTheme.goldLight
        : BhaktiTheme.cream.withValues(alpha: 0.48);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: BhaktiTheme.saffron.withValues(alpha: 0.12),
        highlightColor: BhaktiTheme.gold.withValues(alpha: 0.08),
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.06 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Icon(
                  selected ? spec.activeIcon : spec.icon,
                  size: spec.center && selected ? 26 : 24,
                  color: iconColor,
                  shadows: selected
                      ? [
                          Shadow(
                            color: BhaktiTheme.diyaGlow.withValues(alpha: 0.65),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: selected
                    ? BhaktiTheme.titleHi.copyWith(
                        fontSize: 10,
                        color: BhaktiTheme.goldLight,
                      )
                    : BhaktiTheme.labelSub.copyWith(
                        fontSize: 10,
                        color: BhaktiTheme.cream.withValues(alpha: 0.48),
                      ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    spec.label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
