import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:bhakti_sadhana/bootstrap/supabase_bootstrap.dart';
import 'package:bhakti_sadhana/data/repositories/aarti_audio_repository.dart';
import 'package:bhakti_sadhana/services/aarti_player/aarti_supabase_resolver.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

enum AartiPlayerStatus { idle, loading, playing, paused, error }

class AartiPlaybackSnapshot {
  const AartiPlaybackSnapshot({
    this.aartiId,
    this.status = AartiPlayerStatus.idle,
    this.position = Duration.zero,
    this.duration,
    this.errorMessage,
    this.audioPlaying = false,
  });

  final String? aartiId;
  final AartiPlayerStatus status;
  final Duration position;
  final Duration? duration;
  final String? errorMessage;

  /// just_audio की असली playing state — buttons के लिए।
  final bool audioPlaying;

  bool get isActive =>
      aartiId != null &&
      (status == AartiPlayerStatus.playing ||
          status == AartiPlayerStatus.paused ||
          status == AartiPlayerStatus.loading);

  bool get isPlaying => status == AartiPlayerStatus.playing && audioPlaying;

  bool get isPaused => status == AartiPlayerStatus.paused;

  bool get isLoading => status == AartiPlayerStatus.loading;
}

/// Supabase Storage MP3 → just_audio
class AartiPlayerService {
  AartiPlayerService._();
  static final AartiPlayerService instance = AartiPlayerService._();

  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<AartiPlaybackSnapshot> snapshot =
      ValueNotifier(const AartiPlaybackSnapshot());

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration?>? _durationSub;

  String? _loadedAartiId;
  int _loadToken = 0;
  bool _userPaused = false;

  void _emit(AartiPlaybackSnapshot next) => snapshot.value = next;

  void _sync({AartiPlayerStatus? forceStatus}) {
    final snap = snapshot.value;
    final id = snap.aartiId;
    if (id == null) return;

    AartiPlayerStatus status;
    if (forceStatus != null) {
      status = forceStatus;
    } else if (_player.processingState == ProcessingState.completed) {
      status = AartiPlayerStatus.idle;
      _loadedAartiId = null;
      _userPaused = false;
    } else if (_userPaused) {
      status = AartiPlayerStatus.paused;
    } else if (_player.playing) {
      status = AartiPlayerStatus.playing;
    } else if (_player.processingState == ProcessingState.loading) {
      status = AartiPlayerStatus.loading;
    } else if (_loadedAartiId == id) {
      status = AartiPlayerStatus.paused;
    } else {
      status = AartiPlayerStatus.idle;
    }

    _emit(
      AartiPlaybackSnapshot(
        aartiId: id,
        status: status,
        position: _player.position,
        duration: _player.duration ?? snap.duration,
        errorMessage: snap.errorMessage,
        audioPlaying: _player.playing,
      ),
    );
  }

  Future<void> _ensureSession() async {
    if (kIsWeb) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await session.setActive(true);
    } catch (e) {
      debugPrint('AartiPlayerService session: $e');
    }
  }

  void _bindStreams() {
    _positionSub ??= _player.positionStream.listen((_) => _sync());
    _stateSub ??= _player.playerStateStream.listen((_) => _sync());
    _durationSub ??= _player.durationStream.listen((_) => _sync());
  }

  /// चलाएँ — नई आरती या resume
  Future<void> play(String aartiId) async {
    if (!SupabaseBootstrap.initialized) {
      _emit(
        AartiPlaybackSnapshot(
          aartiId: aartiId,
          status: AartiPlayerStatus.error,
          errorMessage: SupabaseBootstrap.initError ?? 'supabase_not_configured',
        ),
      );
      return;
    }

    // Same track paused → resume only
    if (_loadedAartiId == aartiId &&
        _userPaused &&
        snapshot.value.aartiId == aartiId) {
      await resume();
      return;
    }

    final token = ++_loadToken;
    _userPaused = false;
    _bindStreams();

    _emit(
      AartiPlaybackSnapshot(
        aartiId: aartiId,
        status: AartiPlayerStatus.loading,
        position: Duration.zero,
        audioPlaying: false,
      ),
    );

    try {
      final source = await AartiAudioRepository.instance.getSource(aartiId);
      if (source == null || !source.hasSource) {
        throw StateError('no_catalog');
      }

      final streamUrl = await AartiSupabaseResolver.instance.resolve(source);
      if (token != _loadToken) return;

      await _ensureSession();
      await _player.stop();
      await _player.setUrl(streamUrl);
      if (token != _loadToken) return;

      _loadedAartiId = aartiId;
      await _player.play();
      if (token != _loadToken) return;

      _userPaused = false;
      _sync(forceStatus: AartiPlayerStatus.playing);
    } catch (e) {
      if (token != _loadToken) return;
      debugPrint('AartiPlayerService.play: $e');
      _loadedAartiId = null;
      _emit(
        AartiPlaybackSnapshot(
          aartiId: aartiId,
          status: AartiPlayerStatus.error,
          errorMessage: e.toString(),
          audioPlaying: false,
        ),
      );
    }
  }

  Future<void> pause() async {
    final id = snapshot.value.aartiId;
    if (id == null) return;

    _loadToken++;
    _userPaused = true;

    if (_player.playing || _player.processingState != ProcessingState.idle) {
      await _player.pause();
    }

    _sync(forceStatus: AartiPlayerStatus.paused);
  }

  Future<void> resume() async {
    final id = snapshot.value.aartiId;
    if (id == null || _loadedAartiId != id) {
      if (id != null) await play(id);
      return;
    }

    _userPaused = false;
    await _ensureSession();
    await _player.play();
    _sync(forceStatus: AartiPlayerStatus.playing);
  }

  Future<void> stop() async {
    _loadToken++;
    _userPaused = false;
    _loadedAartiId = null;
    await _player.stop();
    _emit(const AartiPlaybackSnapshot());
  }

  Future<void> seek(Duration position) async {
    final snap = snapshot.value;
    if (snap.aartiId == null) return;

    final max = snap.duration ?? _player.duration;
    var target = position;
    if (max != null && max.inMilliseconds > 0) {
      target = Duration(
        milliseconds: position.inMilliseconds.clamp(0, max.inMilliseconds),
      );
    }

    _emit(
      AartiPlaybackSnapshot(
        aartiId: snap.aartiId,
        status: snap.status,
        position: target,
        duration: max ?? snap.duration,
        errorMessage: snap.errorMessage,
        audioPlaying: snap.audioPlaying,
      ),
    );

    try {
      await _player.seek(target);
      _sync();
    } catch (e) {
      debugPrint('AartiPlayerService.seek: $e');
    }
  }

  Future<void> dispose() async {
    _loadToken++;
    await _positionSub?.cancel();
    await _stateSub?.cancel();
    await _durationSub?.cancel();
    _positionSub = null;
    _stateSub = null;
    _durationSub = null;
    _loadedAartiId = null;
    await _player.dispose();
    _emit(const AartiPlaybackSnapshot());
  }
}
