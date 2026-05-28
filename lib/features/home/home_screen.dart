import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/models/worship_category.dart';
import 'package:bhakti_sadhana/widgets/category_card.dart';
import 'package:bhakti_sadhana/widgets/ads/puja_section_banner_shell.dart';
import 'package:bhakti_sadhana/widgets/temple_background.dart';
import 'package:bhakti_sadhana/widgets/temple_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_imagesPrecached) return;
    _imagesPrecached = true;
    _precacheCategoryImages();
  }

  void _precacheCategoryImages() {
    for (final cat in WorshipCategory.values) {
      precacheImage(AssetImage(cat.imageAsset), context).ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        WorshipCategory.values.where((c) => c.showOnPujaHome).toList();

    return Scaffold(
      body: TempleBackground(
        child: SafeArea(
          child: PujaSectionBannerShell(
            child: CustomScrollView(
            cacheExtent: 200,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TempleHeader(),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.homePrompt,
                        textAlign: TextAlign.center,
                        style: BhaktiTheme.bodyHi.copyWith(
                          fontSize: 18,
                          color: BhaktiTheme.cream,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.homeSubPrompt,
                        textAlign: TextAlign.center,
                        style: BhaktiTheme.labelSub,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cat = categories[index];
                      return CategoryCard(
                        key: ValueKey(cat.id),
                        category: cat,
                        onTap: () => context.push('/select/${cat.id}'),
                      );
                    },
                    childCount: categories.length,
                    addRepaintBoundaries: true,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: BhaktiTheme.maroon.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: BhaktiTheme.gold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: BhaktiTheme.saffronLight.withValues(alpha: 0.9),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppStrings.disclaimer,
                            style: BhaktiTheme.bodyHi.copyWith(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
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
