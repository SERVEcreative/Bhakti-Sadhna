import 'package:bhakti_sadhana/core/assets/asset_paths.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Sirf `.png` assets load karta hai — cache + clear errors.
abstract final class AssetImageResolver {
  static final Map<String, String> _resolved = {};
  static final Set<String> _missing = {};

  static Future<String?> resolvePng(String pathOrBase) async {
    final pngPath = AssetPaths.toPngPath(pathOrBase);
    final base = AssetPaths.stripExtension(pathOrBase);

    final hit = _resolved[base];
    if (hit != null) return hit;
    if (_missing.contains(base)) return null;

    try {
      await rootBundle.load(pngPath);
      _resolved[base] = pngPath;
      return pngPath;
    } catch (e) {
      _missing.add(base);
      if (kDebugMode) {
        debugPrint('AssetImageResolver: missing $pngPath — $e');
      }
      return null;
    }
  }

  static void clearCache() {
    _resolved.clear();
    _missing.clear();
  }
}
