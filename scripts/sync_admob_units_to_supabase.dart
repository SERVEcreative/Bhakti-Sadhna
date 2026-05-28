// ignore_for_file: avoid_print
/// `assets/content/admob_ad_units.json` → Supabase `admob_ad_units` upsert।
///
/// पहले SQL Editor में `supabase/admob_ad_units.sql` चलाएँ।
///
/// ```bash
/// export SUPABASE_SERVICE_ROLE_KEY='eyJ...'
/// dart run scripts/sync_admob_units_to_supabase.dart
/// ```
///
/// Supabase → phone/native sync (pull):
/// `dart run scripts/pull_admob_config_from_supabase.dart`
import 'dart:convert';
import 'dart:io';

const _url = 'https://kprgqcycfmihixhwkdwc.supabase.co';
const _jsonPath = 'assets/content/admob_ad_units.json';

const _sortOrder = <String, int>{
  'app_id_android': 1,
  'app_id_ios': 2,
  'deity_banner_android': 10,
  'deity_banner_ios': 11,
  'puja_exit_interstitial_android': 20,
  'puja_exit_interstitial_ios': 21,
  'aarti_rewarded_android': 30,
  'aarti_rewarded_ios': 31,
  'home_native_android': 40,
  'home_native_ios': 41,
  'app_open_android': 50,
  'app_open_ios': 51,
};

Future<void> main() async {
  final serviceKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY']?.trim();
  if (serviceKey == null || serviceKey.isEmpty) {
    stderr.writeln('SUPABASE_SERVICE_ROLE_KEY set karein.');
    exit(1);
  }

  final raw = await File(_jsonPath).readAsString();
  final units = (jsonDecode(raw) as Map<String, dynamic>)['units']
      as List<dynamic>;

  final rows = units.map((e) {
    final m = e as Map<String, dynamic>;
    final id = m['id'] as String;
    return <String, dynamic>{
      'id': id,
      'placement': m['placement'],
      'ad_format': m['adFormat'],
      'platform': m['platform'],
      'ad_unit_id': m['adUnitId'],
      'label_hi': m['labelHi'],
      'sort_order': _sortOrder[id] ?? 99,
      'is_active': true,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }).toList();

  final uri = Uri.parse('$_url/rest/v1/admob_ad_units?on_conflict=id');
  final client = HttpClient();
  try {
    final request = await client.postUrl(uri);
    request.headers.set('apikey', serviceKey);
    request.headers.set('Authorization', 'Bearer $serviceKey');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Prefer', 'resolution=merge-duplicates,return=minimal');
    request.write(jsonEncode(rows));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      stderr.writeln('Upsert failed (${response.statusCode}): $body');
      exit(1);
    }
    print('Upserted ${rows.length} admob_ad_units rows.');
  } finally {
    client.close();
  }
}
