// ignore_for_file: avoid_print
/// JSON → Supabase `live_darshan_temples` upsert (service role key चाहिए)।
///
/// पहली बार: Supabase SQL Editor में `supabase/live_darshan_temples.sql` चलाएँ।
///
/// ```bash
/// export SUPABASE_SERVICE_ROLE_KEY='eyJ...'  # Dashboard → API → service_role
/// dart run scripts/sync_live_darshan_to_supabase.dart
/// ```
import 'dart:convert';
import 'dart:io';

const _url = 'https://kprgqcycfmihixhwkdwc.supabase.co';
const _jsonPath = 'assets/content/live_darshan.json';

const _sortOrder = <String, int>{
  'kashi_vishwanath': 10,
  'mahakaleshwar': 20,
  'somnath': 30,
  'matanamadh': 35,
  'tirupati_svbc': 40,
  'shirdi_sai': 50,
};

Future<void> main() async {
  final serviceKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY']?.trim();
  if (serviceKey == null || serviceKey.isEmpty) {
    stderr.writeln(
      'SUPABASE_SERVICE_ROLE_KEY set karein (Supabase → Project Settings → API → service_role).',
    );
    exit(1);
  }

  final raw = await File(_jsonPath).readAsString();
  final temples = (jsonDecode(raw) as Map<String, dynamic>)['temples']
      as List<dynamic>;

  final rows = temples.map((e) {
    final m = e as Map<String, dynamic>;
    final id = m['id'] as String;
    return <String, dynamic>{
      'id': id,
      'name_hi': m['nameHi'],
      'location_hi': m['locationHi'],
      'deity_hi': m['deityHi'],
      'youtube_handle': m['youtubeHandle'],
      'youtube_channel_id': m['youtubeChannelId'],
      'source_hi': m['sourceHi'],
      'sort_order': _sortOrder[id] ?? 99,
      'is_active': true,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }).toList();

  final client = HttpClient();
  try {
    final req = await client.postUrl(
      Uri.parse('$_url/rest/v1/live_darshan_temples?on_conflict=id'),
    );
    req.headers.set('apikey', serviceKey);
    req.headers.set('Authorization', 'Bearer $serviceKey');
    req.headers.set('Content-Type', 'application/json');
    req.headers.set('Prefer', 'resolution=merge-duplicates,return=representation');
    req.write(jsonEncode(rows));

    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final count = (jsonDecode(body) as List).length;
      print('OK: $count mandir Supabase par update ho gaye.');
      return;
    }

    if (res.statusCode == 404 && body.contains('live_darshan_temples')) {
      stderr.writeln(
        'Table nahi mili. Pehle Supabase SQL Editor mein supabase/live_darshan_temples.sql chalayein.',
      );
      exit(2);
    }

    stderr.writeln('HTTP ${res.statusCode}: $body');
    exit(1);
  } finally {
    client.close();
  }
}
