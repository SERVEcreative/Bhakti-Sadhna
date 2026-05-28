import 'dart:async';

import 'package:bhakti_sadhana/config/ad_config.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (_loading || _loadedForWidth == width) return;
    _loadedForWidth = width;
    unawaited(_loadBanner(width));
  }

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
    final unitId = _adUnitId;
    if (!AdConfig.supportsMobileAds || unitId.isEmpty) return;
    if (_loading) return;

    _loading = true;
    _banner?.dispose();
    if (mounted) {
      setState(() {
        _banner = null;
        _isLoaded = false;
        _loadFailed = false;
      });
    }

    // Standard anchored adaptive (~50dp tall). Large API is ~3× taller.
    // ignore: deprecated_member_use
    final size = await AdSize.getAnchoredAdaptiveBannerAdSize(
      MediaQuery.orientationOf(context),
      width,
    );
    if (!mounted) {
      _loading = false;
      return;
    }
    if (size == null) {
      setState(() {
        _loadFailed = true;
        _loading = false;
      });
      return;
    }

    final banner = BannerAd(
      adUnitId: unitId,
      size: size,
      request: AdConfig.adRequest,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isLoaded = true;
            _loadFailed = false;
            _loading = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'BhaktiBannerAd failed (${AdConfig.useTestAds ? 'test' : 'prod'}): '
            '${error.code} ${error.message}',
          );
          ad.dispose();
          if (mounted) {
            setState(() {
              _loadFailed = true;
              _loading = false;
            });
          }
        },
      ),
    );
    _banner = banner;
    await banner.load();
    if (mounted && !_isLoaded && !_loadFailed) {
      setState(() => _loading = false);
    }
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
              widthFactor: 1,
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
            final width = MediaQuery.sizeOf(context).width.truncate();
            _loadedForWidth = null;
            unawaited(_loadBanner(width));
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
  }
}
