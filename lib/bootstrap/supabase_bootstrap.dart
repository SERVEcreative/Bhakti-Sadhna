import 'package:bhakti_sadhana/config/supabase_config.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase startup — fail hone par bhi app chalegi (setup message dikhega)।
abstract final class SupabaseBootstrap {
  static bool initialized = false;
  static String? initError;

  static Future<void> init() async {
    if (initialized) return;

    if (!SupabaseConfig.isConfigured) {
      initError = 'supabase_not_configured';
      debugPrint(
        'SupabaseBootstrap: set SUPABASE_URL & SUPABASE_ANON_KEY in lib/config/supabase_config.dart '
        'or pass --dart-define',
      );
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      initialized = true;
      initError = null;
      debugPrint('SupabaseBootstrap: ready');
    } catch (e, st) {
      initError = e.toString();
      debugPrint('SupabaseBootstrap.init: $e\n$st');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
