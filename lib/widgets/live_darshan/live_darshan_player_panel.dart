import 'dart:async';

import 'package:bhakti_sadhana/config/live_darshan_config.dart';
import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/models/live_stream_status.dart';
import 'package:bhakti_sadhana/data/models/live_temple.dart';
import 'package:bhakti_sadhana/services/live_darshan/youtube_launcher.dart';
import 'package:bhakti_sadhana/services/live_darshan/youtube_live_status_service.dart';
import 'package:bhakti_sadhana/widgets/live_darshan/live_darshan_overlay_scaffold.dart';
import 'package:bhakti_sadhana/widgets/live_darshan/live_youtube_watch_card.dart';
import 'package:bhakti_sadhana/widgets/live_darshan/mandir_closed_cover.dart';
import 'package:bhakti_sadhana/widgets/live_darshan/youtube_iframe_live_player.dart';
import 'package:flutter/material.dart';

/// लाइव → ऐप में iframe प्लेयर; नहीं चले तो YouTube ऐप।
class LiveDarshanPlayerPanel extends StatefulWidget {
  const LiveDarshanPlayerPanel({
    super.key,
    required this.temple,
    this.pollWhenVisible = true,
  });

  final LiveTemple temple;
  final bool pollWhenVisible;

  @override
  State<LiveDarshanPlayerPanel> createState() => _LiveDarshanPlayerPanelState();
}

class _LiveDarshanPlayerPanelState extends State<LiveDarshanPlayerPanel> {
  LiveStreamStatus _status = const LiveStreamLoading();
  Timer? _pollTimer;
  var _requestGen = 0;
  var _iframeFailed = false;
  var _playerClosed = false;
  final _iframeKey = GlobalKey<YoutubeIframeLivePlayerState>();

  @override
  void initState() {
    super.initState();
    _refresh(force: true);
    _startPolling();
  }

