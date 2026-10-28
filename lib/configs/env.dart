/// Configuração de ambiente, passada no build:
/// `flutter run --dart-define-from-file=config/dev.json`
/// (modelo em `config/dev.example.json`).
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Client ID "Web" do Google Cloud; é o que o Supabase valida no token.
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  /// Client ID "iOS" do Google Cloud (no Android não é usado).
  static const googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );

  /// Sem Supabase configurado, o app roda só com a sessão local
  /// (conta de demonstração), útil para desenvolver e para os testes.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static bool get hasGoogle => googleWebClientId.isNotEmpty;
}
