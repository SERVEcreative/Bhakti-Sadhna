import 'package:bhakti_sadhana/config/legal_config.dart';
import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// गोपनीयता नीति — ऐप में WebView screen।
class LegalLinksFooter extends StatelessWidget {
  const LegalLinksFooter({super.key});

  static void openPrivacyPolicy(BuildContext context) {
    context.push(
      '/legal/privacy',
      extra: LegalConfig.privacyPolicyUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          HapticFeedback.selectionClick();
          openPrivacyPolicy(context);
        },
        icon: Icon(
          Icons.privacy_tip_outlined,
          size: 18,
          color: BhaktiTheme.saffronLight.withValues(alpha: 0.9),
        ),
        label: Text(
          AppStrings.privacyPolicy,
          style: BhaktiTheme.bodyHi.copyWith(
            fontSize: 13,
            color: BhaktiTheme.saffronLight,
            decoration: TextDecoration.underline,
            decorationColor: BhaktiTheme.saffronLight.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
