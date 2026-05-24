import 'dart:convert';

import 'package:bhakti_sadhana/data/models/deity.dart';
import 'package:bhakti_sadhana/data/models/vrat_katha.dart';
import 'package:flutter/services.dart';

class ContentRepository {
  ContentRepository._();
  static final ContentRepository instance = ContentRepository._();

  List<Deity>? _cache;
  final Map<String, VratKathaDocument> _vratKathaCache = {};
  Map<String, List<MantraItem>>? _mantraCatalog;

  Future<List<Deity>> loadDeities() async {
    if (_cache != null) return _cache!;
    final catalog = await _loadMantraCatalog();
    final all = <Deity>[];
    for (final path in [
      'assets/content/deities.json',
      'assets/content/deities_extra.json',
    ]) {
      final raw = await rootBundle.loadString(path);
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final list = map['deities'] as List<dynamic>;
      all.addAll(
        list.map((e) {
          final deity = Deity.fromJson(e as Map<String, dynamic>);
          final mantras = catalog[deity.id];
          if (mantras != null && mantras.isNotEmpty) {
            return deity.copyWith(mantras: mantras);
          }
          return deity;
        }),
      );
    }
    _cache = all;
    return _cache!;
  }

  Future<Map<String, List<MantraItem>>> _loadMantraCatalog() async {
    if (_mantraCatalog != null) return _mantraCatalog!;
    try {
      final raw = await rootBundle.loadString('assets/content/mantras.json');
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final deities = map['deities'] as Map<String, dynamic>;
      _mantraCatalog = deities.map(
        (id, list) => MapEntry(
          id,
          (list as List<dynamic>)
              .map((e) => MantraItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
    } catch (_) {
      _mantraCatalog = {};
    }
    return _mantraCatalog!;
  }

  Future<Deity?> getDeity(String id) async {
    final all = await loadDeities();
    for (final d in all) {
      if (d.id == id) return d;
    }
    return null;
  }

  Future<VratKathaDocument?> getVratKatha(String deityId) async {
    if (_vratKathaCache.containsKey(deityId)) {
      return _vratKathaCache[deityId];
    }
    try {
      final raw = await rootBundle.loadString(
        'assets/content/katha/$deityId.json',
      );
      final doc = VratKathaDocument.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      _vratKathaCache[deityId] = doc;
      return doc;
    } catch (_) {
      return null;
    }
  }
}
