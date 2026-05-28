import 'dart:async';

import 'package:bhakti_sadhana/config/ad_config.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/services/ads/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// नीचे fixed AdMob banner (पूजा / आरती देवता स्क्रीन)।
class BhaktiBannerAd extends StatefulWidget {
  const BhaktiBannerAd({
    super.key,
    this.placement = AdConfig.placementDeityContent,
  });

  final String placement;

  @override
  State<BhaktiBannerAd> createState() => _BhaktiBannerAdState();
}

class _BhaktiBannerAdState extends State<BhaktiBannerAd> {
  BannerAd? _banner;
  var _isLoaded = false;
  var _loadFailed = false;
  var _loading = false;
  int? _loadedForWidth;
  var _retryCount = 0;
  static const _maxRetries = 2;

  String get _adUnitId {
    if (widget.placement == AdConfig.placementDeityContent) {
      return AdConfig.deityBannerAdUnitId;
    }
    return AdConfig.resolveUnitId(
      placement: widget.placement,
      adFormat: AdConfig.formatBanner,
    );
  }

  Future<void> _loadBanner(int width) async {
    if (!AdConfig.supportsMobileAds || width <= 0) return;
    if (_loading) return;

    final unitId = _adUnitId;
    if (unitId.isEmpty) {
      debugPrint('BhaktiBannerAd: empty unit id');
      if (mounted) setState(() => _loadFailed = true);
      return;
    }

    _loading = true;
    _banner?.dispose();
    if (mounted) {
      setState(() {
        _banner = null;
        _isLoaded = false;
        _loadFailed = false;
      });
    }

    try {
      await AdService.ensureReady();
    } catch (e) {
      debugPrint('BhaktiBannerAd: AdService not ready — $e');
      if (mounted) {
        setState(() {
          _loadFailed = true;
          _loading = false;
        });
      }
      return;
    }

    if (!mounted) {
      _loading = false;
      return;
    }

    AdSize size;
    // ignore: deprecated_member_use
    final adaptive = await AdSize.getAnchoredAdaptiveBannerAdSize(
      MediaQuery.orientationOf(context),
      width,
    );
    size = adaptive ?? AdSize.banner;

    if (!mounted) {
      _loading = false;
      return;
    }

    debugPrint(
      'BhaktiBannerAd: loading $unitId (${size.width}x${size.height})',
    );

    final banner = BannerAd(
      adUnitId: unitId,
      size: size,
      request: AdConfig.adRequest,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BhaktiBannerAd: loaded');
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isLoaded = true;
            _loadFailed = false;
            _loading = false;
            _retryCount = 0;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'BhaktiBannerAd failed (${AdConfig.useTestAds ? 'test' : 'prod'}): '
            '${error.code} ${error.message}',
          );
          ad.dispose();
          if (!mounted) return;

          if (_retryCount < _maxRetries) {
            _retryCount++;
            _loading = false;
            _loadedForWidth = null;
            Future<void>.delayed(const Duration(seconds: 2), () {
              if (mounted) _scheduleLoad(width);
            });
            return;
          }

          setState(() {
            _loadFailed = true;
            _loading = false;
          });
        },
      ),
    );
    _banner = banner;
    await banner.load();
    if (mounted && !_isLoaded && !_loadFailed) {
      setState(() => _loading = false);
    }
  }

  void _scheduleLoad(int width) {
    if (!mounted || width <= 0) return;
    if (_loading || (_loadedForWidth == width && _isLoaded)) return;
    _loadedForWidth = width;
    unawaited(_loadBanner(width));
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  Widget _shell({required Widget child}) {
    return SafeArea(
      top: false,
      child: Material(
        color: const Color(0xFF1A0808),
        elevation: _isLoaded ? 8 : 0,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AdConfig.supportsMobileAds) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.truncate();
        if (width > 0 &&
            !_loading &&
            !_isLoaded &&
            (_loadedForWidth != width || _loadFailed)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scheduleLoad(width);
          });
        }

        if (_isLoaded && _banner != null) {
          final ad = _banner!;
          final h = ad.size.height.toDouble();
          final w = ad.size.width.toDouble();
          return _shell(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: BhaktiTheme.gold.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: h,
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: w,
                    height: h,
                    child: AdWidget(ad: ad),
                  ),
                ),
              ),
            ),
          );
        }

        if (_loadFailed) {
          return _shell(
            child: InkWell(
              onTap: () {
                _retryCount = 0;
                _loadedForWidth = null;
                _scheduleLoad(width);
              },
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: Center(
                  child: Text(
                    'विज्ञापन लोड नहीं हुआ — फिर कोशिश करें',
                    style: BhaktiTheme.labelSub.copyWith(
                      fontSize: 11,
                      color: BhaktiTheme.cream.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return _shell(
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: BhaktiTheme.saffron,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
