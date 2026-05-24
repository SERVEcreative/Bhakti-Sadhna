import 'dart:js_interop';

import 'package:flutter/foundation.dart';

@JS('playMandirBell')
external JSPromise<JSBoolean> _playMandirBell();

Future<bool> playViaBrowser() async {
  try {
    final result = await _playMandirBell().toDart;
    final ok = result.toDart;
    debugPrint('TempleBellService web playMandirBell => $ok');
    return ok;
  } catch (e) {
    debugPrint('TempleBellService web error: $e');
    return false;
  }
}
