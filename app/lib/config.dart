/// Backend-Konfiguration. Der Publishable Key ist clientseitig öffentlich
/// (Sicherheit kommt aus Row-Level-Security, nicht aus dem Key) und ist
/// deshalb fest als Default eingebaut — die App läuft so out-of-the-box
/// gegen das echte EU-Backend, ohne --dart-define.
///
/// Override für andere Umgebungen:
///   flutter run --dart-define=SUPABASE_KEY=… --dart-define=SUPABASE_URL=…
abstract class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ncldijjkxoshshunkkmu.supabase.co',
  );

  /// Publishable Key (sb_publishable_…). Öffentlich, RLS schützt die Daten.
  static const supabaseKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: 'sb_publishable_EnjaOD-6UTlJVO-bPSLfIw_DFYAOUyL',
  );

  /// In Widget-Tests (ohne Supabase-Init) auf true setzen → Mock-Pfad.
  static bool forceMock = false;

  /// Backend ist verfügbar, sobald URL und Key gesetzt sind.
  static bool get hasBackend =>
      !forceMock && supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
}
