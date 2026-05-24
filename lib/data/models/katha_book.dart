import 'package:bhakti_sadhana/data/models/vrat_katha.dart';

enum KathaPageKind { sectionTitle, chapterTitle, body }

/// एक पृष्ठ — किताब पढ़ने के लिए।
class KathaBookPage {
  const KathaBookPage({
    required this.kind,
    required this.text,
    this.sectionTitle,
    this.chapterTitle,
  });

  final KathaPageKind kind;
  final String text;
  final String? sectionTitle;
  final String? chapterTitle;

  bool get isReadable => kind == KathaPageKind.body;
}

/// JSON कथा → पृष्ठों में बाँटना (क्षैतिज पलट)।
abstract final class KathaBookBuilder {
  static const int _maxCharsPerPage = 420;

  static List<KathaBookPage> fromDocument(
    VratKathaDocument doc, {
    int? sectionIndex,
  }) {
    final sections = sectionIndex != null
        ? [doc.sections[sectionIndex]]
        : doc.sections;
    final pages = <KathaBookPage>[];
    for (final section in sections) {
      pages.addAll(_pagesForSection(section));
    }
    return pages;
  }

  static List<KathaBookPage> fromPlainText(String title, String body) {
    return [
      KathaBookPage(
        kind: KathaPageKind.sectionTitle,
        text: title,
        sectionTitle: title,
      ),
      ..._bodyPages(body, sectionTitle: title),
    ];
  }

  /// TTS के लिए केवल पढ़ने योग्य पाठ (क्रम में)।
  static List<String> speakableTexts(List<KathaBookPage> pages) {
    return pages
        .where((p) => p.isReadable && p.text.trim().isNotEmpty)
        .map((p) => p.text.trim())
        .toList();
  }

  static List<KathaBookPage> _pagesForSection(VratKathaSection section) {
    final pages = <KathaBookPage>[
      KathaBookPage(
        kind: KathaPageKind.sectionTitle,
        text: section.title,
        sectionTitle: section.title,
      ),
    ];

    if (section.chapters.isNotEmpty) {
      for (final chapter in section.chapters) {
        pages.add(
          KathaBookPage(
            kind: KathaPageKind.chapterTitle,
            text: chapter.title,
            sectionTitle: section.title,
            chapterTitle: chapter.title,
          ),
        );
        for (final paragraph in chapter.paragraphs) {
          pages.addAll(_bodyPages(paragraph, sectionTitle: section.title, chapterTitle: chapter.title));
        }
      }
    } else {
      for (final paragraph in section.paragraphs) {
        pages.addAll(_bodyPages(paragraph, sectionTitle: section.title));
      }
    }
    return pages;
  }

  static List<KathaBookPage> _bodyPages(
    String paragraph, {
    required String sectionTitle,
    String? chapterTitle,
  }) {
    final chunks = _splitParagraph(paragraph);
    return chunks
        .map(
          (chunk) => KathaBookPage(
            kind: KathaPageKind.body,
            text: chunk,
            sectionTitle: sectionTitle,
            chapterTitle: chapterTitle,
          ),
        )
        .toList();
  }

  static List<String> _splitParagraph(String paragraph) {
    final trimmed = paragraph.trim();
    if (trimmed.isEmpty) return const [];
    if (trimmed.length <= _maxCharsPerPage) return [trimmed];

    final parts = trimmed.split(RegExp(r'(?<=[।॥])\s*'));
    if (parts.length <= 1) {
      return _splitByLength(trimmed);
    }

    final chunks = <String>[];
    var buffer = StringBuffer();
    for (final part in parts) {
      final piece = part.trim();
      if (piece.isEmpty) continue;
      final candidate = buffer.isEmpty ? piece : '${buffer.toString()} $piece';
      if (candidate.length > _maxCharsPerPage && buffer.isNotEmpty) {
        chunks.add(buffer.toString().trim());
        buffer = StringBuffer(piece);
      } else {
        buffer = StringBuffer(candidate);
      }
    }
    if (buffer.isNotEmpty) chunks.add(buffer.toString().trim());
    return chunks;
  }

  static List<String> _splitByLength(String text) {
    final chunks = <String>[];
    var start = 0;
    while (start < text.length) {
      final end = (start + _maxCharsPerPage).clamp(0, text.length);
      chunks.add(text.substring(start, end).trim());
      start = end;
    }
    return chunks.where((c) => c.isNotEmpty).toList();
  }
}
