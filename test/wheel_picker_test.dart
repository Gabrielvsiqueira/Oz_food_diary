import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oz_contador_de_calorias/controllers/onboarding_controller.dart';
import 'package:oz_contador_de_calorias/controllers/profile_controller.dart';
import 'package:oz_contador_de_calorias/mocks/mock_user_profile.dart';
import 'package:oz_contador_de_calorias/models/nutrition_goal.dart';
import 'package:oz_contador_de_calorias/repositories/profile_repository.dart';
import 'package:oz_contador_de_calorias/services/date_utils.dart';
import 'package:oz_contador_de_calorias/widgets/inputs/wheel_picker.dart';

class _Profiles implements ProfileRepository {
  @override
  Future<ProfileData?> load() async => (
    profile: mockUserProfile,
    goal: const NutritionGoal(
      caloriesTarget: 2000,
      carbsTargetG: 200,
      proteinTargetG: 150,
      fatTargetG: 60,
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('idade estimada', () {
    test('a data estimada tem exatamente a idade informada', () {
      final now = DateTime(2026, 10, 28);
      final birth = birthDateForAge(25, now: now);
      expect(birth, DateTime(2001, 10, 28));
      expect(ageOn(birth, now), 25);
      expect(ageOn(birth, DateTime(2027, 10, 27)), 25);
      expect(ageOn(birth, DateTime(2027, 10, 28)), 26, reason: 'sobe sozinha');
    });

    test('em 29 de fevereiro, não cai em março', () {
      final now = DateTime(2028, 2, 29);
      final birth = birthDateForAge(25, now: now);
      expect(birth, DateTime(2003, 2, 28));
      expect(ageOn(birth, now), 25);
    });

    test('o onboarding guarda a idade como data estimada', () {
      final controller = OnboardingController()..setAge(31);
      expect(controller.age, 31);
    });

    test('mudar a idade no perfil pede recálculo das metas', () async {
      final controller = ProfileController(_Profiles());
      await controller.load();
      final profile = controller.profile;

      expect(controller.requiresRecalculation(profile), isFalse);
      expect(
        controller.requiresRecalculation(
          profile.copyWith(birthDate: birthDateForAge(profile.age + 1)),
        ),
        isTrue,
      );
    });
  });

  group('roletas', () {
    Future<void> pump(WidgetTester tester, Widget picker) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: picker)),
      ),
    );

    /// Arrasta a roleta [index] por [items] posições (positivo = valores
    /// maiores).
    Future<void> spin(WidgetTester tester, int items, {int index = 0}) async {
      await tester.drag(
        find.byType(CupertinoPicker).at(index),
        Offset(0, -48.0 * items),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a roleta de números começa no valor e informa a escolha', (
      tester,
    ) async {
      int? chosen;
      await pump(
        tester,
        IntWheelPicker(
          min: 100,
          max: 250,
          value: 170,
          unit: 'cm',
          onChanged: (v) => chosen = v,
        ),
      );
      expect(find.text('170'), findsOneWidget);
      expect(find.text('cm'), findsOneWidget);

      await spin(tester, 3);
      expect(chosen, 173);
    });

    testWidgets('não passa dos limites', (tester) async {
      int? chosen;
      await pump(
        tester,
        IntWheelPicker(
          min: 13,
          max: 100,
          value: 98,
          unit: 'anos',
          onChanged: (v) => chosen = v,
        ),
      );
      await spin(tester, 10);
      expect(chosen, 100);
    });

    testWidgets('o peso junta os kg e a casa decimal', (tester) async {
      var weight = 72.5;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => WeightWheelPicker(
                value: weight,
                onChanged: (v) => setState(() => weight = v),
              ),
            ),
          ),
        ),
      );
      expect(find.text('72'), findsOneWidget);
      expect(find.text(',5'), findsOneWidget);

      await spin(tester, 2, index: 1);
      expect(weight, 72.7);
      await spin(tester, -1);
      expect(weight, 71.7);
    });
  });
}
