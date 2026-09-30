import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Oz'**
  String get appTitle;

  /// No description provided for @commonSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get commonDelete;

  /// No description provided for @commonConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonNo.
  ///
  /// In pt, this message translates to:
  /// **'Não'**
  String get commonNo;

  /// No description provided for @commonYes.
  ///
  /// In pt, this message translates to:
  /// **'Sim'**
  String get commonYes;

  /// No description provided for @errorRequired.
  ///
  /// In pt, this message translates to:
  /// **'Campo obrigatório'**
  String get errorRequired;

  /// No description provided for @errorInvalidNumber.
  ///
  /// In pt, this message translates to:
  /// **'Informe um número válido'**
  String get errorInvalidNumber;

  /// No description provided for @errorMustBePositive.
  ///
  /// In pt, this message translates to:
  /// **'Informe um valor maior que zero'**
  String get errorMustBePositive;

  /// No description provided for @errorMustBeNonNegative.
  ///
  /// In pt, this message translates to:
  /// **'O valor não pode ser negativo'**
  String get errorMustBeNonNegative;

  /// No description provided for @errorOutOfRange.
  ///
  /// In pt, this message translates to:
  /// **'Informe um valor entre {min} e {max}'**
  String errorOutOfRange(String min, String max);

  /// No description provided for @errorInvalidEmail.
  ///
  /// In pt, this message translates to:
  /// **'Informe um e-mail válido'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter no mínimo 8 caracteres'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não conferem'**
  String get errorPasswordMismatch;

  /// No description provided for @errorInvalidDate.
  ///
  /// In pt, this message translates to:
  /// **'Informe uma data válida'**
  String get errorInvalidDate;

  /// No description provided for @errorAgeOutOfRange.
  ///
  /// In pt, this message translates to:
  /// **'A idade deve estar entre {min} e {max} anos'**
  String errorAgeOutOfRange(int min, int max);

  /// No description provided for @errorMacrosEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Informe ao menos um macro maior que zero'**
  String get errorMacrosEmpty;

  /// No description provided for @goalLose.
  ///
  /// In pt, this message translates to:
  /// **'Perder peso'**
  String get goalLose;

  /// No description provided for @goalMaintain.
  ///
  /// In pt, this message translates to:
  /// **'Manter peso'**
  String get goalMaintain;

  /// No description provided for @goalGain.
  ///
  /// In pt, this message translates to:
  /// **'Ganhar peso'**
  String get goalGain;

  /// No description provided for @goalLoseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perder Peso'**
  String get goalLoseTitle;

  /// No description provided for @goalMaintainTitle.
  ///
  /// In pt, this message translates to:
  /// **'Manter Peso'**
  String get goalMaintainTitle;

  /// No description provided for @goalGainTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ganhar Peso'**
  String get goalGainTitle;

  /// No description provided for @genderMale.
  ///
  /// In pt, this message translates to:
  /// **'Masculino'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In pt, this message translates to:
  /// **'Feminino'**
  String get genderFemale;

  /// No description provided for @activitySedentary.
  ///
  /// In pt, this message translates to:
  /// **'Sedentário'**
  String get activitySedentary;

  /// No description provided for @activitySedentaryDescription.
  ///
  /// In pt, this message translates to:
  /// **'Não me exercito'**
  String get activitySedentaryDescription;

  /// No description provided for @activityLight.
  ///
  /// In pt, this message translates to:
  /// **'Leve'**
  String get activityLight;

  /// No description provided for @activityLightDescription.
  ///
  /// In pt, this message translates to:
  /// **'1 a 2 vezes por semana'**
  String get activityLightDescription;

  /// No description provided for @activityModerate.
  ///
  /// In pt, this message translates to:
  /// **'Moderado'**
  String get activityModerate;

  /// No description provided for @activityModerateDescription.
  ///
  /// In pt, this message translates to:
  /// **'3 a 5 vezes por semana'**
  String get activityModerateDescription;

  /// No description provided for @activityHeavy.
  ///
  /// In pt, this message translates to:
  /// **'Pesado'**
  String get activityHeavy;

  /// No description provided for @activityHeavyDescription.
  ///
  /// In pt, this message translates to:
  /// **'6 a 7 vezes por semana'**
  String get activityHeavyDescription;

  /// No description provided for @activityAthlete.
  ///
  /// In pt, this message translates to:
  /// **'Atleta'**
  String get activityAthlete;

  /// No description provided for @activityAthleteDescription.
  ///
  /// In pt, this message translates to:
  /// **'2 vezes ao dia'**
  String get activityAthleteDescription;

  /// No description provided for @mealTypeBreakfast.
  ///
  /// In pt, this message translates to:
  /// **'Café da manhã'**
  String get mealTypeBreakfast;

  /// No description provided for @mealTypeLunch.
  ///
  /// In pt, this message translates to:
  /// **'Almoço'**
  String get mealTypeLunch;

  /// No description provided for @mealTypeDinner.
  ///
  /// In pt, this message translates to:
  /// **'Jantar'**
  String get mealTypeDinner;

  /// No description provided for @mealTypeSnack.
  ///
  /// In pt, this message translates to:
  /// **'Lanche'**
  String get mealTypeSnack;

  /// No description provided for @calories.
  ///
  /// In pt, this message translates to:
  /// **'Calorias'**
  String get calories;

  /// No description provided for @carbs.
  ///
  /// In pt, this message translates to:
  /// **'Carboidratos'**
  String get carbs;

  /// No description provided for @protein.
  ///
  /// In pt, this message translates to:
  /// **'Proteínas'**
  String get protein;

  /// No description provided for @fat.
  ///
  /// In pt, this message translates to:
  /// **'Gorduras'**
  String get fat;

  /// No description provided for @kcal.
  ///
  /// In pt, this message translates to:
  /// **'Kcal'**
  String get kcal;

  /// No description provided for @unitKcal.
  ///
  /// In pt, this message translates to:
  /// **'kcal'**
  String get unitKcal;

  /// No description provided for @unitGrams.
  ///
  /// In pt, this message translates to:
  /// **'g'**
  String get unitGrams;

  /// No description provided for @unitCm.
  ///
  /// In pt, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// No description provided for @unitKg.
  ///
  /// In pt, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual é seu objetivo?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'O que você pretende alcançar com a dieta?'**
  String get onboardingGoalSubtitle;

  /// No description provided for @onboardingGenderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual é seu gênero'**
  String get onboardingGenderTitle;

  /// No description provided for @onboardingGenderSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu gênero influencia no tipo da dieta'**
  String get onboardingGenderSubtitle;

  /// No description provided for @onboardingBirthdateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Que dia você nasceu?'**
  String get onboardingBirthdateTitle;

  /// No description provided for @onboardingBirthdateSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Cada faixa etária responde de forma única'**
  String get onboardingBirthdateSubtitle;

  /// No description provided for @onboardingBirthdateHint.
  ///
  /// In pt, this message translates to:
  /// **'DD/MM/AAAA'**
  String get onboardingBirthdateHint;

  /// No description provided for @onboardingHeightTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual é sua altura?'**
  String get onboardingHeightTitle;

  /// No description provided for @onboardingWeightTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual é seu peso?'**
  String get onboardingWeightTitle;

  /// No description provided for @onboardingEstimateSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Você pode inserir uma estimativa'**
  String get onboardingEstimateSubtitle;

  /// No description provided for @onboardingActivityTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual seu nível de atividade?'**
  String get onboardingActivityTitle;

  /// No description provided for @onboardingAccountTitle.
  ///
  /// In pt, this message translates to:
  /// **'Crie sua conta'**
  String get onboardingAccountTitle;

  /// No description provided for @onboardingAccountSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Para poder visualizar seu progresso'**
  String get onboardingAccountSubtitle;

  /// No description provided for @onboardingCreateAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get onboardingCreateAccount;

  /// No description provided for @onboardingLoadingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Estamos personalizando o app para você'**
  String get onboardingLoadingTitle;

  /// No description provided for @onboardingResultTitlePrefix.
  ///
  /// In pt, this message translates to:
  /// **'Seu plano de dieta para'**
  String get onboardingResultTitlePrefix;

  /// No description provided for @onboardingResultTitleSuffix.
  ///
  /// In pt, this message translates to:
  /// **'está pronto!'**
  String get onboardingResultTitleSuffix;

  /// No description provided for @onboardingResultDescription.
  ///
  /// In pt, this message translates to:
  /// **'Essa é a recomendação diária recomendada para seu plano. Fique tranquilo, você poderá editar depois caso deseje.'**
  String get onboardingResultDescription;

  /// No description provided for @onboardingResultStart.
  ///
  /// In pt, this message translates to:
  /// **'Começar meu plano'**
  String get onboardingResultStart;

  /// No description provided for @nameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In pt, this message translates to:
  /// **'João Silva'**
  String get nameHint;

  /// No description provided for @emailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In pt, this message translates to:
  /// **'joaosilva@gmail.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get passwordHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar Senha'**
  String get confirmPasswordLabel;

  /// No description provided for @birthDateLabel.
  ///
  /// In pt, this message translates to:
  /// **'Data de Nascimento'**
  String get birthDateLabel;

  /// No description provided for @heightLabel.
  ///
  /// In pt, this message translates to:
  /// **'Altura'**
  String get heightLabel;

  /// No description provided for @weightLabel.
  ///
  /// In pt, this message translates to:
  /// **'Peso'**
  String get weightLabel;

  /// No description provided for @sexLabel.
  ///
  /// In pt, this message translates to:
  /// **'Sexo'**
  String get sexLabel;

  /// No description provided for @tabHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get tabHome;

  /// No description provided for @tabGoals.
  ///
  /// In pt, this message translates to:
  /// **'Metas'**
  String get tabGoals;

  /// No description provided for @tabProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get tabProfile;

  /// No description provided for @homeGreeting.
  ///
  /// In pt, this message translates to:
  /// **'Olá, 👋'**
  String get homeGreeting;

  /// No description provided for @homeToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get homeToday;

  /// No description provided for @homeYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get homeYesterday;

  /// No description provided for @homeMealsSection.
  ///
  /// In pt, this message translates to:
  /// **'REFEIÇÕES'**
  String get homeMealsSection;

  /// No description provided for @homeNoMealsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma refeição registrada'**
  String get homeNoMealsTitle;

  /// No description provided for @homeNoMealsToday.
  ///
  /// In pt, this message translates to:
  /// **'Toque no + para registrar sua primeira refeição do dia'**
  String get homeNoMealsToday;

  /// No description provided for @homeNoMealsPast.
  ///
  /// In pt, this message translates to:
  /// **'Nada foi registrado neste dia'**
  String get homeNoMealsPast;

  /// No description provided for @homePreviousDay.
  ///
  /// In pt, this message translates to:
  /// **'Dia anterior'**
  String get homePreviousDay;

  /// No description provided for @homeNextDay.
  ///
  /// In pt, this message translates to:
  /// **'Próximo dia'**
  String get homeNextDay;

  /// No description provided for @homeAddMeal.
  ///
  /// In pt, this message translates to:
  /// **'Nova refeição'**
  String get homeAddMeal;

  /// No description provided for @mealNewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova refeição'**
  String get mealNewTitle;

  /// No description provided for @mealEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar refeição'**
  String get mealEditTitle;

  /// No description provided for @mealTypeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tipo'**
  String get mealTypeLabel;

  /// No description provided for @mealDescriptionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get mealDescriptionLabel;

  /// No description provided for @mealDescriptionHint.
  ///
  /// In pt, this message translates to:
  /// **'Pão, manteiga e café'**
  String get mealDescriptionHint;

  /// No description provided for @mealCaloriesAuto.
  ///
  /// In pt, this message translates to:
  /// **'Calculadas automaticamente a partir dos macros'**
  String get mealCaloriesAuto;

  /// No description provided for @mealDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir refeição?'**
  String get mealDeleteTitle;

  /// No description provided for @mealDeleteMessage.
  ///
  /// In pt, this message translates to:
  /// **'Essa ação não pode ser desfeita.'**
  String get mealDeleteMessage;

  /// No description provided for @mealSaved.
  ///
  /// In pt, this message translates to:
  /// **'Refeição salva'**
  String get mealSaved;

  /// No description provided for @mealDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Refeição excluída'**
  String get mealDeleted;

  /// No description provided for @goalsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Suas Metas'**
  String get goalsTitle;

  /// No description provided for @goalsSaved.
  ///
  /// In pt, this message translates to:
  /// **'Metas atualizadas'**
  String get goalsSaved;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @profileSaved.
  ///
  /// In pt, this message translates to:
  /// **'Perfil atualizado'**
  String get profileSaved;

  /// No description provided for @profileRecalculateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza?'**
  String get profileRecalculateTitle;

  /// No description provided for @profileRecalculateMessage.
  ///
  /// In pt, this message translates to:
  /// **'Você alterou seu peso ou sua altura. Suas metas de calorias e macros serão recalculadas.'**
  String get profileRecalculateMessage;

  /// No description provided for @profileGoalsRecalculated.
  ///
  /// In pt, this message translates to:
  /// **'Perfil atualizado e metas recalculadas'**
  String get profileGoalsRecalculated;

  /// No description provided for @profileLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get profileLogout;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair do app?'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutMessage.
  ///
  /// In pt, this message translates to:
  /// **'Você voltará para a tela inicial. Seus dados continuam salvos enquanto o app estiver aberto.'**
  String get profileLogoutMessage;

  /// No description provided for @welcomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Controle sua dieta de forma simples'**
  String get welcomeTitle;

  /// No description provided for @welcomeCreateAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get welcomeCreateAccount;

  /// No description provided for @welcomeGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Google'**
  String get welcomeGoogle;

  /// No description provided for @commonComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Em breve'**
  String get commonComingSoon;

  /// No description provided for @welcomeHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tem conta?'**
  String get welcomeHaveAccount;

  /// No description provided for @welcomeLogin.
  ///
  /// In pt, this message translates to:
  /// **'Acessar conta'**
  String get welcomeLogin;

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre em sua conta'**
  String get loginTitle;

  /// No description provided for @loginButton.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
