// ignore_for_file: avoid_print
/// `admob_ad_units.json` se Android properties + iOS Info.plist sync।
///
/// ```bash
/// dart run scripts/apply_admob_native_ids.dart
/// dart run scripts/apply_admob_native_ids.dart path/to/units.json
/// ```
import 'dart:convert';
import 'dart:io';

const _defaultJson = 'assets/content/admob_ad_units.json';
const _androidProps = 'android/admob_app_ids.properties';
const _iosPlist = 'ios/Runner/Info.plist';

const _admobIdPattern = r'ca-app-pub-\d+[~\/][\w\/]+';

Future<void> main(List<String> args) async {
  final jsonPath = args.isNotEmpty ? args.first : _defaultJson;
  final file = File(jsonPath);
  if (!await file.exists()) {
    stderr.writeln('File not found: $jsonPath');
    exit(1);
  }

  final raw = await file.readAsString();
  final units = (jsonDecode(raw) as Map<String, dynamic>)['units']
      as List<dynamic>;

  String? appIdFor(String platform) {
    for (final item in units) {
      final m = item as Map<String, dynamic>;
      final format = (m['adFormat'] ?? m['ad_format']).toString();
      if (format != 'app_id') continue;
      if (m['platform'] != platform) continue;
      final id = (m['adUnitId'] ?? m['ad_unit_id']).toString().trim();
      if (id.isNotEmpty) return id;
    }
    return null;
  }

  final androidId = appIdFor('android');
  final iosId = appIdFor('ios');
  if (androidId == null || iosId == null) {
    stderr.writeln('app_id rows missing for android/ios in $jsonPath');
    exit(1);
  }

  if (!RegExp(_admobIdPattern).hasMatch(androidId) ||
      !RegExp(_admobIdPattern).hasMatch(iosId)) {
    stderr.writeln('Invalid AdMob App ID format.');
    exit(1);
  }

  await _writeProperties(androidId: androidId, iosId: iosId);
  await _patchIosPlist(iosId);

  print('Native AdMob App IDs applied:');
  print('  Android: $androidId → $_androidProps (Gradle build time)');
  print('  iOS:     $iosId → $_iosPlist');
  print('Next: flutter run / release build (hot restart native IDs change nahi karta).');
}

Future<void> _writeProperties({
  required String androidId,
  required String iosId,
}) async {
  final content = '''
# AUTO-GENERATED — scripts/apply_admob_native_ids.dart
# Supabase admob_ad_units (app_id rows) se update hota hai.
# Manual edit mat karein; DB update ke baad: dart run scripts/pull_admob_config_from_supabase.dart
ADMOB_APP_ID_ANDROID=$androidId
ADMOB_APP_ID_IOS=$iosId
''';
  await File(_androidProps).writeAsString(content);
}

Future<void> _patchIosPlist(String appId) async {
  final plist = File(_iosPlist);
  final lines = await plist.readAsLines();
  var foundKey = false;
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].contains('GADApplicationIdentifier</key>')) {
      foundKey = true;
      if (i + 1 < lines.length && lines[i + 1].contains('<string>')) {
        lines[i + 1] = '\t<string>$appId</string>';
        break;
      }
    }
  }
  if (!foundKey) {
    stderr.writeln('GADApplicationIdentifier not found in Info.plist');
    exit(1);
  }
  await plist.writeAsString('${lines.join('\n')}\n');
}
