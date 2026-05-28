/// Supabase `admob_ad_units` row या `admob_ad_units.json` entry।
class AdMobAdUnit {
  const AdMobAdUnit({
    required this.id,
    required this.placement,
    required this.adFormat,
    required this.platform,
    required this.adUnitId,
    this.labelHi,
  });

  final String id;
  final String placement;
  final String adFormat;
  final String platform;
  final String adUnitId;
  final String? labelHi;

  String get lookupKey => '${placement}_${adFormat}_$platform';

  factory AdMobAdUnit.fromJson(Map<String, dynamic> json) {
    String field(String camel, String snake) {
      final v = json[camel] ?? json[snake];
      return v.toString().trim();
    }

    return AdMobAdUnit(
      id: json['id'] as String,
      placement: field('placement', 'placement'),
      adFormat: field('adFormat', 'ad_format'),
      platform: field('platform', 'platform'),
      adUnitId: field('adUnitId', 'ad_unit_id'),
      labelHi: _optional(field('labelHi', 'label_hi')),
    );
  }

  static String? _optional(String s) => s.isEmpty ? null : s;
}
