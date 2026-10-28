import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../models/auth_failure.dart';
import '../models/session_user.dart';
import 'session_repository.dart';

/// Autenticação pelo Supabase Auth: e-mail/senha e Google (token nativo do
/// Google validado pelo Supabase).
class SupabaseSessionRepository implements SessionRepository {
  SupabaseSessionRepository(
    this._client,
    this._db, {
    GoogleSignIn? google,
    this.googleWebClientId,
    this.googleIosClientId,
  }) : _google = google ?? GoogleSignIn.instance;

  final SupabaseClient _client;
  final AppDatabase _db;
  final GoogleSignIn _google;
  final String? googleWebClientId;
  final String? googleIosClientId;

  Future<void>? _googleReady;

  GoTrueClient get _auth => _client.auth;

  @override
  Stream<void> get sessionRevoked => _auth.onAuthStateChange
      .handleError((_) {})
      .where(
        (state) =>
            state.event == AuthChangeEvent.signedOut &&
            state.signOutReason != SignOutReason.userInitiated,
      );

  /// A sessão salva vale mesmo com o token de acesso vencido: o Supabase
  /// renova quando a internet voltar.
  @override
  Future<SessionUser?> currentUser() async {
    final user = _auth.currentSession?.user;
    return user == null ? null : _toSessionUser(user);
  }

  @override
  Future<SessionUser> signIn({
    required String email,
    required String password,
  }) => _guard(() async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _toSessionUser(response.user!);
  });

  @override
  Future<SessionUser> signUp({
    required String email,
    required String password,
    required String name,
  }) => _guard(() async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
    // Com confirmação de e-mail ligada não há sessão até o clique no link.
    // O projeto usa confirmação desligada (ver docs/arquitetura.md).
    if (response.session == null) throw const UnknownAuthFailure();
    return _toSessionUser(response.user!);
  });

  @override
  Future<SessionUser> signInWithGoogle() => _guard(() async {
    if (googleWebClientId == null || googleWebClientId!.isEmpty) {
      throw const ProviderUnavailableFailure();
    }
    await (_googleReady ??= _google.initialize(
      clientId: Platform.isIOS ? googleIosClientId : null,
      serverClientId: googleWebClientId,
    ));
    final account = await _google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) throw const UnknownAuthFailure();
    final response = await _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
    return _toSessionUser(response.user!);
  });

  @override
  Future<void> signOut() async {
    // Remove a sessão local na hora; avisar o servidor é melhor esforço.
    try {
      await _auth.signOut();
    } catch (_) {}
    try {
      await _google.signOut();
    } catch (_) {}
    await _db.clearUserData();
  }

  @override
  Future<void> deleteAccount() => _guard(() async {
    await _client.rpc<void>('delete_account');
    await signOut();
  });

  SessionUser _toSessionUser(User user) => SessionUser(
    id: user.id,
    name:
        user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String?,
    email: user.email,
  );

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthFailure {
      rethrow;
    } on GoogleSignInException catch (e) {
      throw e.code == GoogleSignInExceptionCode.canceled
          ? const SignInCancelledFailure()
          : UnknownAuthFailure(e);
    } on AuthRetryableFetchException {
      throw const OfflineFailure();
    } on AuthWeakPasswordException {
      throw const WeakPasswordFailure();
    } on AuthException catch (e) {
      throw switch (e.code) {
        'invalid_credentials' => const InvalidCredentialsFailure(),
        'user_already_exists' ||
        'email_exists' => const EmailAlreadyRegisteredFailure(),
        'weak_password' => const WeakPasswordFailure(),
        _ => UnknownAuthFailure(e),
      };
    } on SocketException {
      throw const OfflineFailure();
    } on PostgrestException catch (e) {
      throw UnknownAuthFailure(e);
    } on ClientException {
      throw const OfflineFailure();
    }
  }
}
