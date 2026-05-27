/// लाइव दर्शन — YouTube Data API (चैनल पर active live जाँच)।
abstract final class LiveDarshanConfig {
  /// Google Cloud Console → YouTube Data API v3 key।
  /// `flutter run --dart-define=YOUTUBE_API_KEY=आपकी_कुंजी`
  static const String youtubeApiKey = String.fromEnvironment('YOUTUBE_API_KEY');

  static bool get hasYoutubeApiKey => youtubeApiKey.trim().isNotEmpty;

  /// चुने मंदिर की लाइव स्थिति दोबारा जाँच (सेकंड)।
  static const Duration pollInterval = Duration(seconds: 90);

  /// API जवाब कैश — quota बचाने के लिए।
  static const Duration statusCacheTtl = Duration(seconds: 40);
}
