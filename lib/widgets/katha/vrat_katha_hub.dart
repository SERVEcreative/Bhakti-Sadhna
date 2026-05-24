import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/models/deity.dart';
import 'package:bhakti_sadhana/data/models/katha_book.dart';
import 'package:bhakti_sadhana/data/models/vrat_katha.dart';
import 'package:bhakti_sadhana/data/repositories/content_repository.dart';
import 'package:bhakti_sadhana/features/katha/katha_listen_screen.dart';
import 'package:bhakti_sadhana/features/katha/katha_reader_screen.dart';
import 'package:flutter/material.dart';
/// व्रत कथा — हर कथा के लिए पढ़ें / सुनें।
class VratKathaHub extends StatelessWidget {
  const VratKathaHub({super.key, required this.deity});

  final Deity deity;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VratKathaDocument?>(
      future: ContentRepository.instance.getVratKatha(deity.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(color: BhaktiTheme.gold),
            ),
          );
        }

        final doc = snapshot.data;
        if (doc != null && doc.sections.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HubSectionTitle(),
              const SizedBox(height: 10),
              Text(
                doc.title,
                textAlign: TextAlign.center,
                style: BhaktiTheme.titleHi.copyWith(
                  fontSize: 19,
                  color: BhaktiTheme.goldLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.kathaHubHint,
                textAlign: TextAlign.center,
                style: BhaktiTheme.labelSub.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 18),
              ...List.generate(doc.sections.length, (i) {
                final section = doc.sections[i];
                final pages = KathaBookBuilder.fromDocument(doc, sectionIndex: i);
                final texts = KathaBookBuilder.speakableTexts(pages);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _KathaStoryCard(
                    title: section.title,
                    pageCount: pages.where((p) => p.isReadable).length,
                    onRead: () => _openReader(context, doc.title, pages),
                    onListen: () => _openListen(context, section.title, texts),
                  ),
                );
              }),
            ],
          );
        }

        if (deity.vrat.trim().isEmpty) {
          return _EmptyNote('${AppStrings.vratKatha} ${AppStrings.comingSoonSection}');
        }

        final pages = KathaBookBuilder.fromPlainText(
          AppStrings.vratKatha,
          deity.vrat,
        );
        final texts = KathaBookBuilder.speakableTexts(pages);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HubSectionTitle(),
            const SizedBox(height: 14),
            _KathaStoryCard(
              title: AppStrings.vratKatha,
              pageCount: pages.where((p) => p.isReadable).length,
              onRead: () => _openReader(context, deity.name, pages),
              onListen: () => _openListen(context, deity.name, texts),
            ),
          ],
        );
      },
    );
  }

  void _openReader(BuildContext context, String title, List<KathaBookPage> pages) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => KathaReaderScreen(title: title, pages: pages),
      ),
    );
  }

  void _openListen(BuildContext context, String title, List<String> texts) {
    if (texts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.kathaNoAudioText, style: BhaktiTheme.bodyHi)),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => KathaListenScreen(title: title, texts: texts, autoStart: false),
      ),
    );
  }
}

class _HubSectionTitle extends StatelessWidget {
  const _HubSectionTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.menu_book_rounded, color: BhaktiTheme.goldLight, size: 22),
        const SizedBox(width: 8),
        Text(AppStrings.vratKatha, style: BhaktiTheme.titleHi.copyWith(fontSize: 20)),
      ],
    );
  }
}

class _KathaStoryCard extends StatelessWidget {
  const _KathaStoryCard({
    required this.title,
    required this.pageCount,
    required this.onRead,
    required this.onListen,
  });

  final String title;
  final int pageCount;
  final VoidCallback onRead;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: BhaktiTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: BhaktiTheme.titleHi.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            '$pageCount ${AppStrings.kathaPagesShort}',
            style: BhaktiTheme.labelSub.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  label: AppStrings.kathaPadhe,
                  icon: Icons.auto_stories_rounded,
                  onTap: onRead,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeButton(
                  label: AppStrings.kathaSune,
                  icon: Icons.headphones_rounded,
                  onTap: onListen,
                  secondary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.secondary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: secondary ? null : BhaktiTheme.goldShimmer,
            color: secondary ? BhaktiTheme.saffron.withValues(alpha: 0.22) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: secondary
                  ? BhaktiTheme.gold.withValues(alpha: 0.5)
                  : Colors.transparent,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: BhaktiTheme.maroonDeep, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: BhaktiTheme.titleHi.copyWith(
                  fontSize: 15,
                  color: BhaktiTheme.maroonDeep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BhaktiTheme.maroon.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.3)),
      ),
      child: Text(message, style: BhaktiTheme.bodyHi),
    );
  }
}
