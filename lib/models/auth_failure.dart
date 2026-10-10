/// Falhas de autenticação, independentes do provedor. A mensagem exibida
/// fica na camada de View (`string_extensions.dart`).
sealed class AuthFailure implements Exception {
  const AuthFailure();
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure();
}

class EmailAlreadyRegisteredFailure extends AuthFailure {
  const EmailAlreadyRegisteredFailure();
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure();
}

class OfflineFailure extends AuthFailure {
  const OfflineFailure();
}

/// O usuário fechou a tela de login do Google.
class SignInCancelledFailure extends AuthFailure {
  const SignInCancelledFailure();
}

class ProviderUnavailableFailure extends AuthFailure {
  const ProviderUnavailableFailure();
}

class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure([this.cause]);
  final Object? cause;
}
