import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/models/deity.dart';
import 'package:bhakti_sadhana/data/models/katha_book.dart';
import 'package:bhakti_sadhana/data/repositories/content_repository.dart';
import 'package:bhakti_sadhana/features/katha/katha_listen_screen.dart';
import 'package:bhakti_sadhana/features/katha/katha_reader_screen.dart';
import 'package:flutter/material.dart';

/// कथा पढ़ें / सुनें — पूजा विधि या व्रत से खोलें।
abstract final class KathaLauncher {
  static Future<void> showModePicker(BuildContext context, Deity deity) async {
    final stories = await _loadStories(deity);
    if (!context.mounted) return;

    if (stories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.vratKatha} ${AppStrings.comingSoonSection}',
            style: BhaktiTheme.bodyHi,
          ),
        ),
      );
      return;
    }

    if (stories.length == 1) {
      await _pickMode(context, stories.first);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: BhaktiTheme.maroonDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.kathaChooseStory,
                  textAlign: TextAlign.center,
                  style: BhaktiTheme.titleHi.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),
                ...stories.map(
                  (s) => ListTile(
                    title: Text(s.title, style: BhaktiTheme.bodyHi),
                    trailing: const Icon(Icons.chevron_right_rounded, color: BhaktiTheme.gold),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickMode(context, s);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _pickMode(BuildContext context, _KathaStory story) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: BhaktiTheme.maroonDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  story.title,
                  textAlign: TextAlign.center,
                  style: BhaktiTheme.titleHi.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SheetButton(
                        label: AppStrings.kathaPadhe,
                        icon: Icons.auto_stories_rounded,
                        onTap: () {
                          Navigator.pop(ctx);
                          _openReader(context, story);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SheetButton(
                        label: AppStrings.kathaSune,
                        icon: Icons.headphones_rounded,
                        filled: false,
                        onTap: () {
                          Navigator.pop(ctx);
                          _openListen(context, story);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _openReader(BuildContext context, _KathaStory story) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => KathaReaderScreen(title: story.screenTitle, pages: story.pages),
      ),
    );
  }

  static void _openListen(BuildContext context, _KathaStory story) {
    if (story.texts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.kathaNoAudioText, style: BhaktiTheme.bodyHi)),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => KathaListenScreen(
          title: story.title,
          texts: story.texts,
          autoStart: false,
        ),
      ),
    );
  }

  static Future<List<_KathaStory>> _loadStories(Deity deity) async {
    final doc = await ContentRepository.instance.getVratKatha(deity.id);
    if (doc != null && doc.sections.isNotEmpty) {
      return List.generate(doc.sections.length, (i) {
        final pages = KathaBookBuilder.fromDocument(doc, sectionIndex: i);
        return _KathaStory(
          title: doc.sections[i].title,
          screenTitle: doc.title,
          pages: pages,
          texts: KathaBookBuilder.speakableTexts(pages),
        );
      });
    }
    if (deity.vrat.trim().isEmpty) return [];
    final pages = KathaBookBuilder.fromPlainText(AppStrings.vratKatha, deity.vrat);
    return [
      _KathaStory(
        title: AppStrings.vratKatha,
        screenTitle: deity.name,
        pages: pages,
        texts: KathaBookBuilder.speakableTexts(pages),
      ),
    ];
  }
}

class _KathaStory {
  const _KathaStory({
    required this.title,
    required this.screenTitle,
    required this.pages,
    required this.texts,
  });

  final String title;
  final String screenTitle;
  final List<KathaBookPage> pages;
  final List<String> texts;
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: filled ? BhaktiTheme.goldShimmer : null,
            color: filled ? null : BhaktiTheme.saffron.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.5)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: BhaktiTheme.maroonDeep, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
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
