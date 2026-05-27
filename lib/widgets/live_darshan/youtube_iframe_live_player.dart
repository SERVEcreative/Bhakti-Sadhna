import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// ऐप के अंदर YouTube iframe प्लेयर (लाइव वीडियो)।
class YoutubeIframeLivePlayer extends StatefulWidget {
  const YoutubeIframeLivePlayer({
    super.key,
    required this.videoId,
    this.onPlaybackFailed,
    this.onControllerReady,
    this.autoPlay = true,
  });

  final String videoId;
  final VoidCallback? onPlaybackFailed;
  final ValueChanged<YoutubePlayerController>? onControllerReady;
  final bool autoPlay;

  @override
  State<YoutubeIframeLivePlayer> createState() =>
      YoutubeIframeLivePlayerState();
}

class YoutubeIframeLivePlayerState extends State<YoutubeIframeLivePlayer> {
  late YoutubePlayerController _controller;
  var _reportedFailure = false;

  @override
  void initState() {
    super.initState();
    _initController(widget.videoId);
  }

  void _initController(String videoId) {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: widget.autoPlay,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        playsInline: true,
        enableJavaScript: true,
      ),
    );
    _controller.listen(_onPlayerUpdate);
    widget.onControllerReady?.call(_controller);
  }

  /// स्क्रॉल पर Android video surface glitch कम करने के लिए।
  Future<void> pausePlayback() async {
    try {
      await _controller.pauseVideo();
    } catch (_) {}
  }

  void _onPlayerUpdate(YoutubePlayerValue value) {
    if (_reportedFailure || widget.onPlaybackFailed == null) return;
    final err = value.error;
    if (err == YoutubeError.none || err == YoutubeError.unknown) return;
    _reportedFailure = true;
    widget.onPlaybackFailed!();
  }

  @override
  void didUpdateWidget(covariant YoutubeIframeLivePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      _reportedFailure = false;
      _controller.close();
      _initController(widget.videoId);
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      aspectRatio: 16 / 9,
      backgroundColor: Colors.black,
      enableFullScreenOnVerticalDrag: false,
      autoFullScreen: false,
      gestureRecognizers: {
        Factory<VerticalDragGestureRecognizer>(
          VerticalDragGestureRecognizer.new,
        ),
      },
    );
  }
}
