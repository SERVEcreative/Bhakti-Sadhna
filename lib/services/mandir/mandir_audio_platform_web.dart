import 'dart:js_interop';

import 'package:flutter/foundation.dart';

@JS('startMandirAartiLoop')
external JSPromise<JSBoolean> _startMandirAartiLoop();

@JS('startMandirShankhLoop')
external JSPromise<JSBoolean> _startMandirShankhLoop();

@JS('stopMandirAarti')
external void _stopMandirAarti();

@JS('stopMandirShankh')
external void _stopMandirShankh();

Future<bool> startMandirAartiLoopWeb() async {
  try {
    final ok = (await _startMandirAartiLoop().toDart).toDart;
    debugPrint('MandirShrineAudio web aarti => $ok');
    return ok;
  } catch (e) {
    debugPrint('MandirShrineAudio web aarti error: $e');
    return false;
  }
}

Future<bool> startMandirShankhLoopWeb() async {
  try {
    final ok = (await _startMandirShankhLoop().toDart).toDart;
    debugPrint('MandirShrineAudio web shankh => $ok');
    return ok;
  } catch (e) {
    debugPrint('MandirShrineAudio web shankh error: $e');
    return false;
  }
}

Future<void> stopMandirAartiWeb() async {
  try {
    _stopMandirAarti();
  } catch (e) {
    debugPrint('MandirShrineAudio web stop aarti: $e');
  }
}

Future<void> stopMandirShankhWeb() async {
  try {
    _stopMandirShankh();
  } catch (e) {
    debugPrint('MandirShrineAudio web stop shankh: $e');
  }
}
