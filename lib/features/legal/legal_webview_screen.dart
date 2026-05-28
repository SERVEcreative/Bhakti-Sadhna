import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/services/external_link_launcher.dart';
import 'package:bhakti_sadhana/widgets/temple_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// गोपनीयता नीति — ऐप के अंदर WebView (browser fail hone par bhi chalega)।
class LegalWebViewScreen extends StatefulWidget {
  const LegalWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<LegalWebViewScreen> createState() => _LegalWebViewScreenState();
}

class _LegalWebViewScreenState extends State<LegalWebViewScreen> {
  late final WebViewController _controller;
  var _loading = true;
  var _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(BhaktiTheme.maroonDeep)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _loading = true;
                _loadFailed = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _loading = false;
                _loadFailed = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _openInBrowser() async {
    final ok = await ExternalLinkLauncher.open(Uri.parse(widget.url));
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.privacyPolicyOpenError,
            style: BhaktiTheme.bodyHi,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TempleScaffold(
      title: widget.title,
      actions: [
        IconButton(
          tooltip: 'Browser में खोलें',
          icon: const Icon(Icons.open_in_browser_rounded),
          onPressed: _openInBrowser,
        ),
      ],
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: BhaktiTheme.gold),
            ),
          if (_loadFailed)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.privacyPolicyOpenError,
                      textAlign: TextAlign.center,
                      style: BhaktiTheme.bodyHi,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _loadFailed = false;
                          _loading = true;
                        });
                        _controller.loadRequest(Uri.parse(widget.url));
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('फिर कोशिश करें'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _openInBrowser,
                      child: const Text('Browser में खोलें'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
