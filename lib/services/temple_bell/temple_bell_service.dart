import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:bhakti_sadhana/services/temple_bell/bell_platform_stub.dart'
    if (dart.library.js_interop) 'package:bhakti_sadhana/services/temple_bell/bell_platform_web.dart'
    as bell_platform;
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// मंदिर घंटी — Android/iOS: just_audio (asset) | Web: HTML5 fetch+play
class TempleBellService {
  TempleBellService._();
  static final TempleBellService instance = TempleBellService._();

  static const String assetPath = 'assets/sounds/temple_bell.mp3';

  AudioPlayer? _player;
  bool _ready = false;
  Future<void>? _initFuture;
  bool _isPlaying = false;

  Future<void> _configureAudioSession() async {
    if (kIsWeb) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await session.setActive(true);
    } catch (e) {
      debugPrint('AudioSession: $e');
    }
  }

  Future<void> init() async {
    if (_ready || kIsWeb) {
      if (kIsWeb) debugPrint('TempleBellService: web mode (HTML bell)');
      return;
    }
    if (_initFuture != null) return _initFuture!;

    _initFuture = _initInternal();
    try {
      await _initFuture;
    } catch (_) {
      _initFuture = null;
      rethrow;
    }
  }

  Future<void> _initInternal() async {
    try {
      await _configureAudioSession();
      await _player?.dispose();
      _player = AudioPlayer();
      await _player!.setAsset(assetPath);
      await _player!.setLoopMode(LoopMode.off);
      await _player!.setVolume(1.0);
      _ready = true;
      debugPrint('TempleBellService: native ready');
    } catch (e, st) {
      debugPrint('TempleBellService.init: $e\n$st');
      _ready = false;
      rethrow;
    }
  }

  Future<bool> _playNative() async {
    if (_isPlaying) return true;

    try {
      await init();
      if (_player == null || !_ready) return false;

      _isPlaying = true;
      await _configureAudioSession();
      await _player!.stop();
      await _player!.seek(Duration.zero);
      await _player!.play();

      // play() के तुरंत बाद playing=false हो सकता है — थोड़ा इंतज़ार।
      var ok = _player!.playing;
      if (!ok) {
        try {
          await _player!.playerStateStream
              .firstWhere((s) => s.playing)
              .timeout(const Duration(milliseconds: 600));
          ok = true;
        } catch (_) {
          ok = _player!.processingState != ProcessingState.idle;
        }
      }

      debugPrint('TempleBellService: native playing=$ok');
      return ok;
    } catch (e, st) {
      debugPrint('TempleBellService native play: $e\n$st');
      return false;
    } finally {
      _isPlaying = false;
    }
  }

  Future<bool> play() async {
    if (kIsWeb) {
      return bell_platform.playViaBrowser();
    }
    return _playNative();
  }

  Future<bool> playWithRetry() async {
    if (await play()) return true;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return play();
  }

  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _ready = false;
    _initFuture = null;
    _isPlaying = false;
  }
}
