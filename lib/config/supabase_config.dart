/// Supabase — Dashboard → Project Settings → API se copy karein।
abstract final class SupabaseConfig {
  static const String placeholder = 'REPLACE_ME';

  /// https://xxxxx.supabase.co
  static const String url = 'https://kprgqcycfmihixhwkdwc.supabase.co';

  /// anon public key
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtwcmdxY3ljZm1paGl4aHdrZHdjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk1NTg2ODIsImV4cCI6MjA5NTEzNDY4Mn0.GOcGvSYPK80KGbbqwGSWldC7KCEHJBkSsz13B7cJZOo';

  /// Storage bucket (public read) — Supabase Storage में यही नाम बनाएँ
  static const String aartiBucket = 'aartis';

  static bool get isConfigured =>
      url != placeholder &&
      anonKey != placeholder &&
      url.startsWith('https://') &&
      url.contains('supabase.co');
}
