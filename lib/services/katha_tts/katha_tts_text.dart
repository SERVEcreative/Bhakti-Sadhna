import 'package:bhakti_sadhana/services/katha_tts/katha_speech_segment.dart';

/// कथा TTS — वाक्य अलग, विराम चिह्न न बोलें, रुकावट साफ़।
abstract final class KathaTtsText {
  /// वाक्य खत्म — छोटी साँस
  static const Duration _pauseFull = Duration(milliseconds: 200);

  /// अल्प विराम (,) — बहुत हल्की
  static const Duration _pauseComma = Duration(milliseconds: 70);

  /// पूरी कथा का अंत
  static const Duration _pauseParagraphEnd = Duration(milliseconds: 260);

  /// एक अनुच्छेद → वाक्य/खंड + रुकावट।
  static List<KathaSpeechSegment> segmentsFromParagraph(
    String raw,
    int paragraphIndex, {
    bool isLastParagraph = false,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const [];

    if (_isClosingLine(trimmed)) {
      final t = cleanClause(trimmed);
      if (t.length < 4) return const [];
      return [
        KathaSpeechSegment(
          text: t,
          pauseAfter: _pauseParagraphEnd,
          paragraphIndex: paragraphIndex,
        ),
      ];
    }

    final segments = <KathaSpeechSegment>[];
    final sentences = trimmed.split(RegExp(r'(?<=[।॥.!?])\s*'));

    for (var si = 0; si < sentences.length; si++) {
      final sentence = sentences[si].trim();
      if (sentence.isEmpty) continue;

      final clauses = sentence.split(RegExp(r',\s*'));
      for (var ci = 0; ci < clauses.length; ci++) {
        final clause = cleanClause(clauses[ci]);
        if (clause.length < 3) continue;

        final isLastClause = ci == clauses.length - 1;
        final isLastSentence = si == sentences.length - 1;
        Duration pause;
        if (!isLastClause) {
          pause = _pauseComma;
        } else if (isLastSentence && isLastParagraph) {
          pause = _pauseParagraphEnd;
        } else {
          pause = _pauseFull;
        }

        segments.add(
          KathaSpeechSegment(
            text: clause,
            pauseAfter: pause,
            paragraphIndex: paragraphIndex,
          ),
        );
      }
    }

    return segments;
  }

  static List<KathaSpeechSegment> segmentsFromParagraphs(List<String> paragraphs) {
    final out = <KathaSpeechSegment>[];
    for (var i = 0; i < paragraphs.length; i++) {
      out.addAll(
        segmentsFromParagraph(
          paragraphs[i],
          i,
          isLastParagraph: i == paragraphs.length - 1,
        ),
      );
    }
    return out;
  }

  /// बोले जाने वाले पाठ से विराम चिह्न हटाएँ (नाम न बोलें)।
  static String cleanClause(String raw) {
    var t = raw.trim();
    if (t.isEmpty) return t;

    t = t.replaceAll(RegExp(r'[॥ॐ]+'), ' ');
    t = t.replaceAll(RegExp(r'[।.!?]+'), ' ');
    t = t.replaceAll(
      RegExp(r'''[,;:'"“”‘’«»()\[\]{}\\/_\-–—…•·|@#$%^&*+=~`<>]'''),
      ' ',
    );
    t = t.replaceAll(RegExp(r'[\u2000-\u206F\u2E00-\u2E7F]'), ' ');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t;
  }

  static bool _isClosingLine(String t) {
    return t.length < 90 &&
        RegExp(r'संपूर्ण|बोलिए|की जय', caseSensitive: false).hasMatch(t);
  }
}
