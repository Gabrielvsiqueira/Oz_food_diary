import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/enums/weight_period.dart';
import '../models/weight_entry.dart';
import '../repositories/profile_repository.dart';
import '../services/date_utils.dart' as date_utils;

/// Histórico de peso para o gráfico do Perfil, filtrado pelo período
/// escolhido. Atualiza sozinho quando um peso novo é salvo ou sincronizado.
class WeightHistoryController extends ChangeNotifier {
  WeightHistoryController(
    ProfileRepository repository, {
    this._today = date_utils.today,
  }) {
    _subscription = repository.watchWeightHistory().listen((entries) {
      _entries = entries;
      _loaded = true;
      notifyListeners();
    });
  }

  final DateTime Function() _today;
  late final StreamSubscription<List<WeightEntry>> _subscription;

  List<WeightEntry> _entries = const [];
  bool _loaded = false;
  WeightPeriod _period = WeightPeriod.days30;

  bool get isLoaded => _loaded;

  /// Medição mais recente, em qualquer período.
  WeightEntry? get latest => _entries.isEmpty ? null : _entries.last;

  /// Uma medição em [day] passa a ser o peso atual (não é anterior à última).
  bool becomesCurrent(DateTime day) {
    final latest = this.latest;
    return latest == null || !day.isBefore(latest.date);
  }

  WeightPeriod get period => _period;

  /// Medições dentro do período, da mais antiga para a mais recente.
  List<WeightEntry> get visibleEntries {
    final days = _period.days;
    if (days == null) return _entries;
    final from = _today().subtract(Duration(days: days - 1));
    return [
      for (final entry in _entries)
        if (!entry.date.isBefore(from)) entry,
    ];
  }

  /// Diferença entre a última e a primeira medição do período; `null` com
  /// menos de duas medições.
  double? get change {
    final visible = visibleEntries;
    if (visible.length < 2) return null;
    return visible.last.weightKg - visible.first.weightKg;
  }

  void selectPeriod(WeightPeriod period) {
    if (period == _period) return;
    _period = period;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
