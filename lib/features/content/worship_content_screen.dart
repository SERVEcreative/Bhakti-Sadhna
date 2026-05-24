import 'dart:async';

import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/models/deity.dart';
import 'package:bhakti_sadhana/data/models/worship_category.dart';
import 'package:bhakti_sadhana/data/repositories/content_repository.dart';
import 'package:bhakti_sadhana/widgets/katha/katha_launcher.dart';
import 'package:bhakti_sadhana/widgets/katha/vrat_katha_hub.dart';
import 'package:bhakti_sadhana/services/aarti_player/aarti_player_service.dart';
import 'package:bhakti_sadhana/widgets/aarti_player_bar.dart';
import 'package:bhakti_sadhana/widgets/deity_portrait.dart';
import 'package:bhakti_sadhana/widgets/temple_scaffold.dart';
import 'package:flutter/material.dart';
class WorshipContentScreen extends StatefulWidget {
  const WorshipContentScreen({
    super.key,
    required this.categoryId,
    required this.deityId,
  });

  final String categoryId;
  final String deityId;

  @override
  State<WorshipContentScreen> createState() => _WorshipContentScreenState();
}

class _WorshipContentScreenState extends State<WorshipContentScreen> {
  late final Future<Deity?> _deityFuture;
  WorshipCategory? _category;

  @override
  void initState() {
    super.initState();
    _category = WorshipCategory.fromId(widget.categoryId);
    _deityFuture = ContentRepository.instance.getDeity(widget.deityId);
  }

  @override
  void dispose() {
    if (widget.categoryId == WorshipCategory.aarti.id) {
      unawaited(AartiPlayerService.instance.stop());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = _category;
    if (category == null) {
      return const TempleScaffold(
        title: AppStrings.errorTitle,
        body: Center(child: Text(AppStrings.errorInvalidCategory)),
      );
    }

    return FutureBuilder<Deity?>(
      future: _deityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TempleScaffold(
            title: category.label,
            body: const Center(
              child: CircularProgressIndicator(color: BhaktiTheme.gold),
            ),
          );
        }

        final deity = snapshot.data;
        if (deity == null) {
          return TempleScaffold(
            title: category.label,
            body: Center(
              child: Text(AppStrings.errorDeityNotFound, style: BhaktiTheme.bodyHi),
            ),
          );
        }

        return TempleScaffold(
          title: deity.name,
          body: _ContentBody(category: category, deity: deity),
        );
      },
    );
  }
}

class _ContentBody extends StatelessWidget {
  const _ContentBody({required this.category, required this.deity});

  final WorshipCategory category;
  final Deity deity;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _DeityHero(deity: deity, category: category),
        const SizedBox(height: 20),
        ...switch (category) {
          WorshipCategory.puja => _pujaContent(context, deity),
          WorshipCategory.aarti => _aartiContent(deity),
          WorshipCategory.mantra => _mantraContent(deity),
          WorshipCategory.festival => _textSection(AppStrings.festival, deity.festival),
          WorshipCategory.vrat => [VratKathaHub(deity: deity)],
          WorshipCategory.donation => const [],
        },
      ],
    );
  }

  List<Widget> _pujaContent(BuildContext context, Deity d) {
    void openKatha() => KathaLauncher.showModePicker(context, d);

    return [
      if (d.samagri.isNotEmpty) ...[
        const _SectionTitle(AppStrings.pujaSamagri, Icons.inventory_2_outlined),
        const SizedBox(height: 8),
        _SamagriList(items: d.samagri),
        const SizedBox(height: 20),
      ],
      const _SectionTitle(AppStrings.pujaSteps, Icons.format_list_numbered_rounded),
      const SizedBox(height: 12),
      ...d.pujaSteps.map(
        (s) => _PujaStepCard(
          step: s,
          total: d.pujaSteps.length,
          showKathaLink: d.hasKatha && s.isKathaStep,
          onKathaPadhe: openKatha,
          aarti: d.aartis.isNotEmpty && s.isAartiStep ? d.aartis.first : null,
        ),
      ),
    ];
  }

  List<Widget> _aartiContent(Deity d) {
    if (d.aartis.isEmpty) {
      return [_emptyNote(AppStrings.comingSoonAarti)];
    }
    return d.aartis.expand((a) => [
          _SectionTitle(a.title, Icons.local_fire_department_rounded),
          const SizedBox(height: 8),
          AartiPlayerBar(aartiId: a.id, title: a.title),
          const SizedBox(height: 12),
          _VerseCard(verses: a.verses),
          const SizedBox(height: 24),
        ]).toList();
  }

  List<Widget> _mantraContent(Deity d) {
    if (d.mantras.isEmpty) {
      return [_emptyNote(AppStrings.comingSoonMantra)];
    }
    return d.mantras
        .map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _MantraCard(text: m.text, meaning: m.meaning),
          ),
        )
        .toList();
  }

  List<Widget> _textSection(String title, String body) {
    if (body.isEmpty) {
      return [_emptyNote('$title ${AppStrings.comingSoonSection}')];
    }
    return [
      _SectionTitle(title, Icons.menu_book_rounded),
      const SizedBox(height: 12),
      _VerseCard(verses: body.split('\n').where((l) => l.trim().isNotEmpty).toList()),
    ];
  }

  Widget _emptyNote(String msg) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BhaktiTheme.maroon.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.3)),
        ),
        child: Text(msg, style: BhaktiTheme.bodyHi),
      );
}

