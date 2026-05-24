import 'package:bhakti_sadhana/core/assets/asset_paths.dart';

class PujaStep {
  const PujaStep({
    required this.order,
    required this.title,
    required this.body,
    this.mantra,
  });

  factory PujaStep.fromJson(Map<String, dynamic> json) => PujaStep(
        order: json['order'] as int,
        title: (json['titleHi'] ?? json['title']) as String,
        body: (json['bodyHi'] ?? json['body']) as String,
        mantra: (json['mantraHi'] ?? json['mantra']) as String?,
      );

  final int order;
  final String title;
  final String body;
  final String? mantra;
}

class AartiItem {
  const AartiItem({
    required this.id,
    required this.title,
    required this.verses,
  });

  factory AartiItem.fromJson(Map<String, dynamic> json) => AartiItem(
        id: json['id'] as String,
        title: (json['titleHi'] ?? json['title']) as String,
        verses: ((json['versesHi'] ?? json['verses']) as List<dynamic>).cast<String>(),
      );

  final String id;
  final String title;
  final List<String> verses;
}

class BhajanItem {
  const BhajanItem({
    required this.id,
    required this.title,
    required this.lyrics,
  });

  factory BhajanItem.fromJson(Map<String, dynamic> json) => BhajanItem(
        id: json['id'] as String,
        title: (json['titleHi'] ?? json['title']) as String,
        lyrics: ((json['lyricsHi'] ?? json['lyrics']) as List<dynamic>).cast<String>(),
      );

  final String id;
  final String title;
  final List<String> lyrics;
}

class MantraItem {
  const MantraItem({
    required this.text,
    required this.meaning,
  });

  factory MantraItem.fromJson(Map<String, dynamic> json) => MantraItem(
        text: (json['textHi'] ?? json['text']) as String,
        meaning: (json['meaningHi'] ?? json['meaning']) as String,
      );

  final String text;
  final String meaning;
}

class Deity {
  const Deity({
    required this.id,
    required this.name,
    required this.tagline,
    required this.emoji,
    this.imageAsset,
    required this.about,
    required this.samagri,
    required this.pujaSteps,
    required this.aartis,
    required this.bhajans,
    required this.mantras,
    required this.festival,
    required this.vrat,
  });

  factory Deity.fromJson(Map<String, dynamic> json) {
    final puja = json['puja'] as Map<String, dynamic>?;
    final id = json['id'] as String;
    final image = json['image'] as String?;
    return Deity(
      id: id,
      name: (json['nameHi'] ?? json['name']) as String,
      tagline: (json['taglineHi'] ?? json['nameEn'] ?? json['tagline'] ?? '') as String,
      emoji: json['emoji'] as String? ?? '🙏',
      imageAsset: image != null
          ? AssetPaths.toPngPath(image)
          : AssetPaths.deityImage(id),
      about: (json['shortAboutHi'] ?? json['about']) as String,
      samagri: (json['samagriHi'] as List<dynamic>?)?.cast<String>() ??
          (puja?['samagriHi'] as List<dynamic>?)?.cast<String>() ??
          [],
      pujaSteps: (puja?['steps'] as List<dynamic>?)
              ?.map((e) => PujaStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      aartis: (json['aartis'] as List<dynamic>?)
              ?.map((e) => AartiItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bhajans: (json['bhajans'] as List<dynamic>?)
              ?.map((e) => BhajanItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mantras: (json['mantras'] as List<dynamic>?)
              ?.map((e) => MantraItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      festival: json['festivalHi'] as String? ?? '',
      vrat: json['vratHi'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String tagline;
  final String emoji;
  final String? imageAsset;

  bool get hasImage => imageAsset != null && imageAsset!.isNotEmpty;

  final String about;
  final List<String> samagri;
  final List<PujaStep> pujaSteps;
  final List<AartiItem> aartis;
  final List<BhajanItem> bhajans;
  final List<MantraItem> mantras;
  final String festival;
  final String vrat;

  /// व्रत कथा श्रेणी में सामग्री उपलब्ध है या नहीं।
  bool get hasKatha => vrat.trim().isNotEmpty;
}
