import 'package:bhakti_sadhana/config/ad_config.dart';
import 'package:bhakti_sadhana/data/repositories/admob_config_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob SDK — test mode / Supabase units, फिर initialize।
class AdService {
  AdService._();

  static var _initialized = false;

  static Future<void> init() async {
    if (_initialized || !AdConfig.supportsMobileAds) return;
    try {
      await AdMobConfigRepository.instance.load();
      _logAppIdSyncHint();

      await MobileAds.instance.initialize();

      if (AdConfig.useTestAds) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(
            testDeviceIds: kDebugMode ? const <String>['EMULATOR'] : const [],
          ),
        );
      }

      _initialized = true;
      debugPrint(
        'AdService: ready '
        '(testMode=${AdConfig.useTestAds}, units: ${AdMobConfigRepository.instance.source})',
      );
    } catch (e, st) {
      debugPrint('AdService init failed: $e\n$st');
    }
  }

  static Future<void> refreshUnits() =>
      AdMobConfigRepository.instance.load(refresh: true);

  static void _logAppIdSyncHint() {
    final repo = AdMobConfigRepository.instance;
    if (!repo.isLoaded) return;
    final androidAppId = repo.unitId(
      placement: AdConfig.placementApp,
      adFormat: AdConfig.formatAppId,
      platform: 'android',
    );
    if (androidAppId == null || androidAppId.isEmpty) return;
    debugPrint(
      'AdMob App ID (Supabase): $androidAppId — '
      'DB badalne par: dart run scripts/pull_admob_config_from_supabase.dart '
      'phir flutter run (manifest/iOS native sync)',
    );
  }
}
