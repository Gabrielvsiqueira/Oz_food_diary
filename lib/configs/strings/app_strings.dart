abstract final class AppStrings {
  static const appTitle = 'Oz';

  static const commonSave = 'Salvar';
  static const commonCancel = 'Cancelar';
  static const commonDelete = 'Excluir';
  static const commonConfirm = 'Confirmar';
  static const commonNo = 'Não';
  static const commonYes = 'Sim';
  static const commonRetry = 'Tentar novamente';

  static const errorRequired = 'Campo obrigatório';
  static const errorInvalidNumber = 'Informe um número válido';
  static const errorMustBePositive = 'Informe um valor maior que zero';
  static const errorMustBeNonNegative = 'O valor não pode ser negativo';
  static String errorOutOfRange(String min, String max) =>
      'Informe um valor entre $min e $max';
  static const errorInvalidEmail = 'Informe um e-mail válido';
  static const errorPasswordTooShort =
      'A senha deve ter no mínimo 8 caracteres';
  static const errorPasswordMismatch = 'As senhas não conferem';
  static const errorInvalidDate = 'Informe uma data válida';
  static String errorAgeOutOfRange(int min, int max) =>
      'A idade deve estar entre $min e $max anos';
  static const errorEmptyMeal = 'Adicione ao menos um alimento';
  static String errorFoodQuantityTooLarge(int max) =>
      'Máximo de $max g por alimento';

  static const goalLose = 'Perder peso';
  static const goalMaintain = 'Manter peso';
  static const goalGain = 'Ganhar peso';
  static const goalLoseTitle = 'Perder Peso';
  static const goalMaintainTitle = 'Manter Peso';
  static const goalGainTitle = 'Ganhar Peso';

  static const genderMale = 'Masculino';
  static const genderFemale = 'Feminino';

  static const activitySedentary = 'Sedentário';
  static const activitySedentaryDescription = 'Não me exercito';
  static const activityLight = 'Leve';
  static const activityLightDescription = '1 a 2 vezes por semana';
  static const activityModerate = 'Moderado';
  static const activityModerateDescription = '3 a 5 vezes por semana';
  static const activityHeavy = 'Pesado';
  static const activityHeavyDescription = '6 a 7 vezes por semana';
  static const activityAthlete = 'Atleta';
  static const activityAthleteDescription = '2 vezes ao dia';

  static const mealTypeBreakfast = 'Café da manhã';
  static const mealTypeLunch = 'Almoço';
  static const mealTypeDinner = 'Jantar';
  static const mealTypeSnack = 'Lanche';

  static const calories = 'Calorias';

  static const carbs = 'Carboidratos';

  static const protein = 'Proteínas';

  static const fat = 'Gorduras';

  static const kcal = 'Kcal';

  static const unitKcal = 'kcal';
  static const unitGrams = 'g';
  static const unitCm = 'cm';
  static const unitKg = 'kg';

  static const onboardingGoalTitle = 'Qual é seu objetivo?';
  static const onboardingGoalSubtitle =
      'O que você pretende alcançar com a dieta?';
  static const onboardingGenderTitle = 'Qual é seu gênero';
  static const onboardingGenderSubtitle =
      'Seu gênero influencia no tipo da dieta';
  static const onboardingBirthdateTitle = 'Que dia você nasceu?';
  static const onboardingBirthdateSubtitle =
      'Cada faixa etária responde de forma única';
  static const onboardingBirthdateHint = 'DD/MM/AAAA';
  static const onboardingHeightTitle = 'Qual é sua altura?';
  static const onboardingWeightTitle = 'Qual é seu peso?';
  static const onboardingEstimateSubtitle = 'Você pode inserir uma estimativa';
  static const onboardingActivityTitle = 'Qual seu nível de atividade?';
  static const onboardingAccountTitle = 'Crie sua conta';
  static const onboardingAccountSubtitle =
      'Para poder visualizar seu progresso';
  static const onboardingCreateAccount = 'Criar conta';
  static const onboardingLoadingTitle =
      'Estamos personalizando o app para você';
  static const onboardingResultTitlePrefix = 'Seu plano de dieta para';
  static const onboardingResultTitleSuffix = 'está pronto!';
  static const onboardingResultDescription =
      'Essa é a recomendação diária recomendada para seu plano. Fique tranquilo, você poderá editar depois caso deseje.';
  static const onboardingResultStart = 'Começar meu plano';

  static const nameLabel = 'Nome';
  static const nameHint = 'João Silva';

  static const emailLabel = 'E-mail';
  static const emailHint = 'joaosilva@gmail.com';

  static const passwordLabel = 'Senha';
  static const passwordHint = 'Mínimo 8 caracteres';

  static const confirmPasswordLabel = 'Confirmar Senha';

  static const birthDateLabel = 'Data de Nascimento';

  static const heightLabel = 'Altura';

  static const weightLabel = 'Peso';

  static const sexLabel = 'Sexo';

  static const tabHome = 'Início';
  static const tabGoals = 'Metas';
  static const tabProfile = 'Perfil';

  static const homeGreeting = 'Olá, 👋';
  static const homeToday = 'Hoje';
  static const homeYesterday = 'Ontem';
  static const homeMealsSection = 'REFEIÇÕES';
  static const homeNoMealsTitle = 'Nenhuma refeição registrada';
  static const homeNoMealsToday =
      'Toque no + para registrar sua primeira refeição do dia';
  static const homeNoMealsPast = 'Nada foi registrado neste dia';
  static const homePreviousDay = 'Dia anterior';
  static const homeNextDay = 'Próximo dia';
  static const homeAddMeal = 'Nova refeição';

  static const mealNewTitle = 'Nova refeição';
  static const mealEditTitle = 'Editar refeição';
  static const mealTypeLabel = 'Tipo';
  static const mealFoodsLabel = 'Alimentos';
  static const mealAddFood = 'Adicionar alimento';
  static const mealNoFoods = 'Nenhum alimento adicionado ainda';
  static const mealRemoveFood = 'Remover alimento';
  static const mealTotalLabel = 'Total da refeição';

  static const foodSearchTitle = 'Buscar alimento';
  static const foodSearchHint = 'Ex.: arroz, frango, banana';
  static String foodSearchNoResults(String query) =>
      'Nenhum alimento encontrado para "$query"';
  static const foodSearchError = 'Não foi possível carregar os alimentos';
  static String foodPer100g(String kcal) => '$kcal kcal a cada 100 g';
  static const foodQuantityLabel = 'Quantidade';
  static const foodPortionLabel = 'Medida';
  static const foodAdd = 'Adicionar';
  static const foodUpdate = 'Atualizar';

  static String portionGram(num count) => count == 1 ? 'grama' : 'gramas';
  static String portionUnit(num count) => count == 1 ? 'unidade' : 'unidades';
  static String portionSlice(num count) => count == 1 ? 'fatia' : 'fatias';
  static String portionTablespoon(num count) =>
      count == 1 ? 'colher de sopa' : 'colheres de sopa';
  static String portionTeaspoon(num count) =>
      count == 1 ? 'colher de chá' : 'colheres de chá';
  static String portionCup(num count) => count == 1 ? 'xícara' : 'xícaras';
  static String portionLadle(num count) => count == 1 ? 'concha' : 'conchas';

  static const mealDeleteTitle = 'Excluir refeição?';
  static const mealDeleteMessage = 'Essa ação não pode ser desfeita.';
  static const mealSaved = 'Refeição salva';
  static const mealDeleted = 'Refeição excluída';

  static const goalsTitle = 'Suas Metas';
  static const goalsSaved = 'Metas atualizadas';

  static const profileTitle = 'Perfil';
  static const profileSaved = 'Perfil atualizado';
  static const profileRecalculateTitle = 'Tem certeza?';
  static const profileRecalculateMessage =
      'Você alterou seu peso ou sua altura. Suas metas de calorias e macros serão recalculadas.';
  static const profileGoalsRecalculated =
      'Perfil atualizado e metas recalculadas';
  static const profileLogout = 'Sair';
  static const profileLogoutTitle = 'Sair do app?';
  static const profileLogoutMessage =
      'Você voltará para a tela inicial. Seus dados continuam salvos enquanto o app estiver aberto.';

  static const welcomeTitle = 'Controle sua dieta de forma simples';
  static const welcomeCreateAccount = 'Criar conta';
  static const welcomeGoogle = 'Continuar com Google';

  static const commonComingSoon = 'Em breve';

  static const welcomeHaveAccount = 'Já tem conta?';
  static const welcomeLogin = 'Acessar conta';

  static const loginTitle = 'Entre em sua conta';
  static const loginButton = 'Entrar';
}
