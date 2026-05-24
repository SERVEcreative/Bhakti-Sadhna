import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<void> main() async {
  final yt = YoutubeExplode();
  final ids = ['yg6qZUSZPWM', 'f6s0WUqLmh0', '6EZ930Gte04', '5Xz7K8T5V8Q'];
  for (final id in ids) {
    try {
      final m = await yt.videos.streamsClient.getManifest(id);
      final s = m.audioOnly.withHighestBitrate();
      // ignore: avoid_print
      print('$id OK bitrate=${s.bitrate}');
    } catch (e) {
      // ignore: avoid_print
      print('$id FAIL: $e');
    }
  }
  yt.close();
}
