import 'package:bhakti_sadhana/widgets/ads/bhakti_banner_ad.dart';
import 'package:flutter/material.dart';

/// पूजा टैब फ्लो — स्क्रॉल ऊपर, banner नीचे (bottom nav के ऊपर)।
class PujaSectionBannerShell extends StatelessWidget {
  const PujaSectionBannerShell({
    super.key,
    required this.child,
    this.showBanner = true,
  });

  final Widget child;
  final bool showBanner;

  @override
  Widget build(BuildContext context) {
    if (!showBanner) return child;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: child),
        const BhaktiBannerAd(),
      ],
    );
  }
}
