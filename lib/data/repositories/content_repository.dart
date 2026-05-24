import 'dart:convert';

import 'package:bhakti_sadhana/data/models/deity.dart';
import 'package:flutter/services.dart';

class ContentRepository {
  ContentRepository._();
  static final ContentRepository instance = ContentRepository._();

  List<Deity>? _cache;

  Future<List<Deity>> loadDeities() async {
    if (_cache != null) return _cache!;
    final all = <Deity>[];
    for (final path in [
      'assets/content/deities.json',
      'assets/content/deities_extra.json',
    ]) {
      final raw = await rootBundle.loadString(path);
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final list = map['deities'] as List<dynamic>;
      all.addAll(
        list.map((e) => Deity.fromJson(e as Map<String, dynamic>)),
      );
    }
    _cache = all;
    return _cache!;
  }

  Future<Deity?> getDeity(String id) async {
    final all = await loadDeities();
    for (final d in all) {
      if (d.id == id) return d;
    }
    return null;
  }
}
