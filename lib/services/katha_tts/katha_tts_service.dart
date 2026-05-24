import 'dart:async';

import 'package:bhakti_sadhana/services/katha_tts/katha_speech_segment.dart';
import 'package:bhakti_sadhana/services/katha_tts/katha_tts_backend.dart';
import 'package:bhakti_sadhana/services/katha_tts/katha_tts_backend_export.dart';
import 'package:bhakti_sadhana/services/katha_tts/katha_tts_text.dart';
import 'package:flutter/foundation.dart';

enum KathaTtsStatus { idle, playing, paused }

class KathaTtsSnapshot {
  const KathaTtsSnapshot({
    this.status = KathaTtsStatus.idle,
    this.currentIndex = 0,
    this.total = 0,
    this.currentText = '',
    this.errorMessage,
  });

  final KathaTtsStatus status;
  final int currentIndex;
  final int total;
  final String currentText;
  final String? errorMessage;

  bool get isPlaying => status == KathaTtsStatus.playing;
  bool get isPaused => status == KathaTtsStatus.paused;
  bool get isActive => status != KathaTtsStatus.idle;
}

/// व्रत कथा TTS — वाक्यवार, प्राकृतिक रुकावट।
class KathaTtsService {
  KathaTtsService._() {
    _backend.setHandlers(
      onComplete: _onUtteranceComplete,
      onCancel: _onUtteranceComplete,
    );
  }
  static final KathaTtsService instance = KathaTtsService._();

  final KathaTtsBackend _backend = createKathaTtsBackend();
  final ValueNotifier<KathaTtsSnapshot> snapshot =
      ValueNotifier(const KathaTtsSnapshot());

  List<String> _displayQueue = const [];
  List<KathaSpeechSegment> _segments = const [];
  int _segmentIndex = 0;
  bool _paused = false;
  bool _initialized = false;
  int _session = 0;

  void _emit(KathaTtsSnapshot next) => snapshot.value = next;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _backend.init();
    _initialized = true;
  }

  Future<void> playAll(List<String> texts, {int startIndex = 0}) async {
    if (texts.isEmpty) return;
    await _hardStop();
    final session = ++_session;

    try {
      await _ensureInit();
    } catch (e) {
      debugPrint('KathaTtsService.init: $e');
      _emit(KathaTtsSnapshot(errorMessage: e.toString()));
      return;
    }

    _displayQueue = List<String>.from(texts);
    _segments = KathaTtsText.segmentsFromParagraphs(_displayQueue);
    if (_segments.isEmpty) return;

    _segmentIndex = _segmentIndexForParagraph(
      startIndex.clamp(0, _displayQueue.length - 1),
    );
    _paused = false;
    await _speakSegment(session);
  }

  int _segmentIndexForParagraph(int paragraphIndex) {
    for (var i = 0; i < _segments.length; i++) {
      if (_segments[i].paragraphIndex >= paragraphIndex) return i;
    }
    return 0;
  }

  Future<void> _speakSegment(int session) async {
    if (session != _session || _paused) return;
    if (_segmentIndex >= _segments.length) {
      await stop();
      return;
    }

    final seg = _segments[_segmentIndex];
    final display = _displayQueue[seg.paragraphIndex];

    _emit(
      KathaTtsSnapshot(
        status: KathaTtsStatus.playing,
        currentIndex: seg.paragraphIndex,
        total: _displayQueue.length,
        currentText: display,
      ),
    );

    try {
      await _backend.speak(seg.text);
    } catch (e) {
      debugPrint('KathaTtsService.speak: $e');
      _emit(
        KathaTtsSnapshot(
          status: KathaTtsStatus.idle,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onUtteranceComplete() {
    if (_paused || _segments.isEmpty) return;
    final session = _session;
    if (_segmentIndex >= _segments.length) return;

    final pause = _segments[_segmentIndex].pauseAfter;
    _segmentIndex++;

    if (_segmentIndex >= _segments.length) {
      unawaited(stop());
      return;
    }

    Future<void>.delayed(pause, () {
      if (session != _session || _paused) return;
      unawaited(_speakSegment(session));
    });
  }

  Future<void> pause() async {
    if (!snapshot.value.isPlaying) return;
    _paused = true;
    await _backend.stop();
    final seg = _segmentIndex < _segments.length ? _segments[_segmentIndex] : null;
    _emit(
      KathaTtsSnapshot(
        status: KathaTtsStatus.paused,
        currentIndex: seg?.paragraphIndex ?? snapshot.value.currentIndex,
        total: _displayQueue.length,
        currentText: _displayQueue.isNotEmpty
            ? _displayQueue[seg?.paragraphIndex ?? snapshot.value.currentIndex]
            : '',
      ),
    );
  }

  Future<void> resume() async {
    if (!snapshot.value.isPaused || _segments.isEmpty) return;
    _paused = false;
    await _speakSegment(_session);
  }

  Future<void> next() async {
    if (_segments.isEmpty) return;
    _session++;
    _segmentIndex = (_segmentIndex + 1).clamp(0, _segments.length - 1);
    _paused = false;
    await _backend.stop();
    await _speakSegment(_session);
  }

  Future<void> previous() async {
    if (_segments.isEmpty) return;
    _session++;
    _segmentIndex = (_segmentIndex - 1).clamp(0, _segments.length - 1);
    _paused = false;
    await _backend.stop();
    await _speakSegment(_session);
  }

  Future<void> stop() async {
    _session++;
    await _hardStop();
  }

  Future<void> _hardStop() async {
    _paused = false;
    _displayQueue = const [];
    _segments = const [];
    _segmentIndex = 0;
    await _backend.stop();
    _emit(const KathaTtsSnapshot());
  }
}
