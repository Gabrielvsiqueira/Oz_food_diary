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
  static const errorInvalidEmail = 'Informe um e-mail válido';
  static const errorPasswordTooShort =
      'A senha deve ter no mínimo 8 caracteres';
  static const errorPasswordMismatch = 'As senhas não conferem';
  static const errorEmptyMeal = 'Adicione ao menos um alimento';
  static const errorInvalidBarcode =
      'Digite os números do código de barras (8 a 14 dígitos)';
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
  static const onboardingAgeTitle = 'Quantos anos você tem?';
  static const onboardingAgeSubtitle =
      'Cada faixa etária responde de forma única';
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

  static const ageLabel = 'Idade';
  static String ageValue(int years) => '$years anos';
  static const unitYears = 'anos';

  static const heightLabel = 'Altura';

  static const weightLabel = 'Peso';

  static const sexLabel = 'Sexo';

  static const tabHome = 'Início';
  static const tabGoals = 'Metas';
  static const tabEvolution = 'Evolução';
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
  static const mealPhotoLabel = 'Foto';
  static const mealPhotoHint = 'Opcional. A foto fica salva só neste aparelho.';
  static const mealPhotoAdd = 'Adicionar foto';
  static const mealPhotoChange = 'Trocar foto';
  static const mealPhotoRemove = 'Remover foto';
  static const mealPhotoCamera = 'Tirar foto';
  static const mealPhotoGallery = 'Escolher da galeria';
  static const mealPhotoDenied =
      'O Oz não tem acesso à câmera ou às fotos. Libere o acesso nos ajustes '
      'do aparelho.';
  static const mealPhotoUnavailable =
      'Não foi possível abrir a câmera ou a galeria.';

  static const foodSearchTitle = 'Buscar alimento';
  static const foodSearchHint = 'Ex.: arroz, frango, banana';
  static String foodSearchNoResults(String query) =>
      'Nenhum alimento encontrado para "$query"';
  static const foodSearchError = 'Não foi possível carregar os alimentos';
  static const foodSourceCredit =
      'Fontes: Tabela Brasileira de Composição de Alimentos (TACO), 4ª ed., '
      'NEPA/UNICAMP, 2011; medidas caseiras: IBGE, POF 2008-2009; '
      'produtos industrializados: Open Food Facts (ODbL).';
  static String foodPer100g(String kcal) => '$kcal kcal a cada 100 g';
  static const foodQuantityLabel = 'Quantidade';
  static const foodPortionLabel = 'Medida';
  static const foodAdd = 'Adicionar';
  static const foodUpdate = 'Atualizar';

  static const barcodeScanTooltip = 'Escanear código de barras';
  static const barcodeScannerTitle = 'Código de barras';
  static const barcodeScannerHint =
      'Aponte a câmera para o código de barras da embalagem';
  static const barcodeTypeCode = 'Digitar código';
  static const barcodeTorch = 'Lanterna';
  static const barcodeCameraDenied =
      'O Oz não tem acesso à câmera. Libere o acesso nos ajustes do aparelho '
      'ou digite o código.';
  static const barcodeCameraUnavailable =
      'Não foi possível abrir a câmera. Você pode digitar o código.';
  static const barcodeLabel = 'Código de barras';
  static const barcodeSearch = 'Buscar';
  static const barcodeSearching = 'Buscando produto…';
  static const barcodeErrorOffline =
      'Sem conexão. Conecte-se à internet para buscar produtos novos.';
  static const barcodeErrorFailed =
      'Não foi possível buscar o produto. Tente novamente.';
  static const barcodeNotFoundTitle = 'Produto não encontrado';
  static String barcodeNotFoundMessage(String barcode) =>
      'O código $barcode não está na Open Food Facts. Quer cadastrar o '
      'produto com os dados da embalagem?';
  static const barcodeRegister = 'Cadastrar';

  static const productFormNewTitle = 'Novo produto';
  static const productFormCompleteTitle = 'Completar produto';
  static const productFormNewHint =
      'Preencha com a tabela nutricional da embalagem. Os valores são a cada '
      '100 g (ou 100 ml).';
  static const productFormCompleteHint =
      'A Open Food Facts não tem todas as informações deste produto. Confira '
      'e complete com a tabela nutricional da embalagem, a cada 100 g '
      '(ou 100 ml).';
  static const productFormName = 'Nome';
  static const productFormNameHint = 'Ex.: Iogurte natural integral';
  static const productFormServing = 'Porção da embalagem';
  static const productFormServingHelper = 'Opcional. Ex.: 1 pote = 170 g';

  static String portionGram(num count) => count == 1 ? 'grama' : 'gramas';
  static String portionUnit(num count) => count == 1 ? 'unidade' : 'unidades';
  static String portionSlice(num count) => count == 1 ? 'fatia' : 'fatias';
  static String portionTablespoon(num count) =>
      count == 1 ? 'colher de sopa' : 'colheres de sopa';
  static String portionTeaspoon(num count) =>
      count == 1 ? 'colher de chá' : 'colheres de chá';
  static String portionCup(num count) => count == 1 ? 'xícara' : 'xícaras';
  static String portionLadle(num count) => count == 1 ? 'concha' : 'conchas';
  static String portionServingSpoon(num count) =>
      count == 1 ? 'colher de servir' : 'colheres de servir';
  static String portionServing(num count) => count == 1 ? 'porção' : 'porções';

  static const mealDeleteTitle = 'Excluir refeição?';
  static const mealDeleteMessage = 'Essa ação não pode ser desfeita.';
  static const mealSaved = 'Refeição salva';
  static const mealDeleted = 'Refeição excluída';

  static const goalsTitle = 'Suas Metas';
  static const goalsSaved = 'Metas atualizadas';

  static const profileTitle = 'Perfil';

  static const remindersTitle = 'Lembretes de refeição';
  static const remindersSubtitle = 'Avisos para não esquecer de registrar';
  static const remindersHint =
      'Se você já registrou a refeição no dia, o lembrete daquele dia não '
      'aparece. Os lembretes ficam só neste aparelho.';
  static const remindersPermissionTitle = 'Notificações desativadas';
  static const remindersPermissionMessage =
      'Sem a permissão, os lembretes não aparecem.';
  static const remindersPermissionAllow = 'Permitir';
  static const remindersPermissionDenied =
      'Libere as notificações do Oz nos ajustes do aparelho.';
  static const reminderChannelName = 'Lembretes de refeição';
  static const reminderChannelDescription =
      'Avisos nos horários das refeições para registrar no Oz';
  static String reminderBody(String meal) =>
      'Não esqueça de registrar o ${meal.toLowerCase()} no Oz.';

  static const evolutionTitle = 'Evolução do peso';
  static const weightPeriod30 = '30 dias';
  static const weightPeriod90 = '90 dias';
  static const weightPeriodAll = 'Tudo';
  static const weightCurrent = 'Atual';
  static const weightPeriodStart = 'Início';
  static const weightChangeLabel = 'Variação';
  static const weightHistoryEmptyPeriod = 'Nenhuma medição neste período.';
  static const weightHistoryOnePoint =
      'Registre seu peso em outros dias para ver a evolução aqui.';
  static const weightEntriesTitle = 'Medições';
  static const weightLogButton = 'Registrar peso';
  static const weightLogTitle = 'Registrar peso';
  static const weightLogHint =
      'Uma medição por dia: registrar de novo no mesmo dia substitui a anterior.';
  static const weightLogDate = 'Data';
  static const weightLogSave = 'Registrar';
  static const weightLogged = 'Peso registrado';
  static const profileSaved = 'Perfil atualizado';
  static const profileRecalculateTitle = 'Tem certeza?';
  static const profileRecalculateMessage =
      'Você alterou seu peso, sua altura ou sua idade. Suas metas de calorias e macros serão recalculadas.';
  static const profileGoalsRecalculated =
      'Perfil atualizado e metas recalculadas';
  static const profileLogout = 'Sair';
  static const profileLogoutTitle = 'Sair do app?';
  static const profileLogoutMessage =
      'Você voltará para a tela inicial e os dados salvos neste aparelho serão apagados.';

  static const profileLogoutSyncedMessage =
      'Seus dados ficam salvos na sua conta e voltam quando você entrar de novo.';
  static const profileLogoutSending = 'Enviando seus dados…';
  static const profileLogoutPendingTitle = 'Dados não enviados';
  static String profileLogoutPendingMessage(int count) => count == 1
      ? 'Uma alteração ainda não foi enviada para sua conta. Se sair agora, ela será perdida.'
      : '$count alterações ainda não foram enviadas para sua conta. Se sair agora, elas serão perdidas.';
  static const profileLogoutAnyway = 'Sair mesmo assim';

  static const profileDeleteAccount = 'Excluir conta';
  static const profileDeleteAccountTitle = 'Excluir sua conta?';
  static const profileDeleteAccountMessage =
      'Sua conta e todos os seus dados serão apagados para sempre. Essa ação não pode ser desfeita.';
  static const profileAccountDeleted = 'Conta excluída';

  static const authErrorInvalidCredentials = 'E-mail ou senha incorretos';
  static const authErrorEmailAlreadyRegistered =
      'Já existe uma conta com este e-mail';
  static const authErrorWeakPassword =
      'Senha fraca. Use uma combinação mais forte';
  static const authErrorOffline =
      'Sem conexão. Verifique sua internet e tente novamente';
  static const authErrorProviderUnavailable =
      'Login com Google indisponível nesta versão';
  static const authErrorUnknown = 'Não foi possível concluir. Tente novamente';
  static const defaultUserName = 'Você';
  static const authSessionRevoked = 'Sua sessão expirou. Entre novamente.';

  static const syncStatusSynced = 'Tudo sincronizado';
  static const syncStatusSyncing = 'Sincronizando…';
  static const syncStatusOffline = 'Sem conexão';
  static const syncStatusFailed = 'Não foi possível sincronizar';
  static String syncPending(int count) => count == 1
      ? '1 alteração aguardando envio'
      : '$count alterações aguardando envio';
  static String syncPendingWhenOnline(int count) => count == 1
      ? '1 alteração será enviada quando a internet voltar'
      : '$count alterações serão enviadas quando a internet voltar';
  static const syncSavedOnDevice = 'Seus dados estão salvos neste aparelho';
  static String syncLastSyncedAt(String time) =>
      'Última sincronização às $time';
  static const syncTapToSync = 'Toque para sincronizar agora';
  static const syncTapToRetry = 'Toque para tentar novamente';
  static const syncErrorOffline =
      'Sem conexão. Seus dados continuam salvos neste aparelho.';
  static const syncErrorFailed =
      'Não foi possível sincronizar. Tente novamente.';
  static const syncErrorFirstDownload =
      'Não foi possível baixar seus dados. Verifique sua conexão e tente novamente.';

  static const welcomeTitle = 'Controle sua dieta de forma simples';
  static const welcomeCreateAccount = 'Criar conta';
  static const welcomeGoogle = 'Continuar com Google';

  static const commonComingSoon = 'Em breve';

  static const welcomeHaveAccount = 'Já tem conta?';
  static const welcomeLogin = 'Acessar conta';

  static const loginTitle = 'Entre em sua conta';
  static const loginButton = 'Entrar';
}
