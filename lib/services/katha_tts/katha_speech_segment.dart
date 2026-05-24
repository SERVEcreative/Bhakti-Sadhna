/// TTS का एक बोला जाने वाला हिस्सा + उसके बाद रुकना।
class KathaSpeechSegment {
  const KathaSpeechSegment({
    required this.text,
    required this.pauseAfter,
    required this.paragraphIndex,
  });

  final String text;
  final Duration pauseAfter;

  /// कौन सा अनुच्छेद स्क्रीन पर दिखे।
  final int paragraphIndex;
}