  @override
  void didUpdateWidget(covariant LiveDarshanPlayerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.temple.id != widget.temple.id) {
      _iframeFailed = false;
      _playerClosed = false;
      _refresh(force: true);
    }
    if (oldWidget.pollWhenVisible != widget.pollWhenVisible) {
      if (widget.pollWhenVisible) {
        _startPolling();
        _refresh();
      } else {
        _pollTimer?.cancel();
        _pollTimer = null;
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    if (!widget.pollWhenVisible) return;
    _pollTimer = Timer.periodic(LiveDarshanConfig.pollInterval, (_) {
      _refresh();
    });
  }

  Future<void> _refresh({bool force = false}) async {
    if (force) {
      YoutubeLiveStatusService.instance.clearCacheForTemple(widget.temple);
      _iframeFailed = false;
    }
    final gen = ++_requestGen;
    if (mounted) setState(() => _status = const LiveStreamLoading());

    final next =
        await YoutubeLiveStatusService.instance.resolveForTemple(widget.temple);
    if (!mounted || gen != _requestGen) return;
    setState(() => _status = next);
  }

  Future<void> _openYoutubeLive({String? videoId, String? channelId}) async {
    final ok = await YoutubeLauncher.openLive(
      videoId: videoId,
      channelId: channelId,
      fallbackUrl: widget.temple.openUrl,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.liveDarshanOpenError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pollWhenVisible) {
      return const ColoredBox(
        key: ValueKey('inactive'),
        color: Color(0xFF140404),
      );
    }
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return switch (_status) {
      LiveStreamLoading() => _buildLoading(key: const ValueKey('loading')),
      LiveStreamLive(:final videoId, :final channelId) =>
        _buildLivePlayer(videoId, channelId),
      LiveStreamEmbedBlocked(:final videoId, :final channelId) =>
        _buildLivePlayer(videoId, channelId, keySuffix: 'blocked'),
      LiveStreamOffline() => MandirClosedCover(
          key: const ValueKey('closed'),
          templeName: widget.temple.nameHi,
          onRefresh: () => _refresh(force: true),
          onOpenYoutube: () => _openYoutubeLive(),
        ),
      LiveStreamError(:final message) => _buildError(message),
    };
  }

  void _closePlayer() {
    _iframeKey.currentState?.pausePlayback();
    setState(() => _playerClosed = true);
  }

  void _resumePlayer() {
    setState(() => _playerClosed = false);
  }

  Widget _buildLivePlayer(
    String videoId,
    String? channelId, {
    String keySuffix = 'live',
  }) {
    if (_iframeFailed) {
      return LiveYoutubeWatchCard(
        key: ValueKey('fallback-$keySuffix-$videoId'),
        templeName: widget.temple.nameHi,
        onWatchYoutube: () => _openYoutubeLive(
          videoId: videoId,
          channelId: channelId,
        ),
        showTryInApp: true,
        onTryInApp: () => setState(() => _iframeFailed = false),
      );
    }

    if (_playerClosed) {
      return LiveDarshanOverlayScaffold(
        key: ValueKey('closed-player-$keySuffix-$videoId'),
        color: const Color(0xFF140404),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.temple.nameHi,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: BhaktiTheme.titleHi.copyWith(
                fontSize: 13,
                color: BhaktiTheme.goldLight,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _resumePlayer,
                icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppStrings.liveDarshanResumePlayer,
                    style: BhaktiTheme.titleHi.copyWith(
                      fontSize: 12,
                      color: BhaktiTheme.maroonDeep,
                    ),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: BhaktiTheme.saffron,
                  foregroundColor: BhaktiTheme.maroonDeep,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      key: ValueKey('iframe-$keySuffix-$videoId'),
      children: [
        _LivePlayerToolbar(
          onClose: _closePlayer,
          onOpenYoutube: () => _openYoutubeLive(
            videoId: videoId,
            channelId: channelId,
          ),
        ),
        Expanded(
          child: ClipRect(
            child: YoutubeIframeLivePlayer(
              key: _iframeKey,
              videoId: videoId,
              autoPlay: true,
              onPlaybackFailed: () {
                if (!mounted) return;
                setState(() => _iframeFailed = true);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading({Key? key}) {
    return ColoredBox(
      key: key,
      color: const Color(0xFF1A0505),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: BhaktiTheme.saffron,
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.liveDarshanChecking,
              style: BhaktiTheme.bodyHi.copyWith(
                fontSize: 12,
                color: BhaktiTheme.cream.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    if (message == 'api_key_missing') {
      return LiveDarshanOverlayScaffold(
        key: const ValueKey('api-missing'),
        color: const Color(0xFF140404),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.liveDarshanApiKeyHint,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: BhaktiTheme.bodyHi.copyWith(
                fontSize: 10,
                color: BhaktiTheme.cream.withValues(alpha: 0.65),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openYoutubeLive(),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(AppStrings.liveDarshanOpenYoutube),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: BhaktiTheme.saffron,
                  foregroundColor: BhaktiTheme.maroonDeep,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return MandirClosedCover(
      key: ValueKey('err-$message'),
      templeName: widget.temple.nameHi,
      onRefresh: () => _refresh(force: true),
      onOpenYoutube: () => _openYoutubeLive(),
    );
  }
}

/// WebView के ऊपर नहीं — हमेशा टैप होने वाला बंद / YouTube बार।
class _LivePlayerToolbar extends StatelessWidget {
  const _LivePlayerToolbar({
    required this.onClose,
    required this.onOpenYoutube,
  });

  final VoidCallback onClose;
  final VoidCallback onOpenYoutube;

  static const _barHeight = 42.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _barHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF1A0808),
          border: Border(
            bottom: BorderSide(
              color: BhaktiTheme.gold.withValues(alpha: 0.25),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.liveDarshanLiveNow,
                style: BhaktiTheme.labelSub.copyWith(
                  color: const Color(0xFFFF8A80),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onOpenYoutube,
                tooltip: AppStrings.liveDarshanOpenYoutube,
                icon: Icon(
                  Icons.open_in_new_rounded,
                  size: 20,
                  color: BhaktiTheme.goldLight.withValues(alpha: 0.9),
                ),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              FilledButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppStrings.liveDarshanClosePlayer,
                    style: BhaktiTheme.titleHi.copyWith(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 34),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
