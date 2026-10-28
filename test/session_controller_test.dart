import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/configs/strings/string_extensions.dart';
import 'package:oz_contador_de_calorias/controllers/session_controller.dart';
import 'package:oz_contador_de_calorias/models/auth_failure.dart';
import 'package:oz_contador_de_calorias/models/session_user.dart';
import 'package:oz_contador_de_calorias/repositories/session_repository.dart';

class _FakeSessionRepository implements SessionRepository {
  SessionUser? saved;
  AuthFailure? failure;
  int signOuts = 0;
  final revoked = StreamController<void>.broadcast();

  @override
  Stream<void> get sessionRevoked => revoked.stream;

  @override
  Future<SessionUser?> currentUser() async => saved;

  Future<SessionUser> _result(SessionUser user) async {
    if (failure case final failure?) throw failure;
    return saved = user;
  }

  @override
  Future<SessionUser> signIn({
    required String email,
    required String password,
  }) => _result(SessionUser(id: 'u1', email: email));

  @override
  Future<SessionUser> signUp({
    required String email,
    required String password,
    required String name,
  }) => _result(SessionUser(id: 'u1', email: email, name: name));

  @override
  Future<SessionUser> signInWithGoogle() =>
      _result(const SessionUser(id: 'g1', name: 'Ana Google'));

  @override
  Future<void> signOut() async {
    signOuts++;
    saved = null;
  }

  @override
  Future<void> deleteAccount() => signOut();
}

void main() {
  late _FakeSessionRepository repository;
  late SessionController controller;

  setUp(() {
    repository = _FakeSessionRepository();
    controller = SessionController(repository);
  });

  tearDown(() => controller.dispose());

  test('retoma a sessão salva no aparelho', () async {
    expect(await controller.restore(), isFalse);
    repository.saved = const SessionUser(id: 'u1');
    expect(await controller.restore(), isTrue);
    expect(controller.user!.id, 'u1');
  });

  test('cadastro guarda o usuário com o nome informado', () async {
    await controller.signUp(email: 'a@b.com', password: '12345678', name: 'Ana');
    expect(controller.isAuthenticated, isTrue);
    expect(controller.user!.name, 'Ana');
  });

  test('falha no login é repassada e não abre sessão', () async {
    repository.failure = const InvalidCredentialsFailure();
    await expectLater(
      controller.login(email: 'a@b.com', password: 'errada12'),
      throwsA(isA<InvalidCredentialsFailure>()),
    );
    expect(controller.isAuthenticated, isFalse);
  });

  test('sessão encerrada pelo servidor apaga os dados e avisa', () async {
    await controller.loginWithGoogle();
    repository.revoked.add(null);
    await pumpEventQueue();

    expect(controller.isAuthenticated, isFalse);
    expect(controller.wasRevoked, isTrue);
    expect(repository.signOuts, 1);
  });

  test('logout encerra a sessão', () async {
    await controller.loginWithGoogle();
    await controller.logout();
    expect(controller.isAuthenticated, isFalse);
    expect(controller.wasRevoked, isFalse);
  });

  test('mensagens de erro de autenticação em português', () {
    expect(
      const InvalidCredentialsFailure().message,
      'E-mail ou senha incorretos',
    );
    expect(const OfflineFailure().message, startsWith('Sem conexão'));
    expect(const SignInCancelledFailure().message, isNull);
  });
}
