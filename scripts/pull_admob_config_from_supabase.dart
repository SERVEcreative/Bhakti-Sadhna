// ignore_for_file: avoid_print
/// Supabase `admob_ad_units` → assets JSON + Android/iOS native App IDs।
///
/// Supabase SQL Editor mein IDs update karne ke baad yeh script chalao:
///
/// ```bash
/// dart run scripts/pull_admob_config_from_supabase.dart
/// flutter run -d <device> --dart-define-from-file=dart_defines.json
/// ```
import 'dart:convert';
import 'dart:io';

const _url = 'https://kprgqcycfmihixhwkdwc.supabase.co';
const _assetsJson = 'assets/content/admob_ad_units.json';
const _configDart = 'lib/config/supabase_config.dart';

Future<void> main() async {
  final anonKey = _resolveAnonKey();
  final uri = Uri.parse(
    '$_url/rest/v1/admob_ad_units?is_active=eq.true&order=sort_order.asc',
  );

  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      stderr.writeln('Supabase fetch failed (${response.statusCode}): $body');
      exit(1);
    }

    final rows = jsonDecode(body) as List<dynamic>;
    if (rows.isEmpty) {
      stderr.writeln('admob_ad_units table empty — SQL seed chalao.');
      exit(1);
    }

    final units = rows.map((row) {
      final m = row as Map<String, dynamic>;
      return <String, dynamic>{
        'id': m['id'],
        'placement': m['placement'],
        'adFormat': m['ad_format'],
        'platform': m['platform'],
        'adUnitId': m['ad_unit_id'],
        if (m['label_hi'] != null) 'labelHi': m['label_hi'],
      };
    }).toList();

    final payload = jsonEncode({'units': units});
    await File(_assetsJson).writeAsString(
      const JsonEncoder.withIndent('  ').convert(jsonDecode(payload)),
    );
    print('Wrote ${units.length} units → $_assetsJson');

    final apply = await Process.run(
      Platform.executable,
      ['run', 'scripts/apply_admob_native_ids.dart', _assetsJson],
      runInShell: true,
    );
    stdout.write(apply.stdout);
    stderr.write(apply.stderr);
    if (apply.exitCode != 0) exit(apply.exitCode ?? 1);

    print('');
    print('Done. App ab Supabase + native manifest dono se sync hai.');
    print('Phone par dekhne ke liye app dubara build/run karein (hot restart kaafi nahi).');
  } finally {
    client.close();
  }
}

String _resolveAnonKey() {
  final fromEnv = Platform.environment['SUPABASE_ANON_KEY']?.trim();
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

  final config = File(_configDart);
  if (!config.existsSync()) {
    stderr.writeln('Set SUPABASE_ANON_KEY or configure $_configDart');
    exit(1);
  }
  final content = config.readAsStringSync();
  final match = RegExp(r"anonKey\s*=\s*'([^']+)'").firstMatch(content);
  if (match == null) {
    stderr.writeln('Could not read anonKey from $_configDart');
    exit(1);
  }
  return match.group(1)!;
}
