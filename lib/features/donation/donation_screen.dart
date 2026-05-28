import 'package:bhakti_sadhana/config/donation_config.dart';
import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/donation_catalog.dart';
import 'package:bhakti_sadhana/data/models/donation_cause.dart';
import 'package:bhakti_sadhana/data/models/worship_category.dart';
import 'package:bhakti_sadhana/features/donation/donation_checkout_sheet.dart';
import 'package:bhakti_sadhana/widgets/ads/puja_section_banner_shell.dart';
import 'package:bhakti_sadhana/widgets/legal/legal_links_footer.dart';
import 'package:bhakti_sadhana/widgets/temple_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({
    super.key,
    this.highlightCauseId,
    this.inTab = false,
  });

  final String? highlightCauseId;
  final bool inTab;

  @override
  Widget build(BuildContext context) {
    return TempleScaffold(
      title: AppStrings.donationTitle,
      showBackButton: !inTab,
      body: PujaSectionBannerShell(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _DonationHero(),
            const SizedBox(height: 16),
            const _DonationBenefitStrip(),
            const SizedBox(height: 20),
            _DonationCausesSection(highlightCauseId: highlightCauseId),
            const SizedBox(height: 20),
            const _DonationTrustFooter(),
            const SizedBox(height: 8),
            const LegalLinksFooter(),
          ],
        ),
      ),
    );
  }
}

class _DonationHero extends StatelessWidget {
  const _DonationHero();

  static const _imageAsset = 'assets/images/categories/donation.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7A2A12),
            Color(0xFF4A1212),
            Color(0xFF2D0808),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: BhaktiTheme.diyaGlow.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'ॐ',
            style: BhaktiTheme.displayHi.copyWith(
              fontSize: 36,
              color: BhaktiTheme.saffronLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.donationHeroTitle,
            textAlign: TextAlign.center,
            style: BhaktiTheme.titleHi.copyWith(fontSize: 22, height: 1.25),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.donationSubtitle,
            textAlign: TextAlign.center,
            style: BhaktiTheme.bodyHi.copyWith(
              fontSize: 14.5,
              height: 1.55,
              color: BhaktiTheme.cream.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              _imageAsset,
              width: 72,
              height: 72,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) => Icon(
                WorshipCategory.donation.icon,
                size: 44,
                color: BhaktiTheme.goldLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationBenefitStrip extends StatelessWidget {
  const _DonationBenefitStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BenefitChip(
            icon: Icons.favorite_rounded,
            label: AppStrings.donationBenefitShraddha,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _BenefitChip(
            icon: Icons.auto_awesome_rounded,
            label: AppStrings.donationBenefitPunya,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _BenefitChip(
            icon: Icons.volunteer_activism_rounded,
            label: AppStrings.donationBenefitSeva,
          ),
        ),
      ],
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: BhaktiTheme.maroon.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Icon(icon, color: BhaktiTheme.saffronLight, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: BhaktiTheme.titleHi.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DonationCausesSection extends StatelessWidget {
  const _DonationCausesSection({this.highlightCauseId});

  final String? highlightCauseId;

  @override
  Widget build(BuildContext context) {
    final group = DonationGroup.general;
    final causes = DonationCatalog.forGroup(group);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(group.title, style: BhaktiTheme.titleHi.copyWith(fontSize: 20)),
        const SizedBox(height: 6),
        Text(
          group.subtitle,
          style: BhaktiTheme.bodyHi.copyWith(fontSize: 14, height: 1.45),
        ),
        const SizedBox(height: 14),
        Text(
          AppStrings.donationPopularAmounts,
          style: BhaktiTheme.labelSub.copyWith(
            fontSize: 12,
            color: BhaktiTheme.goldLight.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DonationConfig.presetAmounts.take(4).map((amt) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: BhaktiTheme.gold.withValues(alpha: 0.4),
                ),
                color: BhaktiTheme.saffron.withValues(alpha: 0.12),
              ),
              child: Text(
                '₹$amt',
                style: BhaktiTheme.titleHi.copyWith(fontSize: 14),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ...causes.map(
          (cause) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DonationCauseCard(
              cause: cause,
              highlighted: cause.id == highlightCauseId,
            ),
          ),
        ),
      ],
    );
  }
}

class _DonationCauseCard extends StatefulWidget {
  const _DonationCauseCard({
    required this.cause,
    this.highlighted = false,
  });

  final DonationCause cause;
  final bool highlighted;

  @override
  State<_DonationCauseCard> createState() => _DonationCauseCardState();
}

class _DonationCauseCardState extends State<_DonationCauseCard> {
  bool _pressed = false;

  Color get _accent => switch (widget.cause.id) {
        'gau_daan' => const Color(0xFFE8A84A),
        'temple_trust' => BhaktiTheme.saffronLight,
        _ => const Color(0xFF90CAF9),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        showDonationCheckoutSheet(context, widget.cause);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: BhaktiTheme.cardGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.highlighted
                  ? BhaktiTheme.saffronLight
                  : BhaktiTheme.gold.withValues(alpha: 0.45),
              width: widget.highlighted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: _pressed ? 0.1 : 0.22),
                blurRadius: 14,
                offset: Offset(0, _pressed ? 2 : 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _accent.withValues(alpha: 0.35),
                        BhaktiTheme.maroon.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Icon(
                    widget.cause.icon,
                    color: BhaktiTheme.goldLight,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cause.title,
                        style: BhaktiTheme.titleHi.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.cause.taglineHi,
                        style: BhaktiTheme.bodyHi.copyWith(
                          fontSize: 13,
                          color: BhaktiTheme.saffronLight,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.cause.description,
                        style: BhaktiTheme.labelSub.copyWith(
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                BhaktiTheme.saffron,
                                BhaktiTheme.diyaGlow,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: BhaktiTheme.diyaGlow.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppStrings.donationCardCta,
                                style: BhaktiTheme.titleHi.copyWith(
                                  fontSize: 14,
                                  color: BhaktiTheme.maroonDeep,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: BhaktiTheme.maroonDeep,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DonationTrustFooter extends StatelessWidget {
  const _DonationTrustFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BhaktiTheme.maroon.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_rounded,
            color: BhaktiTheme.goldLight.withValues(alpha: 0.9),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.donationTrustLine,
              style: BhaktiTheme.bodyHi.copyWith(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
