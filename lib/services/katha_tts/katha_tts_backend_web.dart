import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:bhakti_sadhana/services/katha_tts/katha_tts_backend.dart';
import 'package:bhakti_sadhana/services/katha_tts/katha_tts_text.dart';
import 'package:flutter/foundation.dart';

/// Chrome — Speech Synthesis, वाक्य-दर-वाक्य (service रुकावट जोड़ती है)।
class WebKathaTtsBackend implements KathaTtsBackend {
  html.SpeechSynthesisUtterance? _utterance;
  void Function()? _onComplete;
  void Function()? _onCancel;

  @override
  Future<void> init() async {
    // आवाज़ें lazy load होती हैं — एक बार खाली बोलकर warm-up
    final synth = html.window.speechSynthesis;
    if (synth == null) return;
    if (synth.getVoices().isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }

  @override
  void setHandlers({void Function()? onComplete, void Function()? onCancel}) {
    _onComplete = onComplete;
    _onCancel = onCancel;
  }

  @override
  Future<void> speak(String text) async {
    final cleaned = KathaTtsText.cleanClause(text);
    if (cleaned.length < 3) return;

    await stop();
    final synth = html.window.speechSynthesis;
    if (synth == null) {
      debugPrint('WebKathaTtsBackend: speechSynthesis unavailable');
      return;
    }

    final utterance = html.SpeechSynthesisUtterance(cleaned);
    utterance.lang = 'hi-IN';
    // थोड़ा धीमा = कम रोबोटिक
    utterance.rate = 0.94;
    utterance.pitch = 0.96;
    _pickHindiVoice(synth, utterance);

    final done = Completer<void>();

    void finish(void Function()? handler) {
      if (!identical(_utterance, utterance)) return;
      _utterance = null;
      handler?.call();
      if (!done.isCompleted) done.complete();
    }

    utterance.onEnd.listen((_) => finish(_onComplete));
    utterance.onError.listen((_) => finish(_onCancel));

    _utterance = utterance;
    synth.speak(utterance);
    await done.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () => finish(_onCancel),
    );
  }

  @override
  Future<void> stop() async {
    html.window.speechSynthesis?.cancel();
    _utterance = null;
  }

  void _pickHindiVoice(html.SpeechSynthesis synth, html.SpeechSynthesisUtterance u) {
    final voices = synth.getVoices();
    if (voices.isEmpty) return;

    html.SpeechSynthesisVoice? best;
    var bestScore = -1;

    for (final v in voices) {
      final lang = (v.lang ?? '').toLowerCase();
      if (!lang.startsWith('hi')) continue;
      final name = (v.name ?? '').toLowerCase();
      var score = 0;
      if (lang == 'hi-in') score += 10;
      if (name.contains('google')) score += 8;
      if (name.contains('neural')) score += 7;
      if (name.contains('natural')) score += 6;
      if (name.contains('premium')) score += 5;
      if (score > bestScore) {
        bestScore = score;
        best = v;
      }
    }
    if (best != null) u.voice = best;
  }
}

KathaTtsBackend createKathaTtsBackend() => WebKathaTtsBackend();
