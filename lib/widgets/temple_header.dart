import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:flutter/material.dart';

/// Arch-style temple header with Om and app title.
class TempleHeader extends StatelessWidget {
  const TempleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: BhaktiTheme.goldShimmer,
            boxShadow: [
              BoxShadow(
                color: BhaktiTheme.diyaGlow.withValues(alpha: 0.45),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: BhaktiTheme.gold, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            'ॐ',
            style: BhaktiTheme.displayHi.copyWith(
              fontSize: 36,
              color: BhaktiTheme.maroonDeep,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.appTitle,
          style: BhaktiTheme.displayHi.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(AppStrings.appTagline, style: BhaktiTheme.labelSub),
        const SizedBox(height: 16),
        const _TempleArchDivider(),
      ],
    );
  }
}

class _TempleArchDivider extends StatelessWidget {
  const _TempleArchDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(child: _goldLine()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: BhaktiTheme.saffronLight.withValues(alpha: 0.9),
              size: 18,
            ),
          ),
          Expanded(child: _goldLine()),
        ],
      ),
    );
  }

  Widget _goldLine() => Container(
        height: 1,
        decoration: const BoxDecoration(gradient: BhaktiTheme.goldShimmer),
      );
}