class _DeityHero extends StatelessWidget {
  const _DeityHero({required this.deity, required this.category});

  final Deity deity;
  final WorshipCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: BhaktiTheme.cardGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: BhaktiTheme.diyaGlow.withValues(alpha: 0.25),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          DeityPortraitBanner(deity: deity),
          const SizedBox(height: 14),
          Text(deity.name, style: BhaktiTheme.displayHi.copyWith(fontSize: 26)),
          if (deity.tagline.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(deity.tagline, style: BhaktiTheme.labelSub.copyWith(fontSize: 15)),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: BhaktiTheme.saffron.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(category.icon, size: 16, color: BhaktiTheme.goldLight),
                const SizedBox(width: 6),
                Text(category.label, style: BhaktiTheme.bodyHi.copyWith(fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            deity.about,
            textAlign: TextAlign.center,
            style: BhaktiTheme.bodyHi.copyWith(fontSize: 15, color: BhaktiTheme.creamDim),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, this.icon);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: BhaktiTheme.saffronLight, size: 22),
        const SizedBox(width: 8),
        Text(text, style: BhaktiTheme.titleHi.copyWith(fontSize: 20)),
      ],
    );
  }
}

class _SamagriList extends StatelessWidget {
  const _SamagriList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BhaktiTheme.cream.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🪷 ', style: TextStyle(fontSize: 14)),
                    Expanded(child: Text(item, style: BhaktiTheme.bodyHi.copyWith(fontSize: 15))),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PujaActionButton extends StatelessWidget {
  const _PujaActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.trailingIcon = Icons.arrow_forward_rounded,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: BhaktiTheme.goldShimmer,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: BhaktiTheme.diyaGlow.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: BhaktiTheme.maroonDeep, size: 26),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: BhaktiTheme.titleHi.copyWith(
                    fontSize: 18,
                    color: BhaktiTheme.maroonDeep,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(trailingIcon, color: BhaktiTheme.maroonDeep, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PujaStepCard extends StatelessWidget {
  const _PujaStepCard({
    required this.step,
    required this.total,
    this.showKathaLink = false,
    this.onKathaPadhe,
    this.aarti,
  });

  final PujaStep step;
  final int total;
  final bool showKathaLink;
  final VoidCallback? onKathaPadhe;
  final AartiItem? aarti;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: BhaktiTheme.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: BhaktiTheme.goldShimmer,
                  ),
                  child: Text(
                    '${step.order}',
                    style: BhaktiTheme.titleHi.copyWith(
                      fontSize: 16,
                      color: BhaktiTheme.maroonDeep,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(step.title, style: BhaktiTheme.titleHi.copyWith(fontSize: 17)),
                ),
                Text(
                  '${AppStrings.stepCounter} ${step.order}/$total',
                  style: BhaktiTheme.labelSub.copyWith(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(step.body, style: BhaktiTheme.bodyHi.copyWith(fontSize: 15)),
            if (step.mantra != null) ...[
              const SizedBox(height: 10),
              Text(step.mantra!, style: BhaktiTheme.mantraHi),
            ],
            if (showKathaLink && onKathaPadhe != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: _PujaActionButton(
                  label: AppStrings.kathaPadhe,
                  icon: Icons.menu_book_rounded,
                  onPressed: onKathaPadhe!,
                ),
              ),
            ],
            if (aarti != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: _PujaActionButton(
                  label: AppStrings.aartiChalaye,
                  icon: Icons.local_fire_department_rounded,
                  trailingIcon: Icons.play_arrow_rounded,
                  onPressed: () => AartiPlayerService.instance.play(aarti!.id),
                ),
              ),
              ValueListenableBuilder<AartiPlaybackSnapshot>(
                valueListenable: AartiPlayerService.instance.snapshot,
                builder: (context, snap, _) {
                  if (snap.aartiId != aarti!.id) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: AartiPlayerBar(aartiId: aarti!.id, title: aarti!.title),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard({required this.verses});

  final List<String> verses;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BhaktiTheme.cream.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: BhaktiTheme.diyaGlow.withValues(alpha: 0.12),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: verses
            .map(
              (v) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  v,
                  textAlign: TextAlign.center,
                  style: BhaktiTheme.bodyHi.copyWith(
                    fontSize: 18,
                    height: 1.8,
                    color: BhaktiTheme.goldLight,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MantraCard extends StatelessWidget {
  const _MantraCard({required this.text, required this.meaning});

  final String text;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: BhaktiTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(text, textAlign: TextAlign.center, style: BhaktiTheme.mantraHi.copyWith(fontSize: 20)),
          const SizedBox(height: 10),
          Text(meaning, textAlign: TextAlign.center, style: BhaktiTheme.bodyHi.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
