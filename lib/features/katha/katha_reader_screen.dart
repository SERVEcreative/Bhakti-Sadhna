import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/models/katha_book.dart';
import 'package:bhakti_sadhana/widgets/temple_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// किताब जैसी कथा — क्षैतिज स्वाइप से अगला पृष्ठ।
class KathaReaderScreen extends StatefulWidget {
  const KathaReaderScreen({
    super.key,
    required this.title,
    required this.pages,
    this.initialPage = 0,
  });

  final String title;
  final List<KathaBookPage> pages;
  final int initialPage;

  @override
  State<KathaReaderScreen> createState() => _KathaReaderScreenState();
}

class _KathaReaderScreenState extends State<KathaReaderScreen> {
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(0, widget.pages.length - 1);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _readableCount =>
      widget.pages.where((p) => p.kind == KathaPageKind.body).length;

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text(widget.title, style: BhaktiTheme.titleHi.copyWith(fontSize: 18)),
        ),
        body: Center(
          child: Text(AppStrings.kathaNoPages, style: BhaktiTheme.bodyHi),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.title,
          style: BhaktiTheme.titleHi.copyWith(fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                AppStrings.kathaSwipeHint,
                style: BhaktiTheme.labelSub.copyWith(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
      body: TempleBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: _BookPageView(page: widget.pages[index]),
                    );
                  },
                ),
              ),
              _ReaderFooter(
                current: _currentPage + 1,
                total: widget.pages.length,
                readableTotal: _readableCount,
                onPrevious: _currentPage > 0
                    ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        )
                    : null,
                onNext: _currentPage < widget.pages.length - 1
                    ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookPageView extends StatelessWidget {
  const _BookPageView({required this.page});

  final KathaBookPage page;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFD4C4A0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(4, 6),
              ),
              BoxShadow(
                color: BhaktiTheme.gold.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 14,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 22, 24),
                child: _pageContent(constraints.maxHeight),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pageContent(double maxHeight) {
    return switch (page.kind) {
      KathaPageKind.sectionTitle => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, size: 48, color: BhaktiTheme.maroon.withValues(alpha: 0.7)),
              const SizedBox(height: 20),
              Text(
                page.text,
                textAlign: TextAlign.center,
                style: BhaktiTheme.titleHi.copyWith(
                  fontSize: 26,
                  color: BhaktiTheme.maroonDeep,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.kathaTurnPage,
                style: BhaktiTheme.bodyHiDark.copyWith(
                  fontSize: 15,
                  color: BhaktiTheme.maroon.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      KathaPageKind.chapterTitle => Center(
          child: Text(
            page.text,
            textAlign: TextAlign.center,
            style: BhaktiTheme.titleHi.copyWith(
              fontSize: 22,
              color: BhaktiTheme.maroonDeep,
              height: 1.4,
            ),
          ),
        ),
      KathaPageKind.body => SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: maxHeight - 52),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (page.chapterTitle != null) ...[
                  Text(
                    page.chapterTitle!,
                    textAlign: TextAlign.center,
                    style: BhaktiTheme.labelSub.copyWith(
                      fontSize: 13,
                      color: BhaktiTheme.maroon.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  page.text,
                  textAlign: TextAlign.justify,
                  style: BhaktiTheme.bodyHiDark.copyWith(
                    fontSize: 20,
                    height: 1.85,
                    letterSpacing: 0.2,
                    color: const Color(0xFF2A1810),
                  ),
                ),
              ],
            ),
          ),
        ),
    };
  }
}

class _ReaderFooter extends StatelessWidget {
  const _ReaderFooter({
    required this.current,
    required this.total,
    required this.readableTotal,
    this.onPrevious,
    this.onNext,
  });

  final int current;
  final int total;
  final int readableTotal;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BhaktiTheme.maroon.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: onPrevious != null ? BhaktiTheme.goldLight : BhaktiTheme.textMuted,
              size: 32,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${AppStrings.kathaPageLabel} $current / $total',
                  style: BhaktiTheme.titleHi.copyWith(fontSize: 16),
                ),
                Text(
                  '$readableTotal ${AppStrings.kathaParagraphsLabel}',
                  style: BhaktiTheme.labelSub.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: onNext != null ? BhaktiTheme.goldLight : BhaktiTheme.textMuted,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
