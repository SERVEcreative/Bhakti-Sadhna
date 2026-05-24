import 'package:bhakti_sadhana/services/katha_tts/katha_tts_backend.dart';
import 'package:bhakti_sadhana/services/katha_tts/katha_tts_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class IoKathaTtsBackend implements KathaTtsBackend {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  @override
  Future<void> init() async {
    if (_ready) return;
    await _trySet(() => _tts.setVolume(1.0));
    // थोड़ा नीची pitch — कम “रोबोट” जैसी
    await _trySet(() => _tts.setPitch(0.92));
    await _trySet(() => _tts.setSpeechRate(0.47));
    await _trySet(() => _tts.awaitSpeakCompletion(true));

    final hiIn = await _trySet(() => _tts.isLanguageAvailable('hi-IN'));
    if (hiIn == true) {
      await _trySet(() => _tts.setLanguage('hi-IN'));
    } else {
      await _trySet(() => _tts.setLanguage('hi'));
    }

    // Android: Google TTS engine अगर मिले
    if (defaultTargetPlatform == TargetPlatform.android) {
      final engines = await _trySet(() => _tts.getEngines);
      if (engines != null) {
        for (final e in engines) {
          final name = e.toString().toLowerCase();
          if (name.contains('google')) {
            await _trySet(() => _tts.setEngine(e.toString()));
            break;
          }
        }
      }
    }
    _ready = true;
  }

  @override
  void setHandlers({void Function()? onComplete, void Function()? onCancel}) {
    _tts.setCompletionHandler(() => onComplete?.call());
    _tts.setCancelHandler(() => onCancel?.call());
  }

  @override
  Future<void> speak(String text) async {
    final cleaned = KathaTtsText.cleanClause(text);
    if (cleaned.length < 3) return;
    await _tts.stop();
    await _tts.speak(cleaned);
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<T?> _trySet<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      debugPrint('IoKathaTtsBackend: $e');
      return null;
    }
  }
}

KathaTtsBackend createKathaTtsBackend() => IoKathaTtsBackend();
