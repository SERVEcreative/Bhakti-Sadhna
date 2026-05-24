class VratKathaChapter {
  const VratKathaChapter({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;
}

/// एक देवता के अंतर्गत अलग-अलग कथा (जैसे संकष्टी, सोमवार व्रत आदि)।
class VratKathaSection {
  const VratKathaSection({
    required this.title,
    this.chapters = const [],
    this.paragraphs = const [],
  });

  final String title;
  final List<VratKathaChapter> chapters;
  final List<String> paragraphs;

  bool get isEmpty => chapters.isEmpty && paragraphs.isEmpty;
}

class VratKathaDocument {
  const VratKathaDocument({required this.title, required this.sections});

  final String title;
  final List<VratKathaSection> sections;

  factory VratKathaDocument.fromJson(Map<String, dynamic> json) {
    final title = json['titleHi'] as String? ?? 'व्रत कथा';

    if (json['sections'] != null) {
      final sectionsJson = json['sections'] as List<dynamic>;
      return VratKathaDocument(
        title: title,
        sections: sectionsJson
            .map((s) => _sectionFromJson(s as Map<String, dynamic>))
            .where((s) => !s.isEmpty)
            .toList(),
      );
    }

    // पुराना प्रारूप: सिर्फ chapters
    if (json['chapters'] != null) {
      return VratKathaDocument(
        title: title,
        sections: [
          VratKathaSection(
            title: 'संपूर्ण कथा',
            chapters: _chaptersFromJson(json['chapters'] as List<dynamic>),
          ),
        ],
      );
    }

    return VratKathaDocument(title: title, sections: const []);
  }

  static VratKathaSection _sectionFromJson(Map<String, dynamic> json) {
    final chaptersJson = json['chapters'] as List<dynamic>?;
    final paragraphsJson = json['paragraphsHi'] as List<dynamic>? ??
        json['paragraphs'] as List<dynamic>?;

    return VratKathaSection(
      title: (json['titleHi'] ?? json['title']) as String,
      chapters: chaptersJson != null ? _chaptersFromJson(chaptersJson) : const [],
      paragraphs: paragraphsJson?.cast<String>() ?? const [],
    );
  }

  static List<VratKathaChapter> _chaptersFromJson(List<dynamic> list) {
    return list
        .map(
          (c) => VratKathaChapter(
            title: (c['titleHi'] ?? c['title']) as String,
            paragraphs: ((c['paragraphsHi'] ?? c['paragraphs']) as List<dynamic>)
                .cast<String>(),
          ),
        )
        .toList();
  }
}
