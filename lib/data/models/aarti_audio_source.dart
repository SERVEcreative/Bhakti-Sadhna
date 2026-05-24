class AartiAudioSource {
  const AartiAudioSource({
    required this.aartiId,
    this.storagePath,
    this.audioUrl,
  });

  factory AartiAudioSource.fromJson(String aartiId, Map<String, dynamic> json) =>
      AartiAudioSource(
        aartiId: aartiId,
        storagePath: json['storagePath'] as String?,
        audioUrl: json['audioUrl'] as String?,
      );

  final String aartiId;
  final String? storagePath;
  final String? audioUrl;

  bool get hasSource =>
      (audioUrl != null && audioUrl!.isNotEmpty) ||
      (storagePath != null && storagePath!.isNotEmpty);
}
