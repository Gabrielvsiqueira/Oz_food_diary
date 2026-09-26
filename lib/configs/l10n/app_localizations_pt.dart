// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Oz';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonNo => 'Não';

  @override
  String get commonYes => 'Sim';

  @override
  String get errorRequired => 'Campo obrigatório';

  @override
  String get errorInvalidNumber => 'Informe um número válido';

  @override
  String get errorMustBePositive => 'Informe um valor maior que zero';

  @override
  String get errorMustBeNonNegative => 'O valor não pode ser negativo';

  @override
  String errorOutOfRange(String min, String max) {
    return 'Informe um valor entre $min e $max';
  }

  @override
  String get errorInvalidEmail => 'Informe um e-mail válido';

  @override
  String get errorPasswordTooShort => 'A senha deve ter no mínimo 8 caracteres';

  @override
  String get errorPasswordMismatch => 'As senhas não conferem';

  @override
  String get errorInvalidDate => 'Informe uma data válida';

  @override
  String errorAgeOutOfRange(int min, int max) {
    return 'A idade deve estar entre $min e $max anos';
  }

  @override
  String errorCaloriesMismatch(int expected) {
    return 'As calorias não batem com os macros (≈ $expected kcal)';
  }

  @override
  String get goalLose => 'Perder peso';

  @override
  String get goalMaintain => 'Manter peso';

  @override
  String get goalGain => 'Ganhar peso';

  @override
  String get goalLoseTitle => 'Perder Peso';

  @override
  String get goalMaintainTitle => 'Manter Peso';

  @override
  String get goalGainTitle => 'Ganhar Peso';

  @override
  String get genderMale => 'Masculino';

  @override
  String get genderFemale => 'Feminino';

  @override
  String get activitySedentary => 'Sedentário';

  @override
  String get activitySedentaryDescription => 'Não me exercito';

  @override
  String get activityLight => 'Leve';

  @override
  String get activityLightDescription => '1 a 2 vezes por semana';

  @override
  String get activityModerate => 'Moderado';

  @override
  String get activityModerateDescription => '3 a 5 vezes por semana';

  @override
  String get activityHeavy => 'Pesado';

  @override
  String get activityHeavyDescription => '6 a 7 vezes por semana';

  @override
  String get activityAthlete => 'Atleta';

  @override
  String get activityAthleteDescription => '2 vezes ao dia';

  @override
  String get mealTypeBreakfast => 'Café da manhã';

  @override
  String get mealTypeLunch => 'Almoço';

  @override
  String get mealTypeDinner => 'Jantar';

  @override
  String get mealTypeSnack => 'Lanche';

  @override
  String get calories => 'Calorias';

  @override
  String get carbs => 'Carboidratos';

  @override
  String get protein => 'Proteínas';

  @override
  String get fat => 'Gorduras';

  @override
  String get kcal => 'Kcal';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitGrams => 'g';

  @override
  String get unitCm => 'cm';

  @override
  String get unitKg => 'kg';

  @override
  String get onboardingGoalTitle => 'Qual é seu objetivo?';

  @override
  String get onboardingGoalSubtitle =>
      'O que você pretende alcançar com a dieta?';

  @override
  String get onboardingGenderTitle => 'Qual é seu gênero';

  @override
  String get onboardingGenderSubtitle =>
      'Seu gênero influencia no tipo da dieta';

  @override
  String get onboardingBirthdateTitle => 'Que dia você nasceu?';

  @override
  String get onboardingBirthdateSubtitle =>
      'Cada faixa etária responde de forma única';

  @override
  String get onboardingBirthdateHint => 'DD/MM/AAAA';

  @override
  String get onboardingHeightTitle => 'Qual é sua altura?';

  @override
  String get onboardingWeightTitle => 'Qual é seu peso?';

  @override
  String get onboardingEstimateSubtitle => 'Você pode inserir uma estimativa';

  @override
  String get onboardingActivityTitle => 'Qual seu nível de atividade?';

  @override
  String get onboardingAccountTitle => 'Crie sua conta';

  @override
  String get onboardingAccountSubtitle => 'Para poder visualizar seu progresso';

  @override
  String get onboardingCreateAccount => 'Criar conta';

  @override
  String get onboardingLoadingTitle => 'Estamos personalizando o app para você';

  @override
  String get onboardingResultTitlePrefix => 'Seu plano de dieta para';

  @override
  String get onboardingResultTitleSuffix => 'está pronto!';

  @override
  String get onboardingResultDescription =>
      'Essa é a recomendação diária recomendada para seu plano. Fique tranquilo, você poderá editar depois caso deseje.';

  @override
  String get onboardingResultStart => 'Começar meu plano';

  @override
  String get nameLabel => 'Nome';

  @override
  String get nameHint => 'João Silva';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'joaosilva@gmail.com';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get passwordHint => 'Mínimo 8 caracteres';

  @override
  String get confirmPasswordLabel => 'Confirmar Senha';

  @override
  String get birthDateLabel => 'Data de Nascimento';

  @override
  String get heightLabel => 'Altura';

  @override
  String get weightLabel => 'Peso';

  @override
  String get sexLabel => 'Sexo';

  @override
  String get tabHome => 'Início';

  @override
  String get tabGoals => 'Metas';

  @override
  String get tabProfile => 'Perfil';

  @override
  String get homeGreeting => 'Olá, 👋';

  @override
  String get homeToday => 'Hoje';

  @override
  String get homeYesterday => 'Ontem';

  @override
  String get homeMealsSection => 'REFEIÇÕES';

  @override
  String get homeNoMealsTitle => 'Nenhuma refeição registrada';

  @override
  String get homeNoMealsToday =>
      'Toque no + para registrar sua primeira refeição do dia';

  @override
  String get homeNoMealsPast => 'Nada foi registrado neste dia';

  @override
  String get homePreviousDay => 'Dia anterior';

  @override
  String get homeNextDay => 'Próximo dia';

  @override
  String get homeAddMeal => 'Nova refeição';

  @override
  String get mealNewTitle => 'Nova refeição';

  @override
  String get mealEditTitle => 'Editar refeição';

  @override
  String get mealTypeLabel => 'Tipo';

  @override
  String get mealDescriptionLabel => 'Descrição';

  @override
  String get mealDescriptionHint => 'Pão, manteiga e café';

  @override
  String mealMacrosEstimate(int value) {
    return 'Pelos macros: ≈ $value kcal';
  }

  @override
  String get mealDeleteTitle => 'Excluir refeição?';

  @override
  String get mealDeleteMessage => 'Essa ação não pode ser desfeita.';

  @override
  String get mealSaved => 'Refeição salva';

  @override
  String get mealDeleted => 'Refeição excluída';

  @override
  String get goalsTitle => 'Suas Metas';

  @override
  String get goalsSaved => 'Metas atualizadas';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileSaved => 'Perfil atualizado';

  @override
  String get profileRecalculateTitle => 'Tem certeza?';

  @override
  String get profileRecalculateMessage =>
      'Você alterou seu peso ou sua altura. Suas metas de calorias e macros serão recalculadas.';

  @override
  String get profileGoalsRecalculated =>
      'Perfil atualizado e metas recalculadas';

  @override
  String get profileLogout => 'Sair';

  @override
  String get profileLogoutTitle => 'Sair do app?';

  @override
  String get profileLogoutMessage =>
      'Você voltará para a tela inicial. Seus dados continuam salvos enquanto o app estiver aberto.';

  @override
  String get welcomeTitle => 'Controle sua dieta de forma simples';

  @override
  String get welcomeCreateAccount => 'Criar conta';

  @override
  String get welcomeGoogle => 'Continuar com Google';

  @override
  String get commonComingSoon => 'Em breve';

  @override
  String get welcomeHaveAccount => 'Já tem conta?';

  @override
  String get welcomeLogin => 'Acessar conta';

  @override
  String get loginTitle => 'Entre em sua conta';

  @override
  String get loginButton => 'Entrar';
}
