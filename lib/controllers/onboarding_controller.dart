import 'package:flutter/foundation.dart';

import '../models/enums/activity_level.dart';
import '../models/enums/gender.dart';
import '../models/enums/goal_type.dart';
import '../models/user_profile.dart';

/// Guarda as respostas do onboarding enquanto o usuário avança pelas telas.
/// E-mail e senha da tela "Crie sua conta" são só validados, nunca guardados.
class OnboardingController extends ChangeNotifier {
  GoalType? _goal;
  Gender? _gender;
  DateTime? _birthDate;
  double? _height;
  double? _weight;
  ActivityLevel? _activityLevel;
  String? _name;

  GoalType? get goal => _goal;
  Gender? get gender => _gender;
  DateTime? get birthDate => _birthDate;
  double? get height => _height;
  double? get weight => _weight;
  ActivityLevel? get activityLevel => _activityLevel;
  String? get name => _name;

  static const totalSteps = 7;

  void selectGoal(GoalType goal) {
    _goal = goal;
    notifyListeners();
  }

  void selectGender(Gender gender) {
    _gender = gender;
    notifyListeners();
  }

  void setBirthDate(DateTime date) {
    _birthDate = date;
    notifyListeners();
  }

  void setHeight(double heightCm) {
    _height = height;
    notifyListeners();
  }

  void setWeight(double weightKg) {
    _weight = weight;
    notifyListeners();
  }

  void selectActivityLevel(ActivityLevel level) {
    _activityLevel = level;
    notifyListeners();
  }

  void setName(String name) {
    _name = name.trim();
    notifyListeners();
  }

  bool get isComplete =>
      _goal != null &&
      _gender != null &&
      _birthDate != null &&
      _height != null &&
      _weight != null &&
      _activityLevel != null &&
      (_name?.isNotEmpty ?? false);

  UserProfile buildProfile() {
    if (!isComplete) {
      throw StateError('Onboarding incompleto');
    }
    return UserProfile(
      name: _name!,
      goal: _goal!,
      gender: _gender!,
      birthDate: _birthDate!,
      activityLevel: _activityLevel!,
      height: _height!,
      weight: _weight!,
    );
  }

  void reset() {
    _goal = null;
    _gender = null;
    _birthDate = null;
    _height = null;
    _weight = null;
    _activityLevel = null;
    _name = null;
    notifyListeners();
  }
}
