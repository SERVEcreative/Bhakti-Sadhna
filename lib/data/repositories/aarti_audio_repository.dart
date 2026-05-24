import 'dart:convert';

import 'package:bhakti_sadhana/data/models/aarti_audio_source.dart';
import 'package:flutter/services.dart';

class AartiAudioRepository {
  AartiAudioRepository._();
  static final AartiAudioRepository instance = AartiAudioRepository._();

  static const _assetPath = 'assets/content/aarti_audio.json';

  Map<String, AartiAudioSource>? _cache;

  Future<Map<String, AartiAudioSource>> _load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final sources = map['sources'] as Map<String, dynamic>;
    _cache = sources.map(
      (id, json) => MapEntry(
        id,
        AartiAudioSource.fromJson(id, json as Map<String, dynamic>),
      ),
    );
    return _cache!;
  }

  Future<AartiAudioSource?> getSource(String aartiId) async {
    final all = await _load();
    return all[aartiId];
  }
}
