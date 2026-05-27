import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// YouTube लाइव embed — video ID, फिर channel live fallback।
class YoutubeLiveEmbed extends StatefulWidget {
  YoutubeLiveEmbed({
    super.key,
    required this.youtubeVideoId,
    this.youtubeChannelId,
    this.onEmbedFailed,
  }) : assert(youtubeVideoId.isNotEmpty, 'videoId खाली नहीं हो सकता');

  final String youtubeVideoId;
  final String? youtubeChannelId;
  final VoidCallback? onEmbedFailed;

  @override
  State<YoutubeLiveEmbed> createState() => _YoutubeLiveEmbedState();
}

class _YoutubeLiveEmbedState extends State<YoutubeLiveEmbed> {
  late final WebViewController _controller;
  var _loading = true;
  var _loadStage = 0;

  static const _referer = 'https://www.youtube.com/';
  static const _mobileChromeUa =
      'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    _controller = _createController();
    _loadStage = 0;
    _loadCurrent();
  }

  WebViewController _createController() {
    late final PlatformWebViewControllerCreationParams params;
    if (!kIsWeb && WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..addJavaScriptChannel(
        'UnavailableDetector',
        onMessageReceived: (_) => _handleEmbedFailure(),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _onPageFinished(),
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) {
              _handleEmbedFailure();
            }
          },
        ),
      );

    if (!kIsWeb && controller.platform is AndroidWebViewController) {
      final android = controller.platform as AndroidWebViewController;
      android.setMediaPlaybackRequiresUserGesture(false);
      android.setUserAgent(_mobileChromeUa);
    }

    return controller;
  }

  Future<void> _onPageFinished() async {
    if (!mounted) return;
    setState(() => _loading = false);

    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    try {
      await _controller.runJavaScript('''
(function() {
  var t = (document.body && document.body.innerText) ? document.body.innerText.toLowerCase() : '';
  if (t.indexOf('video unavailable') >= 0 ||
      t.indexOf('unavailable') >= 0 ||
      t.indexOf('playback on other websites') >= 0 ||
      t.indexOf('embedding disabled') >= 0) {
    UnavailableDetector.postMessage('unavailable');
  }
})();
''');
    } catch (_) {
      // ignore
    }
  }

  void _handleEmbedFailure() {
    if (!mounted) return;

    if (_loadStage == 0) {
      _loadStage = 1;
      setState(() => _loading = true);
      _loadRequest(_embedVideoUri(useNoCookie: true));
      return;
    }

    if (_loadStage == 1 &&
        widget.youtubeChannelId != null &&
        widget.youtubeChannelId!.isNotEmpty) {
      _loadStage = 2;
      setState(() => _loading = true);
      _loadRequest(_embedChannelLiveUri());
      return;
    }

    setState(() => _loading = false);
    widget.onEmbedFailed?.call();
  }

  void _loadCurrent() {
    _loadRequest(_embedVideoUri());
  }

  void _loadRequest(Uri uri) {
    if (kIsWeb) {
      _controller.loadRequest(uri);
    } else {
      _controller.loadRequest(
        uri,
        headers: const {'Referer': _referer},
      );
    }
  }

  @override
  void didUpdateWidget(covariant YoutubeLiveEmbed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.youtubeVideoId != widget.youtubeVideoId ||
        oldWidget.youtubeChannelId != widget.youtubeChannelId) {
      _loadStage = 0;
      setState(() => _loading = true);
      _loadCurrent();
    }
  }

  Uri _embedVideoUri({bool useNoCookie = false}) {
    final host = useNoCookie
        ? 'https://www.youtube-nocookie.com'
        : 'https://www.youtube.com';
    return Uri.parse(
      '$host/embed/${widget.youtubeVideoId}'
      '?playsinline=1'
      '&rel=0'
      '&modestbranding=1'
      '&controls=1'
      '&fs=1'
      '&autoplay=1'
      '&mute=0'
      '&live=1'
      '&enablejsapi=1'
      '&origin=https://www.youtube.com'
      '&widget_referrer=https://www.youtube.com',
    );
  }

  Uri _embedChannelLiveUri() {
    return Uri.parse(
      'https://www.youtube.com/embed/live_stream'
      '?channel=${widget.youtubeChannelId}'
      '&playsinline=1'
      '&rel=0'
      '&autoplay=1'
      '&mute=0'
      '&enablejsapi=1'
      '&origin=https://www.youtube.com',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const ColoredBox(
            color: Color(0xFF1A0505),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE8B84A),
                strokeWidth: 2.5,
              ),
            ),
          ),
      ],
    );
  }
}
