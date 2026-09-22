import 'enums/activity_level.dart';
import 'enums/gender.dart';
import 'enums/goal_type.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.goal,
    required this.gender,
    required this.birthDate,
    required this.activityLevel,
    required this.height,
    required this.weight,
  });

  final String name;
  final GoalType goal;
  final Gender gender;
  final DateTime birthDate;
  final ActivityLevel activityLevel;
  final double height;
  final double weight;

  int get age => ageAt(DateTime.now());

  int ageAt(DateTime date) {
    var years = date.year - birthDate.year;
    final hadBirthday =
        date.month > birthDate.month ||
        (date.month == birthDate.month && date.day >= birthDate.day);
    if (!hadBirthday) years--;
    return years;
  }

  UserProfile copyWith({
    String? name,
    GoalType? goal,
    Gender? gender,
    DateTime? birthDate,
    ActivityLevel? activityLevel,
    double? heightCm,
    double? weightKg,
  }) {
    return UserProfile(
      name: name ?? this.name,
      goal: goal ?? this.goal,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      activityLevel: activityLevel ?? this.activityLevel,
      height: heightCm ?? height,
      weight: weightKg ?? weight,
    );
  }
}
