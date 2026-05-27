import 'dart:convert';

import 'package:bhakti_sadhana/bootstrap/supabase_bootstrap.dart';
import 'package:bhakti_sadhana/data/models/live_temple.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LiveDarshanRepository {
  LiveDarshanRepository._();
  static final LiveDarshanRepository instance = LiveDarshanRepository._();

  List<LiveTemple>? _cache;

  /// Supabase से सूची (active) — fail हो तो local JSON fallback।
  Future<List<LiveTemple>> loadTemples({bool refresh = false}) async {
    if (_cache != null && !refresh) return _cache!;

    if (SupabaseBootstrap.initialized) {
      try {
        final rows = await SupabaseBootstrap.client
            .from('live_darshan_temples')
            .select()
            .eq('is_active', true)
            .order('sort_order', ascending: true);

        final list = (rows as List<dynamic>)
            .map((e) => LiveTemple.fromJson(e as Map<String, dynamic>))
            .where((t) => t.hasYoutubeSource)
            .toList();

        if (list.isNotEmpty) {
          _cache = list;
          debugPrint('LiveDarshanRepository: ${list.length} temples from Supabase');
          return _cache!;
        }
      } catch (e, st) {
        debugPrint('LiveDarshanRepository Supabase: $e\n$st');
      }
    }

    _cache = await _loadFromAssets();
    debugPrint('LiveDarshanRepository: ${_cache!.length} temples from assets fallback');
    return _cache!;
  }

  void clearCache() => _cache = null;

  Future<List<LiveTemple>> _loadFromAssets() async {
    final raw =
        await rootBundle.loadString('assets/content/live_darshan.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final list = map['temples'] as List<dynamic>;
    return list
        .map((e) => LiveTemple.fromJson(e as Map<String, dynamic>))
        .where((t) => t.hasYoutubeSource)
        .toList();
  }
}
