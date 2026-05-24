import 'package:bhakti_sadhana/bootstrap/supabase_bootstrap.dart';
import 'package:bhakti_sadhana/config/supabase_config.dart';
import 'package:bhakti_sadhana/data/models/aarti_audio_source.dart';
import 'package:flutter/foundation.dart';

/// Supabase Storage → public HTTPS URL for just_audio.
class AartiSupabaseResolver {
  AartiSupabaseResolver._();
  static final AartiSupabaseResolver instance = AartiSupabaseResolver._();

  final Map<String, _CachedUrl> _cache = {};

  Future<String> resolve(AartiAudioSource source) async {
    if (source.audioUrl != null && source.audioUrl!.isNotEmpty) {
      return source.audioUrl!;
    }

    final path = _objectPath(source.storagePath);
    if (path == null || path.isEmpty) {
      throw StateError('no_storage_path');
    }

    if (!SupabaseBootstrap.initialized) {
      throw StateError(SupabaseBootstrap.initError ?? 'supabase_not_ready');
    }

    final cached = _cache[path];
    if (cached != null && !cached.isExpired) {
      return cached.url;
    }

    try {
      final storage = SupabaseBootstrap.client.storage.from(SupabaseConfig.aartiBucket);
      final url = storage.getPublicUrl(path);
      _cache[path] = _CachedUrl(url: url, fetchedAt: DateTime.now());
      return url;
    } catch (e, st) {
      debugPrint('AartiSupabaseResolver $path: $e\n$st');
      rethrow;
    }
  }

  /// `aartis/jai_ganesh.mp3` → `jai_ganesh.mp3` (bucket already `aartis`)
  static String? _objectPath(String? storagePath) {
    if (storagePath == null) return null;
    final p = storagePath.trim();
    if (p.isEmpty) return null;
    const prefix = 'aartis/';
    if (p.startsWith(prefix)) return p.substring(prefix.length);
    return p;
  }

  void invalidate(String storagePath) {
    final path = _objectPath(storagePath);
    if (path != null) _cache.remove(path);
  }
}

class _CachedUrl {
  _CachedUrl({required this.url, required this.fetchedAt});

  final String url;
  final DateTime fetchedAt;

  bool get isExpired => DateTime.now().difference(fetchedAt) > const Duration(hours: 12);
}
