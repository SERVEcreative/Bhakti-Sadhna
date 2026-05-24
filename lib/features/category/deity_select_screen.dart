import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/models/deity.dart';
import 'package:bhakti_sadhana/data/models/worship_category.dart';
import 'package:bhakti_sadhana/data/repositories/content_repository.dart';
import 'package:bhakti_sadhana/widgets/deity_tile.dart' show DeityGridCard;
import 'package:bhakti_sadhana/widgets/temple_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeitySelectScreen extends StatefulWidget {
  const DeitySelectScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<DeitySelectScreen> createState() => _DeitySelectScreenState();
}

class _DeitySelectScreenState extends State<DeitySelectScreen> {
  late final Future<List<Deity>> _deitiesFuture;
  WorshipCategory? _category;

  @override
  void initState() {
    super.initState();
    _category = WorshipCategory.fromId(widget.categoryId);
    if (_category?.opensDonationScreen == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.replace('/donation');
      });
    }
    _deitiesFuture = ContentRepository.instance.loadDeities();
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

    return TempleScaffold(
      title: category.label,
      body: FutureBuilder<List<Deity>>(
        future: _deitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: BhaktiTheme.gold),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                AppStrings.errorLoadContent,
                style: BhaktiTheme.bodyHi,
              ),
            );
          }

          final deities = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryBanner(category: category),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.selectDeity,
                        style: BhaktiTheme.titleHi.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${deities.length} देवी-देवता • ${category.subtitle}',
                        style: BhaktiTheme.labelSub,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final d = deities[index];
                      return DeityGridCard(
                        key: ValueKey(d.id),
                        deity: d,
                        onTap: () => context.push(
                          '/content/${category.id}/${d.id}',
                        ),
                      );
                    },
                    childCount: deities.length,
                    addRepaintBoundaries: true,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryBanner extends StatelessWidget {
  const _CategoryBanner({required this.category});

  final WorshipCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: BhaktiTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: BhaktiTheme.diyaGlow.withValues(alpha: 0.2),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BhaktiTheme.saffron.withValues(alpha: 0.3),
              border: Border.all(color: BhaktiTheme.gold),
            ),
            child: Icon(category.icon, color: BhaktiTheme.goldLight, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _hintFor(category),
              style: BhaktiTheme.bodyHi.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  String _hintFor(WorshipCategory c) {
    return switch (c) {
      WorshipCategory.puja =>
        'चरणबद्ध पूजा विधि, सामग्री और मंत्र — घर पर मंदिर जैसी पूजा के लिए।',
      WorshipCategory.aarti =>
        'पूर्ण आरती और स्तुति के श्लोक — दीप जलाकर पढ़ें।',
      WorshipCategory.mantra =>
        'पवित्र मंत्र और उनका अर्थ — जप के लिए।',
      WorshipCategory.festival =>
        'प्रमुख त्योहारों की पूजा विधि संक्षेप में।',
      WorshipCategory.vrat =>
        'व्रत की कथा और नियम — श्रद्धा से पालन करें।',
      WorshipCategory.donation =>
        'गौ सेवा, मातृ-पितृ सेवा, मंदिर और तीर्थ — श्रद्धा से दान।',
    };
  }
}
