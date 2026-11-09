import 'package:flutter/foundation.dart';

import '../models/nutrition_goal.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../services/nutrition_calculator.dart';

/// Dono do perfil do usuário e das metas globais.
class ProfileController extends ChangeNotifier {
  ProfileController(
    this._repository, {
    this._calculator = const NutritionCalculator(),
  });

  final ProfileRepository _repository;
  final NutritionCalculator _calculator;

  late UserProfile _profile;
  late NutritionGoal _goal;

  UserProfile get profile => _profile;
  NutritionGoal get goal => _goal;

  /// Carrega o perfil salvo; `false` se não houver nenhum.
  Future<bool> load() async {
    final data = await _repository.load();
    if (data == null) return false;
    _profile = data.profile;
    _goal = data.goal;
    notifyListeners();
    return true;
  }

  Future<void> completeOnboarding(
    UserProfile profile, {
    required String userId,
  }) async {
    final goal = _calculator.calculateGoal(profile);
    await _repository.create(profile, goal, userId: userId);
    _profile = profile;
    _goal = goal;
    notifyListeners();
  }

  /// Peso, altura e idade entram na fórmula das metas.
  bool requiresRecalculation(UserProfile updated) =>
      updated.weight != _profile.weight ||
      updated.height != _profile.height ||
      updated.age != _profile.age;

  Future<void> updateProfile(
    UserProfile updated, {
    bool recalculateGoal = false,
  }) async {
    await _repository.updateProfile(updated);
    _profile = updated;
    if (recalculateGoal) {
      _goal = _calculator.calculateGoal(updated);
      await _repository.saveGoal(_goal);
    }
    notifyListeners();
  }

  /// Registra o peso de [day]. O peso atual passa a ser o da medição mais
  /// recente; com [recalculateGoal], as metas acompanham esse peso.
  Future<void> logWeight(
    DateTime day,
    double weightKg, {
    bool recalculateGoal = false,
  }) async {
    await _repository.saveWeight(day, weightKg);
    final data = await _repository.load();
    if (data != null) _profile = data.profile;
    if (recalculateGoal) {
      _goal = _calculator.calculateGoal(_profile);
      await _repository.saveGoal(_goal);
    }
    notifyListeners();
  }

  Future<void> updateGoal(NutritionGoal goal) async {
    await _repository.saveGoal(goal);
    _goal = goal;
    notifyListeners();
  }
}
