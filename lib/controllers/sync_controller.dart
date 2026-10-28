import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import '../database/app_database.dart';
import '../models/enums/sync_status.dart';
import '../models/sync_failure.dart';
import '../services/sync_service.dart';
import 'session_controller.dart';

/// Dono do estado da sincronização. Sincroniza ao entrar na conta, alguns
/// segundos depois de cada gravação local, quando a internet volta e quando
/// o app volta para a tela. Sem [SyncService] (Supabase não configurado),
/// fica desligado e os dados vivem só no aparelho.
class SyncController extends ChangeNotifier {
  SyncController({
    required this._session,
    required this._database,
    this._service,
    this._onProfileChanged,
    Stream<bool>? connectivity,
    this.debounce = const Duration(seconds: 3),
  }) {
    if (!isEnabled) return;
    _session.addListener(_onSession);
    _pendingSubscription = _database.watchPendingCount().listen(_onPending);
    _connectivitySubscription = (connectivity ?? _deviceConnectivity()).listen((
      online,
    ) {
      if (online) unawaited(syncNow());
    });
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(syncNow()));
    _onSession();
  }

  final SessionController _session;
  final AppDatabase _database;
  final SyncService? _service;
  final Future<void> Function()? _onProfileChanged;

  /// Espera depois de uma gravação local, para juntar edições seguidas num
  /// envio só.
  final Duration debounce;

  StreamSubscription<int>? _pendingSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  AppLifecycleListener? _lifecycle;
  Timer? _debounceTimer;

  String? _userId;

  /// Muda a cada saída da conta: uma sincronização de uma sessão anterior
  /// para de gravar no aparelho.
  int _generation = 0;
  Future<bool>? _running;
  bool _again = false;

  SyncStatus _status = SyncStatus.idle;
  int _pendingCount = 0;
  DateTime? _lastSyncedAt;

  bool get isEnabled => _service != null;

  SyncStatus get status => _status;

  /// Registros ainda não enviados ao servidor.
  int get pendingCount => _pendingCount;

  DateTime? get lastSyncedAt => _lastSyncedAt;

  /// Sincroniza agora; se já houver uma em andamento, espera por ela.
  /// Devolve `true` se terminou sem erro (ou se a sincronização está
  /// desligada).
  Future<bool> syncNow() {
    if (!isEnabled) return Future.value(true);
    if (_userId == null) return Future.value(false);
    return _running ??= _run().whenComplete(() => _running = null);
  }

  /// Antes de sair: tenta enviar o que falta e devolve quantos registros
  /// ainda não chegaram ao servidor (e seriam perdidos no logout).
  Future<int> flushBeforeLogout() async {
    if (!isEnabled) return 0;
    await syncNow();
    return _database.pendingCount();
  }

  /// Para antes de apagar os dados do aparelho (logout, exclusão da conta):
  /// o que estiver em andamento não grava mais nada.
  void stop() {
    _generation++;
    _userId = null;
    _again = false;
    _debounceTimer?.cancel();
    _status = SyncStatus.idle;
    _lastSyncedAt = null;
    notifyListeners();
  }

  /// Volta a sincronizar depois de um [stop] que não terminou em saída
  /// (a exclusão da conta falhou, por exemplo).
  void resume() => _onSession();

  void _onSession() {
    final userId = _session.user?.id;
    if (userId == _userId) return;
    if (_userId != null) stop();
    _userId = userId;
    if (userId != null) unawaited(syncNow());
  }

  void _onPending(int count) {
    _pendingCount = count;
    notifyListeners();
    if (count == 0 || _userId == null) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      // Uma gravação feita durante a sincronização sobe logo em seguida.
      if (_running != null) {
        _again = true;
      } else {
        unawaited(syncNow());
      }
    });
  }

  Future<bool> _run() async {
    bool ok;
    do {
      _again = false;
      ok = await _syncOnce();
    } while (ok && _again);
    return ok;
  }

  Future<bool> _syncOnce() async {
    final userId = _userId;
    if (userId == null) return false;
    final generation = _generation;
    bool isActive() => generation == _generation;

    _status = SyncStatus.syncing;
    notifyListeners();
    try {
      final result = await _service!.sync(userId, isActive: isActive);
      if (!isActive()) return false;
      _status = SyncStatus.idle;
      _lastSyncedAt = DateTime.now();
      if (result.profileChanged) await _onProfileChanged?.call();
      return true;
    } on SyncOfflineFailure {
      if (isActive()) _status = SyncStatus.offline;
      return false;
    } catch (error) {
      debugPrint('Falha na sincronização: $error');
      if (isActive()) _status = SyncStatus.failed;
      return false;
    } finally {
      if (isActive()) notifyListeners();
    }
  }

  static Stream<bool> _deviceConnectivity() => Connectivity()
      .onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));

  @override
  void dispose() {
    _session.removeListener(_onSession);
    _pendingSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _lifecycle?.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
