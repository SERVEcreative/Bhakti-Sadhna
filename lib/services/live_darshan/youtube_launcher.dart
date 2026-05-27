import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// YouTube ऐप / ब्राउज़र में लाइव खोलें (Android package visibility सहित)।
class YoutubeLauncher {
  YoutubeLauncher._();

  static Future<bool> openLive({
    String? videoId,
    String? channelId,
    String? fallbackUrl,
  }) async {
    final uris = <Uri>[];

    if (videoId != null && videoId.isNotEmpty) {
      uris.addAll([
        Uri.parse('vnd.youtube://watch?v=$videoId'),
        Uri.parse('https://youtu.be/$videoId'),
        Uri.parse('https://www.youtube.com/watch?v=$videoId'),
      ]);
    }

    if (channelId != null && channelId.isNotEmpty) {
      uris.addAll([
        Uri.parse('vnd.youtube://channel/$channelId'),
        Uri.parse('https://www.youtube.com/channel/$channelId/live'),
      ]);
    }

    if (fallbackUrl != null && fallbackUrl.trim().isNotEmpty) {
      uris.add(Uri.parse(fallbackUrl.trim()));
    }

    for (final uri in uris) {
      if (await _tryLaunch(uri)) return true;
    }

    return false;
  }

  static Future<bool> openUrl(String url) => openLive(fallbackUrl: url);

  static Future<bool> _tryLaunch(Uri uri) async {
    try {
      final modes = defaultTargetPlatform == TargetPlatform.android
          ? [
              LaunchMode.externalNonBrowserApplication,
              LaunchMode.externalApplication,
              LaunchMode.platformDefault,
            ]
          : [
              LaunchMode.externalApplication,
              LaunchMode.platformDefault,
            ];

      for (final mode in modes) {
        try {
          final launched = await launchUrl(uri, mode: mode);
          if (launched) return true;
        } catch (e) {
          debugPrint('YoutubeLauncher $uri ($mode): $e');
        }
      }
    } catch (e) {
      debugPrint('YoutubeLauncher: $e');
    }
    return false;
  }
}
