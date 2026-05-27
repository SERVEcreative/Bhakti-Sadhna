import 'package:audio_session/audio_session.dart';
import 'package:bhakti_sadhana/core/assets/asset_paths.dart';
import 'package:bhakti_sadhana/services/aarti_player/aarti_player_service.dart';
import 'package:bhakti_sadhana/services/mandir/mandir_audio_platform_stub.dart'
    if (dart.library.js_interop) 'package:bhakti_sadhana/services/mandir/mandir_audio_platform_web.dart'
    as mandir_audio;
import 'package:bhakti_sadhana/services/temple_bell/temple_bell_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

/// मंदिर — आरती / शंख loop; एक समय पर एक ही ध्वनि (शंख once को छोड़कर)।
class MandirShrineAudioService {
  MandirShrineAudioService._();
  static final MandirShrineAudioService instance = MandirShrineAudioService._();

  /// शंख — सिर्फ `assets/sounds/mandir_shankh.mp3` (घंटी / आरती नहीं)।
  static const String _shankhAsset = AssetPaths.mandirShankhSound;

  AudioPlayer? _aartiPlayer;
  AudioPlayer? _shankhPlayer;
  AudioPlayer? _shankhOncePlayer;

  Future<void> warmUp() async {
    if (kIsWeb) return;
    try {
      final shankh = await rootBundle.load(_shankhAsset);
      await rootBundle.load(AssetPaths.mandirAartiSound);
      debugPrint(
        'MandirShrineAudioService: shankh asset OK (${shankh.lengthInBytes} bytes)',
      );
    } catch (e) {
      debugPrint('MandirShrineAudioService.warmUp: $e');
    }
  }

  Future<void> _ensureSession() async {
    if (kIsWeb) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await session.setActive(true);
    } catch (e) {
      debugPrint('MandirShrineAudioService session: $e');
    }
  }

  Future<void> _stopExternalPlayers() async {
    await AartiPlayerService.instance.stop();
    await TempleBellService.instance.stop();
  }

  Future<void> stopAll() async {
    await stopAarti();
    await stopShankh();
  }

  Future<void> _playShankhOn(
    AudioPlayer player, {
    required bool loop,
  }) async {
    await player.stop();
    await player.setAudioSource(
      AudioSource.asset(_shankhAsset),
      preload: true,
    );
    await player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
    await player.setVolume(1.0);
    await player.seek(Duration.zero);
    await player.play();
  }

  Future<void> startAarti() async {
    await _stopExternalPlayers();
    await stopShankh();

    if (kIsWeb) {
      final ok = await mandir_audio.startMandirAartiLoopWeb();
      if (!ok) {
        debugPrint('MandirShrineAudioService: web aarti failed — full restart करें');
      }
      return;
    }

    try {
      await _ensureSession();
      await warmUp();
      _aartiPlayer ??= AudioPlayer();
      await _aartiPlayer!.stop();
      await _aartiPlayer!.setAudioSource(
        AudioSource.asset(AssetPaths.mandirAartiSound),
        preload: true,
      );
      await _aartiPlayer!.setLoopMode(LoopMode.one);
      await _aartiPlayer!.setVolume(1.0);
      await _aartiPlayer!.play();
    } catch (e, st) {
      debugPrint('MandirShrineAudioService.startAarti: $e\n$st');
    }
  }

  Future<void> stopAarti() async {
    if (kIsWeb) {
      await mandir_audio.stopMandirAartiWeb();
      return;
    }
    try {
      await _aartiPlayer?.stop();
    } catch (e) {
      debugPrint('MandirShrineAudioService.stopAarti: $e');
    }
  }

  Future<void> startShankh() async {
    await stopAarti();
    await _stopExternalPlayers();

    if (kIsWeb) {
      final ok = await mandir_audio.startMandirShankhLoopWeb();
      if (!ok) {
        debugPrint(
          'MandirShrineAudioService: web shankh ($_shankhAsset) failed — full restart',
        );
      }
      return;
    }

    try {
      await _ensureSession();
      await warmUp();
      _shankhPlayer ??= AudioPlayer();
      await _playShankhOn(_shankhPlayer!, loop: true);
      debugPrint('MandirShrineAudioService: playing $_shankhAsset (loop)');
    } catch (e, st) {
      debugPrint('MandirShrineAudioService.startShankh: $e\n$st');
    }
  }

  Future<void> stopShankh() async {
    if (kIsWeb) {
      await mandir_audio.stopMandirShankhWeb();
      return;
    }
    try {
      await _shankhPlayer?.stop();
    } catch (e) {
      debugPrint('MandirShrineAudioService.stopShankh: $e');
    }
  }

  /// आरती चलते हुए बीच में एक बार शंख — आरती बंद नहीं होती।
  Future<void> playShankhOnce() async {
    if (kIsWeb) {
      final ok = await mandir_audio.playMandirShankhOnceWeb();
      if (!ok) {
        debugPrint(
          'MandirShrineAudioService: web shankh once ($_shankhAsset) failed',
        );
      }
      return;
    }

    try {
      await _ensureSession();
      await warmUp();
      await _shankhPlayer?.stop();

      await _shankhOncePlayer?.dispose();
      _shankhOncePlayer = AudioPlayer();
      await _playShankhOn(_shankhOncePlayer!, loop: false);
      debugPrint('MandirShrineAudioService: playing $_shankhAsset (once)');
    } catch (e, st) {
      debugPrint('MandirShrineAudioService.playShankhOnce: $e\n$st');
    }
  }
}
