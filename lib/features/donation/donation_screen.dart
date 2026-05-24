import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/donation_catalog.dart';
import 'package:bhakti_sadhana/data/models/donation_cause.dart';
import 'package:bhakti_sadhana/data/models/worship_category.dart';
import 'package:bhakti_sadhana/features/donation/donation_checkout_sheet.dart';
import 'package:bhakti_sadhana/widgets/temple_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key, this.highlightCauseId});

  final String? highlightCauseId;

  @override
  Widget build(BuildContext context) {
    return TempleScaffold(
      title: AppStrings.donationTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const _DonationIntro(),
          const SizedBox(height: 20),
          ...DonationGroup.values.map(
            (g) => _DonationGroupSection(
              group: g,
              highlightCauseId: highlightCauseId,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationIntro extends StatelessWidget {
  const _DonationIntro();

  static const _imageAsset = 'assets/images/categories/donation.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: BhaktiTheme.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              _imageAsset,
              width: 88,
              height: 88,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) => Icon(
                WorshipCategory.donation.icon,
                size: 48,
                color: BhaktiTheme.goldLight,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.donationSubtitle,
            textAlign: TextAlign.center,
            style: BhaktiTheme.bodyHi.copyWith(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _DonationGroupSection extends StatelessWidget {
  const _DonationGroupSection({
    required this.group,
    this.highlightCauseId,
  });

  final DonationGroup group;
  final String? highlightCauseId;

  @override
  Widget build(BuildContext context) {
    final causes = DonationCatalog.forGroup(group);
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(group.title, style: BhaktiTheme.titleHi.copyWith(fontSize: 19)),
          const SizedBox(height: 4),
          Text(group.subtitle, style: BhaktiTheme.labelSub.copyWith(fontSize: 13)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: causes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final cause = causes[index];
              return _DonationSquareCard(
                cause: cause,
                highlighted: cause.id == highlightCauseId,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DonationSquareCard extends StatefulWidget {
  const _DonationSquareCard({
    required this.cause,
    this.highlighted = false,
  });

  final DonationCause cause;
  final bool highlighted;

  @override
  State<_DonationSquareCard> createState() => _DonationSquareCardState();
}

class _DonationSquareCardState extends State<_DonationSquareCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        showDonationCheckoutSheet(context, widget.cause);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: BhaktiTheme.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.highlighted
                  ? BhaktiTheme.saffronLight
                  : BhaktiTheme.gold.withValues(alpha: 0.4),
              width: widget.highlighted ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 8,
                offset: Offset(0, _pressed ? 2 : 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: BhaktiTheme.saffron.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: BhaktiTheme.gold.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        widget.cause.icon,
                        color: BhaktiTheme.goldLight,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.cause.title,
                  textAlign: TextAlign.center,
                  style: BhaktiTheme.titleHi.copyWith(fontSize: 13, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
