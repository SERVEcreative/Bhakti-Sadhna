import 'dart:async';

import 'package:bhakti_sadhana/app.dart';
import 'package:bhakti_sadhana/bootstrap/supabase_bootstrap.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/services/temple_bell/temple_bell_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseBootstrap.init();
  BhaktiTheme.titleHi;
  BhaktiTheme.bodyHi;
  BhaktiTheme.labelSub;
  unawaited(TempleBellService.instance.init());
  runApp(const BhaktiApp());
}
