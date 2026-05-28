import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// HTTPS links — Android par kai modes try karta hai।
abstract final class ExternalLinkLauncher {
  static Future<bool> open(Uri uri) async {
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;

    final modes = defaultTargetPlatform == TargetPlatform.android
        ? [
            LaunchMode.platformDefault,
            LaunchMode.externalApplication,
            LaunchMode.inAppBrowserView,
          ]
        : [
            LaunchMode.platformDefault,
            LaunchMode.externalApplication,
          ];

    for (final mode in modes) {
      try {
        if (await launchUrl(uri, mode: mode)) return true;
      } catch (e) {
        debugPrint('ExternalLinkLauncher $uri ($mode): $e');
      }
    }
    return false;
  }
}
