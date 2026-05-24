/// Platform TTS — native (flutter_tts) या web (Speech Synthesis)।
abstract class KathaTtsBackend {
  Future<void> init();
  Future<void> speak(String text);
  Future<void> stop();
  void setHandlers({void Function()? onComplete, void Function()? onCancel});
}
