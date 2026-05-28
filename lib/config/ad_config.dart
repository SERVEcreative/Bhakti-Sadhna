import 'dart:io';

import 'package:bhakti_sadhana/data/repositories/admob_config_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob — Supabase / assets / `--dart-define` fallback chain।
abstract final class AdConfig {
  /// Placement keys (Supabase `placement` column से मेल)।
  static const placementApp = 'app';
  static const placementDeityContent = 'deity_content';
  static const placementPujaExit = 'puja_exit';
  static const placementAartiReward = 'aarti_reward';
  static const placementHomeFeed = 'home_feed';
  static const placementAppLaunch = 'app_launch';

  /// Ad formats (`ad_format` column)।
  static const formatAppId = 'app_id';
  static const formatBanner = 'banner';
  static const formatInterstitial = 'interstitial';
  static const formatRewarded = 'rewarded';
  static const formatNative = 'native';
  static const formatAppOpen = 'app_open';

  static const String _testAppIdAndroid =
      'ca-app-pub-3940256099942544~3347511713';
  static const String _testAppIdIos = 'ca-app-pub-3940256099942544~1458002511';
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIos =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _testNativeAndroid =
      'ca-app-pub-3940256099942544/2247696110';
  static const String _testNativeIos = 'ca-app-pub-3940256099942544/3986624511';
  static const String _testAppOpenAndroid =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _testAppOpenIos =
      'ca-app-pub-3940256099942544/5575463023';

  static String get _platform {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return '';
  }

  static bool get supportsMobileAds =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Test device config — unit IDs हमेशा Supabase/assets से।
  /// Production ads: Supabase में real IDs + `--dart-define=USE_PRODUCTION_ADS=true`
  static bool get useTestAds {
    const production = bool.fromEnvironment(
      'USE_PRODUCTION_ADS',
      defaultValue: false,
    );
    return !production;
  }

  static const AdRequest adRequest = AdRequest();

  /// Supabase/assets fail होने पर आखिरी fallback (Google sample IDs)।
  static String _hardcodedFallback({
    required String placement,
    required String adFormat,
  }) {
    final android = _platform == 'android';
    return switch ((placement, adFormat)) {
      (placementApp, formatAppId) =>
        android ? _testAppIdAndroid : _testAppIdIos,
      (placementDeityContent, formatBanner) =>
        android ? _testBannerAndroid : _testBannerIos,
      (placementPujaExit, formatInterstitial) =>
        android ? _testInterstitialAndroid : _testInterstitialIos,
      (placementAartiReward, formatRewarded) =>
        android ? _testRewardedAndroid : _testRewardedIos,
      (placementHomeFeed, formatNative) =>
        android ? _testNativeAndroid : _testNativeIos,
      (placementAppLaunch, formatAppOpen) =>
        android ? _testAppOpenAndroid : _testAppOpenIos,
      _ => '',
    };
  }

  /// 1) Supabase → 2) assets JSON → 3) `--dart-define` (prod only) → 4) hardcoded।
  static String resolveUnitId({
    required String placement,
    required String adFormat,
    String? dartDefineKey,
    String? testFallback,
  }) {
    final platform = _platform;
    if (platform.isEmpty) return '';

    final remote = AdMobConfigRepository.instance.unitId(
      placement: placement,
      adFormat: adFormat,
      platform: platform,
    );
    if (remote != null && remote.isNotEmpty) return remote;

    if (!useTestAds && dartDefineKey != null) {
      final fromEnv = String.fromEnvironment(dartDefineKey);
      if (fromEnv.trim().isNotEmpty) return fromEnv.trim();
    }

    final fallback = testFallback ??
        _hardcodedFallback(placement: placement, adFormat: adFormat);
    return fallback;
  }

  static String get admobAppId {
    if (!supportsMobileAds) return '';
    final android = _platform == 'android';
    return resolveUnitId(
      placement: placementApp,
      adFormat: formatAppId,
      dartDefineKey: android ? 'ADMOB_APP_ID_ANDROID' : 'ADMOB_APP_ID_IOS',
    );
  }

  static String get deityBannerAdUnitId {
    if (!supportsMobileAds) return '';
    final android = _platform == 'android';
    return resolveUnitId(
      placement: placementDeityContent,
      adFormat: formatBanner,
      dartDefineKey:
          android ? 'ADMOB_BANNER_DEITY_ANDROID' : 'ADMOB_BANNER_DEITY_IOS',
    );
  }

  static String get pujaExitInterstitialUnitId {
    if (!supportsMobileAds) return '';
    return resolveUnitId(
      placement: placementPujaExit,
      adFormat: formatInterstitial,
    );
  }

  static String get aartiRewardedUnitId {
    if (!supportsMobileAds) return '';
    return resolveUnitId(
      placement: placementAartiReward,
      adFormat: formatRewarded,
    );
  }

  static String get homeNativeUnitId {
    if (!supportsMobileAds) return '';
    return resolveUnitId(
      placement: placementHomeFeed,
      adFormat: formatNative,
    );
  }

  static String get appOpenUnitId {
    if (!supportsMobileAds) return '';
    return resolveUnitId(
      placement: placementAppLaunch,
      adFormat: formatAppOpen,
    );
  }

  static bool get showDeityBannerAds =>
      supportsMobileAds && deityBannerAdUnitId.isNotEmpty;
}
