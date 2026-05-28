import 'dart:convert';

import 'package:bhakti_sadhana/bootstrap/supabase_bootstrap.dart';
import 'package:bhakti_sadhana/data/models/admob_ad_unit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// AdMob units — Supabase पहले, फिर local JSON fallback।
class AdMobConfigRepository {
  AdMobConfigRepository._();
  static final AdMobConfigRepository instance = AdMobConfigRepository._();

  static const _cacheTtl = Duration(hours: 1);

  Map<String, AdMobAdUnit> _byKey = {};
  DateTime? _loadedAt;
  var _source = 'none';

  String get source => _source;
  bool get isLoaded => _byKey.isNotEmpty;

  Future<void> load({bool refresh = false}) async {
    if (_byKey.isNotEmpty &&
        !refresh &&
        _loadedAt != null &&
        DateTime.now().difference(_loadedAt!) < _cacheTtl) {
      return;
    }

    if (SupabaseBootstrap.initialized) {
      try {
        final rows = await SupabaseBootstrap.client
            .from('admob_ad_units')
            .select()
            .eq('is_active', true)
            .order('sort_order', ascending: true);

        final map = <String, AdMobAdUnit>{};
        for (final row in rows as List<dynamic>) {
          final unit =
              AdMobAdUnit.fromJson(row as Map<String, dynamic>);
          if (unit.adUnitId.isEmpty) continue;
          map[unit.lookupKey] = unit;
        }

        if (map.isNotEmpty) {
          _byKey = map;
          _loadedAt = DateTime.now();
          _source = 'supabase';
          debugPrint('AdMobConfigRepository: ${map.length} units from Supabase');
          return;
        }
      } catch (e, st) {
        debugPrint('AdMobConfigRepository Supabase: $e\n$st');
      }
    }

    _byKey = await _loadFromAssets();
    _loadedAt = DateTime.now();
    _source = 'assets';
    debugPrint('AdMobConfigRepository: ${_byKey.length} units from assets');
  }

  void clearCache() {
    _byKey = {};
    _loadedAt = null;
    _source = 'none';
  }

  String? unitId({
    required String placement,
    required String adFormat,
    required String platform,
  }) {
    final key = '${placement}_${adFormat}_$platform';
    return _byKey[key]?.adUnitId;
  }

  List<AdMobAdUnit> unitsForPlacement(String placement) {
    return _byKey.values.where((u) => u.placement == placement).toList();
  }

  Future<Map<String, AdMobAdUnit>> _loadFromAssets() async {
    final raw =
        await rootBundle.loadString('assets/content/admob_ad_units.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final list = map['units'] as List<dynamic>;
    final result = <String, AdMobAdUnit>{};
    for (final item in list) {
      final unit = AdMobAdUnit.fromJson(item as Map<String, dynamic>);
      if (unit.adUnitId.isEmpty) continue;
      result[unit.lookupKey] = unit;
    }
    return result;
  }
}
