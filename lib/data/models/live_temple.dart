class LiveTemple {
  const LiveTemple({
    required this.id,
    required this.nameHi,
    required this.locationHi,
    required this.deityHi,
    this.youtubeChannelId,
    this.youtubeHandle,
    this.sourceHi,
  });

  final String id;
  final String nameHi;
  final String locationHi;
  final String deityHi;
  final String? youtubeChannelId;
  final String? youtubeHandle;
  final String? sourceHi;

  String get cacheKey => id;

  bool get hasYoutubeSource =>
      (youtubeChannelId != null && youtubeChannelId!.trim().isNotEmpty) ||
      (youtubeHandle != null && youtubeHandle!.trim().isNotEmpty);

  String get openUrl {
    if (youtubeChannelId != null && youtubeChannelId!.isNotEmpty) {
      return 'https://www.youtube.com/channel/$youtubeChannelId/live';
    }
    if (youtubeHandle != null && youtubeHandle!.isNotEmpty) {
      final h = youtubeHandle!.replaceFirst(RegExp(r'^@'), '');
      return 'https://www.youtube.com/@$h/live';
    }
    return 'https://www.youtube.com';
  }

  /// `assets/content/live_darshan.json` (camelCase) या Supabase row (snake_case)।
  factory LiveTemple.fromJson(Map<String, dynamic> json) {
    String? field(String camel, String snake) {
      final v = json[camel] ?? json[snake];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return LiveTemple(
      id: json['id'] as String,
      nameHi: field('nameHi', 'name_hi')!,
      locationHi: field('locationHi', 'location_hi')!,
      deityHi: field('deityHi', 'deity_hi')!,
      youtubeChannelId: field('youtubeChannelId', 'youtube_channel_id'),
      youtubeHandle: field('youtubeHandle', 'youtube_handle'),
      sourceHi: field('sourceHi', 'source_hi'),
    );
  }
}
