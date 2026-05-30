// ignore_for_file: avoid_print
/// Production AdMob IDs → Supabase `admob_ad_units` table.
///
/// Requires service role key (never commit):
/// ```bash
/// export SUPABASE_SERVICE_ROLE_KEY='your-service-role-key'
/// dart run scripts/push_admob_config_to_supabase.dart
/// ```
///
/// Or pass a JSON map of row id → ad unit id:
/// ```bash
/// dart run scripts/push_admob_config_to_supabase.dart updates.json
/// ```
import 'dart:convert';
import 'dart:io';

const _url = 'https://kprgqcycfmihixhwkdwc.supabase.co';

/// Default production IDs — edit before running or pass updates.json.
const _defaultUpdates = <String, String>{
  // 'app_id_android': 'ca-app-pub-XXXX~YYYY',
  // 'deity_banner_android': 'ca-app-pub-XXXX/ZZZZ',
};

Future<void> main(List<String> args) async {
  final serviceKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY']?.trim();
  if (serviceKey == null || serviceKey.isEmpty) {
    stderr.writeln(
      'Set SUPABASE_SERVICE_ROLE_KEY (Supabase → Settings → API → service_role).',
    );
    exit(1);
  }

  final updates = await _loadUpdates(args);
  if (updates.isEmpty) {
    stderr.writeln(
      'No updates. Edit _defaultUpdates in this script or pass updates.json.',
    );
    exit(1);
  }

  final client = HttpClient();
  try {
    for (final entry in updates.entries) {
      await _patchRow(
        client: client,
        serviceKey: serviceKey,
        id: entry.key,
        adUnitId: entry.value,
      );
    }
    print('');
    print('Done. Verify: dart run scripts/pull_admob_config_from_supabase.dart');
  } finally {
    client.close();
  }
}

Future<Map<String, String>> _loadUpdates(List<String> args) async {
  if (args.isNotEmpty) {
    final file = File(args.first);
    if (!await file.exists()) {
      stderr.writeln('File not found: ${file.path}');
      exit(1);
    }
    final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return raw.map((k, v) => MapEntry(k, v.toString().trim()));
  }
  return Map.fromEntries(
    _defaultUpdates.entries.where((e) => e.value.trim().isNotEmpty),
  );
}

Future<void> _patchRow({
  required HttpClient client,
  required String serviceKey,
  required String id,
  required String adUnitId,
}) async {
  if (!RegExp(r'^ca-app-pub-\d+[~\/][\w\/]+$').hasMatch(adUnitId)) {
    stderr.writeln('Invalid AdMob ID for $id: $adUnitId');
    exit(1);
  }

  final uri = Uri.parse('$_url/rest/v1/admob_ad_units?id=eq.$id');
  final request = await client.patchUrl(uri);
  request.headers.set('apikey', serviceKey);
  request.headers.set('Authorization', 'Bearer $serviceKey');
  request.headers.set('Content-Type', 'application/json');
  request.headers.set('Prefer', 'return=representation');
  request.write(jsonEncode({'ad_unit_id': adUnitId, 'updated_at': DateTime.now().toUtc().toIso8601String()}));

  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  if (response.statusCode < 200 || response.statusCode >= 300) {
    stderr.writeln('PATCH $id failed (${response.statusCode}): $body');
    exit(1);
  }

  final rows = jsonDecode(body) as List<dynamic>;
  if (rows.isEmpty) {
    stderr.writeln('Row not found: $id — pehle supabase/admob_ad_units.sql seed chalao.');
    exit(1);
  }
  final row = rows.first as Map<String, dynamic>;
  print('Updated $id → ${row['ad_unit_id']}');
}
