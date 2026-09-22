import '../models/enums/activity_level.dart';
import '../models/enums/gender.dart';
import '../models/enums/goal_type.dart';
import '../models/user_profile.dart';

final mockUserProfile = UserProfile(
  name: 'Gabriel Siqueira',
  goal: GoalType.lose,
  gender: Gender.male,
  birthDate: DateTime(2001, 2, 25),
  activityLevel: ActivityLevel.moderate,
  height: 181,
  weight: 95,
);
