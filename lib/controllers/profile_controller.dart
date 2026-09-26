import 'package:flutter/foundation.dart';

import '../mocks/mock_user_profile.dart';
import '../models/nutrition_goal.dart';
import '../models/user_profile.dart';
import '../services/nutrition_calculator.dart';

/// Dono do perfil do usuário e das metas globais.
class ProfileController extends ChangeNotifier {
  ProfileController({this._calculator = const NutritionCalculator()}) {
    _load(mockUserProfile);
  }

  final NutritionCalculator _calculator;

  late UserProfile _profile;
  late NutritionGoal _goal;

  UserProfile get profile => _profile;
  NutritionGoal get goal => _goal;

  void _load(UserProfile profile) {
    _profile = profile;
    _goal = _calculator.calculateGoal(profile);
  }

  void completeOnboarding(UserProfile profile) {
    _load(profile);
    notifyListeners();
  }

  /// Mudanças de peso ou altura exigem confirmação e recálculo das metas.
  bool requiresRecalculation(UserProfile updated) =>
      updated.weight != _profile.weight || updated.height != _profile.height;

  void updateProfile(UserProfile updated, {bool recalculateGoal = false}) {
    _profile = updated;
    if (recalculateGoal) {
      _goal = _calculator.calculateGoal(updated);
    }
    notifyListeners();
  }

  void updateGoal(NutritionGoal goal) {
    _goal = goal;
    notifyListeners();
  }
}
